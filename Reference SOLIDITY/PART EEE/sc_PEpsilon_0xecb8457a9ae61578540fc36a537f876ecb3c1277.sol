/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;


/** @title PEpsilon
 *  @author Daniel Babbev
 *
 *  This contract implements a p + epsilon attack against the Kleros court.
 *  The attack is described by VitaliK Buterin here: https://blog.ethereum.org/2015/01/28/p-epsilon-attack/
 */
contract PEpsilon {
  Pinakion public pinakion;
  Kleros public court;

  uint public balance;
  uint public disputeID;
  uint public desiredOutcome;
  uint public epsilon;
  bool public settled;
  uint public maxAppeals; // The maximum number of appeals this cotracts promises to pay
  mapping (address => uint) public withdraw; // We'll use a withdraw pattern here to avoid multiple sends when a juror has voted multiple times.

  address public attacker;
  uint public remainingWithdraw; // Here we keep the total amount bribed jurors have available for withdraw.

  modifier onlyBy(address _account) {require(msg.sender == _account); _;}

  event AmountShift(uint val, uint epsilon ,address juror);
  event Log(uint val, address addr, string message);

  /** @dev Constructor.
   *  @param _pinakion The PNK contract.
   *  @param _kleros   The Kleros court.
   *  @param _disputeID The dispute we are targeting.
   *  @param _desiredOutcome The desired ruling of the dispute.
   *  @param _epsilon  Jurors will be paid epsilon more for voting for the desiredOutcome.
   *  @param _maxAppeals The maximum number of appeals this contract promises to pay out
   */
  constructor(Pinakion _pinakion, Kleros _kleros, uint _disputeID, uint _desiredOutcome, uint _epsilon, uint _maxAppeals) public {
    pinakion = _pinakion;
    court = _kleros;
    disputeID = _disputeID;
    desiredOutcome = _desiredOutcome;
    epsilon = _epsilon;
    attacker = msg.sender;
    maxAppeals = _maxAppeals;
  }

  /** @dev Callback of approveAndCall - transfer pinakions in the contract. Should be called by the pinakion contract. TRUSTED.
   *  The attacker has to deposit sufficiently large amount of PNK to cover the payouts to the jurors.
   *  @param _from The address making the transfer.
   *  @param _amount Amount of tokens to transfer to this contract (in basic units).
   */
  function receiveApproval(address _from, uint _amount, address, bytes) public onlyBy(pinakion) {
    require(pinakion.transferFrom(_from, this, _amount));

    balance += _amount;
  }

  /** @dev Jurors can withdraw their PNK from here
   */
  function withdrawJuror() {
    withdrawSelect(msg.sender);
  }

  /** @dev Withdraw the funds of a given juror
   *  @param _juror The address of the juror
   */
  function withdrawSelect(address _juror) {
    uint amount = withdraw[_juror];
    withdraw[_juror] = 0;

    balance = sub(balance, amount); // Could underflow
    remainingWithdraw = sub(remainingWithdraw, amount);

    // The juror receives d + p + e (deposit + p + epsilon)
    require(pinakion.transfer(_juror, amount));
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /** @dev The attacker can withdraw their PNK from here after the bribe has been settled.
   */
  function withdrawAttacker(){
    require(settled);

    if (balance > remainingWithdraw) {
      // The remaning balance of PNK after settlement is transfered to the attacker.
      uint amount = balance - remainingWithdraw;
      balance = remainingWithdraw;

      require(pinakion.transfer(attacker, amount));
    }
  }

  /** @dev Settles the p + e bribe with the jurors.
   * If the dispute is ruled differently from desiredOutcome:
   *    The jurors who voted for desiredOutcome receive p + d + e in rewards from this contract.
   * If the dispute is ruled as in desiredOutcome:
   *    The jurors don't receive anything from this contract.
   */
  function settle() public {
    require(court.disputeStatus(disputeID) ==  Arbitrator.DisputeStatus.Solved); // The case must be solved.
    require(!settled); // This function can be executed only once.

    settled = true; // settle the bribe

    // From the dispute we get the # of appeals and the available choices
    var (, , appeals, choices, , , ,) = court.disputes(disputeID);

    if (court.currentRuling(disputeID) != desiredOutcome){
      // Calculate the redistribution amounts.
      uint amountShift = court.getStakePerDraw();
      uint winningChoice = court.getWinningChoice(disputeID, appeals);

      // Rewards are calculated as per the one shot token reparation.
      for (uint i=0; i <= (appeals > maxAppeals ? maxAppeals : appeals); i++){ // Loop each appeal and each vote.

        // Note that we don't check if the result was a tie becuse we are getting a funny compiler error: "stack is too deep" if we check.
        // TODO: Account for ties
        if (winningChoice != 0){
          // votesLen is the length of the votes per each appeal. There is no getter function for that, so we have to calculate it here.
          // We must end up with the exact same value as if we would have called dispute.votes[i].length
          uint votesLen = 0;
          for (uint c = 0; c <= choices; c++) { // Iterate for each choice of the dispute.
            votesLen += court.getVoteCount(disputeID, i, c);
          }

          emit Log(amountShift, 0x0 ,"stakePerDraw");
          emit Log(votesLen, 0x0, "votesLen");

          uint totalToRedistribute = 0;
          uint nbCoherent = 0;

          // Now we will use votesLen as a substitute for dispute.votes[i].length
          for (uint j=0; j < votesLen; j++){
            uint voteRuling = court.getVoteRuling(disputeID, i, j);
            address voteAccount = court.getVoteAccount(disputeID, i, j);

            emit Log(voteRuling, voteAccount, "voted");

            if (voteRuling != winningChoice){
              totalToRedistribute += amountShift;

              if (voteRuling == desiredOutcome){ // If the juror voted as we desired.
                // Transfer this juror back the penalty.
                withdraw[voteAccount] += amountShift + epsilon;
                remainingWithdraw += amountShift + epsilon;
                emit AmountShift(amountShift, epsilon, voteAccount);
              }
            } else {
              nbCoherent++;
            }
          }
          // toRedistribute is the amount each juror received when he voted coherently.
          uint toRedistribute = (totalToRedistribute - amountShift) / (nbCoherent + 1);

          // We use votesLen again as a substitute for dispute.votes[i].length
          for (j = 0; j < votesLen; j++){
            voteRuling = court.getVoteRuling(disputeID, i, j);
            voteAccount = court.getVoteAccount(disputeID, i, j);

            if (voteRuling == desiredOutcome){
              // Add the coherent juror reward to the total payout.
              withdraw[voteAccount] += toRedistribute;
              remainingWithdraw += toRedistribute;
              emit AmountShift(toRedistribute, 0, voteAccount);
            }
          }
        }
      }
    }
  }
}

/**
 *  @title Kleros
 *  @author Clément Lesaege - <