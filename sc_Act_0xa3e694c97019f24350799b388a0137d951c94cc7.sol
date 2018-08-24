#These solidity codes have been obtained from Etherscan for extracting the smartcontract related info. The data will be used by MATRIX AI team as the reference basis for MATRIX model analysis, extraction of contract semantics, as well as AI based data analysis, etc.
pragma solidity ^0.4.21;


contract Act {

    bytes32 public symbol;
    bytes32 public  name;
    string public act = "QmbQepVoQdawBcz8A98nApTH5SaFGHqK6pTKi2eYK3DvAm";

    function Act() public {
        symbol = "ACT";
        name = "ActoOfIndependenceOfLithuania";
    }

    function getAct() public view returns (string) {
        return act;
    }

}