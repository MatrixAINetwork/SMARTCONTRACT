//These solidity codes have been obtained from Etherscan for extracting the smartcontract related info. The data will be used by MATRIX AI team as the reference basis for MATRIX model analysis, extraction of contract semantics, as well as AI based data analysis, etc.
/**
* @title BurnABLE
* @dev ABLE burn contract.
*/
contract ABLEBurned {

    /**
    * @dev Function to contruct.
    */
    function () payable {
    }

    /**
    * @dev Function to Selfdestruct contruct.
    */
    function burnMe () {
        // Selfdestruct and send eth to self, 
        selfdestruct(address(this));
    }
}