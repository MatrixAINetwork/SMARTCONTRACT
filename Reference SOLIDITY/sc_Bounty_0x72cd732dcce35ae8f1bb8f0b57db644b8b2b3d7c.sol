/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract Bounty {
    struct Talk {
        uint balance;
        mapping(address => uint) witnessedPresenter;
        mapping(address => bool) witnessedBy;
    }
    mapping(bytes32 => Talk) public talks;

    function add(bytes32 title) payable {
        talks[title].balance += msg.value;
    }

    function witness(bytes32 title, address presenter) onlywitness returns (uint) {
        if (talks[title].witnessedBy[msg.sender]) {
            revert();
        }
        talks[title].witnessedBy[msg.sender] = true;
        talks[title].witnessedPresenter[presenter] += 1;
        return talks[title].witnessedPresenter[presenter];
    }

    modifier onlywitness {
        require(msg.sender == 0xa4e15612af5434f05b22405c574d015e54a5e13e);
        _;
    }

    function claim(bytes32 title) {
        if (talks[title].witnessedPresenter[msg.sender] < 2) {
            revert();
        }
        uint amount = talks[title].balance;
        talks[title].balance = 0;
        msg.sender.transfer(amount);
    }
}