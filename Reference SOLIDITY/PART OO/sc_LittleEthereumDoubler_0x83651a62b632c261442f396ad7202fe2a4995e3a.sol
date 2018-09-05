/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract LittleEthereumDoubler {
//--------------------------------------------------USERS-----------------------------------------------------------
    struct User {
        address addr;
        uint paidOut;
        uint payoutLeft;
    }
    User[] private users;
    uint private index;
//--------------------------------------------------DEPLOYMENT AND FEES---------------------------------------------
    address private feeAddress;

    modifier execute { if (feeAddress == tx.origin) _ }
    
    function NewFeeAddress(address newFeeAddress) execute {
        if (msg.value != 0) tx.origin.send(msg.value);
        feeAddress = newFeeAddress;
    }
    
    function LittleEthereumDoubler() {
        feeAddress = tx.origin;
    }
//--------------------------------------------------CONTRACT--------------------------------------------------------
    function() {
        Start();
    }
    
    function Start() internal {
        uint a = msg.value;     // a = amount
        a = DepositLimit(a);    // trim if too much, throw is too little
        Fees(a);                // 2,5% fees goes to the fee address
        NewDeposit(a);          // put user in the usersdatabase
        Payout();               // pay out who is in the index
    }
    
    function DepositLimit(uint a) internal returns (uint x){
        x = a;
        if (x < 100 finney) throw;
        if (x > 50 ether) {
            x = 50 ether;
            tx.origin.send(a - x);
        }
    }
    
    function Fees(uint a) internal {
        feeAddress.send(a * 25 / 1000);
    }
    
    function NewDeposit(uint a) internal {
        users.length++;
        users[users.length - 1].addr = tx.origin;
        users[users.length - 1].payoutLeft = a * 2;
    }
    
    function Payout() internal {
        while (this.balance != 0) {
            if (users[index].payoutLeft > this.balance) {
                users[index].payoutLeft -= this.balance;
                users[index].paidOut += this.balance;
                users[index].addr.send(this.balance);
            }
            else {
                users[index].paidOut += users[index].payoutLeft;
                users[index].addr.send(users[index].payoutLeft);
                delete users[index].payoutLeft;
                index++;
            }
        }
    }
//--------------------------------------------------MIST GUI--------------------------------------------------------
    function UserDatabase(uint id) constant returns(address Address, uint Payout, uint PaidOut, uint PayoutLeft, string info) {
        Address = users[id].addr;
        PaidOut = users[id].paidOut / 100 finney;
        PayoutLeft = users[id].payoutLeft / 100 finney;
        Payout = (users[id].paidOut + users[id].payoutLeft) / 100 finney;
        info = 'values are shown in a denomination of 100 finneys ( 100 finney = 0.1 ether = minimum input)';
    }
}