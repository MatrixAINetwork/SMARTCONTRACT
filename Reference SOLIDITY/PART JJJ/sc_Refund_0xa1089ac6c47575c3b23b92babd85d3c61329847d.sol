/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;
contract Refund {
    address owner = 0x0;
    function Refund() public payable {
        // 将部署合约的地址作为合约拥有者
        owner = msg.sender;
    }
    

}