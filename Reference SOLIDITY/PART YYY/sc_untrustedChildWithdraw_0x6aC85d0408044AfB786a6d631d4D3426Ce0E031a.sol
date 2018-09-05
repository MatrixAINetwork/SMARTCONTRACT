/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract DAO {
    function balanceOf(address addr) returns (uint);
    function transferFrom(address from, address to, uint balance) returns (bool);
    function getNewDAOAddress(uint _proposalID) constant returns(address _newDAO);
    uint public totalSupply;
}

/**
 * @title untrustedChildWithdraw
 * @author Paul Szczesny, Alexey Akhunov
 * A withdraw contract for untrusted childDAOs affected by the hard fork.
 * Based on the official WithdrawDAO contract found here: https://etherscan.io/address/0xbf4ed7b27f1d666546e30d74d50d173d20bca754#code
 */
contract untrustedChildWithdraw {

  struct childDAO {
	  DAO dao;
    uint numerator;
	}

  DAO constant public mainDAO = DAO(0xbb9bc244d798123fde783fcc1c72d3bb8c189413);
  uint[] public untrustedProposals = [35, 36, 53, 62, 67, 68, 70, 71, 73, 76, 87];
  uint public ratioDenominator = 1000000000;
  uint[] public untrustedTokenNumerator = [1458321331, 1458321331, 1399760834, 1457994374, 1457994374, 1146978827, 1457994374, 1458321336, 1458307000, 1458328768, 1458376290];
  mapping (uint => childDAO) public whiteList;

  /**
  * Populates the whiteList based on the list of trusted proposal Ids.
  */
  function untrustedChildWithdraw() {
      for(uint i=0; i<untrustedProposals.length; i++) {
          uint proposalId = untrustedProposals[i];
          whiteList[proposalId] = childDAO(DAO(mainDAO.getNewDAOAddress(proposalId)), untrustedTokenNumerator[i]);
      }
  }

  /**
  * Convienience function for the Curator to calculate the required amount of Wei
  * that needs to be transferred to this contract.
  */
  function requiredEndowment() constant returns (uint endowment) {
      uint sum = 0;
      for(uint i=0; i<untrustedProposals.length; i++) {
          uint proposalId = untrustedProposals[i];
          DAO child = whiteList[proposalId].dao;
          sum += (child.totalSupply() * (untrustedTokenNumerator[i] / ratioDenominator) );
      }
      return sum;
  }

  /**
   * Function call to withdraw ETH by burning childDao tokens.
   * @param proposalId The split proposal ID which created the childDao
   * @dev This requires that the token-holder authorizes this contract's address using the approve() function.
   */
  function withdraw(uint proposalId) {
    //Check the token balance
    uint balance = whiteList[proposalId].dao.balanceOf(msg.sender);
    uint adjustedBalance = balance * (whiteList[proposalId].numerator / ratioDenominator);

    // Transfer childDao tokens first, then send Ether back in return
    if (!whiteList[proposalId].dao.transferFrom(msg.sender, this, balance) || !msg.sender.send(adjustedBalance))
      throw;
  }

}