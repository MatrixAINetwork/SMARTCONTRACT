/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

interface Token {
    function transfer(address receiver, uint amount) public;
}

contract C5PMCrowdsale {
    
    Token public tokenReward;
    address owner = 0x1862154CEEF9c349d7b6D4040F2DB9b4864135b6;
    uint price = 10 ** 10;

    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function C5PMCrowdsale() public {
        startDate = 1517439600;
        endDate = 1522620000;
        tokenReward = Token(0x4Ad02bF71d9Fcf86BD155fB1d7Bf891E0CD9b31D);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
        uint amount = msg.value / price;
        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}