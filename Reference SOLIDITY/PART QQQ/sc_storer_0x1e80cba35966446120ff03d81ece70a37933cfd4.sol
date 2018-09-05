/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.2;
contract storer {
	address public owner;
	string public log;

	function storer() {
		owner = msg.sender ;
		}

	modifier onlyOwner {
		if (msg.sender != owner)
            		throw;
        		_;
		}

	function store(string _log) onlyOwner() {
	log = _log;
		}

	function kill() onlyOwner() {
	selfdestruct(owner); }
}