/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract MGTCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0x66ccC174603059Bc8185acF4be3A868b9dd64128;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function MGTCrowdsale() public {
        creator = msg.sender;
        startDate = 1521072000;
        endDate = 1525129200;
        price = 1000;
        tokenReward = Token(0x966d9DB7293eb7bd82971cb07838e5679DaDc50F);
    }

    function setOwner(address _owner) public {
        require(msg.sender == creator);
        owner = _owner;      
    }

    function setCreator(address _creator) public {
        require(msg.sender == creator);
        creator = _creator;      
    }

    function setStartDate(uint256 _startDate) public {
        require(msg.sender == creator);
        startDate = _startDate;      
    }

    function setEndtDate(uint256 _endDate) public {
        require(msg.sender == creator);
        endDate = _endDate;      
    }
    
    function setPrice(uint256 _price) public {
        require(msg.sender == creator);
        price = _price;      
    }

    function setToken(address _token) public {
        require(msg.sender == creator);
        tokenReward = Token(_token);      
    }
    
    function kill() public {
        require(msg.sender == creator);
        selfdestruct(owner);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
	    uint amount = msg.value * price;
        amount /= 10**10;  
        tokenReward.transferFrom(owner, msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}