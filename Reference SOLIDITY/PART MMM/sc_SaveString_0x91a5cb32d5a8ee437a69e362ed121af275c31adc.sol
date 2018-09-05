/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract SaveString{
    constructor() public {
    }
    mapping (uint=>string) data;
    function setStr(uint key, string value) public {
        data[key] = value;
    }
    function getStr(uint key) public constant returns(string){
        return data[key];
    }
}