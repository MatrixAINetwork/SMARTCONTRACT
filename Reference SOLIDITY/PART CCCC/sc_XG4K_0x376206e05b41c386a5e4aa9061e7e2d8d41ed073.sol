/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;
/* This currency XG4K/ETH can only be issued by the coiner Xgains4keeps owner of 
the Equity4keeps programme and can be transferred to anyone or entity.
*/
contract XG4K {	
	mapping (address => uint) public balances;
	function XG4K() {
		balances[tx.origin] = 100000;
	}
	function sendToken(address receiver, uint amount) returns(bool successful){
		if (balances[msg.sender] < amount) return false;
 		balances[msg.sender] -= amount;
 		balances[receiver] += amount;
 		return false;
 	}
} 
contract coinSpawn{
 	mapping(uint => XG4K) deployedContracts;
	uint numContracts;
	function createCoin() returns(address a){
		deployedContracts[numContracts] = new XG4K();
		numContracts++;
		return deployedContracts[numContracts];
	}
}