/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;
contract KnowItAll {
    address owner;
    function KnowItAll() 
        public {
        owner = msg.sender;
        // I knew my address was going to be :
        address precalculatedAddress = 0xce08e97536b992d8da761e95db4eff0c649fce93;
    }
    function calculateAddress(uint8 _nonce) 
    // works only for nonces between 1 and 127 (or 255 maybe? must investigate RLP in more detail)
    //calculates address of any potential brother (other contract created by same address)
        public 
        constant 
        returns (address) {
        require(msg.sender == owner);
        return address(keccak256(0xd6, 0x94, 0x6B1e0fb8c127B29747a186AEC66973A8CE2458ee, _nonce));
    }
}