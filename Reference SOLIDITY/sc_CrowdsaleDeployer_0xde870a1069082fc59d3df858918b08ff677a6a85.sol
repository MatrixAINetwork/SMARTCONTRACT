/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract SafeMath {

    function safeMul(uint256 a, uint256 b) internal constant returns (uint256 ) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal constant returns (uint256 ) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal constant returns (uint256 ) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal constant returns (uint256 ) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20 {

    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is ERC20, SafeMath {

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint256 _value) returns (bool) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = safeSub(balances[msg.sender], _value);
            balances[_to] = safeAdd(balances[_to], _value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else return false;
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] = safeAdd(balances[_to], _value);
            balances[_from] = safeSub(balances[_from], _value);
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            return true;
        } else return false;
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract Ownable {

    address public owner;
    address public pendingOwner;

    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Safe transfer of ownership in 2 steps. Once called, a newOwner needs to call claimOwnership() to prove ownership.
    function transferOwnership(address newOwner) onlyOwner {
        pendingOwner = newOwner;
    }

    function claimOwnership() {
        if (msg.sender == pendingOwner) {
            owner = pendingOwner;
            pendingOwner = 0;
        }
    }
}

contract MultiOwnable {

    mapping (address => bool) ownerMap;
    address[] public owners;

    event OwnerAdded(address indexed _newOwner);
    event OwnerRemoved(address indexed _oldOwner);

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function MultiOwnable() {
        // Add default owner
        address owner = msg.sender;
        ownerMap[owner] = true;
        owners.push(owner);
    }

    function ownerCount() public constant returns (uint256) {
        return owners.length;
    }

    function isOwner(address owner) public constant returns (bool) {
        return ownerMap[owner];
    }

    function addOwner(address owner) onlyOwner returns (bool) {
        if (!isOwner(owner) && owner != 0) {
            ownerMap[owner] = true;
            owners.push(owner);

            OwnerAdded(owner);
            return true;
        } else return false;
    }

    function removeOwner(address owner) onlyOwner returns (bool) {
        if (isOwner(owner)) {
            ownerMap[owner] = false;
            for (uint i = 0; i < owners.length - 1; i++) {
                if (owners[i] == owner) {
                    owners[i] = owners[owners.length - 1];
                    break;
                }
            }
            owners.length -= 1;

            OwnerRemoved(owner);
            return true;
        } else return false;
    }
}

contract Pausable is Ownable {

    bool public paused;

    modifier ifNotPaused {
        require(!paused);
        _;
    }

    modifier ifPaused {
        require(paused);
        _;
    }

    // Called by the owner on emergency, triggers paused state
    function pause() external onlyOwner {
        paused = true;
    }

    // Called by the owner on end of emergency, returns to normal state
    function resume() external onlyOwner ifPaused {
        paused = false;
    }
}

contract TokenSpender {
    function receiveApproval(address _from, uint256 _value);
}


contract CommonBsToken is StandardToken, MultiOwnable {

    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals = 18;
    string public version = 'v0.1';

    address public creator;
    address public seller;     // The main account that holds all tokens at the beginning.

    uint256 public saleLimit;  // (e18) How many tokens can be sold in total through all tiers or tokensales.
    uint256 public tokensSold; // (e18) Number of tokens sold through all tiers or tokensales.
    uint256 public totalSales; // Total number of sale (including external sales) made through all tiers or tokensales.

    bool public locked;

    event Sell(address indexed _seller, address indexed _buyer, uint256 _value);
    event SellerChanged(address indexed _oldSeller, address indexed _newSeller);

    event Lock();
    event Unlock();

    event Burn(address indexed _burner, uint256 _value);

    modifier onlyUnlocked() {
        require(isOwner(msg.sender) || !locked);
        _;
    }

    function CommonBsToken(
        address _seller,
        string _name,
        string _symbol,
        uint256 _totalSupplyNoDecimals,
        uint256 _saleLimitNoDecimals
    ) public MultiOwnable() {

        // Lock the transfer function during the presale/crowdsale to prevent speculations.
        locked = true;

        creator = msg.sender;
        seller = _seller;

        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupplyNoDecimals * 1e18;
        saleLimit = _saleLimitNoDecimals * 1e18;

        balances[seller] = totalSupply;
        Transfer(0x0, seller, totalSupply);
    }

    function changeSeller(address newSeller) onlyOwner public returns (bool) {
        require(newSeller != 0x0 && seller != newSeller);

        address oldSeller = seller;
        uint256 unsoldTokens = balances[oldSeller];
        balances[oldSeller] = 0;
        balances[newSeller] = safeAdd(balances[newSeller], unsoldTokens);
        Transfer(oldSeller, newSeller, unsoldTokens);

        seller = newSeller;
        SellerChanged(oldSeller, newSeller);
        return true;
    }

    function sellNoDecimals(address _to, uint256 _value) public returns (bool) {
        return sell(_to, _value * 1e18);
    }

    function sell(address _to, uint256 _value) onlyOwner public returns (bool) {

        // Check that we are not out of limit and still can sell tokens:
        if (saleLimit > 0) require(safeSub(saleLimit, safeAdd(tokensSold, _value)) >= 0);

        require(_to != address(0));
        require(_value > 0);
        require(_value <= balances[seller]);

        balances[seller] = safeSub(balances[seller], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(seller, _to, _value);

        tokensSold = safeAdd(tokensSold, _value);
        totalSales = safeAdd(totalSales, 1);
        Sell(seller, _to, _value);

        return true;
    }

    function transfer(address _to, uint256 _value) onlyUnlocked public returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) onlyUnlocked public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function lock() onlyOwner public {
        locked = true;
        Lock();
    }

    function unlock() onlyOwner public {
        locked = false;
        Unlock();
    }

    function burn(uint256 _value) public returns (bool) {
        require(_value > 0);
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = safeSub(balances[msg.sender], _value) ;
        totalSupply = safeSub(totalSupply, _value);
        Transfer(msg.sender, 0x0, _value);
        Burn(msg.sender, _value);

        return true;
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value) public {
        TokenSpender spender = TokenSpender(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value);
        }
    }

    function () payable {
        revert();
    }
}

