/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract SaiTub {
    function tab(bytes32 cup) public returns (uint);
    function rap(bytes32 cup) public returns (uint);
    function din() public returns (uint);
    function chi() public returns (uint);
    function rhi() public returns (uint);
}

contract GetSaiTubValues {
    SaiTub public saiTub = SaiTub(0x448a5065aeBB8E423F0896E6c5D525C040f59af3);

    bytes32 public cup;
    uint public tab;
    uint public rap;
    uint public din;
    uint public chi;
    uint public rhi;

    function updateTabRap(bytes32 _cup) public {
        cup = _cup;
        tab = saiTub.tab(_cup);
        rap = saiTub.rap(_cup);
    }

    function updateRest() public {
        din = saiTub.din();
        chi = saiTub.chi();
        rhi = saiTub.rhi();
    }
}