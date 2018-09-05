/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.17;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
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
* @title Authorizable
* @dev The Authorizable contract has authorized addresses, and provides basic authorization control
* functions, this simplifies the implementation of "multiple user permissions".
*/
contract Authorizable is Ownable {
mapping(address => bool) public authorized;

event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);

/**
* @dev The Authorizable constructor sets the first `authorized` of the contract to the sender
* account.
*/
function Authorizable() public {
  AuthorizationSet(msg.sender, true);
    authorized[msg.sender] = true;
  }

  /**
  * @dev Throws if called by any account other than the authorized.
  */
  modifier onlyAuthorized() {
    require(authorized[msg.sender]);
    _;
  }

  /**
  * @dev Allows the current owner to set an authorization.
  * @param addressAuthorized The address to change authorization.
  */
  function setAuthorized(address addressAuthorized, bool authorization) public onlyOwner {
    require(authorized[addressAuthorized] != authorization);
    AuthorizationSet(addressAuthorized, authorization);
    authorized[addressAuthorized] = authorization;
  }
}

/**
* @title WhiteList
* @dev The WhiteList contract has whiteListed addresses, and provides basic whiteListStatus control
* functions, this simplifies the implementation of "multiple user permissions".
*/
contract WhiteList is Authorizable {
  mapping(address => bool) whiteListed;

  event WhiteListSet(address indexed addressWhiteListed, bool indexed whiteListStatus);

  /**
  * @dev The WhiteList constructor sets the first `whiteListed` of the contract to the sender
  * account.
  */
  function WhiteList() public {
    WhiteListSet(msg.sender, true);
    whiteListed[msg.sender] = true;
  }

  /**
  * @dev Throws if called by any account other than the whiteListed.
  */
  modifier onlyWhiteListed() {
    require(whiteListed[msg.sender]);
    _;
  }

  function isWhiteListed(address _address) public view returns (bool) {
    return whiteListed[_address];
  }

  /**
  * @dev Allows the current owner to set an whiteListStatus.
  * @param addressWhiteListed The address to change whiteListStatus.
  */
  function setWhiteListed(address addressWhiteListed, bool whiteListStatus) public onlyAuthorized {
    require(whiteListed[addressWhiteListed] != whiteListStatus);
    WhiteListSet(addressWhiteListed, whiteListStatus);
    whiteListed[addressWhiteListed] = whiteListStatus;
  }
}

