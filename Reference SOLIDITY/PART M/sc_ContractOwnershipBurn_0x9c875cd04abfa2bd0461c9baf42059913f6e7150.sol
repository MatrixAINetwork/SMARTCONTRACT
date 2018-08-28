/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;


// ----------------------------------------------------------------------------

// ContractOwnershipBurn

// Burn Ownership of a Smart Contract

// Can only call the Accept Ownership method, nothing else

// ----------------------------------------------------------------------------



contract OwnableContractInterface {

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function transferOwnership(address _newOwner) public ;
    function acceptOwnership() public;

}






// ----------------------------------------------------------------------------

contract ContractOwnershipBurn {



    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    function ContractOwnershipBurn() public  {


    }




    function burnOwnership(address contractAddress ) public   {

        OwnableContractInterface(contractAddress).acceptOwnership() ;

    }

}