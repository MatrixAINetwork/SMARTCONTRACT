/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;



contract Owned {
    address owner;

    modifier onlyOwner() {
        if (msg.sender == owner) {
            _;
        }
    }

    function Owned() {
        owner = msg.sender;
    }
}

contract Mortal is Owned {

    function kill() onlyOwner {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }

}

contract CVExtender {

    function getDescription() constant returns (string);
    function getTitle() constant returns (string);
    function getAuthor() constant returns (string, string);
    function getAddress() constant returns (string);

    function elementsAreSet() constant returns (bool) {
        //Normally I'd do whitelisting, but for sake of simplicity, lets do blacklisting

        bytes memory tempEmptyStringTest = bytes(getDescription());
        if(tempEmptyStringTest.length == 0) {
            return false;
        }
        tempEmptyStringTest = bytes(getTitle());
        if(tempEmptyStringTest.length == 0) {
            return false;
        }
        var (testString1, testString2) = getAuthor();

        tempEmptyStringTest = bytes(testString1);
        if(tempEmptyStringTest.length == 0) {
            return false;
        }
        tempEmptyStringTest = bytes(testString2);
        if(tempEmptyStringTest.length == 0) {
            return false;
        }
        tempEmptyStringTest = bytes(getAddress());
        if(tempEmptyStringTest.length == 0) {
            return false;
        }
        return true;
    }
}


contract CVAlejandro is Mortal, CVExtender {

    string[] _experience;
    string[] _education;
    string[] _language;

    string _name;
    string _summary;
    string _email;
    string _link;
    string _description;
    string _title;

    // Social
    string _linkedIn;
    string _twitter;
    string _gitHub;



    function CVAlejandro() {

        // Main
        _name = "Alejandro Saucedo";
        _email = "