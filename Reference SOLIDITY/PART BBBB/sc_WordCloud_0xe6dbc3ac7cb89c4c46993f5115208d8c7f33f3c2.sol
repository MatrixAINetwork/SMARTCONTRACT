/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

// Add your message to the word cloud: https://jamespic.github.io/ether-wordcloud

contract WordCloud {
  address guyWhoGetsPaid = msg.sender;
  mapping (string => uint) wordSizes;
  event WordSizeIncreased(string word, uint newSize);

  function increaseWordSize(string word) external payable {
    wordSizes[word] += msg.value;
    guyWhoGetsPaid.transfer(this.balance);
    WordSizeIncreased(word, wordSizes[word]);
  }

  function wordSize(string word) external view returns (uint) {
    return wordSizes[word];
  }
}