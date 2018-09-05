/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;
  
contract SaveData {
    mapping (uint => string) sign;
    address public owner;
    event SetString(uint key,string types);
    function SaveData() public {
        owner = msg.sender;
    }
    function setstring(uint key,string md5) public returns(string){
        sign[key]=md5;
        return sign[key];
    }

    function getString(uint key) public view returns(string){
        return sign[key];
    }
}