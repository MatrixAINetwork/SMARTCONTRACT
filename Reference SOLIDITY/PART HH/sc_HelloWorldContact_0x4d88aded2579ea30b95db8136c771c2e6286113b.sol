/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract HelloWorldContact {
	string word = "Hello World";
	address owner;
	
	function HelloWorldContract() {
		owner = msg.sender;
	}

	function getWord() constant returns(string) {
		return word;
	}

	function setWord(string newWord) constant returns(string) {
		if (owner !=msg.sender) {
			return 'You shall not pass';
		}
		word = newWord;
		return 'You successfully changed the variable word';
	}
}