/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

contract LarsGeburtstagsgruss {
    address owner;
    string gruss = "Alles Gute zum Geburtstag Lars! - Sören";
    string datum = "19.08.2017";

    function LarsGeburtstagsgruss() { 
        owner = msg.sender;
    }
    
    function greet() constant returns (string) {
        return gruss;
    }
    
    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
    }
}