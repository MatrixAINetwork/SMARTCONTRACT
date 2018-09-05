/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/*************************************************************************
 * This contract has been merged with solidify
 * https://github.com/tiesnetwork/solidify
 *************************************************************************/
 
 pragma solidity 0.4.15;

/*************************************************************************
 * import "./STQPreICOBase.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "./crowdsale/SimpleCrowdsaleBase.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "../security/ArgumentsChecker.sol" : start
 *************************************************************************/


/// @title utility methods and modifiers of arguments validation
contract ArgumentsChecker {

    /// @dev check which prevents short address attack
    modifier payloadSizeIs(uint size) {
       require(msg.data.length == size + 4 /* function selector */);
       _;
    }

    /// @dev check that address is valid
    modifier validAddress(address addr) {
        require(addr != address(0));
        _;
    }
}
/*************************************************************************
 * import "../security/ArgumentsChecker.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "../token/MintableMultiownedToken.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "../ownership/MultiownedControlled.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "./multiowned.sol" : start
 *************************************************************************/// Code taken from https://github.com/ethereum/dapp-bin/blob/master/wallet/wallet.sol
// Audit, refactoring and improvements by github.com/Eenae

// @authors:
// Gav Wood <