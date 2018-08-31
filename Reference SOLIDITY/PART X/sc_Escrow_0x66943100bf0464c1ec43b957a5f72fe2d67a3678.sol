/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Escrow {
    
    address seller;
    address buyer;
    address arbiter;
    
    function Escrow() {
        buyer = msg.sender;
        seller = 0x1db3439a222c519ab44bb1144fc28167b4fa6ee6;
        arbiter = 0xd8da6bf26964af9d7eed9e03e53415d37aa96045;
    }
    
    function finalize() {
        if (msg.sender != buyer && msg.sender != arbiter) throw;
        seller.send(this.balance);
    }
    
    function refund() {
        if (msg.sender != seller && msg.sender != arbiter) throw;
        buyer.send(this.balance);        
    }
}