/**
* @title ERC20Basic
* @dev Simpler version of ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/179
*/
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
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
  function balanceOf(address _owner) public view returns (uint256 balance) {
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
  mapping (address => mapping (address => uint256)) internal allowed;

  /**
  * @dev Transfer tokens from one address to another
  * @param _from address The address which you want to send tokens from
  * @param _to address The address which you want to transfer to
  * @param _value uint256 the amount of tokens to be transferred
  */
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

  /**
  * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
  *
  * Beware that changing an allowance with this method brings the risk that someone may use both the old
  * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
  * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
  * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  * @param _spender The address which will spend the funds.
  * @param _value The amount of tokens to be spent.
  */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
  * @dev Function to check the amount of tokens that an owner allowed to a spender.
  * @param _owner address The address which owns the funds.
  * @param _spender address The address which will spend the funds.
  * @return A uint256 specifying the amount of tokens still available for the spender.
  */
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
  * approve should be called when allowed[_spender] == 0. To increment
  * allowed value is better to use this function to avoid 2 calls (and wait until
  * the first transaction is mined)
  * From MonolithDAO Token.sol
  */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract TreasureBox {
  // ERC20 basic token contract being held
  StandardToken token;
  // beneficiary of tokens after they are released
  address public beneficiary;
  // timestamp where token release is enabled
  uint public releaseTime;

  function TreasureBox(StandardToken _token, address _beneficiary, uint _releaseTime) public {
    require(_beneficiary != address(0));
    token = StandardToken(_token);
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  function claim() external {
    require(available());
    require(amount() > 0);
    token.transfer(beneficiary, amount());
  }

  function available() public view returns (bool) {
    return (now >= releaseTime);
  }

  function amount() public view returns (uint256) {
    return token.balanceOf(this);
  }
}

contract AirDropper is Authorizable {
  mapping(address => bool) public isAnExchanger; // allow to airdrop to destination is exchanger with out minimum
  mapping(address => bool) public isTreasureBox; // flag who not eligible airdrop
  mapping(address => address) public airDropDestinations; // setTo 0x0 if want airdrop to self

  StandardToken token;

  event SetDestination(address _address, address _destination);
  event SetExchanger(address _address, bool _isExchanger);

  function AirDropper(StandardToken _token) public {
    token = _token;
  }

  function getToken() public view returns(StandardToken) {
    return token;
  }

  /**
  * set _destination to 0x0 if want to self airdrop
  */
  function setAirDropDestination(address _destination) external {
    require(_destination != msg.sender);
    airDropDestinations[msg.sender] = _destination;
    SetDestination(msg.sender, _destination);
  }

  function setTreasureBox (address _address, bool _status) public onlyAuthorized {
    require(_address != address(0));
    require(isTreasureBox[_address] != _status);
    isTreasureBox[_address] = _status;
  }

  function setExchanger(address _address, bool _isExchanger) external onlyAuthorized {
    require(_address != address(0));
    require(isAnExchanger[_address] != _isExchanger);
    isAnExchanger[_address] = _isExchanger;
    SetExchanger(_address, _isExchanger);
  }

  /**
  * help fix airdrop when holder > 100
  * but need to calculate outer
  */
  function multiTransfer(address[] _address, uint[] _value) public returns (bool) {
    for (uint i = 0; i < _address.length; i++) {
      token.transferFrom(msg.sender, _address[i], _value[i]);
    }
    return true;
  }
}

/**
* @title TemToken
* @dev The main ZMINE token contract
*
* ABI
* [{"constant":true,"inputs":[],"name":"mintingFinished","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"startTrading","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_amount","type":"uint256"}],"name":"mint","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"tradingStarted","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"finishMinting","outputs":[{"name":"","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Mint","type":"event"},{"anonymous":false,"inputs":[],"name":"MintFinished","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]
*/
contract ZMINE is StandardToken, Ownable {
  string public name = "ZMINE Token";
  string public symbol = "ZMN";
  uint8 public decimals = 18;

  uint256 public totalSupply = 1000000000000000000000000000; // 1,000,000,000 ^ 18

  function ZMINE() public {
    balances[owner] = totalSupply;
    Transfer(address(0x0), owner, totalSupply);
  }

  /**
  * burn token if token is not sold out after Public
  */
  function burn(uint _amount) external onlyOwner {
    require(balances[owner] >= _amount);
    balances[owner] = balances[owner] - _amount;
    totalSupply = totalSupply - _amount;
    Transfer(owner, address(0x0), _amount);
  }
}

contract RateContract is Authorizable {
  uint public rate = 6000000000000000000000;

  event UpdateRate(uint _oldRate, uint _newRate);

  function updateRate(uint _rate) public onlyAuthorized {
    require(rate != _rate);
    UpdateRate(rate, _rate);
    rate = _rate;
  }

  function getRate() public view returns (uint) {
    return rate;
  }
}

contract FounderThreader is Ownable {
  using SafeMath for uint;

  event TokenTransferForFounder(address _recipient, uint _value, address box1, address box2);

  AirDropper public airdropper;

  uint public hardCap = 300000000000000000000000000; // 300 000 000 * 1e18
  uint public remain = 300000000000000000000000000; // 300 000 000 * 1e18

  uint public minTx = 100000000000000000000; // 100 * 1e18

  mapping(address => bool) isFounder;

  function FounderThreader (AirDropper _airdropper, address[] _founders) public {
    airdropper = AirDropper(_airdropper);
    for (uint i = 0; i < _founders.length; i++) {
      isFounder[_founders[i]] = true;
    }
  }

  function transferFor(address _recipient, uint _tokens) external onlyOwner {
    require(_recipient != address(0));
    require(_tokens >= minTx);
    require(isFounder[_recipient]);

    StandardToken token = StandardToken(airdropper.getToken());

    TreasureBox box1 = new TreasureBox(token, _recipient, 1533088800); // can open 2018-08-01 09+07:00
    TreasureBox box2 = new TreasureBox(token, _recipient, 1548986400); // can open 2019-02-01 09+07:00

    airdropper.setTreasureBox(box1, true);
    airdropper.setTreasureBox(box2, true);

    token.transferFrom(owner, _recipient, _tokens.mul(33).div(100)); // 33 % for now
    token.transferFrom(owner, box1, _tokens.mul(33).div(100)); // 33 % for box1
    token.transferFrom(owner, box2, _tokens.mul(34).div(100)); // 34 % for box2

    remain = remain.sub(_tokens);

    TokenTransferForFounder(_recipient, _tokens, box1, box2);
  }
}

contract PreSale is Ownable {
  using SafeMath for uint;

  event TokenSold(address _recipient, uint _value, uint _tokens, uint _rate);
  event TokenSold(address _recipient, uint _tokens);

  ZMINE public token;
  WhiteList whitelist;

  uint public hardCap = 300000000000000000000000000; // 300 000 000 * 1e18
  uint public remain = 300000000000000000000000000; // 300 000 000 * 1e18

  uint public startDate = 1512525600; // 2017-12-06 09+07:00
  uint public stopDate = 1517364000;  // 2018-01-31 09+07:00

  uint public minTx = 100000000000000000000; // 100 * 1e18
  uint public maxTx = 100000000000000000000000; // 100 000 * 1e18

  RateContract rateContract;

  function PreSale (ZMINE _token, RateContract _rateContract, WhiteList _whitelist) public {
    token = ZMINE(_token);
    rateContract = RateContract(_rateContract);
    whitelist = WhiteList(_whitelist);
  }

  /**
  * transfer token to presale investor who pay by cash
  */
  function transferFor(address _recipient, uint _tokens) external onlyOwner {
    require(_recipient != address(0));
    require(available());

    remain = remain.sub(_tokens);
    token.transferFrom(owner, _recipient, _tokens);

    TokenSold(_recipient, _tokens);
  }

  function sale(address _recipient, uint _value, uint _rate) private {
    require(_recipient != address(0));
    require(available());
    require(isWhiteListed(_recipient));
    require(_value >= minTx && _value <= maxTx);
    uint tokens = _rate.mul(_value).div(1000000000000000000);

    remain = remain.sub(tokens);
    token.transferFrom(owner, _recipient, tokens);
    owner.transfer(_value);

    TokenSold(_recipient, _value, tokens, _rate);
  }

  function rate() public view returns (uint) {
    return rateContract.getRate();
  }

  function available() public view returns (bool) {
    return (now > startDate && now < stopDate);
  }

  function isWhiteListed(address _address) public view returns (bool) {
    return whitelist.isWhiteListed(_address);
  }

  function() external payable {
    sale(msg.sender, msg.value, rate());
  }
}

contract PublicSale is Ownable {
  using SafeMath for uint;

  event TokenSold(address _recipient, uint _value, uint _tokens, uint _rate);
  event IncreaseHardCap(uint _amount);

  ZMINE public token;

  WhiteList whitelistPublic;
  WhiteList whitelistPRE;

  uint public hardCap = 400000000000000000000000000; // 400 000 000 * 1e18
  uint public remain = 400000000000000000000000000; // 400 000 000 * 1e18

  uint public startDate = 1515376800; // 2018-01-08 09+07:00
  uint public stopDate = 1517364000;  // 2018-01-31 09+07:00

  uint public minTx = 1000000000000000000; // 1e18
  uint public maxTx = 100000000000000000000000; // 100 000 1e18

  RateContract rateContract;

  function PublicSale(ZMINE _token, RateContract _rateContract, WhiteList _whitelistPRE, WhiteList _whitelistPublic) public {
    token = ZMINE(_token);
    rateContract = RateContract(_rateContract);
    whitelistPRE = WhiteList(_whitelistPRE);
    whitelistPublic = WhiteList(_whitelistPublic);
  }

  /**
  * increase hard cap if previous dont sold out
  */
  function increaseHardCap(uint _amount) external onlyOwner {
    require(_amount <= 300000000000000000000000000); // presale hard cap
    hardCap = hardCap.add(_amount);
    remain = remain.add(_amount);
    IncreaseHardCap(_amount);
  }

  function sale(address _recipient, uint _value, uint _rate) private {
    require(available());
    require(isWhiteListed(_recipient));
    require(_value >= minTx && _value <= maxTx);
    uint tokens = _rate.mul(_value).div(1000000000000000000);

    remain = remain.sub(tokens);
    token.transferFrom(owner, _recipient, tokens);
    owner.transfer(_value);

    TokenSold(_recipient, _value, tokens, _rate);
  }

  function rate() public view returns (uint) {
    return rateContract.getRate();
  }

  function available () public view returns (bool) {
    return (now > startDate && now < stopDate);
  }

  function isWhiteListed (address _address) public view returns(bool) {
    return (whitelistPRE.isWhiteListed(_address) || (whitelistPublic.isWhiteListed(_address)));
  }

  function() external payable {
    sale(msg.sender, msg.value, rate());
  }
}