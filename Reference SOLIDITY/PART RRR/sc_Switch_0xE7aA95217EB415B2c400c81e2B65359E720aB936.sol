/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Switch {
    address constant theWithdraw = 0xbf4ed7b27f1d666546e30d74d50d173d20bca754;
    function Switch() {
        forked = theWithdraw.balance > 10000 ether;
    }
    
    function transferringETC(address to) {
        if (forked)
            throw;
        if (!to.send(msg.value))
            throw;
    }

    function transferringETH(address to) {
        if (!forked)
            throw;
        if (!to.send(msg.value))
            throw;
    }
    
    bool public forked;
}