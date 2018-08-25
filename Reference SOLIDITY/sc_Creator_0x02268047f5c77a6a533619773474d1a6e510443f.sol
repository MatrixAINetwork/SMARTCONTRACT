/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Creator {
    function newContract(bytes data) public returns (address) {
        address theNewContract;
        uint s = data.length;

        assembly {
            calldatacopy(mload(0x40), 68, s)
            theNewContract := create(callvalue, mload(0x40), s)
        }

        return theNewContract;
    }
}