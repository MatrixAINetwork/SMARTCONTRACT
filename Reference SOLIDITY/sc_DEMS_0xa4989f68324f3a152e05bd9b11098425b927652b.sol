/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract DEMS {
    event SendMessage(bytes iv, bytes epk, bytes ct, bytes mac, address sender);
    
    function sendMessage(bytes iv, bytes epk, bytes ct, bytes mac) external {
        SendMessage(iv, epk, ct, mac, msg.sender);
    }
}