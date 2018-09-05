/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// Note: 0.4.19 is a pre-release compiler, warning suggests use 0.4.18
// pragma solidity ^0.4.18;
contract Osler_SmartContracts_Demo_Certificate_of_Attendance {
  address public owner = msg.sender;
  string certificate;

  function publishLawyersInAttendance(string cert) {

    if (msg.sender !=owner){
      // return remainin gas back to  the caller
      revert();
    }
    certificate = cert;
  }
  function showCertificate() constant returns (string) {
    return certificate;
  }
}