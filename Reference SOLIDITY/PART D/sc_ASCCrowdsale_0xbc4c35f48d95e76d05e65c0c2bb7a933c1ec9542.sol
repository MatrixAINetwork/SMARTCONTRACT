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

contract ASCCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0xb99776950E24a1D580d8c1622ab6C92002aEc169;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function ASCCrowdsale() public {
        creator = msg.sender;
        startDate = 1452038400;     // 06/01/2018
        endDate = 1521586800;       // 21/03/2018
        price = 72000;
        tokenReward = Token(0x9A7fF9c99ECa95Faea0d866a4cdaceaFf276D948);
    }

    function setOwner(address _owner) public {
        require(msg.sender == creator);
        owner = _owner;      
    }

    function setCreator(address _creator) public {
        require(msg.sender == creator);
        creator = _creator;      
    }

    function setPrice(uint256 _price) public {
        require(msg.sender == creator);
        price = _price;      
    }
    
    function kill() public {
        require(msg.sender == creator);
        selfdestruct(owner);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
	    uint256 _price = price / 10;

        // period 1 : 60%
        if(now > startDate && now < 1516230000) {
            _price *= 6;
            _price += price;
        }

        // Pperiod 2 : 40%
        if(now > 1516230000 && now < 1517439600) {
            _price *= 4;
            _price += price;
        }

        // period 3 : 20%
        if(now > 1517439600 && now < 1518649200) {
            _price *= 2;
            _price += price;
        }

        // period 4 : 10%
        if(now > 1518649200 && now < 1519858800) {
            _price += price;
        }
        uint amount = msg.value;
        amount /= 10 finney;
        tokenReward.transferFrom(owner, msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}