/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
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
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) returns (bool);
    function approve(address spender, uint256 value) returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ChronoBase is ERC20 {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    string public version;
    address public owner;

    /* This creates an array with all balances */
    mapping (address => uint256) public balances;
    mapping (address => uint256) public frozen;
    mapping (address => mapping (address => uint256)) public allowed;

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    /* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);

    /* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function ChronoBase() {
        balances[msg.sender] = 10000000000000000;       // Give the creator all initial tokens
        totalSupply = 10000000000000000;                // Update total supply
        name = 'ChronoBase';                            // Set the name for display purposes
        symbol = 'BASE';                                // Set the symbol for display purposes
        decimals = 8;                                   // Amount of decimals for display purposes
        version = 'BASE1.0';                            // Token contract version
        owner = msg.sender;
    }

    function balanceOf(address _owner) constant returns (uint256 balance){
        return balances[_owner];
    }

    modifier noBurn(address _to) {
        require(_to != 0x0);
        _;
    }

    /* Send tokens */
    function transfer(address _to, uint256 _value) noBurn(_to) returns (bool){
        balances[msg.sender] = balances[msg.sender].sub(_value);            // Subtract from the sender
        balances[_to] = balances[_to].add(_value);                          // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                      // Notify anyone listening that this transfer took place
        return true;
    }

    /* Transfer tokens */
    function transferFrom(address _from, address _to, uint256 _value) noBurn(_to) returns (bool success) {
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);                     // Subtract from the sender
        balances[_to] = balances[_to].add(_value);                         // Add the same to the recipient
        Transfer(_from, _to, _value);
        return true;
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /* Destruction of the token */
    function burn(uint256 _value) returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);           // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                             // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    function freeze(uint256 _value) returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);            // Subtract from the sender
        frozen[msg.sender] = frozen[msg.sender].add(_value);                // Updates frozen tokens
        Freeze(msg.sender, _value);
        return true;
    }

    function unfreeze(uint256 _value) returns (bool success) {
        frozen[msg.sender] = frozen[msg.sender].sub(_value);                // Updates frozen tokens
        balances[msg.sender] = balances[msg.sender].add(_value);            // Add to the sender
        Unfreeze(msg.sender, _value);
        return true;
    }

    function freezeOf(address _owner) constant returns (uint256) {
        return frozen[_owner];
    }

    /* Prevents accidental sending of Ether */
    function () payable {
        revert();
    }
}