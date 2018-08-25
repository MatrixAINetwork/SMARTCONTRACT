/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract check {
    function add(address _add, uint _req) {
        _add.callcode(bytes4(keccak256("changeRequirement(uint256)")), _req);
    }
}