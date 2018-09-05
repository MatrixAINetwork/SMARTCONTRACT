/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/**
 * SimpleRegistrar lets you claim a subdomain name for yourself and configure it
 * all in one step. This one is deployed at registrar.gimmethe.eth.
 * 
 * To use it, simply call register() with the name you want and the appropriate
 * fee (initially 0.01 ether, but adjustable over time; call fee() to get the
 * current price). For example, in a web3 console:
 * 
 *     var simpleRegistrarContract = web3.eth.contract([{"constant":true,"inputs":[],"name":"fee","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"name","type":"string"}],"name":"register","outputs":[],"payable":true,"type":"function"}]);
 *     var simpleRegistrar = simpleRegistrarContract.at("0x1bebbc372772817d5d11a06ee2a4eba33ab6ee65");
 *     simpleRegistrar.register('myname', {from: accounts[0], value: simpleRegistrar.fee(), gas: 150000});
 * 
 * SimpleRegistrar will take care of everything: registering your subdomain,
 * setting up a resolver, and pointing that resolver at the account that called
 * it.
 * 
 * Funds received from running this service are reinvested into building new
 * ENS tools and utilities.
 * 
 * Note that the Deed owning gimmethe.eth is not currently in a holding
 * contract, so I could theoretically change the registrar at any time. This is
 * a temporary measure, as it may be necessary to replace this contract with an
 * updated one as ENS best practices change. You have only my word that I will
 * never interfere with a properly registered subdomain of gimmethe.eth.
 * 
 * Author: Nick Johnson <