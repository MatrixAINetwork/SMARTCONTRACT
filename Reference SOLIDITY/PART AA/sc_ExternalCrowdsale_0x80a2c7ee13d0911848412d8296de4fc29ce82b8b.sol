/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.18;


/*
 * https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * The MIT License (MIT)
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
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


/*
 * https://github.com/OpenZeppelin/zeppelin-solidity
 *
 * The MIT License (MIT)
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
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
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


/**
 * @title Mintable token interface
 * @author Jakub Stefanski (https://github.com/jstefanski)
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
 */
contract Mintable {
    function mint(address to, uint256 amount) public;
}


/**
 * @title Crowdsale for off-chain payment methods
 * @author Jakub Stefanski (https://github.com/jstefanski)
 *
 * https://github.com/OnLivePlatform/onlive-contracts
 *
 * The BSD 3-Clause Clear License
 * Copyright (c) 2018 OnLive LTD
 */
contract ExternalCrowdsale is Ownable {

    using SafeMath for uint256;

    /**
     * @dev Address of mintable token instance
     */
    Mintable public token;

    /**
     * @dev Start block of active sale (inclusive). Zero if not scheduled.
     */
    uint256 public startBlock;

    /**
     * @dev End block of active sale (inclusive). Zero if not scheduled.
     */
    uint256 public endBlock;

    /**
     * @dev Indicates whether payment identified by bytes32 id is already registered
     */
    mapping (bytes32 => bool) public isPaymentRegistered;

    /**
     * @dev Current amount of tokens available for sale
     */
    uint256 public availableAmount;

    function ExternalCrowdsale(Mintable _token, uint256 _availableAmount)
        public
        onlyValid(_token)
        onlyNotZero(_availableAmount)
    {
        token = _token;
        availableAmount = _availableAmount;
    }

    /**
     * @dev Purchase with given payment id registered
     * @param paymentId bytes32 A unique payment id
     * @param purchaser address The recipient of the tokens
     * @param amount uint256 The amount of tokens
     */
    event PurchaseRegistered(bytes32 indexed paymentId, address indexed purchaser, uint256 amount);

    /**
     * @dev Sale scheduled on the given blocks
     * @param startBlock uint256 The first block of active sale
     * @param endBlock uint256 The last block of active sale
     */
    event SaleScheduled(uint256 startBlock, uint256 endBlock);

    modifier onlySufficientAvailableTokens(uint256 amount) {
        require(availableAmount >= amount);
        _;
    }

    modifier onlyUniquePayment(bytes32 paymentId) {
        require(!isPaymentRegistered[paymentId]);
        _;
    }

    modifier onlyValid(address addr) {
        require(addr != address(0));
        _;
    }

    modifier onlyNotZero(uint256 value) {
        require(value != 0);
        _;
    }

    modifier onlyNotScheduled() {
        require(startBlock == 0);
        require(endBlock == 0);
        _;
    }

    modifier onlyActive() {
        require(isActive());
        _;
    }

    /**
     * @dev Schedule sale for given block range
     * @param _startBlock uint256 The first block of sale
     * @param _endBlock uint256 The last block of sale
     */
    function scheduleSale(uint256 _startBlock, uint256 _endBlock)
        public
        onlyOwner
        onlyNotScheduled
        onlyNotZero(_startBlock)
        onlyNotZero(_endBlock)
    {
        require(_startBlock < _endBlock);

        startBlock = _startBlock;
        endBlock = _endBlock;

        SaleScheduled(_startBlock, _endBlock);
    }

    /**
     * @dev Register purchase with given payment id
     * @param paymentId bytes32 A unique payment id
     * @param purchaser address The recipient of the tokens
     * @param amount uint256 The amount of tokens
     */
    function registerPurchase(bytes32 paymentId, address purchaser, uint256 amount)
        public
        onlyOwner
        onlyActive
        onlyValid(purchaser)
        onlyNotZero(amount)
        onlyUniquePayment(paymentId)
        onlySufficientAvailableTokens(amount)
    {
        isPaymentRegistered[paymentId] = true;

        availableAmount = availableAmount.sub(amount);

        token.mint(purchaser, amount);

        PurchaseRegistered(paymentId, purchaser, amount);
    }

    /**
     * @dev Check whether sale is currently active
     */
    function isActive() public view returns (bool) {
        return block.number >= startBlock && block.number <= endBlock;
    }
}