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
    a) Adding the emergency transfer functionality for owner.
    b) Removing the logic of crowdsale according to standard MintToken in order to improve the neatness and
    legibility of the Sharder smart contract coding.
    c) Adding the broadcast event 'Frozen'.
    d) Changing the parameters of name, symbol, decimal, etc. to lower-case according to convention. Adjust format of input paramters.
    e) The global parameter is added to our smart contact in order to avoid that the exchanges trade Sharder tokens
    before officials partnering with Sharder.
    f) Add holder array to facilitate the exchange of the current ERC-20 token to the Sharder Chain token later this year
    when Sharder Chain is online.
    g) Lockup and lock-up query functions.
    The deplyed online contract you can found at: https://etherscan.io/address/XXXXXX

    Sharder-Token-v1.0 is expired. You can check the code and get the details on branch 'sharder-token-v1.0'.
*/
pragma solidity ^0.4.18;

/**
 * Math operations with safety checks
 */
library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

/**
* @title Sharder Token v2.0. SS(Sharder) is upgrade from SS(Sharder Storage).
* @author Ben - <