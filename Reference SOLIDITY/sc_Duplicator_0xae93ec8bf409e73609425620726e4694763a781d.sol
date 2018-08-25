/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.18;

// Duplicator - Version 1
// can be bought for 1 wei each
// this mean 1 ether = 1000000000000000000 tokens
// can be duplicated on command
// can be sold for 1 wei each

// token contracts at top, duplicator at bottom

// code from https://github.com/ConsenSys/Tokens/blob/master/contracts/Token.sol

contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function approve(address _spender, uint256 _value) returns (bool success);

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// code from https://github.com/ConsenSys/Tokens/blob/master/contracts/StandardToken.sol

contract StandardToken is Token {

    uint256 constant MAX_UINT256 = 2**256 - 1;

    function transfer(address _to, uint256 _value) returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

// code from https://github.com/ConsenSys/Tokens/blob/master/contracts/HumanStandardToken.sol

contract HumanStandardToken is StandardToken {

    string public name;
    uint8 public decimals;
    string public symbol;

    function HumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}

// code from https://ethereum.org/token

contract Owned {

    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract Duplicator is Owned, HumanStandardToken {

    function Duplicator() HumanStandardToken(0, "Duplicator", 0, "DUP") {}

    // buy by sending ether to the contract
    function () public payable {
        buy();
    }

    function buy() public payable {
        totalSupply += msg.value;
        balances[msg.sender] += msg.value;
    }

    function duplicate() public {
        totalSupply += balances[msg.sender];
        balances[msg.sender] += balances[msg.sender];
    }

    function sellAll() public {
        uint amountToSell = balances[msg.sender];

        // subtract the amount sold
        totalSupply -= amountToSell;
        balances[msg.sender] -= amountToSell;

        // transfer the ether over to the seller
        msg.sender.transfer(amountToSell);

        // make sure that the money was sent from the contracts balance
        require(this.balance == totalSupply);
    }

    // when the contract needs to upgrade to version 2
    function migrate(address newContract) public onlyOwner {
        selfdestruct(newContract);
    }
}