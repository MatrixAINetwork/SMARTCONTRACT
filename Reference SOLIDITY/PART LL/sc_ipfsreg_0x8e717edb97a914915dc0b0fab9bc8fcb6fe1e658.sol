/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract PublicResolver {
    function text(bytes32 node, string key) constant returns (string ret) {
    }
}
contract ipfsreg {

    PublicResolver public publicResolver = PublicResolver(0x5FfC014343cd971B7eb70732021E26C35B744cc4);
    
    function IPFShash(string _name) public view returns (string) {
        return publicResolver.text(namehash(_name), "ipfs");
    }
    function tinyIPFShash(string _name) public view returns (string) {
        return publicResolver.text(namehash(_name), "tinyipfs");
    }
    
    function namehash(string _name) public pure returns (bytes32 node) {
        node = 0x0000000000000000000000000000000000000000000000000000000000000000;
        node = keccak256(
        abi.encodePacked(node, keccak256(abi.encodePacked('eth')))
        );
        node = keccak256(
        abi.encodePacked(node, keccak256(abi.encodePacked(_name)))
        );
    }

}