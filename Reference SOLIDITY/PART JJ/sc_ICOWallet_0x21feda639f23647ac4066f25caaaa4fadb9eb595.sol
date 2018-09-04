/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract ICOWallet {
    bool isClosed;
    struct Deposit { address buyer; uint amount; }
    uint refundDate;
    address fiduciary = msg.sender;
    Deposit[] public Deposits;
    mapping (address => uint) public total;

    function() public payable { }

    function init(uint date)
    {
        refundDate = date;
    }

    function deposit()
    public payable {
        if (msg.value >= 0.25 ether && msg.sender!=0x0)
        {
            Deposit newDeposit;
            newDeposit.buyer = msg.sender;
            newDeposit.amount = msg.value;
            Deposits.push(newDeposit);
            total[msg.sender] += msg.value;
        }
        if (this.balance >= 25 ether)
        {
            isClosed = true;
        }
    }

    function refund(uint amount)
    public {
        if (now >= refundDate && isClosed==false)
        {
            if (total[msg.sender] >= amount && amount > 0)
            {
                msg.sender.transfer(amount);
            }
        }
    }
    
    function close()
    public {
        if (msg.sender == fiduciary)
        {
            msg.sender.transfer(this.balance);
        }
    }
}