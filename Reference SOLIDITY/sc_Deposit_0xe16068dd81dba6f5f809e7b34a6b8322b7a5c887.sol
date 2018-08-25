/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

contract Deposit {

    address public owner;
    Withdraw[] public withdraws;

    // constructor
    function Deposit() public {
        owner = msg.sender;
    }

    // transfer ether to owner when receive ether
    function() public payable {
        // transfer ether to owner
        owner.transfer(msg.value);
        // create withdraw contract
        withdraws.push(new Withdraw(msg.sender));
    }
}

contract Withdraw {

    address public owner;

    // constructor
    function Withdraw(address _owner) public {
        owner = _owner;
    }

}