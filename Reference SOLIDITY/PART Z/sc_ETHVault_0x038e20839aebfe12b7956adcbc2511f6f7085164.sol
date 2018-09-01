/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract Owned {
    address public Owner = msg.sender;
    modifier onlyOwner { if (msg.sender == Owner) _; }
}

contract ETHVault is Owned {
    address public Owner;
    mapping (address => uint) public Deposits;

    event Deposit(uint amount);
    event Withdraw(uint amount);
    
    function Vault() payable {
        Owner = msg.sender;
        deposit();
    }
    
    function() payable {
        revert();
    }

    function deposit() payable {
        if (msg.value >= 1 ether)
            if (Deposits[msg.sender] + msg.value >= Deposits[msg.sender]) {
                Deposits[msg.sender] += msg.value;
                Deposit(msg.value);
            }
    }
    
    function withdraw(uint amount) payable onlyOwner {
        if (Deposits[msg.sender] > 0 && amount <= Deposits[msg.sender]) {
            msg.sender.transfer(amount);
            Withdraw(amount);
        }
    }
    
    function kill() payable onlyOwner {
        if (this.balance == 0)
            selfdestruct(msg.sender);
    }
}