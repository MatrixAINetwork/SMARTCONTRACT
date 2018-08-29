/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

/**
 * @title A contract that maintains a hashtable of EOS addresses associated with Ethereum addresses
 * @author Sagewise
 */
contract EOSVerify {
  event LogRegisterEOSAddress(address indexed _from, string _eosAddress);
  mapping(address => string) public eosAddressBook;

  /**
   * @notice Associate a string, which represents an EOS address, to the Ethereum address of the entity interacting with the contract
   * @param eosAddress A string value that represents an EOS address
   */
  function registerEOSAddress(string eosAddress) public {
    assert(bytes(eosAddress).length <= 64);

    eosAddressBook[msg.sender] = eosAddress;

    emit LogRegisterEOSAddress(msg.sender, eosAddress);
  }
}