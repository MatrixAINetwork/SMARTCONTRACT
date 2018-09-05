/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// The contract that allows DTH that held DAO at a contract address to
// authorize an enduser-account to do the withdrawal for them
//
// License: BSD3

contract WHAuthorizeAddress {

    modifier noEther() {if (msg.value > 0) throw; _}

    event Authorize(address indexed dthContract, address indexed authorizedAddress);

    /// @notice Authorizes a regular account to act on behalf of a contract
    /// @param _authorizedAddress The address of the regular account that will
    ///                           act on behalf of the msg.sender contract.
    function authorizeAddress(address _authorizedAddress) noEther() {

        // sender must be a contract and _authorizedAddress must be a user account
        if  (getCodeSize(msg.sender) == 0 || getCodeSize(_authorizedAddress) > 0) {
            throw;
        }

        Authorize(msg.sender, _authorizedAddress);
    }

    function() {
        throw;
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }
}