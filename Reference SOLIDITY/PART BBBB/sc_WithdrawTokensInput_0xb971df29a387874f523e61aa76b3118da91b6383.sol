/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract MintInterface {
  function mint(address recipient, uint amount) returns (bool success);
}

/**
 * Math operations with safety checks
 * Reference: https://github.com/OpenZeppelin/zeppelin-solidity/commit/353285e5d96477b4abb86f7cde9187e84ed251ac
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal constant returns (uint) {
    uint c = a * b;

    assert(a == 0 || c / a == b);

    return c;
  }

  function safeDiv(uint a, uint b) internal constant returns (uint) {    
    uint c = a / b;

    return c;
  }

  function safeSub(uint a, uint b) internal constant returns (uint) {
    require(b <= a);

    return a - b;
  }

  function safeAdd(uint a, uint b) internal constant returns (uint) {
    uint c = a + b;

    assert(c>=a && c>=b);

    return c;
  }
}

/*
 * Mint tokens of a linked token
 * The tokens will be minted following a formula
 * The mining will start when an external address (a multisig) says so
 */
contract WithdrawTokensInput is SafeMath {
  address public tokenContract; // address of the token
  address public receiver; // receiver of the tokens
  uint public numTokensLimit; // Max amount of tokens to be minted
  uint public numTokensIssued; // Number of tokens issued so far

  address public multisig; // external address that will start the minting of the tokens
  bool public open; // If "multisig" has started the minting or not

  uint public startDate; // Timestamp in which "multisig" starts the minting. 0 if !open

  modifier input() {
    require(open);

    _;
  }

  modifier onlyMultisig() {
    require(msg.sender == multisig);

    _;
  }

  modifier onlyReceiver() {
    require(msg.sender == receiver);

    _;
  }

  function WithdrawTokensInput(
    address _tokenContract,
    address _multisig,
    address _receiver,
    uint _numTokens
  ) {
    tokenContract = _tokenContract;
    multisig = _multisig;
    receiver = _receiver;
    numTokensLimit = _numTokens;
  }

  // Creates tokens to "receiver" address following a formula
  // Only executed if "multisig" has started the minting process
  // The maximum amount of tokens is "numTokensLimit"
  // Only executed by "receiver"
  function withdraw() public input onlyReceiver {
    uint tokensToIssue = safeSub(limit(safeDiv(safeSub(now, startDate), 24 hours)), numTokensIssued);

    numTokensIssued += tokensToIssue;

    // mint tokens
    if (!MintInterface(tokenContract).mint(receiver, tokensToIssue))
      revert();
  }

  // Number of tokens available to be minted at day "d"
  function limit(uint d) public constant returns (uint tokensToIssue) {

    if(d > 3650)
      tokensToIssue = numTokensLimit;
    else
      tokensToIssue = (   (  ( (560791145 * d) >> 10 ) - ( d * (d-1) ) * 75  ) >> 1   ) * 10**18;
  }

  // Starts the minting process
  // Only executed by "multisig"
  function submitInput() public onlyMultisig {
    require(!open);

    open = true;
    startDate = now;
  }
}