/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;


// ----------------------------------------------------------------------------------------------
// Derived from: Sample fixed supply token contract
// Enjoy. (c) BokkyPooBah 2017. The MIT Licence.
// (c) Ethex LLC 2017.
// ----------------------------------------------------------------------------------------------

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
     function totalSupply() public constant returns (uint);
     function balanceOf(address tokenOwner) public constant returns (uint balance);
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
     function transfer(address to, uint tokens) public returns (bool success);
     function approve(address spender, uint tokens) public returns (bool success);
     function transferFrom(address from, address to, uint tokens) public returns (bool success);

     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Etx is ERC20Interface {
    string public constant symbol = "ETX";

    string public constant name = "Ethex supporter token.";

    uint8 public constant decimals = 18;

    uint256 public blocksToVest;

    uint256 constant _totalSupply = 10000 * (1 ether);

    // Owner of this contract
    address public owner;

    // Balances for each account
    mapping (address => uint256) balances;

    // activate start for each account.
    mapping (address => uint256) activateStartBlock;

    //block at which this Etx token expires
    uint256 public expirationBlock;

    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;

    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Constructor
    function Etx(uint256 _blocksToVest,uint256 _expirationBlock) public {
        blocksToVest = _blocksToVest;
        expirationBlock = _expirationBlock;
        owner = msg.sender;
        balances[owner] = _totalSupply;
        activateStartBlock[owner] = block.number;
    }

    function totalSupply() public constant returns (uint256 ts) {
        ts = _totalSupply;
    }

    // What is the balance of a particular account?
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    //in case the client wants to display how long until they are vested.
    function activateStartBlockOf(address _owner) public constant returns (uint256 blockNumber) {
        if (balances[_owner] >= (1 ether)) {
          return activateStartBlock[_owner];
        }
        return block.number;
    }

    function isActive(address _owner) public constant returns (bool vested) {
        if (block.number > expirationBlock) {
            return false;
        }
        if (balances[_owner] >= (1 ether) &&
        activateStartBlock[_owner] + blocksToVest <= block.number) {
            return true;
        }
        return false;
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount &&
        _amount > 0 &&
        balances[_to] + _amount > balances[_to]) {

            // Record current _to balance.
            uint256 previousBalance = balances[_to];

            // Transfer.
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;

            // If "_to" crossed the 1 ETX level in this transaction, this is the activate start block.
            if (previousBalance < (1 ether) && balances[_to] >= (1 ether)) {
                activateStartBlock[_to] = block.number;
            }

            Transfer(msg.sender, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        if (balances[_from] >= _amount &&
        allowed[_from][msg.sender] >= _amount &&
        _amount > 0 &&
        balances[_to] + _amount > balances[_to]) {

            // Record current _to balance.
            uint256 previousBalance = balances[_to];

            // Transfer.
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;

            // If "_to" crossed the 1 ETX level in this transaction, this is the activate start block.
            if (previousBalance < (1 ether) && balances[_to] >= (1 ether)) {
                activateStartBlock[_to] = block.number;
            }

            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
      // To change the approve amount you first have to reduce the addresses`
      //  allowance to zero by calling `approve(_spender, 0)` if it is not
      //  already 0 to mitigate the race condition described here:
      //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
      require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

      allowed[msg.sender][_spender] = _amount;
      Approval(msg.sender, _spender, _amount);
      return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}