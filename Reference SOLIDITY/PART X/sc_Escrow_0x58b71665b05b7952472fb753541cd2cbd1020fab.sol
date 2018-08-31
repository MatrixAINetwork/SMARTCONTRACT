/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract Escrow {
    address buyer;
    address seller;
    address arbiter;
    
    function Escrow() payable {
        seller = 0x1db3439a222c519ab44bb1144fc28167b4fa6ee6;
        arbiter = 0xd8da6bf26964af9d7eed9e03e53415d37aa96045;
        buyer = msg.sender;
    }
    
    function finalize() {
        if (msg.sender == buyer || msg.sender == arbiter)
            seller.send(msg.value);
    }
    
    function refund() {
        if (msg.sender == seller || msg.sender == arbiter)
            buyer.send(msg.value);
    }
}