contract CommonBsCrowdsale is SafeMath, Ownable, Pausable {

    struct Backer {
        uint256 weiReceived; // Amount of wei given by backer
        uint256 tokensSent;  // Amount of tokens received in return to the given amount of ETH.
    }

    // (buyer_eth_address -> struct)
    mapping(address => Backer) public backers;

    CommonBsToken public token; // Token contract reference.
    address public beneficiary; // Address that will receive ETH raised during this crowdsale.

    uint256 public minContributionWei = 0.0001 ether; // 50 tokens / 1 ETH = 0.02
    uint256 public maxCapWei = 120000 ether; // 6m / 50 tokens/ETH tokens that can be sold


    uint256 public tokensPerWei = 50;
    
    // TODO All bonus tokens should be left to owner/seller once ICO is over.
    uint256 public bonusTokensLeft = 1200000 ether;

    // Each stage is up to 1M tokens, then stage changes.
    struct Stage {
        uint256 fromTokens;
        uint256 toTokens;
        uint256 price;
    }

    Stage[] public stages;

    uint public startTime = now;        // 1512388800 = 2017-12-04T12:00:00Z
    uint public endTime   = 1516881600; // 1516881600 = 2018-01-25T12:00:00Z

    // Stats for current crowdsale

    uint256 public totalInWei         = 0; // Grand total in wei
    uint256 public totalTokensSold    = 0; // Total amount of tokens sold during this crowdsale.
    uint256 public totalEthSales      = 0; // Total amount of ETH contributions during this crowdsale.
    uint256 public weiReceived        = 0; // Total amount of wei received during this crowdsale smart contract.

    uint public finalizedTime = 0; // Unix timestamp when finalize() was called.

    bool public saleEnabled = true;   // if false, then contract will not sell tokens on payment received

    event BeneficiaryChanged(address indexed _oldAddress, address indexed _newAddress);
    event EthReceived(address indexed _buyer, uint256 _amountWei);

    modifier ifUnderMaxCap() {
        require(!isMaxCapReached());
        _;
    }
    
    function CommonBsCrowdsale(address _token, address _beneficiary, address _owner) {
        token = CommonBsToken(_token);
        beneficiary = _beneficiary;
        owner = _owner != 0 ? _owner : msg.sender;
        
        addNextStage(1, 75); // 1m, 50% bonus
        addNextStage(2, 67); // 2m, ~35% (67.5)
        addNextStage(3, 60); // 3m, 20%
        addNextStage(4, 55); // 4m, 10%
        addNextStage(5, 52); // 5m, ~5% (52.5)
        addNextStage(6, 50); // 6m, 0% bonus
    }
    
    function addNextStage(uint _maxMilTokens, uint256 _stagePrice) internal {
        stages.push(Stage(
            toMilTokens(_maxMilTokens - 1), 
            toMilTokens(_maxMilTokens), 
            _stagePrice
        ));
    }
    
    function toMilTokens(uint _num) internal view returns (uint256) {
        return safeMul(_num, 1000000 ether);
    }

    // Override this method to mock current time.
    function getNow() public constant returns (uint) {
        return now;
    }

    function setSaleEnabled(bool _enabled) public onlyOwner {
        saleEnabled = _enabled;
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        BeneficiaryChanged(beneficiary, _beneficiary);
        beneficiary = _beneficiary;
    }

    /*
     * The fallback function corresponds to a donation in ETH
     */
    function() public payable {
        if (saleEnabled) sellTokensForEth(msg.sender, msg.value);
    }

    function sellTokensForEth(address _buyer, uint256 _amountWei) internal ifNotPaused ifUnderMaxCap {

        require(_amountWei >= minContributionWei);

        totalInWei = safeAdd(totalInWei, _amountWei);
        weiReceived = safeAdd(weiReceived, _amountWei);
        require(totalInWei <= maxCapWei); // If max cap reached.

        uint256 tokensE18 = weiToTokens(_amountWei);
        require(token.sell(_buyer, tokensE18)); // Transfer tokens to buyer.

        totalTokensSold = safeAdd(totalTokensSold, tokensE18);
        totalEthSales++;

        Backer backer = backers[_buyer];
        backer.tokensSent = safeAdd(backer.tokensSent, tokensE18);
        backer.weiReceived = safeAdd(backer.weiReceived, _amountWei);  // Update the total wei collected during the crowdfunding for this backer

        EthReceived(_buyer, _amountWei);
    }

    // Calc how much tokens you can buy at current time.
    function weiToTokens(uint256 _amountWei) public constant returns (uint256) {
        uint256 price = tokensPerWei;

        // Get bonus rate based on current stage (6 stages by 1m tokens each)
        // Bonus rules applies only until crowdsale end time. No bonus after.
        if (isSaleOn()) {
            for (uint i = 0; i < stages.length; i++) {
                var s = stages[i];
                if (s.fromTokens <= totalTokensSold && totalTokensSold <= s.toTokens) {
                    price = s.price;
                    break;
                }
            }
        }

        return safeMul(_amountWei, price);
    }

    function stageCount() public constant returns (uint) {
        return stages.length;
    }

    function isMaxCapReached() public constant returns (bool) {
        return totalInWei >= maxCapWei;
    }

    function isSaleOn() public constant returns (bool) {
        uint _now = getNow();
        return startTime <= _now && _now <= endTime;
    }

    function isSaleOver() public constant returns (bool) {
        return getNow() > endTime;
    }

    function isFinalized() public constant returns (bool) {
        return finalizedTime > 0;
    }

    /*
     * Finalize the crowdsale. Raised money can be sent to beneficiary only if crowdsale hit end time or max cap (15m USD).
     */
    function finalize() public onlyOwner {

        // Cannot finalise before end day of crowdsale until max cap is reached.
        require(isMaxCapReached() || isSaleOver());

        beneficiary.transfer(this.balance);

        finalizedTime = getNow();
    }
}

contract CrowdsaleDeployer {

    CommonBsToken public token;
    CommonBsCrowdsale public crowdsale;

    function CrowdsaleDeployer() public {
        token = new CommonBsToken(
            0x48eF88089e5A7C6f538E90E0d5Fffa38277fD98A, // _seller address
            'X full',
            'X',
            10000000,
            7200000
        );
        crowdsale = new CommonBsCrowdsale(
            token, // address _token
            0x3dfa0bDDb80f771f715DEA1A7592Ce3Fc9bF2E69,  // address _beneficiary
            msg.sender
        );
        token.addOwner(msg.sender);
        token.addOwner(crowdsale);
    }
}