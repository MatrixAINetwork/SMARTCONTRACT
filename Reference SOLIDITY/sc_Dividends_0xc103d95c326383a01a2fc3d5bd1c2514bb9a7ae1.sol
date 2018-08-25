/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

// Dev fee payout contract + dividend options 
// EtherGuy DApp fee will be stored here 
// Buying any token gives right to claim part of development dividends.
// It is suggested you do withdraw once in a while. If someone still finds an attack after this fixed contrat 
// they are unable the steal any of your withdrawn eth. Withdrawing does not sell your tokens!
// UI: etherguy.surge.sh/dividend.html
// Made by EtherGuy, 