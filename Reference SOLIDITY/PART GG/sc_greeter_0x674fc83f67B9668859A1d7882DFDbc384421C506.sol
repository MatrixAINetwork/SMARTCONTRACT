/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract greeter {

    address owner;
    string message;

    function greeter(string _message) public {
        owner = msg.sender;
        message = _message;
    }

    function say() constant returns (string) {
        return message;
    }

    function die() {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}