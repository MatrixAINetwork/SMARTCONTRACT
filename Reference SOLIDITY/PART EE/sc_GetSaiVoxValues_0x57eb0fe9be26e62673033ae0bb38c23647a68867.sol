/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract SaiVox {
    function par() public returns (uint);
    function way() public returns (uint);
}

contract GetSaiVoxValues {
    SaiVox public saiVox = SaiVox(0x9B0F70Df76165442ca6092939132bBAEA77f2d7A);

    uint public par;
    uint public way;

    function update() public {
        par = saiVox.par();
        way = saiVox.way();
    }
}