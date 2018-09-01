/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

contract Forgiveness {
    using SafeMath for uint256;
    
    uint constant forgivenessFee = 0.01 ether;
    uint public ownerBalance;
    address public owner;
    
    mapping (bytes32 => bool) forgiven;
    
    function Forgiveness () public {
        owner = msg.sender;
    }
    
    function askForgiveness (string transaction) public payable {
        require(msg.value >= forgivenessFee);
        require(!isForgiven(transaction));
        ownerBalance += msg.value;
        forgiven[keccak256(transaction)] = true;
    }
    
    function isForgiven (string transaction) public view returns (bool) {
        return forgiven[keccak256(transaction)];
    }
    
    function withdrawFees () public {
        require(msg.sender == owner);
        uint toWithdraw = ownerBalance;
        ownerBalance = 0;
        msg.sender.transfer(toWithdraw);
    }
    
    function getBalance () public view returns (uint) {
        require(msg.sender == owner);
        return ownerBalance;
    }

    function () public payable {
    }
}