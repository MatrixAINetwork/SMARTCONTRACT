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

contract AXLCrowdsale {

    mapping (address => uint256) public balanceOf;
    
    Token public tokenReward;
    address public creator;
    address public owner = 0xC4e8E2556905CFD49F16f38f25c5612950761fc9;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;
    uint256 public every15;


    event FundTransfer(address backer, uint amount, bool isContribution);

    function AXLCrowdsale() public {
        creator = msg.sender;
        startDate = 1519776000;
        endDate = 1522537200;
        every15 = startDate + 15 days;
        price = 10000;
        tokenReward = Token(0x2708fF1F06C99932ac099422031da3691c625Aed);
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
        if(now > every15) {
            price += price / 20;
            every15 += 15 days;
        }
	    uint amount = msg.value * price;
        tokenReward.transferFrom(owner, msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}