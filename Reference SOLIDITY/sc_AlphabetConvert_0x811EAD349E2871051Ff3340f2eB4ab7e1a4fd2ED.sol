/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// Copyright Alphabet Inc. 2015 - current.
//
// A simple conversion contract for ETH to ABC. ABC represents an ownership
// position in Alphabet's decentralized enterprise properties.
//
// Release date: April 14th, 2017
// Token issuance: 100,000 ABC
// Network address: convert.alphabet.eth
// https://abc.xyz/token

pragma solidity ^0.4.8;

contract token {
    function transfer(
        address receiver,
        uint amount
    );
}

contract AlphabetConvert {
    address public beneficiary;
    token public tokenReward;
    uint public amountRaised;

    mapping(address => uint256) public balanceOf;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function AlphabetConvert(address sendTo, token tokenAddress) {
        beneficiary = sendTo;
        tokenReward = token(tokenAddress);
    }

    function() payable {
        uint amount = msg.value;
        balanceOf[msg.sender] = amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / 1 ether);
        FundTransfer(msg.sender, amount, true);
    }

    function withdraw() {
        uint amount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        if (amount > 0) {
            if (msg.sender.send(amount)) {
                FundTransfer(msg.sender, amount, false);
            } else {
                balanceOf[msg.sender] = amount;
            }
        }

        if (beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            }
        }
    }
}