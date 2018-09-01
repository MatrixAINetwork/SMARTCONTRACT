/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;


contract destroyer {
    function destroy() public {
        selfdestruct(msg.sender);
    }
}


contract fmp is destroyer {
    uint256 public sameVar;

    function test(uint256 _sameVar) external {
        sameVar = _sameVar;
    }

}