/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract People {
    
    Person[] public people;
    
    struct Person {
        bytes32 firstName;
        bytes32 lastName;
        uint age;
    }
    
    function addPerson(bytes32 _firstname, bytes32 _lastname, uint _age) returns (bool success){
        
        Person memory newPerson;
        newPerson.firstName = _firstname;
        newPerson.lastName = _lastname;
        newPerson.age = _age;
        
        people.push(newPerson);
        return true;
    }
    
    function getPeople() constant returns( bytes32[],bytes32[], uint[]) {
        
        bytes32[] firstNames;
        bytes32[] lastNames;
        uint[] ages;
        
        
        for( uint i = 0; i < people.length; i++){
            Person memory currentPerson;
            currentPerson = people[i];
            firstNames.push(currentPerson.firstName);
            lastNames.push(currentPerson.lastName);
            ages.push(currentPerson.age);
            return (firstNames,lastNames,ages);
        }
    }
}