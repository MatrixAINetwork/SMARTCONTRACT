/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract CreditIDENTITY{
    
    address public creditDao;
    
    uint public nextFieldIndex;
    mapping (uint => string) avaliableFields;
    mapping (string => bool) fieldActivated;
    mapping (string => uint) fieldTypes;
    
    mapping (address => string) addressDescriptions;
    
    uint public nextIdentityAccount;
    mapping (uint => mapping (bytes => bytes)) identityAccounts;
    mapping (address => uint) public addressToAccountMap;
    
    mapping (address => mapping(address => uint)) mappingProposal;
    
    event MappingProposalIssued(address _addressThatMapped, address _addressToMap, uint identityId);
    event MappingDone(address _addressToMap, uint identityId);
    event AddressDescriptionAdded(address _source, string _description);
    
    function CreditIDENTITY(address _creditDao) {
        nextFieldIndex = 1;
        nextIdentityAccount = 1;
        creditDao = _creditDao;
    }
    
    function addAddressDescription(string _addressDescription){
        addressDescriptions[msg.sender] = _addressDescription;
        AddressDescriptionAdded(msg.sender, _addressDescription);
    }
    
    function getFieldData(uint _index) constant returns (uint, bytes, bool, uint){
        string tempField = avaliableFields[_index];
        bytes memory tempByteField = bytes(tempField);
        return (_index, tempByteField, fieldActivated[tempField], fieldTypes[tempField]);
    }
    
    function addAccountData(string _field, bytes _data){
        if (fieldActivated[_field] != true) throw;
        bytes memory fieldBytes = bytes(_field);
        if (addressToAccountMap[msg.sender] == 0){
            identityAccounts[nextIdentityAccount][fieldBytes] = _data;
            addressToAccountMap[msg.sender] = nextIdentityAccount;
            nextIdentityAccount += 1;
        }else{
            uint accountId = addressToAccountMap[msg.sender];
            identityAccounts[accountId][fieldBytes] = _data;
        }
    }
    
    function addAddressMappingProposal(address _addressToMap){
        if (addressToAccountMap[msg.sender] == 0) throw;
        
        mappingProposal[msg.sender][_addressToMap] = addressToAccountMap[msg.sender];
        MappingProposalIssued(msg.sender, _addressToMap, addressToAccountMap[msg.sender]);
    }
    
    function approveMappingProposal(address _addressThatMapped) {
        if (mappingProposal[_addressThatMapped][msg.sender] == 0) throw;
        
        uint tempId = mappingProposal[_addressThatMapped][msg.sender];
        addressToAccountMap[msg.sender] = tempId;
        mappingProposal[_addressThatMapped][msg.sender] = 0;
        MappingDone(msg.sender, tempId);
    }
    
    function getAccountData(address _accountAddress, string _field) constant returns (bytes){
        return identityAccounts[addressToAccountMap[_accountAddress]][bytes(_field)];
    }
    
    function getAddressDescription(address _queryAddress) constant returns (string){
        return addressDescriptions[_queryAddress];
    }
    
    //
    // Admin features
    //
    function addField(string _fieldName, uint _fieldType){
        if (msg.sender != creditDao) throw;
        if (_fieldType == 0) throw;
        if (fieldTypes[_fieldName] != 0) throw;
        
        avaliableFields[nextFieldIndex] = _fieldName;
        fieldActivated[_fieldName] = true;
        fieldTypes[_fieldName] = _fieldType;
        
        nextFieldIndex += 1;
    }
    
    function toggleFieldActivation(string _fieldName){
        if (msg.sender != creditDao) throw;
        if (fieldTypes[_fieldName] == 0) throw;
        
        fieldActivated[_fieldName] = !fieldActivated[_fieldName];
    }
    
    function editAddressDescription(address _targetAddress, string _addressDescription){
        if (msg.sender != creditDao) throw;
        
        addressDescriptions[_targetAddress] = _addressDescription;
    }
    
    function editAccountData(address _targetAddress, string _field, bytes _data){
        if (msg.sender != creditDao) throw;
        
        identityAccounts[addressToAccountMap[_targetAddress]][bytes(_field)] = _data;
    }
    
    function setCreditDao(address _newCreditDao){
        if (msg.sender != creditDao) throw;
        creditDao = _newCreditDao;
    }
    
    function killContract() {
        if (msg.sender != creditDao) throw;
        selfdestruct(creditDao);
    }
}