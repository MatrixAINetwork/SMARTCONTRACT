/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;


contract PharmCoin
{
 
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
    //using SafeMath for uint256;
    
    uint public _totalSupply = 2000000000.0;
    
    string public constant symbol = "PHCX";
    string public constant name = "PharmCoin";
    
    //How many decimal places token can be split up into
    uint public constant decimals = 18;

    //1 ether = 200 PharmCoinTokens
    uint256 public RATE = 200; 

    address public owner;

 
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256) ) allowed;

 
    function () public payable{
        createTokens();
   }
    
    function PharmCoin() public
    {
     owner = msg.sender;  
     //uint256 initForPreSale =  mul(_totalSupply, RATE); 
     balances[owner] = _totalSupply;
    }
    
    function createTokens() public payable{
   
      //Workout tokens to recieve based on rate set
      uint256 tokensToSend =  mul(msg.value, RATE); 

      //Subtract amount from contract 
      //balances[owner] = sub(balances[owner], tokensToSend); 
      //Add tokens to buyer
      balances[msg.sender] = add(balances[msg.sender], tokensToSend ); 
      owner.transfer(msg.value);
    }

    function totalSupply() public constant returns (uint256 totalSupply){
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public constant returns (uint256 balance){
        return balances[_owner];
    }
	
    //allow user to transfer pharmcoin tokens
    function transfer(address _to, uint256 _value) public returns (bool success){
    require
    (
        balances[msg.sender] >= _value
        && _value > 0 && _to != address(0)
    );
    balances[msg.sender] = sub(balances[msg.sender] , _value); 
    balances[_to] = add(balances[_to], _value); 
    Transfer(msg.sender, _to, _value);
    return true;
    }
    

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
    require(allowed[_from][msg.sender] >= _value
           && balances[_from] >= _value
           && _value > 0 && _to != address(0) );
    balances[_from] =  sub(balances[_from], _value);
    balances[_to] =  add (balances[_to], (_value) );
    allowed[_from][msg.sender] = sub(allowed[_from][msg.sender] , _value );
    Transfer(_from, _to, _value);
    return true;
    }

    //Check user is allowed to spend amount
    function approve(address _spender, uint256 _value) public returns (bool success){
    allowed[msg.sender][_spender] = _value;
    //Log Approval
    Approval(msg.sender, _spender, _value);
    return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining){
    return allowed[_owner][_spender];
    }

    function setRate(uint256 rate) external returns (bool success)
    {
        require(rate > 0);
        RATE = rate; 
        return true;
    }

    function setSupply(uint256 supply) external returns (bool success)
    {
         //Check value to buy > 0
         require(supply > 0);
        _totalSupply = supply; 
        return true;
    }

  

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}