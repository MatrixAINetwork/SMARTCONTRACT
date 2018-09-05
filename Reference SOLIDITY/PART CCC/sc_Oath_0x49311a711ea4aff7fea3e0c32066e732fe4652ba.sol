/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Oath {
	mapping (address => bytes) public sig;

	event LogSignature(address indexed from, bytes version);

	function Oath() {
		if(msg.value > 0) { throw; }
	}

	function sign(bytes version) public {
		if(sig[msg.sender].length != 0 ) { throw; }
		if(msg.value > 0) { throw; }

		sig[msg.sender] = version;
		LogSignature(msg.sender, version);
	}

	function () { throw; }
}