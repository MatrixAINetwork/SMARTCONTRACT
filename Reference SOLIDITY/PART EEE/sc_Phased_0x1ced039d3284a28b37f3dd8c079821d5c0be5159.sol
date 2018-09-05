/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/**
 * Copyright 2017 Icofunding S.L. (https://icofunding.com)
 * 
 */

// Interface
contract PriceModel {
  function getPrice(uint block) constant returns (uint);
}

/*
 * Different prices depending on the block
 */
contract Phased is PriceModel {
  uint[] prices;
  uint[] blocks;

  // prices: list of number of tokens (plus with decimals) to be bough by 1 ether
  // blocks: list of blocks when the price changes. Must be sorted
  // List of prices and list of blocks must have the same length
  // Maximum number of phases is 10
  function Phased(uint[] _prices, uint[] _blocks) {
    require(_prices.length == _blocks.length && _prices.length <= 10);
    require(isSorted(_blocks));

    prices = _prices;
    blocks = _blocks;
  }

  // Returns the price for a specific block
  function getPrice(uint _block) public constant returns (uint price) {
    // Binary search of the value in the array
    uint min = 0;
    uint max = blocks.length-1;
    while (max > min) {
      uint mid = (max + min + 1)/ 2;
      if (blocks[mid] <= _block) {
        min = mid;
      } else {
        max = mid-1;
      }
    }

    return prices[min];
  }

  // Checks if an uint array is sorted
  function isSorted(uint[] list) internal constant returns (bool sorted) {
    sorted = true;

    for(uint i = 1; i < list.length; i++) {
      if(list[i-1] > list[i])
        sorted = false;
    }
  }
}