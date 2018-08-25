/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract DonateDust {

	address public owner;
	uint256 public totalDonations;

	constructor() {
		owner = msg.sender;
	}

	modifier onlyOwner { 
		require (msg.sender == owner); 
		_; 
	}
	
	function donate() public payable {
		totalDonations += msg.value;
	}

	function withdraw() public onlyOwner {
		owner.transfer(address(this).balance);
	}
	
	function() public payable {
		donate();
	}
}