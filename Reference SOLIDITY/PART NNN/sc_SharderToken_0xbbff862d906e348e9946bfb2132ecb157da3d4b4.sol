/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/*
  Copyright 2017 Sharder Foundation.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  ################ Sharder-Token-v2.0 ###############
  a) Added an emergency transfer function to transfer tokens to the contract owner.
  b) Removed crowdsale logic according to the MintToken standard to improve neatness and legibility of the token contract.
  c) Added the 'Frozen' broadcast event.
  d) Changed name, symbol, decimal, etc, parameters to lower-case according to the convention. Adjust format parameters.
  e) Added a global parameter to the smart contact to prevent exchanges trading Sharder tokens before officially partnering.
  f) Added address mapping to facilitate the exchange of current ERC-20 tokens to the Sharder Chain token when it goes live.
  g) Added Lockup and lock-up query functionality.

  Sharder-Token-v1.0 has expired. The deprecated code is available in the sharder-token-v1.0' branch.
*/
pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Add two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
}
  
/**
* @title Sharder Token v2.0. SS (Sharder) is an upgrade from SS (Sharder Storage).
* @author Ben-<