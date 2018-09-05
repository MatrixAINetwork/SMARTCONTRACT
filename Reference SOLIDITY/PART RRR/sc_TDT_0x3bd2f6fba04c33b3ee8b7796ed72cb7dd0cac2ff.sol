/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract TDT {
    address public owner;
    uint public supply = 10000000000000000000000000;
    string public name = 'TDT';
    string public symbol = 'TDT';
    uint8 public decimals = 18;
    uint public price = 1 finney;
    uint public durationInBlocks = 157553;
    uint public amountRaised;
    uint public deadline;
    uint public tokensSold;
    
    mapping (address => uint256) public balanceOf;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    function isOwner() returns (bool isOwner) {
        return msg.sender == owner;
    }
    
    function addressIsOwner(address addr)  returns (bool isOwner) {
        return addr == owner;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
    
    function TDT() {
        owner = msg.sender;
        balanceOf[msg.sender] = supply;
        deadline = block.number + durationInBlocks;
    }
    
    function isCrowdsale() returns (bool isCrowdsale) {
        return block.number < deadline;
    }
    
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) revert();
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        Transfer(msg.sender, _to, _value);
    }
    
    function () payable {
        if (isOwner()) {
            owner.transfer(amountRaised);
            FundTransfer(owner, amountRaised, false);
            amountRaised = 0;
        } else if (isCrowdsale()) {
            uint amount = msg.value;
            if (amount == 0) revert();
            
            uint tokensCount = amount * 1000000000000000000 / price;
            if (tokensCount < 1000000000000000000) revert();
            
            balanceOf[msg.sender] += tokensCount;
            supply += tokensCount;
            tokensSold += tokensCount;
            Transfer(0, this, tokensCount);
            Transfer(this, msg.sender, tokensCount);
            amountRaised += amount;
        } else {
            revert();
        }
    }
}