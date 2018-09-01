/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
//! FeeRegistrar contract.
//! By Parity Technologies, 2017.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.16;

// From Owned.sol
contract Owned {
  /// STORAGE
  address public owner = msg.sender;

  /// EVENTS
  event NewOwner(address indexed old, address indexed current);

  /// MODIFIERS
  modifier only_owner { require (msg.sender == owner); _; }

  /// RESTRICTED PUBLIC METHODS
  function setOwner(address _new) public only_owner { NewOwner(owner, _new); owner = _new; }
}

/// @title Delegated Contract
/// @notice This contract can be used to have a a system of delegates
/// who can be authorized to execute certain methods. A (super-)owner
/// is set, who can modify the delegates.
contract Delegated is Owned {
  /// STORAGE
  mapping (address => bool) delegates;

  /// MODIFIERS
  modifier only_delegate { require (msg.sender == owner || delegates[msg.sender]); _; }

  /// PUBLIC METHODS
  function delegate(address who) public constant returns (bool) { return who == owner || delegates[who]; }

  /// RESTRICTED PUBLIC METHODS
  function addDelegate(address _new) public only_owner { delegates[_new] = true; }
  function removeDelegate(address _old) public only_owner { delete delegates[_old]; }
}

/// @title Fee Registrar
/// @author Nicolas Gotchac <