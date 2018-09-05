/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract Ownable {
	event OwnershipRenounced(address indexed previousOwner); 
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	modifier notOwner(address _addr) {
		require(_addr != owner);
		_;
	}

	address public owner;

	constructor() 
		public 
	{
		owner = msg.sender;
	}

	function renounceOwnership()
		external
		onlyOwner 
	{
		emit OwnershipRenounced(owner);
		owner = address(0);
	}

	function transferOwnership(address _newOwner) 
		external
		onlyOwner
		notOwner(_newOwner)
	{
		require(_newOwner != address(0));
		emit OwnershipTransferred(owner, _newOwner);
		owner = _newOwner;
	}
}

contract TimeLockedWallet is Ownable {
	uint256 public unlockTime;

	constructor(uint256 _unlockTime) 
		public
	{
		unlockTime = _unlockTime;
	}

	function()
		public
		payable
	{
	}

	function locked()
		public
		view
		returns (bool)
	{
		return now <= unlockTime;
	}

	function claim()
		external
		onlyOwner
	{
		require(!locked());
		selfdestruct(owner);
	}	
}