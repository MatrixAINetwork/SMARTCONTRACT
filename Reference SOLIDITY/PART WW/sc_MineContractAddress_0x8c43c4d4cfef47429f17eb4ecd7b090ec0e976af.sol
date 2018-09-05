/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract MineContractAddress {
    function mine(
        address _account, 
        uint _nonce
    ) public pure returns(address _contract) {
        if (_nonce == 0) _nonce = 128;
        _contract = address(keccak256(bytes2(0xd694), _account, byte(_nonce)));
    }
}