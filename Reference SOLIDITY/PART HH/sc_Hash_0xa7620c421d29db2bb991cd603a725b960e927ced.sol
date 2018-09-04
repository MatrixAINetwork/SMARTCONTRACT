/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract Hash {
    // storage vars
    address owner;

    // constructor
    function Hash() public {
        owner = msg.sender;
    }

    // fallback: unmatched transactions will be returned
    function() internal {
        revert();
    }

    function hash(string dataString) public pure returns(bytes32){
        return(keccak256(dataString));
    }

    function selfDestruct() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}