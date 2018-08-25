/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

contract myOwned {
    address public contractOwner;
    function myOwned() public { contractOwner = msg.sender; }
    modifier onlyOwner { require(msg.sender == contractOwner); _;}
    function exOwner(address newOwner) onlyOwner public { contractOwner = newOwner;}
}

interface token {
    function transfer(address receiver, uint amount);
}

contract AIAcrowdsale is myOwned {
    uint public startDate;
    uint public stopDate;
    uint public fundingGoal;
    uint public amountRaised;
    token public contractTokenReward;
    address public contractWallet;
    mapping(address => uint256) public balanceOf;
    event GoalReached(address receiver, uint amount);
    event FundTransfer(address backer, uint amount, bool isContribution);

    function AIAcrowdsale (
        uint _startDate,
        uint _stopDate,
        uint _fundingGoal,
        address _contractWallet,
        address _contractTokenReward
    ) {
        startDate = _startDate;
        stopDate = _stopDate;
        fundingGoal = _fundingGoal * 1 ether;
        contractWallet = _contractWallet;
        contractTokenReward = token(_contractTokenReward);
    }
    
    function getCurrentTimestamp() internal returns (uint256) {
        return now;    
    }

    function saleActive() public constant returns (bool) {
        return (now >= startDate && now <= stopDate && amountRaised < fundingGoal);
    }

    function getRateAt(uint256 at) public constant returns (uint256) {
        if (at < startDate) {return 0;} 
        else if (at < (startDate + 150 hours)) {return 4355;} 
        else if (at < (startDate + 318 hours)) {return 3920;} 
        else if (at < (startDate + 486 hours)) {return 3528;} 
        else if (at <= stopDate) {return 3176;} 
        else if (at > stopDate) {return 0;}
    }

    function getRateNow() public constant returns (uint256) {
        return getRateAt(now);
    }

    function () payable {
        require(saleActive());
        require(amountRaised < fundingGoal);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        uint price =  0.0001 ether / getRateAt(now);
        contractTokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
        contractWallet.transfer(msg.value);
    }

    function saleEnd() onlyOwner {
        require(!saleActive());
        require(now > stopDate );
        contractWallet.transfer(this.balance);
        contractTokenReward.transfer(contractWallet, this.balance);

    }

    function destroy() { 
        if (msg.sender == contractWallet) { 
        suicide(contractWallet);
        contractTokenReward.transfer(contractWallet, this.balance);
        }
    }    
}