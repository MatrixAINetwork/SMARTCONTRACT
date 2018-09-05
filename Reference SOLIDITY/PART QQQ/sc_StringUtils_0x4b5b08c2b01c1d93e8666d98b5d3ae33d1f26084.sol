/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;


library StringUtils {
    // Tests for uppercase characters in a given string
    function allLower(string memory _string) internal pure returns (bool) {
        bytes memory bytesString = bytes(_string);
        for (uint i = 0; i < bytesString.length; i++) {
            if ((bytesString[i] >= 65) && (bytesString[i] <= 90)) {  // Uppercase characters
                return false;
            }
        }
        return true;
    }
}