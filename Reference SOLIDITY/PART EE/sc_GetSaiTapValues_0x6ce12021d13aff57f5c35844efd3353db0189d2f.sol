/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract SaiTap {
    function s2s() public returns (uint);
    function bid(uint wad) public returns (uint);
    function ask(uint wad) public returns (uint);
}

contract GetSaiTapValues {
    SaiTap public saiTap = SaiTap(0xBda109309f9FafA6Dd6A9CB9f1Df4085B27Ee8eF);

    uint public wad;
    uint public s2s;
    uint public bid;
    uint public ask;

    function update(uint _wad) public {
        wad = _wad;
        s2s = saiTap.s2s();
        bid = saiTap.bid(_wad);
        ask = saiTap.ask(_wad);
    }
}