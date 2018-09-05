/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Vow {

   struct Customer{
        uint ref;
        uint balance;
    }

    struct Vow {
        address vower;
        address oracle;
        uint funds;
        uint payoff;
        uint deposits;
        uint taar;
        mapping (address => Customer) customers;

    }
    mapping (uint => Vow) vows;
    
    
    uint numVows;
    uint public numRef;
    
    event depositFlag (address addr, uint amount, uint ref);
    event withdrawFlag (address addr, uint amount, uint balance);
    event newVowIdFlag (address addr, uint vowID, uint payoff);
    
    function newvow(uint payoff, address oracle) returns (uint vowID) {
        vowID = numVows++;
        Vow v = vows[vowID];
        v.vower = msg.sender;
        v.funds = msg.value;
        v.payoff= payoff;
        v.oracle = oracle;
        v.taar = 0;
        v.deposits = 0;
        newVowIdFlag(v.vower, vowID, v.payoff);
        return vowID;
    }
    
    function deposit(uint vowID) returns (bool res) {
       
        if (msg.value == 0){
            return false;
        }
        vows[vowID].deposits += msg.value;
        Customer c = vows[vowID].customers[msg.sender];
        c.balance += msg.value;
        c.ref = numRef++;
        depositFlag(msg.sender, c.balance, c.ref);
        return true;
    }

    function withdraw(uint amount, address beneficiary, uint vowID) returns (bool res) {
        
        if (msg.sender != vows[vowID].oracle)
            return false;
        if (wc.balance < amount || amount == 0)
            return false;
        Customer wc = vows[vowID].customers[beneficiary];
        wc.balance -= amount;
        beneficiary.send(amount);
        withdrawFlag(beneficiary, amount, wc.balance);
        return true;
    }
}