/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract BlockmaticsGraduationCertificate_102417 {
    address public owner = msg.sender;
    string certificate;
    bool certIssued = false;

    function publishGraduatingClass(string cert) {
        if (msg.sender != owner || certIssued)
            throw;
        certIssued = true;
        certificate = cert;
    }

    function showBlockmaticsCertificate() constant returns (string) {
        return certificate;
    }
}