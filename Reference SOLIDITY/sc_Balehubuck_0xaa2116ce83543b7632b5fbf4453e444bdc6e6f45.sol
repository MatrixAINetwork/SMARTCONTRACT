/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/// @title SafeMath
/// @dev Math operations with safety checks that throw on error
library SafeMath {
    /// @dev Multiplies a times b
    function mul(uint256 a, uint256 b) 
    internal 
    pure
    returns (uint256) 
    {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    /// @dev Divides a by b
    function div(uint256 a, uint256 b) 
    internal 
    pure
    returns (uint256) 
    {
        // require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /// @dev Subtracts a from b
    function sub(uint256 a, uint256 b) 
    internal 
    pure
    returns (uint256) 
    {
        require(b <= a);
        return a - b;
    }

    /// @dev Adds a to b
    function add(uint256 a, uint256 b) 
    internal 
    pure
    returns (uint256) 
    {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}



/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
/// @title Abstract token contract - Functions to be implemented by token contracts
contract Token {
    /*
     * Events
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /*
     * Public functions
     */
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function balanceOf(address owner) public constant returns (uint256);
    function allowance(address owner, address spender) public constant returns (uint256);
    uint256 public totalSupply;
}


/// @title Standard token contract - Standard token interface implementation
contract StandardToken is Token {
  using SafeMath for uint256;
    /*
     *  Storage
     */
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowances;
    uint256 public totalSupply;

    /*
     *  Public functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success
    /// @param to Address of token receiver
    /// @param value Number of tokens to transfer
    /// @return Returns success of function call
    function transfer(address to, uint256 value)
        public
        returns (bool)
    {
        require(to != address(0));
        require(value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        Transfer(msg.sender, to, value);
        return true;
    }

    /// @dev Allows allowances third party to transfer tokens from one address to another. Returns success
    /// @param from Address from where tokens are withdrawn
    /// @param to Address to where tokens are sent
    /// @param value Number of tokens to transfer
    /// @return Returns success of function call
    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool)
    {
        // if (balances[from] < value || allowances[from][msg.sender] < value)
        //     // Balance or allowance too low
        //     revert();
        require(to != address(0));
        require(value <= balances[from]);
        require(value <= allowances[from][msg.sender]);
        balances[to] = balances[to].add(value);
        balances[from] = balances[from].sub(value);
        allowances[from][msg.sender] = allowances[from][msg.sender].sub(value);
        Transfer(from, to, value);
        return true;
    }

    /// @dev Sets approved amount of tokens for spender. Returns success
    /// @param _spender Address of allowances account
    /// @param value Number of approved tokens
    /// @return Returns success of function call
    function approve(address _spender, uint256 value)
        public
        returns (bool success)
    {
        require((value == 0) || (allowances[msg.sender][_spender] == 0));
        allowances[msg.sender][_spender] = value;
        Approval(msg.sender, _spender, value);
        return true;
    }

 /**
   * approve should be called when allowances[_spender] == 0. To increment
   * allowances value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
    function increaseApproval(address _spender, uint _addedValue)
        public
        returns (bool)
    {
        allowances[msg.sender][_spender] = allowances[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue)
        public
        returns (bool) 
    {
        uint oldValue = allowances[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowances[msg.sender][_spender] = 0;
        } else {
            allowances[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    /// @dev Returns number of allowances tokens for given address
    /// @param _owner Address of token owner
    /// @param _spender Address of token spender
    /// @return Returns remaining allowance for spender
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint256)
    {
        return allowances[_owner][_spender];
    }

    /// @dev Returns number of tokens owned by given address
    /// @param _owner Address of token owner
    /// @return Returns balance of owner
    function balanceOf(address _owner)
        public
        constant
        returns (uint256)
    {
        return balances[_owner];
    }
}


contract Balehubuck is StandardToken {
    using SafeMath for uint256;
    /*
     *  Constants
     */
    string public constant name = "balehubuck";
    string public constant symbol = "BUX";
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_SUPPLY = 1000000000 * 10**18;
    // Presale Allocation = 500 * (5000 + 4500 + 4000 + 3500 + 3250 + 3000)
    // Main Sale Allocation = 75000 * 2500
    // Token Sale Allocation = Presale Allocation + Main Sale Allocation
    uint256 public constant TOKEN_SALE_ALLOCATION = 199125000 * 10**18;
    uint256 public constant WALLET_ALLOCATION = 800875000 * 10**18;

    function Balehubuck(address wallet)
        public
    {
        totalSupply = TOTAL_SUPPLY;
        balances[msg.sender] = TOKEN_SALE_ALLOCATION;
        balances[wallet] = WALLET_ALLOCATION;
        // Sanity check to make sure total allocations match total supply
        require(TOKEN_SALE_ALLOCATION + WALLET_ALLOCATION == TOTAL_SUPPLY);
    }
}