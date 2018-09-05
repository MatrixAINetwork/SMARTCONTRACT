/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract Storage {
    address owner;
    bytes[6] public data;
    uint counter;
    constructor() public {
        owner = msg.sender;
    }
    function uploadData(bytes _data) public returns (uint){
        require(msg.sender == owner);
        data[counter] = _data;
        counter++;
    }
    function getData() public view returns (bytes){
        uint length;
        for(uint i = 0; i<6; i++) {
            length += data[i].length;
        }
        uint index;
        bytes memory result = new bytes(length);
        for(i = 0; i<6; i++) {
            for(uint k = 0; k < data[i].length; k++) {
                result[index + k] = data[i][k];
            }
            index += data[i].length;
        }
        return result;
    }
}