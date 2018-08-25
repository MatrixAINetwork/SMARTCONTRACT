/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract BTCRelay {
    function getBlockHeader(int blockHash) returns (bytes32[3]);
    function getLastBlockHeight() returns (int);
    function getBlockchainHead() returns (int);
    function getFeeAmount(int blockHash) returns (int);
}


contract BlockhashFetch {

  BTCRelay relay;
  mapping(int => int) blockHashes; //Cache blockhashes

  function BlockhashFetch(address _relay){
    relay = BTCRelay(_relay);
  }


  function getPrevHash(int currentHash) returns (int parentHash, uint fee){

    if(blockHashes[currentHash] != 0) return (blockHashes[currentHash], 0);

    fee = uint(relay.getFeeAmount(currentHash));

    if(fee > this.balance) return (0,0);
    bytes32 head = relay.getBlockHeader.value(fee)(currentHash)[2];
    bytes32 temp;

    assembly {
        let x := mload(0x40)
        mstore(x,head)
        temp := mload(add(x,0x04))
    }

    for(int i; i<32; i++){
      parentHash = parentHash | int(temp[uint(i)]) * (0x100**i);
    }

    blockHashes[currentHash] = int(parentHash);
  }

  function getBlockHash (int blockHeight) returns (bytes32, uint totalFee){
    int highestBlock = relay.getLastBlockHeight();
    int currentHash = relay.getBlockchainHead();
    if(blockHeight > highestBlock) return (0x0, 0);

    for(int i; i < highestBlock - blockHeight; i++){
      if(currentHash == 0) return (0x0,totalFee);
      uint fee;
      (currentHash, fee) = getPrevHash(currentHash);
      totalFee += fee;
    }

    return (bytes32(currentHash), totalFee);
  }

}