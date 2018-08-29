/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/**
 * @title ECVerify
 * @dev Singature Verifier 
 * @author Dinesh
 */
contract ECVerify  { 
    
    /**
     * The signature format is a compact form of: {bytes32 r}{bytes32 s}{uint8 v} 
     * Compact means, uint8 is not padded to 32 bytes.
     * 
     * @dev Function to Recover signer address from a message by using his signature
     * @param _msgHash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param v singnature type 27/28, 0/1
     * @param r signature section
     * @param s Signtaure salt
     * 
     */
    function ecrecovery(bytes32 _msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (address) { 
        // albeit non-transactional signatures are not specified by the YP, one would expect it
        // to match the YP range of [27, 28].  geth uses [0, 1] and some clients have followed.
        // So, Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }
        // Check the version is valid or not
        if (v != 27 && v != 28) {
            return (address(0));
        } 
        
        if (v==27) {
            return ecrecover(_msgHash, v, r, s); 
        }
        else if (v==28) {
            //bytes memory _prefix = "\x19Ethereum Signed Message:\n32";
            //bytes32 _prefixedHash = keccak256(_prefix, _msgHash);
            return ecrecover(_msgHash, v, r, s); 
        } 
        return (address(0));
    }
    
    /**
     * @dev function to verify the signature with given input signer
     * @param _msgHash hashed messages
     * @param v singnature type 27/28, 0/1
     * @param r signature section
     * @param s Signtaure salt
     * @param _signer is the address the user who signed the message
     */
    function ecverify(bytes32 _msgHash, uint8 v, bytes32 r, bytes32 s, address _signer) public pure returns (bool) {
        if (_signer == address(0)) {
            return false;
        } 
        // extract the signers address and compare to the input
        return ecrecovery(_msgHash, v, r, s) == _signer;
    } 
}