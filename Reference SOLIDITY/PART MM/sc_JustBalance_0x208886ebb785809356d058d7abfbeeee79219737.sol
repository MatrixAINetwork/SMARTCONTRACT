/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * Fragment of EtherDelta smart contract with balanceOf stub
 */
contract EtherDelta {
  function balanceOf(address token, address user) public constant returns (uint256);
}


/**
 * Simple token stub for returning balanceOf owner
 */
contract Token {
  function balanceOf(address user) public constant returns (uint256);
}


contract JustBalance is Ownable {
  EtherDelta public etherdelta;

  function JustBalance(address _etherdelta) {
    etherdelta = EtherDelta(_etherdelta);
  }

  /**
   * in case etherdelta decides to deploy new smartcontract
   */
  function newEtherdelta(address _etherdelta) public onlyOwner returns (bool) {
    etherdelta = EtherDelta(_etherdelta);
    return true;
  }

  function balanceOf(address token, address user) constant returns (uint256, uint256) {
    uint256 walletBalance = Token(token).balanceOf(user);
    uint256 edBalance = etherdelta.balanceOf(token, user);
    return (walletBalance, edBalance);
  }
}