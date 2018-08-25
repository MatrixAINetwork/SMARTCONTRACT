/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.22;


contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract DiscordPool is Ownable {
    uint public raised;
    bool public active = true;
    mapping(address => uint) public balances;
    event Deposit(address indexed beneficiary, uint value);
    event Withdraw(address indexed beneficiary, uint value);

    function () external payable whenActive {
        raised += msg.value;
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    function finalize() external onlyOwner {
        active = false;
    }
    
    function withdraw(address beneficiary) external onlyOwner whenEnded {
        uint balance = address(this).balance;
        beneficiary.transfer(balance);
        emit Withdraw(beneficiary, balance);
    }

    modifier whenEnded() {
        require(!active);
        _;
    }
    
    modifier whenActive() {
        require(active);
        _;
    }
}