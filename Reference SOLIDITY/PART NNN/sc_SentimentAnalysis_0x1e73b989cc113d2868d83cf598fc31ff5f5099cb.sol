/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        owner = msg.sender;
    }

    address public newOwner;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    function changeOwner(address _newOwner) onlyOwner {
        if(msg.sender == owner) {
            owner = _newOwner;
        }
    }
}


/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}


contract SentimentAnalysis is Owned {
  using SafeMath for uint256;
  
  mapping (address => Reputation) reputations;
  
  event ReputationUpdated(string reputation, uint correct, uint incorrect, string lastUpdateDate, string lastFormulaApplied, address user);
  
  struct Reputation {
    string reputation;
    uint correct;
    uint incorrect;
    string lastUpdateDate;
    string lastFormulaApplied;
  }

  function ()  payable {
    revert();
  }

  /// @dev Returns the reputation for the provided user.
  /// @param user The user address to retrieve reputation for.
  function getReputation(
    address user
  ) 
    public
    constant
    returns (string, uint, uint, string, string)
  {
    return (reputations[user].reputation, reputations[user].correct, reputations[user].incorrect, reputations[user].lastUpdateDate, reputations[user].lastFormulaApplied);
  }

  /// @dev Updates the reputation of the provided user
  /// @param reputation The reputation to update
  /// @param correct The number of correct sentiments provided
  /// @param incorrect The number of incorrect sentiments provided
  /// @param date The date the reputation is updated
  /// @param formulaApplied The formula applied to generate the provided reputation
  /// @param user The address of the user whose reputation is updated
  function updateReputation(
    string reputation,
    uint correct,
    uint incorrect,
    string date,
    string formulaApplied,
    address user
  ) 
    onlyOwner
    public
  {
    reputations[user].reputation = reputation;
    reputations[user].correct = correct;
    reputations[user].incorrect = incorrect;
    reputations[user].lastUpdateDate = date;
    reputations[user].lastFormulaApplied = formulaApplied;
    ReputationUpdated(reputations[user].reputation, reputations[user].correct, reputations[user].incorrect, reputations[user].lastUpdateDate, reputations[user].lastFormulaApplied, user);
  }
}