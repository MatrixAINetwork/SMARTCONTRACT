/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity^0.4.8;

contract BlockAppsCertificateManager {
    address owner;
    Certificate [] certificates;
    
    function BlockAppsCertificateManager() {
        owner = msg.sender;
    }
    function issueCertificate(string _classDate, string _participants, string _location) returns(bool){
        if (msg.sender != owner){
            return false;
        }
        certificates.push(new Certificate(_classDate, _participants, _location)); 
        return true;
    }
}

contract Certificate {
    string classDate; 
    string participants;
    string location;
    address certificateManager;
    
    function Certificate(string _classDate, string _participants, string _location) {
        classDate = _classDate;
        participants = _participants;
        certificateManager = msg.sender;
        location = _location;
    }
}