/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract MyOwned {
    address public owner;
    function MyOwned() public { owner = msg.sender; }
    modifier onlyOwner { require(msg.sender == owner); _;}
    function exOwner(address newOwner) onlyOwner public { owner = newOwner;}
}

interface token {
    function transfer(address receiver, uint amount) public;
}

contract EPOpresale is MyOwned {
    uint public startDate;
    uint public stopDate;
    uint public salePrice;
    uint public saleSupply;
    uint public fundingGoal;
    uint public amountRaised;
    token public tokenReward;
    address public beneficiary;
    mapping(address => uint256) public balanceOf;
    event TakeBackToken(uint amount);
    event FundTransfer(address sender, uint amount, bool isSuccessful);

    function EPOpresale (
        uint _startDate,
        uint _stopDate,
        uint _salePrice,
        uint _saleSupply,
        uint _fundingGoal,
        address _beneficiary,
        address _tokenReward
    ) public {
        startDate = _startDate;
        stopDate = _stopDate;
        salePrice = _salePrice;
        saleSupply = _saleSupply;
        fundingGoal = _fundingGoal;
        beneficiary = _beneficiary;
        tokenReward = token(_tokenReward);
    }
    
    function getCurrentTimestamp() internal constant returns (uint256) {
        return now;    
    }

    function saleActive() public constant returns (bool) {
        return (now >= startDate && now <= stopDate);
    }

    function () payable public {
        require(saleActive());
        require(msg.value >= 0.05 ether);
        uint amount = msg.value;
        amountRaised += amount/10000000000000000;
        uint amountSend = amount/10000000000*salePrice;
        tokenReward.transfer(msg.sender, amountSend);
        beneficiary.transfer(msg.value);

        FundTransfer(msg.sender, amount, true);        
    }

    function saleEnd(uint restAmount) public onlyOwner {
        require(!saleActive());
        require(now > stopDate );
        tokenReward.transfer(beneficiary, restAmount);
        TakeBackToken(restAmount);
    }
}