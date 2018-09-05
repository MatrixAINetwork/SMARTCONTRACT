/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.18;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) view public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) view public returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  
  bool public freezeTransferToken = false;

  modifier onlyPayloadSize(uint size) {
       assert(msg.data.length >= size + 4);
       _;
   }
   
   modifier canTransfer() {
        require(!freezeTransferToken);
        _;
   }



  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value)canTransfer onlyPayloadSize(2 * 32) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) view public returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value)canTransfer public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
    return allowed[_owner][_spender];
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
  function Ownable() public{
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
  function transferOwnership(address newOwner) onlyOwner public{
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {
 
  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint _value) public {
    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }
 
  event Burn(address indexed burner, uint indexed value);
 
}

contract Switch is BurnableToken, Ownable {
    using SafeMath for uint;
    
    address public walletFromTeam;
    
    address public walletForBounty;
    
    address public walletForCommunity;
	
	address public walletForPresale;
    
    uint public percentForBounty;
    
    uint public percentForTeam;
    
    uint public percentForCommunity;
    
    string public constant name = "Switch";
    
    string public constant symbol = "SWI";
    
    uint32 public constant decimals = 18;
    
    uint256 public INITIAL_TOKEN_FROM_COMPAIN = 1200000000*1 ether;
    uint public tokenForTeam;
    uint public tokenForBounty;
    uint public tokenForComunity;
    
    
    function Switch()public{
        walletFromTeam = 0xe49ab1399d63DD2A9eb4805d62EC40B0aBB6f6Ab;
        walletForBounty = 0xf60302a485E34873238098FF33E840B7DaD83854;
        walletForCommunity = 0xFf5A48d893E1EaF9Ea128aA3d4b5AfE2b6282Cb1;
		walletForPresale = 0xEAD962f2788e4Cef655b88A8E5a56fdAa8993895;
        
        percentForTeam = 35;
        percentForBounty = 5;
        percentForCommunity =5;
        
        totalSupply = INITIAL_TOKEN_FROM_COMPAIN; 
        
        tokenForTeam = INITIAL_TOKEN_FROM_COMPAIN.mul(percentForTeam).div(100);
        balances[walletFromTeam] = tokenForTeam;
        transferFrom(this,walletFromTeam, 0);
        
        tokenForComunity = INITIAL_TOKEN_FROM_COMPAIN.mul(percentForCommunity).div(100);
        balances[walletForCommunity] = tokenForComunity;
        transferFrom(this,walletForCommunity, 0);
        
        tokenForBounty = INITIAL_TOKEN_FROM_COMPAIN.mul(percentForBounty).div(100);
        balances[walletForBounty] = tokenForBounty;
        transferFrom(this,walletForBounty, 0);
        
        uint tokenForAirdrop;
        tokenForAirdrop = INITIAL_TOKEN_FROM_COMPAIN.mul(55).div(100);
        balances[walletForPresale] = tokenForAirdrop;
        transferFrom(this,walletForPresale, 0);
    }
    
    function freezeTransfer()onlyOwner public{
        freezeTransferToken = true;
    }
    
    function unFreezeTransfer()onlyOwner public{
        freezeTransferToken = false;
    }    
}