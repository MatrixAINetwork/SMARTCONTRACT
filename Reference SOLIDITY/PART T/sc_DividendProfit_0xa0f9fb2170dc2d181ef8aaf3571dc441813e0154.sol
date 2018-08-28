/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// TESTING CONTRACT

contract DividendProfit {

address public deployer;
address public dividendAddr;


modifier execute {
    if (msg.sender == deployer)
        _
}


function DividendProfit() {
    deployer = msg.sender;
    dividendAddr = deployer;
}


function() {
    if (this.balance > 69 finney) {
        dividendAddr.send(this.balance - 20 finney);
    }
}


function SetAddr (address _newAddr) execute {
    dividendAddr = _newAddr;
}


function TestContract() execute {
    deployer.send(this.balance);
}



}