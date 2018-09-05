/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/**
 *  Relay.sol v1.0.0
 * 
 *  Bilal Arif - https://twitter.com/furusiyya_
 *  Notary Platform
 */

pragma solidity ^0.4.16;

// Used for accepting small contributions without whitelist

contract Ownable {
     /*
      @title Ownable
      @dev The Ownable contract has an owner address, and provides basic authorization control
      functions, this simplifies the implementation of "user permissions".
    */

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable(address _owner){
    owner = _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}
contract Pausable is Ownable {
  
  event Pause(bool indexed state);

  bool private paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev return the current state of contract
   */
  function Paused() external constant returns(bool){ return paused; }

  /**
   * @dev called by the owner to pause or unpause, triggers stopped state
   * on first call and returns to normal state on second call
   */
  function tweakState() external onlyOwner {
    paused = !paused;
    Pause(paused);
  }

}

contract Relay is Pausable{
  
    address private crowdfunding;
    
    function Relay() 
        Ownable(0x0587e235a5906ed8143d026de530d77ad82f8a92){
        crowdfunding = 0x34a3DeB32b4705018F1e543A5867cF01AFf3F15B;
    }
    
    function () payable isMinimum whenNotPaused{
        crowdfunding.transfer(msg.value);
    }
    
    /** Modifier allowing execution only if received value is greater than zero */
    modifier isMinimum(){
        require(msg.value <= 2 ether);
        _;
    }
}