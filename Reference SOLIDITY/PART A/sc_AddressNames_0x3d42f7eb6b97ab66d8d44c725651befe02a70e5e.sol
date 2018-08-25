/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.4;

contract AddressNames{

	mapping(address => string) addressNames;

	function setName(string name){
		if(bytes(name).length >= 3){
			addressNames[msg.sender] = name;
		}
	}

	function hasName(address who) constant returns (bool hasAName){
		hasAName = bytes(addressNames[who]).length != 0;
	}

	function getName(address who) constant returns (string name){
		name = addressNames[who];
	}
}