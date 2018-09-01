/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.2;

/*

EthPledge allows people to pledge to donate a certain amount to a charity, which gets sent only if others match it. A user may pledge to donate 10 Ether to a charity, for example, which will get listed here and will be sent to the charity later only if other people also collectively contribute 10 Ether under that pledge. You can also pledge to donate several times what other people donate, up to a certain amount -- for example, you may choose to put up 10 Ether, which gets sent to the charity if others only contribute 2 Ether.

Matching pledges of this kind are quite common (companies may pledge to match all charitable donations their employees make up to a certain amount, for example, or it may just be a casual arrangement between 2 people) and by running on the Ethereum blockchain, EthPledge guarantees 100% transparency. 

Note that as Ethereum is still relatively new at this stage, not many charities have an Ethereum address to take donations yet, though it's our hope that more will come. The main charity with an Ethereum donation address at this time is Heifer International, whose Ethereum address is 0xb30cb3b3E03A508Db2A0a3e07BA1297b47bb0fb1 (see https://www.heifer.org/what-you-can-do/give/digital-currency.html)

Visit EthPledge.com to play with this smart contract. Reach out: 