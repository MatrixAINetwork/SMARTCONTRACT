/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract BCFSafe {
    /* Time Deposit and Return Funds */
    address owner;
    uint lockTime;
    function TimeDeposit() {
 owner = msg.sender;
 lockTime = now + 30 minutes;
    }
    function returnMyMoney(uint amount){
        if (msg.sender==owner && now > lockTime) {
            owner.send(amount);
        }
    }
}