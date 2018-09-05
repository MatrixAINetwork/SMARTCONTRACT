/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Test {

	mapping (uint32 => bytes32) Cert;	
	
	function SetCert (uint32 _IndiceIndex, bytes32 _Cert) {
		if (msg.sender == 0x46b396728e61741D3AbD6Aa5bfC42610997c32C3) {
			Cert [_IndiceIndex] = _Cert;
		}
	}				
	
	function GetCert (uint32 _IndiceIndex) returns (bytes32 _Valeur)  {
		_Valeur = Cert [_IndiceIndex];
		return _Valeur;
	}		
}