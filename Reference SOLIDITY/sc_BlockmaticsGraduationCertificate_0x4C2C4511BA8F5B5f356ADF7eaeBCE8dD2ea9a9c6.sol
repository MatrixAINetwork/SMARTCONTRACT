/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract BlockmaticsGraduationCertificate {
    address public owner = msg.sender;
    string certificate;


    function publishGraduatingClass(string cert) {
        if (msg.sender != owner)
            throw;
        certificate = cert;
    }


    function showBlockmaticsCertificate() constant returns (string) {
        return certificate;
    }
}