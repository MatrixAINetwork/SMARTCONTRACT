/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract Storage {

    bytes32[] public data;
    bool readOnly;
    function uploadData(bytes32[] _data) public {
        require(readOnly != true);
        uint index = data.length;
        for(uint i = 0; i < _data.length; i++) {
            data.length++;
            data[index + i] = _data[i];
        }
    }
    function uploadFinish() {
        readOnly = true;
    }
    function getData() public view returns (bytes){
        bytes memory result = new bytes(data.length*0x20);
        for(uint i = 0; i < data.length; i++) {
            bytes32 word = data[i];
            assembly {
                mstore(add(result, add(0x20, mul(i, 32))), word)
            }
        }
        return result;
    }
}