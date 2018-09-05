/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract RipplePayExample {

mapping(address => mapping(address => uint)) TrustSettings; // store trustLines for a given address

function updateTrustSettings(address _peer, uint newTrustLimit) {
TrustSettings[msg.sender][_peer] = newTrustLimit;
}

function getTrustSetting(address _peer) returns(uint) {
return TrustSettings[msg.sender][_peer];
}
}