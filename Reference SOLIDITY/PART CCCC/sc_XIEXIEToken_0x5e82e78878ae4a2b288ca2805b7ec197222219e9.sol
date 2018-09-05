/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
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
  function approve(address _spender, uint256 _value) returns (bool) {

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
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

contract XIEXIEToken is StandardToken {
  string public name = "PleaseChinaResumeICOWeLoveYouXieXie";
  uint8 public decimals = 18;
  string public symbol = "XIEXIE";
  string public version = "0.1";
  address public wallet = 0xCDAe88d491030257265CD42226cF56b085aC58cf;
  address public tokensBank = 0x075768D0fB81282e1a62B1f05BAf5279Dc7B5dbe;
  uint256 public circulatingTokens = 0;
  uint256 constant public STARTBLOCKTM = 1506538800; // 2017-09-27 19:00:00 UTC

  function XIEXIEToken() {
    totalSupply = 4200000000000000000000000;
    balances[tokensBank] = totalSupply;
  }

  function dynasty() returns (uint256) {
    if (circulatingTokens <= 37799999999999997902848) return 1644;
    if (circulatingTokens <= 462000000000000054525952) return 1368;
    return 1271;
  }

  function () payable {                                     //  _                             
    require(msg.sender != 0x0);                             //  \`*-.                                                  
    require(msg.value != 0);                                //   )  _`-.                                            
    require(msg.sender != tokensBank);                      //  .  : `. .                                                     
    require(msg.sender != wallet);                          //  : _   '  \                                                
    require(msg.value >= 10000000000000000); //0.01 eth     //  ; *` _.   `*-._                                                                
    require(block.timestamp >= STARTBLOCKTM);               //  `-.-'          `-.                                                   
    uint256 tokens = msg.value.mul(dynasty());              //    ;       `       `.                                                  
    wallet.transfer(msg.value);                             //    :.       .        \                                  
    require(circulatingTokens.add(tokens) <= totalSupply);  //    . \  .   :   .-'   .                                                            
    circulatingTokens = circulatingTokens.add(tokens);      //    '  `+.;  ;  '      :                                                        
    require(allowed[tokensBank][msg.sender] == 0);          //    :  '  |    ;       ;-.                                                  
    allowed[tokensBank][msg.sender] = tokens;               //    ; '   : :`-:     _.`* ;                                            
    transferFrom(tokensBank, msg.sender, tokens);           // .*' /  .*' ; .*`- +'  `*'                                                 
  }                                                         // `*-*   `*-*  `*-*'      
}