/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

contract Ownable {
  address public owner = 0x26C7ac9e83dE03a3035A9558AE9e289FAE825cE8;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}




contract BitLoanex is Ownable {

  using SafeMath for uint256;
  
  string public constant name = "BitLoanex";
  string public constant symbol = "BTLX";
  uint8 public constant decimals = 8;
  
  using SafeMath for uint256;

  //uint256 public constant RATE = 714;
  uint256 public constant CAP = 126000;
  uint256 public constant START = 1514160000;
  uint256 public constant DAYS = 30;
  uint256 public days_interval = 4;
  uint[9] public deadlines = [START, START  ];
  uint[9] public rates = [2000 ,1900, 1800, 1700, 1600, 1500, 1400, 1300, 1200];
  bool public initialized = false;
  uint256 public raisedAmount = 0;
  uint256 public constant INITIAL_SUPPLY = 10000000000000000;
  uint256 public totalSupply;

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event BoughtTokens(address indexed to, uint256 value);
  
  function BitLoanex() public {
    totalSupply = 9000000000000000;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }


  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }


  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  modifier whenSaleActive() {
  assert(isActive());
  _;
  }



  function initialize(uint256 numTokens) onlyOwner {

    require(initialized == false);
    require(tokenAvailable() == numTokens);
    initialized = true;

  }


  function isActive() constant returns (bool) {
    return(
      initialized == true &&
      now >= START &&
      now <= START.add(DAYS * 1 days) &&
      goalReached() == false
    );
  }

  function goalReached() constant returns (bool) {
    return (raisedAmount >= CAP * 1 ether);
  }

  function () payable {

    buyTokens();

  }

  function buyTokens() payable whenSaleActive {
    uint weiAmount = msg.value;
    uint tokens = weiAmount.mul(getRate());
    
    tokens = tokens.div(1 ether);
    
    BoughtTokens(msg.sender, tokens);

    balances[msg.sender] = balances[msg.sender].add(tokens);
    balances[owner] = balances[owner].sub(tokens);
    totalSupply.sub(tokens);

    raisedAmount = raisedAmount.add(msg.value);

    //owner.transfer(msg.value);
  }

  function tokenAvailable() constant returns (uint256){
     return totalSupply;
  }

  function destroy() onlyOwner {
    //uint256 balance = token.balanceOf(this);
    //assert(balance > 0);
    //token.transfer(owner, balance);

    selfdestruct(owner);
  }

  function getRate() constant returns (uint256 rate){
      for(var i = 0; i < deadlines.length; i++)
          if(now<deadlines[i])
              return rates[i];
      return rates[rates.length-1];//should never be returned, but to be sure to not divide by 0
  }


}