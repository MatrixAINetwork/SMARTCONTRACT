/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
}

/**
 * @title Spend Token
 */
contract SpendToken is StandardToken {
  string public constant name = "Spend Token";
  string public constant symbol = "SPEND";
  uint8 public constant decimals = 18;

  address public presale;
  address public team;

  uint public constant TOKEN_LIMIT = 50000000;

  /**
   * @dev Create our actual token
   */
  function SpendToken(address _presale, address _team) public {
    require(_presale != address(0));
    require(_team != address(0));

    presale = _presale;
    team = _team;
  }

  /**
   * @dev Mint new tokens to the specified address, only callable by the
   * presale contract itself
   */
  function mint(address _holder, uint _value) external {
    require(msg.sender == presale);
    require(_value > 0);
    require(totalSupply + _value <= TOKEN_LIMIT);

    balances[_holder] += _value;
    totalSupply += _value;

    Transfer(0x0, _holder, _value);
  }
}

/**
 * @title MoxyOne Presale
 */
contract MoxyOnePresale {
  enum PreSaleState {
    PreSaleStarted,
    PreSaleFinished
  }

  SpendToken public token;
  PreSaleState public preSaleState = PreSaleState.PreSaleStarted;
  address public team;
  bool public isPaused = false;
  uint256 public pricePerToken = 1 ether / 1000;

  event PreSaleStarted();
  event PreSaleFinished();
  event PreSalePaused();
  event PreSaleResumed();
  event TokenBuy(address indexed buyer, uint256 tokens);

  /**
   * @dev Only allow the team to execute these commands
   */
  modifier teamOnly {
    require(msg.sender == team);

    _;
  }

  /**
   * @dev Create the presale contract and the token contract alongside
   */
  function MoxyOnePresale() public {
    team = msg.sender;
    token = new SpendToken(this, team);
  }

  /**
   * @dev Pause the presale in the event of an emergency
   */
  function pausePreSale() external teamOnly {
    require(!isPaused);
    require(preSaleState == PreSaleState.PreSaleStarted);

    isPaused = true;

    PreSalePaused();
  }

  /**
   * @dev Resume the presale if necessary
   */
  function resumePreSale() external teamOnly {
    require(isPaused);
    require(preSaleState == PreSaleState.PreSaleStarted);

    isPaused = false;

    PreSaleResumed();
  }

  /**
   * @dev End the presale event, preventing any further token purchases
   */
  function finishPreSale() external teamOnly {
    require(preSaleState == PreSaleState.PreSaleStarted);

    preSaleState = PreSaleState.PreSaleFinished;

    PreSaleFinished();
  }

  /**
   * @dev Withdraw the funds from this contract to the specified address
   */
  function withdrawFunds(address _target, uint256 _amount) external teamOnly {
    _target.transfer(_amount);
  }

  /**
   * @dev Buy tokens, called internally from the catcher
   */
  function buyTokens(address _buyer, uint256 _value) internal returns (uint) {
    require(_buyer != address(0));
    require(_value > 0);
    require(preSaleState == PreSaleState.PreSaleStarted);
    require(!isPaused);

    uint256 boughtTokens = _value / pricePerToken;

    require(boughtTokens > 0);

    token.mint(_buyer, boughtTokens);

    TokenBuy(_buyer, boughtTokens);
  }

  /**
   * @dev Catch any incoming payments to the contract and convert the ETH to tokens
   */
  function () external payable {
    buyTokens(msg.sender, msg.value);
  }
}