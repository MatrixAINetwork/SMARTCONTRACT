/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

// File: contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 * Based on OpenZeppelin
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * Based on OpenZeppelin
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/crowdsale/PricingStrategy.sol

/**
 * Pricing Strategy - Abstract contract for defining crowdsale pricing.
 */
contract PricingStrategy {

  // How many tokens per one investor is allowed in presale
  uint public presaleMaxValue = 0;

  function isPricingStrategy() external constant returns (bool) {
      return true;
  }

  function getPresaleMaxValue() public constant returns (uint) {
      return presaleMaxValue;
  }

  function isPresaleFull(uint weiRaised) public constant returns (bool);

  function getAmountOfTokens(uint value, uint weiRaised) public constant returns (uint tokensAmount);
}

// File: contracts/crowdsale/AlgoryPricingStrategy.sol

/**
 * @title Algory Algory Pricing Strategy
 *
 * @dev based on TokenMarketNet
 *
 * Apache License, version 2.0 https://github.com/AlgoryProject/algory-ico/blob/master/LICENSE
 */
contract AlgoryPricingStrategy is PricingStrategy, Ownable {

    using SafeMath for uint;

    /**
    * Define pricing schedule using tranches.
    */
    struct Tranche {
        // Amount in weis when this tranche becomes active
        uint amount;
        // How many tokens per wei you will get while this tranche is active
        uint rate;
    }

    Tranche[4] public tranches;

    // How many active tranches we have
    uint public trancheCount = 4;

    function AlgoryPricingStrategy() {

        tranches[0].amount = 0;
        tranches[0].rate = 1200;

        tranches[1].amount = 10000 ether;
        tranches[1].rate = 1100;

        tranches[2].amount = 24000 ether;
        tranches[2].rate = 1050;

        tranches[3].amount = 40000 ether;
        tranches[3].rate = 1000;

        trancheCount = tranches.length;
        presaleMaxValue = 300 ether;
    }

    function() public payable {
        revert();
    }

    function getTranche(uint n) public constant returns (uint amount, uint rate) {
        require(n < trancheCount);
        return (tranches[n].amount, tranches[n].rate);
    }

    function isPresaleFull(uint presaleWeiRaised) public constant returns (bool) {
        return presaleWeiRaised > tranches[1].amount;
    }

    function getCurrentRate(uint weiRaised) public constant returns (uint) {
        return getCurrentTranche(weiRaised).rate;
    }

    function getAmountOfTokens(uint value, uint weiRaised) public constant returns (uint tokensAmount) {
        require(value > 0);
        uint rate = getCurrentRate(weiRaised);
        return value.mul(rate);
    }

    function getCurrentTranche(uint weiRaised) private constant returns (Tranche) {
        for(uint i=1; i < tranches.length; i++) {
            if(weiRaised <= tranches[i].amount) {
                return tranches[i-1];
            }
        }
        return tranches[tranches.length-1];
    }
}