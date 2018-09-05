/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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

// File: contracts/PricingStrategy.sol

contract PricingStrategy {

    using SafeMath for uint;

    uint[] public rates;
    uint[] public limits;

    function PricingStrategy(
        uint[] _rates,
        uint[] _limits
    ) public
    {
        require(_rates.length == _limits.length);
        rates = _rates;
        limits = _limits;
    }

    /** Interface declaration. */
    function isPricingStrategy() public view returns (bool) {
        return true;
    }

    /** Calculate the current price for buy in amount. */
    function calculateTokenAmount(uint weiAmount, uint weiRaised) public view returns (uint tokenAmount) {
        if (weiAmount == 0) {
            return 0;
        }

        var (rate, index) = currentRate(weiRaised);
        tokenAmount = weiAmount.mul(rate);

        // if we crossed slot border, recalculate remaining tokens according to next slot price
        if (weiRaised.add(weiAmount) > limits[index]) {
            uint currentSlotWei = limits[index].sub(weiRaised);
            uint currentSlotTokens = currentSlotWei.mul(rate);
            uint remainingWei = weiAmount.sub(currentSlotWei);
            tokenAmount = currentSlotTokens.add(calculateTokenAmount(remainingWei, limits[index]));
        }
    }

    function currentRate(uint weiRaised) public view returns (uint rate, uint8 index) {
        rate = rates[0];
        index = 0;

        while (weiRaised >= limits[index]) {
            rate = rates[++index];
        }
    }

}