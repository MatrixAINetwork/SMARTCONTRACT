/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

// @dev Contract to hold sale raised funds during the sale period.
// Prevents attack in which the Aragon Multisig sends raised ether
// to the sale contract to mint tokens to itself, and getting the
// funds back immediately.

contract AbstractSale {
  function saleFinalized() constant returns (bool);
}

contract SaleWallet {
  // Public variables
  address public multisig;
  uint public finalBlock;
  AbstractSale public tokenSale;

  // @dev Constructor initializes public variables
  // @param _multisig The address of the multisig that will receive the funds
  // @param _finalBlock Block after which the multisig can request the funds
  function SaleWallet(address _multisig, uint _finalBlock, address _tokenSale) {
    multisig = _multisig;
    finalBlock = _finalBlock;
    tokenSale = AbstractSale(_tokenSale);
  }

  // @dev Receive all sent funds without any further logic
  function () public payable {}

  // @dev Withdraw function sends all the funds to the wallet if conditions are correct
  function withdraw() public {
    if (msg.sender != multisig) throw;                       // Only the multisig can request it
    if (block.number > finalBlock) return doWithdraw();      // Allow after the final block
    if (tokenSale.saleFinalized()) return doWithdraw();      // Allow when sale is finalized
  }

  function doWithdraw() internal {
    if (!multisig.send(this.balance)) throw;
  }
}