/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract I {
    function transfer(address to, uint256 val) public returns (bool);
    function balanceOf(address who) constant public returns (uint256);
}

contract GenTokenAddress {
    function GenTokenAddress(address token, address to) {
        I(token).transfer(to, I(token).balanceOf(address(this)));
    }
}