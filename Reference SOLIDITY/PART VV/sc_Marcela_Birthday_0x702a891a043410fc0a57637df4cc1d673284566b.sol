/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

contract Marcela_Birthday {


string public name ;

string public date;

string public hour;

string public local;


function Marcela_Birthday(string _name, string _date, string _hour ,string _local){
name = _name;
date = _date;
hour = _hour;
local = _local;
}


function getinfo () public constant returns (string,string,string,string) {
    
 return(name,date,hour,local);
}
}