/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.24;
pragma experimental "v0.5.0";


contract SRNTPriceOracle {
    // If SRNT becomes more expensive than ETH, we will have to reissue smart-contracts
    uint256 public SRNT_per_ETH = 10000;

    address internal serenity_wallet = 0x47c8F28e6056374aBA3DF0854306c2556B104601;

    function update_SRNT_price(uint256 new_SRNT_per_ETH) external {
        require(msg.sender == serenity_wallet);

        SRNT_per_ETH = new_SRNT_per_ETH;
    }
}