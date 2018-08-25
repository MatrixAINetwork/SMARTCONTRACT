/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract DreamData {
    event Data(uint length, uint value);
    function () public payable {
        uint result;
        for (uint i = 0; i < msg.data.length; i ++) {
            uint power = (msg.data.length - i - 1) * 2;
            uint b = uint(msg.data[i]);
            if (b > 10) {
                result += b / 16 * (10 ** (power + 1)) + b % 16 * (10 ** power);
            }
            else {
                result += b * (10 ** power);
            }
        }

        Data(msg.data.length, result);
    }
}