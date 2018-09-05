/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract Verifier {
    function recoverAddr(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (address msgAddress) {
        return ecrecover(msgHash, v, r, s);
    }
    
    function isSigned(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool msgSigned) {
        return ecrecover(msgHash, v, r, s) == _addr;
    }
}