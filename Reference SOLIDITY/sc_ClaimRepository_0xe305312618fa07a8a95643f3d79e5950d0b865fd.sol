/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/* first version of the FundRequest ClaimRepository */

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {
  /// @dev `owner` is the only address that can call a function with this
  /// modifier
  modifier onlyOwner { require (msg.sender == owner); _; }

  address public owner;

  /// @notice The Constructor assigns the message sender to be `owner`
  function Owned() public { owner = msg.sender;}

  /// @notice `owner` can step down and assign some other address to this role
  /// @param _newOwner The address of the new owner. 0x0 can be used to create
  ///  an unowned neutral vault, however that cannot be undone
  function changeOwner(address _newOwner) public onlyOwner {
    owner = _newOwner;
  }
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ClaimRepository is Owned {
    using SafeMath for uint256;

    mapping (bytes32 => mapping (string => Claim)) claims;

    mapping(address => bool) public callers;

    uint256 public totalBalanceClaimed;
    uint256 public totalClaims;


    //modifiers
    modifier onlyCaller {
        require(callers[msg.sender]);
        _;
    }

    struct Claim {
        address solverAddress;
        string solver;
        uint256 requestBalance;
    }

    function ClaimRepository() {
        //constructor
    }

    function addClaim(address _solverAddress, bytes32 _platform, string _platformId, string _solver, uint256 _requestBalance) public onlyCaller returns (bool) {
        claims[_platform][_platformId].solver = _solver;
        claims[_platform][_platformId].solverAddress = _solverAddress;
        claims[_platform][_platformId].requestBalance = _requestBalance;
        totalBalanceClaimed = totalBalanceClaimed.add(_requestBalance);
        totalClaims = totalClaims.add(1);
        return true;
    }

    //management of the repositories
    function updateCaller(address _caller, bool allowed) public onlyOwner {
        callers[_caller] = allowed;
    }
}