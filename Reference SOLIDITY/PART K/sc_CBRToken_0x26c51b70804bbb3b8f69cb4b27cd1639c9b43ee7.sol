/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// (c) Bitzlato Ltd, 2017
pragma solidity ^0.4.0;

contract CBRToken {

    string public name = "ChangeBotR";      //  token name
    string public symbol = "CBR";           //  token symbol
    uint256 public decimals = 0;            //  token digit

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;

    uint256 private _totalSupply = 0;
    bool public stopped = false;

    uint256 constant valueFounder = 1e10;
    address ownerA = 0x0;
    address ownerB = 0x0;
    address ownerC = 0x0;
    uint public voteA = 0;
    uint public voteB = 0;
    uint public voteC = 0;
    uint public mintA = 0;
    uint public mintB = 0;
    uint public mintC = 0;

    modifier hasVote {
        require((voteA + voteB + voteC) >= 2);
        _;
        voteA = 0;
        voteB = 0;
        voteC = 0;
    }

    modifier isOwner {
        assert(ownerA == msg.sender || ownerB == msg.sender || ownerC == msg.sender);
        _;
    }

    modifier isRunning {
        assert (!stopped);
        _;
    }

    modifier validAddress {
        assert(0x0 != msg.sender);
        _;
    }

    function CBRToken(address _addressFounderB, address _addressFounderC) public {
        assert(0x0 != msg.sender);
        assert(0x0 != _addressFounderB);
        assert(0x0 != _addressFounderC);
        assert(_addressFounderB != _addressFounderC);
        ownerA = msg.sender;
        ownerB = _addressFounderB;
        ownerC = _addressFounderC;
        _totalSupply = valueFounder;
        balances[ownerA] = valueFounder;
        balances[ownerB] = 0;
        balances[ownerC] = 0;
    }

    function totalSupply() constant public returns (uint256 total) {
        total = _totalSupply;
    }
 
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) isRunning validAddress public returns (bool success) {
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) isRunning validAddress public returns (bool success) {
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        require(allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) isRunning validAddress public returns (bool success) {
        require(_value == 0 || allowed[msg.sender][_spender] == 0);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function stop() isOwner public {
        stopped = true;
    }

    function start() isOwner public {
        stopped = false;
    }

    function setName(string _name) isOwner public {
        name = _name;
    }

    function doMint(uint256 _value) isOwner hasVote public {
        assert(_value > 0 && _value <= (mintA + mintB + mintC));
        mintA = 0; mintB = 0; mintC = 0;
        balances[msg.sender] += _value;
        _totalSupply += _value;
        DoMint(msg.sender, _value);
    }
    
    function proposeMint(uint256 _value) public {
        if (msg.sender == ownerA) {mintA = _value; ProposeMint(msg.sender, _value); return;}
        if (msg.sender == ownerB) {mintB = _value; ProposeMint(msg.sender, _value); return;}
        if (msg.sender == ownerC) {mintC = _value; ProposeMint(msg.sender, _value); return;}
        assert(false);
    }
    
    function vote(uint v) public {
        uint s = 0;
        if (v > 0) {s = 1;}
        if (msg.sender == ownerA) {voteA = s; Vote(msg.sender, s); return;}
        if (msg.sender == ownerB) {voteB = s; Vote(msg.sender, s); return;}
        if (msg.sender == ownerC) {voteC = s; Vote(msg.sender, s); return;}

        assert(false);
    }

    function burn(uint256 _value) public {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[0x0] += _value;
        Transfer(msg.sender, 0x0, _value);
    }

    function destroy(address _addr, uint256 _value) isOwner hasVote public {
        require(balances[_addr] >= _value);
        balances[_addr] -= _value;
        balances[0x0] += _value;
        Transfer(_addr, 0x0, _value);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event ProposeMint(address indexed _owner, uint256 _value);
    event Vote(address indexed _owner, uint v);
    event DoMint(address indexed _from, uint256 _value);
}