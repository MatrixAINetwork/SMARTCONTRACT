/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;
// File: contracts/TulipsSaleInterface.sol

/** @title Crypto Tulips Initial Sale Interface
* @dev This interface sets the standard for initial sale
* contract. All future sale contracts should follow this.
*/
interface TulipsSaleInterface {
    function putOnInitialSale(uint256 tulipId) external;
    function createAuction(
        uint256 _tulipId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _transferFrom
    )external;
}

// File: contracts/ERC721.sol

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <