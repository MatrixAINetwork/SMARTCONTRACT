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

contract ARWCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner =  0x94DEb6BA728d90fB02212EA6d370C1D634311246;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function ARWCrowdsale() public {
        creator = msg.sender;
        startDate = 1521936000;
        endDate = 1527289200;
        price = 10000;
        tokenReward = Token(0xEb0C680B2E42685bc836922d416DfD836704Ab09);
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
        uint _amount = amount / 10;

        // period 1 : 50%
        if(now > 1521936000 && now < 1523746801) {
            amount += _amount * 5;
        }
        
        // period 2 : 30%
        if(now > 1523746800 && now < 1525129201) {
            amount += _amount * 3;
        }

        // Pperiod 3 : 10%
        if(now > 1525129200 && now < 1527289200) {
            amount += _amount;
        }

        tokenReward.transferFrom(owner, msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}