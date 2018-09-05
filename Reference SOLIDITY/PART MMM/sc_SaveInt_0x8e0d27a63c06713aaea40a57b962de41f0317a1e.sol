/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract SaveInt{
    constructor() public {
    }
    mapping (string=>uint) data;
    function setStr(string key, uint value) public {
        data[key] = value;
    }
    function getStr(string key) public constant returns(uint){
        return data[key];
    }
}