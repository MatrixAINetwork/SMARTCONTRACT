/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount);
}

contract knuckCrowdsaleOne {
    address public beneficiary;
    uint public amountRaised;
    uint public price;
    token public knuckReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function knuckCrowdsaleOne(
        address ifSuccessfulSendTo,
        uint CostOfEachKnuck,
        address addressOfTokenUsedAsReward
    ) {
        beneficiary = ifSuccessfulSendTo;
        price = CostOfEachKnuck * 1 wei;
        knuckReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable {
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        knuckReward.transfer(msg.sender, ((amount / price) * 1 ether));
        FundTransfer(msg.sender, amount, true);
        beneficiary.transfer(amount); 
        FundTransfer(beneficiary, amount, false);
            
       
}
    }