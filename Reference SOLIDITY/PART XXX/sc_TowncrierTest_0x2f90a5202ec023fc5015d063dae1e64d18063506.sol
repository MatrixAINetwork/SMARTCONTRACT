/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract TowncrierTest {
    event LogTowncrierCallback(uint64 requestId, uint64 error, bytes32 respData);
    
    function towncrierCallback(uint64 requestId, uint64 error, bytes32 respData) public {
        LogTowncrierCallback(requestId, error, respData);
    }
}