/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract Contrat {

    address owner;

    event Sent(string hash);

    constructor() public {
        owner = msg.sender;
    }

    modifier canAddHash() {
        bool isOwner = false;

        if (msg.sender == owner)
            isOwner = true;

        require(isOwner);
        _;
    }

    function addHash(string hashToAdd) canAddHash public {
        emit Sent(hashToAdd);
    }
}