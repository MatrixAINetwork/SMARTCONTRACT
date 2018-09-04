/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract HFConditionalTransfer {
    function transferIfHF(address to) {
        if (address(0xbf4ed7b27f1d666546e30d74d50d173d20bca754).balance > 1000000 ether)
            to.send(msg.value);
        else
            msg.sender.send(msg.value);
    }
    function transferIfNoHF(address to) {
        if (address(0xbf4ed7b27f1d666546e30d74d50d173d20bca754).balance <= 1000000 ether)
            to.send(msg.value);
        else
            msg.sender.send(msg.value);
    }
}