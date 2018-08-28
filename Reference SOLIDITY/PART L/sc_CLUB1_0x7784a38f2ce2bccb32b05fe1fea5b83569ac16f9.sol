/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

  address public owner;

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
    owner = newOwner;
  }
}

/**
 * @title Token
 * @dev API interface for interacting with the Token contract 
 */
interface Token {
  function transferFrom(address _from, address _to) public returns (bool);
  
  function balanceOf(address _owner) public constant returns (uint256 balance);
}

contract CLUB1 is Ownable {

  using SafeMath for uint256;
  Token token;

  address public CurrentTokenOwner = address(this);
  address tokenAddress = 0x0356e14C2f8De339131C668c1747dEF594467a9A;  // Address of the TOKEN CONTRACT
  uint256 public CurrentPrice = 0;

  mapping (address => bool) prevowners;
  
  event BoughtToken(address indexed to, uint256 LastPrice);

  
  function CLUB1() public payable {
       
      token = Token(tokenAddress); 
            
  }
  
  function checkprevowner(address _owner) public constant returns (bool isOwned) {

    return prevowners[_owner];

  }
  
  
  function () public payable {
   
    buyToken();
   
  }

  /**
  * @dev function that sells available tokens
  */
  function buyToken() public payable {
    
    uint256 lastholdershare = CurrentPrice * 90 / 100;
    uint256 ownershare = msg.value * 10 / 100; 

    require(msg.value > CurrentPrice);    

    BoughtToken(msg.sender, msg.value);

    token.transferFrom(CurrentTokenOwner, msg.sender);      
  
    CurrentPrice = msg.value;
      
    if (lastholdershare > 0) CurrentTokenOwner.transfer(lastholdershare);
    owner.transfer(ownershare);                            
    
    CurrentTokenOwner = msg.sender;                        
    prevowners[msg.sender] = true;
  }

   function resetToken() public payable {
    
    require(msg.sender == tokenAddress);
    uint256 lastholdershare = CurrentPrice * 90 / 100;
        
    BoughtToken(msg.sender, 0);

    CurrentPrice = 0;
    
    CurrentTokenOwner.transfer(lastholdershare);
    CurrentTokenOwner = address(this);
    
  }

   /**
   * @notice Terminate contract and refund to owner
   */
  function destroy() public onlyOwner {
   selfdestruct(owner);
  }

}