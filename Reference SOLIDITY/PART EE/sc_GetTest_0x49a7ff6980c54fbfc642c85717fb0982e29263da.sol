/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract GetTest{
    uint a = 1;
    string b = "b";
    address c;
    constructor() public {
        c = msg.sender;
    }
    function getOne() public constant returns(uint) {
        return a;
    }
    function getTwo() public constant returns(uint, string){
        return (a, b);
    }
    function getThree() public constant returns (uint, string, address){
        return (a, b, c);
    }
}