/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

interface FundInterface {

    // EVENTS

    event PortfolioContent(uint holdings, uint price, uint decimals);
    event RequestUpdated(uint id);
    event Invested(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
    event Redeemed(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
    event SpendingApproved(address onConsigned, address ofAsset, uint amount);
    event FeesConverted(uint atTimestamp, uint shareQuantityConverted, uint unclaimed);
    event CalculationUpdate(uint atTimestamp, uint managementFee, uint performanceFee, uint nav, uint sharePrice, uint totalSupply);
    event OrderUpdated(uint id);
    event LogError(uint ERROR_CODE);
    event ErrorMessage(string errorMessage);

    // EXTERNAL METHODS
    // Compliance by Investor
    function requestInvestment(uint giveQuantity, uint shareQuantity, bool isNativeAsset) external;
    function requestRedemption(uint shareQuantity, uint receiveQuantity, bool isNativeAsset) external;
    function executeRequest(uint requestId) external;
    function cancelRequest(uint requestId) external;
    function redeemAllOwnedAssets(uint shareQuantity) external returns (bool);
    // Administration by Manager
    function enableInvestment() external;
    function disableInvestment() external;
    function enableRedemption() external;
    function disableRedemption() external;
    function shutDown() external;
    // Managing by Manager
    function makeOrder(uint exchangeId, address sellAsset, address buyAsset, uint sellQuantity, uint buyQuantity) external;
    function takeOrder(uint exchangeId, uint id, uint quantity) external;
    function cancelOrder(uint exchangeId, uint id) external;

    // PUBLIC METHODS
    function emergencyRedeem(uint shareQuantity, address[] requestedAssets) public returns (bool success);
    // Fees by Manager
    function allocateUnclaimedFees();

    // PUBLIC VIEW METHODS
    // Get general information
    function getModules() view returns (address, address, address);
    function getLastOrderId() view returns (uint);
    function getLastRequestId() view returns (uint);
    function getNameHash() view returns (bytes32);
    function getManager() view returns (address);

    // Get accounting information
    function performCalculations() view returns (uint, uint, uint, uint, uint, uint, uint);
    function calcSharePrice() view returns (uint);
}

interface ComplianceInterface {

    // PUBLIC VIEW METHODS

    /// @notice Checks whether investment is permitted for a participant
    /// @param ofParticipant Address requesting to invest in a Melon fund
    /// @param giveQuantity Quantity of Melon token times 10 ** 18 offered to receive shareQuantity
    /// @param shareQuantity Quantity of shares times 10 ** 18 requested to be received
    /// @return Whether identity is eligible to invest in a Melon fund.
    function isInvestmentPermitted(
        address ofParticipant,
        uint256 giveQuantity,
        uint256 shareQuantity
    ) view returns (bool);

    /// @notice Checks whether redemption is permitted for a participant
    /// @param ofParticipant Address requesting to redeem from a Melon fund
    /// @param shareQuantity Quantity of shares times 10 ** 18 offered to redeem
    /// @param receiveQuantity Quantity of Melon token times 10 ** 18 requested to receive for shareQuantity
    /// @return Whether identity is eligible to redeem from a Melon fund.
    function isRedemptionPermitted(
        address ofParticipant,
        uint256 shareQuantity,
        uint256 receiveQuantity
    ) view returns (bool);
}

contract OnlyManager is ComplianceInterface {

    // PUBLIC VIEW METHODS

    /// @notice Checks whether investment is permitted for a participant
    /// @param ofParticipant Address requesting to invest in a Melon fund
    /// @param giveQuantity Quantity of Melon token times 10 ** 18 offered to receive shareQuantity
    /// @param shareQuantity Quantity of shares times 10 ** 18 requested to be received
    /// @return Whether identity is eligible to invest in a Melon fund.
    function isInvestmentPermitted(
        address ofParticipant,
        uint256 giveQuantity,
        uint256 shareQuantity
    )
        view
        returns (bool)
    {
        return FundInterface(msg.sender).getManager() == ofParticipant;
    }

    /// @notice Checks whether redemption is permitted for a participant
    /// @param ofParticipant Address requesting to redeem from a Melon fund
    /// @param shareQuantity Quantity of shares times 10 ** 18 offered to redeem
    /// @param receiveQuantity Quantity of Melon token times 10 ** 18 requested to receive for shareQuantity
    /// @return isEligible Whether identity is eligible to redeem from a Melon fund.
    function isRedemptionPermitted(
        address ofParticipant,
        uint256 shareQuantity,
        uint256 receiveQuantity
    )
        view
        returns (bool)
    {
        return true;    // No need for KYC/AML in case of redeeming shares
    }
}