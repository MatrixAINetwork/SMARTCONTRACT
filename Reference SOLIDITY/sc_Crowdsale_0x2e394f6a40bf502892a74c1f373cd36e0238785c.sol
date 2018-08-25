/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract Crowdsale {
    address public payoutAddr;

    uint public deadline;
    uint public amountRaised;
    uint public price = 600;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;
    bool cancelled = false;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function Crowdsale (
        address ifSuccessfulSendTo,
        address addressOfTokenUsedAsReward,
        uint durationInMinutes
    ) public {
        payoutAddr = ifSuccessfulSendTo;
        tokenReward = token(addressOfTokenUsedAsReward);
        deadline = now + durationInMinutes * 1 minutes;
    }
    
    function () public payable {
        require(!crowdsaleClosed);
        balanceOf[msg.sender] += msg.value;
        amountRaised += msg.value;
        tokenReward.transfer(msg.sender, msg.value * price);
        FundTransfer(msg.sender, msg.value, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    function closeSale() public afterDeadline {
        crowdsaleClosed = true;
    }

    function safeWithdrawal() public afterDeadline {
        if (cancelled) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

         if (payoutAddr == msg.sender) {
            if (payoutAddr.send(amountRaised)) {
                FundTransfer(payoutAddr, amountRaised, false);
            } else {
                cancelled = true;
            }
        }
    }
}