/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount) public;
    function balanceOf(address addr) public returns (uint);
}

contract TimedVault {
    address public beneficiary;
    
    // Lock the tokens till 03/01/2019 @ 3:00pm (UTC)
    uint public releaseDate = 1551452400;
    token public tokenReward;
    
    uint public amountOfTokens;

    /**
     * Constructor function
     *
     * Setup the owner
     */
    function TimedVault(
        address ifSuccessfulSendTo,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
    }

    modifier afterDeadline() { if (now >= releaseDate) _; }

    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
     * the amount they contributed.
     */
    function safeWithdrawal() afterDeadline public {
        amountOfTokens = tokenReward.balanceOf(this);
        tokenReward.transfer(beneficiary, amountOfTokens);
    }
}