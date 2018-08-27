/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.6;

contract Blockmatics_Certificate_12142017 {
    address public owner = msg.sender;
    string certificate;
    bool certIssued = false;

    function publishGraduatingClass(string cert) public {
        if (msg.sender != owner || certIssued)
            revert();
        certIssued = true;
        certificate = cert;
    }

    function showCertificate() constant public returns (string)  {
        return certificate;
    }
}