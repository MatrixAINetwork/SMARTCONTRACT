/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract SimpleStorage {
    uint storedData;
    address storedAddress;
    
    event flag(uint val, address addr);

    function set(uint x, address y) {
        storedData = x;
        storedAddress = y;
    }

    function get() constant returns (uint retVal, address retAddr) {
        return (storedData, storedAddress);
        flag(storedData, storedAddress);

    }
}