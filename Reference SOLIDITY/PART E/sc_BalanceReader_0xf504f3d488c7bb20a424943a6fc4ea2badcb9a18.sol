/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.6;
contract BalanceReader {
    BalanceHolder public presale;

	function BalanceReader(){
	    presale = BalanceHolder(0xe3c61a3bff7cb03ddd422258006fddd5ba1ed0fe);
	}
	
	function attach(BalanceHolder _presale) public {
	    presale = _presale;
	}
	
	function balance(address addr) public constant returns (uint) {
		return presale.balances(addr);
	}
}

contract BalanceHolder {
    function balances(address) returns (uint);
}