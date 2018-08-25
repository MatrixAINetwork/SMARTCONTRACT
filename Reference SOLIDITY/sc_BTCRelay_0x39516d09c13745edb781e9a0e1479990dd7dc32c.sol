/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract BTCRelay {

  bool initialized = false;

  struct Header {
    uint32 version;
    bytes32 prevBlock;
    bytes32 merkleRoot;
    uint32 time;
    uint32 nBits;
    uint32 nonce;
    uint32 height;
  }

  mapping(bytes32 => Header) public blockHeaders; // Maps block hashes to headers

  event partialFlip(bytes32 data);
  // storeBlockHeader(header) pareses a length 80 bytes and stores the resulting
  // Header struct in the blockHeaders mapping, where the index is the blockhash

  function getHeader(bytes32 data) public returns (Header) {
      return blockHeaders[data];
  }

  // computeMerkle(txHash, txIndex, siblings) computes the Merkle root of the
  // block that the transaction corresponding to txHash was included in.
  function computeMerkle(bytes32 txHash, uint txIndex, bytes32[] siblings) public pure returns (bytes32 merkleRoot){
    merkleRoot = txHash;
    uint256 proofLen = siblings.length;

    uint256 i = 0;
    while (i < proofLen){
      bytes32 proofHex = siblings[i];

      uint256 sideOfSibling = txIndex % 2;

      if (sideOfSibling == 1) {
        merkleRoot = flip32(sha256(sha256(flip32(proofHex), flip32(merkleRoot))));
      }
      else{
        merkleRoot = flip32(sha256(sha256(flip32(merkleRoot), flip32(proofHex))));
      }

      txIndex = txIndex / 2;
      i = i + 1;
    }

    return merkleRoot;
  }

  // Computes the target from the compressed "bits" form
  // https://bitcoin.org/en/developer-reference#target-nbits
  function targetFromBits(uint32 nBits) public pure returns (bytes32 target){
    uint exp = uint(nBits) >> 24;
    uint c = uint(nBits) & 0xffffff;
    bytes32 result = bytes32(c * 2**(8*(exp - 3)));

    return result;}

  // Converts the input to the opposite endianness
  function flip32(bytes32 le) public pure returns (bytes32 be) {
      be = 0x0;
      for (uint256 i = 0; i < 32; i++){
        be >>= 8;
        be |= le[i];
      }
  }

  // BTC-style reversed double sha256
  function dblShaFlip(bytes data) public returns (bytes32){
      return flip32(sha256(sha256(data)));
  }

  // get parent of block
  function getPrevBlock(bytes header) returns (bytes32) {
    bytes32 tmp;
    assembly {
      tmp := mload(add(header, 36))
    }

    return flip32(bytes32(tmp));
  }


  function getTimestamp(bytes header) public constant returns (uint){
    uint tmp;
    assembly {
      tmp := mload(add(header, 100))
    }
    return uint(flip32(bytes32(tmp)) & 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF);
  }

  function getVersionNo(bytes header) public constant returns (uint){
    uint tmp;
    assembly {
      tmp := mload(add(header, 32))
    }
    return uint(flip32(bytes32(tmp)) & 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF);
  }

  function getNbits(bytes header) public constant returns (uint){
    uint tmp;
    assembly {
      tmp := mload(add(header, 104))
    }
    return uint(flip32(bytes32(tmp)) & 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF);
  }

  function getMerkleRoot(bytes header) public constant returns (uint){
    uint tmp;
    assembly {
      tmp := mload(add(header, 68))
    }
    return uint(flip32(bytes32(tmp)));
  }

  function getNonce(bytes header) public constant returns(uint){
    uint tmp;
    assembly{
      tmp := mload(add(header, 108))
    }
    return uint(flip32(bytes32(tmp)) & 0x00000000000000000000000000000000000000000000000000000000FFFFFFFF);
  }

  function initChain(bytes header, uint32 height) public {
    uint32 bits = uint32(getNbits(header));
    bytes32 target = targetFromBits(bits);
    bytes32 hash = dblShaFlip(header);
    if (hash <= target){
        uint32 nonce = uint32(getNonce(header));
        bytes32 merkleRoot = bytes32(getMerkleRoot(header));
        uint32 timestamp = uint32(getTimestamp(header));
        uint32 version = uint32(getVersionNo(header));
        bytes32 prevBlock = getPrevBlock(header);
        blockHeaders[hash] = Header(version, prevBlock, merkleRoot, timestamp, bits, nonce, height);
        initialized = true;
    }
  }

  function storeBlockHeader(bytes header) public returns (uint256){
      bytes32 prevBlock = flip32(getPrevBlock(header));
      Header storage prevBlockHeader = blockHeaders[prevBlock];
      if (prevBlockHeader.version != 0){
        bytes32 hash = dblShaFlip(header);
        if (blockHeaders[hash].version == 0){
            uint32 bits = uint32(getNbits(header));
            bytes32 target = targetFromBits(bits);
            if (hash <= target){
                uint32 nonce = uint32(getNonce(header));
                bytes32 merkleRoot = bytes32(getMerkleRoot(header));
                uint32 timestamp = uint32(getTimestamp(header));
                uint32 version = uint32(getVersionNo(header));
                uint32 height = prevBlockHeader.height + 1;
                blockHeaders[hash] = Header(version, prevBlock, merkleRoot, timestamp, bits, nonce, height);
                return height;
            }
        }
        return 0;
      }
      return 0;
  }

}