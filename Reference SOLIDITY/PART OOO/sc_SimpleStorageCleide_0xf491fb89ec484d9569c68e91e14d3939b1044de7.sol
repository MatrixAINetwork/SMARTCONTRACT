/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
//Tell the Solidity compiler what version to use
pragma solidity ^0.4.8;

//Declares a new contract
contract SimpleStorageCleide {
    //Storage. Persists in between transactions
    uint price;

    //Allows the unsigned integer stored to be changed
    function setCleide (uint newValue) 
    public
    {
        price = newValue;
    }
    
    //Returns the currently stored unsigned integer
    function getCleide() 
    public 
    view
    returns (uint) 
    {
        return price;
    }
}