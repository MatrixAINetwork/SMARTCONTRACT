/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks
 */
contract SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        require(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c>=a && c>=b);
        return c;
    }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 _balance);
    function allowance(address _owner, address _spender) public constant returns (uint256 _allowance);
    function transfer(address _to, uint256 _value) public returns (bool _succes);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _succes);
    function approve(address _spender, uint256 _value) public returns (bool _succes);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 */
contract StandardToken is ERC20, SafeMath {
    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance; 
    
    function balanceOf(address _owner) public constant returns (uint256){
        return balanceOf[_owner];
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint256){
        return allowance[_owner][_spender];
    }
    
    /**
    * Fix for the ERC20 short address attack
    *
    * http://vessenes.com/the-erc20-short-address-attack-explained/
    */
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }
    
    /*
     * Internal transfer with security checks, 
     * only can be called by this contract
     */
    function safeTransfer(address _from, address _to, uint256 _value) internal {
            // Prevent transfer to 0x0 address.
            require(_to != 0x0);
            // Prevent transfer to this contract
            require(_to != address(this));
            // Check if the sender has enough and subtract from the sender by using safeSub
            balanceOf[_from] = safeSub(balanceOf[_from], _value);
            // check for overflows and add the same value to the recipient by using safeAdd
            balanceOf[_to] = safeAdd(balanceOf[_to], _value);
            Transfer(_from, _to, _value);
    }

    /**
     * @dev Send `_value` tokens to `_to` from your account
     * @param _to address The address which you want to transfer to
     * @param _value uint the amout of tokens to be transfered
     */
    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
        safeTransfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {
        uint256 _allowance = allowance[_from][msg.sender];
        
        // Check (_value > _allowance) is already done in safeSub(_allowance, _value)
        allowance[_from][msg.sender] = safeSub(_allowance, _value);
        safeTransfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        // To change the approve amount you first have to reduce the addresses`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}

/**
 * Upgrade agent interface inspired by Lunyr.
 * 
 * Upgrade agent transfers tokens to a new contract.
 * Upgrade agent itself can be the token contract, or just a middle man contract 
 * doing the heavy lifting.
 */
contract UpgradeAgent {

    uint256 public originalSupply;

    /** Interface marker */
    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }

    function upgradeFrom(address _from, uint256 _value) public;
}

/**
 * A token upgrade mechanism where users can opt-in amount of tokens to the next 
 * smart contract revision.
 *
 * First envisioned by Golem and Lunyr projects.
 *
 */
contract UpgradeableToken is StandardToken {

    /**
     * Contract / person who can set the upgrade path. 
     * This can be the same as team multisig wallet, as what it is with its default value. 
     */
    address public upgradeMaster;

    /** The next contract where the tokens will be migrated. */
    UpgradeAgent public upgradeAgent;

    /** How many tokens we have upgraded by now. */
    uint256 public totalUpgraded;
    
    /**
     * Upgrade states.
     *
     * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
     * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
     * - ReadyToUpgrade: The agent is set, but not a single token has been upgraded yet
     * - Upgrading: Upgrade agent is set and the balance holders can upgrade their tokens
     *
     */
    enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

    /**
     * Somebody has upgraded some of his tokens.
     */
    event Upgrade(address indexed _from, address indexed _to, uint256 _value);

    /**
     * New upgrade agent available.
     */
    event UpgradeAgentSet(address agent);

    /**
     * Do not allow construction without upgrade master set.
     */
    function UpgradeableToken(address _upgradeMaster) public {
        upgradeMaster = _upgradeMaster;
    }

    /**
     * Allow the token holder to upgrade some of their tokens to a new contract.
     */
    function upgrade(uint256 value) public {

        UpgradeState state = getUpgradeState();
        // bad state not allowed
        require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);

        // Validate input value.
        require(value != 0);

        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], value);

        // Take tokens out from circulation
        totalSupply = safeSub(totalSupply, value);
        totalUpgraded = safeAdd(totalUpgraded, value);

        // Upgrade agent reissues the tokens
        upgradeAgent.upgradeFrom(msg.sender, value);
        Upgrade(msg.sender, upgradeAgent, value);
    }

    /**
     * Set an upgrade agent that handles
     */
    function setUpgradeAgent(address agent) external {

        require(canUpgrade());
        require(agent != 0x0);
        // Only a master can designate the next agent
        require(msg.sender == upgradeMaster);
        // Upgrade has already begun for an agent
        require(getUpgradeState() != UpgradeState.Upgrading);

        upgradeAgent = UpgradeAgent(agent);

        // Bad interface
        require(upgradeAgent.isUpgradeAgent());
        // Make sure that token supplies match in source and target
        require(upgradeAgent.originalSupply() == totalSupply);

        UpgradeAgentSet(upgradeAgent);
    }

    /**
     * Get the state of the token upgrade.
     */
    function getUpgradeState() public constant returns (UpgradeState) {
        if(!canUpgrade()) return UpgradeState.NotAllowed;
        else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
        else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
        else return UpgradeState.Upgrading;
    }

    /**
     * Change the upgrade master.
     *
     * This allows us to set a new owner for the upgrade mechanism.
     */
    function setUpgradeMaster(address master) public {
        require(master != 0x0);
        require(msg.sender == upgradeMaster);
        upgradeMaster = master;
    }

    /**
     * Child contract can enable to provide the condition when the upgrade can begun.
     */
    function canUpgrade() public pure returns (bool) {
        return true;
    }
}


/**
 * @title Ownable
 * @dev Ownable contract with two owner addresses
 */
contract Ownable {
    address public ownerOne;
    address public ownerTwo;

    /**
     * @dev The Ownable constructor sets one of the owners of the contract to the sender
     * account.
     */
    function Ownable() public {
        ownerOne = msg.sender;
        ownerTwo = msg.sender;
    }

    /**
     * @dev Can only be called by the owners.
     */
    modifier onlyOwner {
        require(msg.sender == ownerOne || msg.sender == ownerTwo);
        _;
    }

    /**
     * @dev Allows the current owners to transfer control of the contract to a new owner.
     * @param newOwner The address to transfer ownership to.
     * @param replaceOwnerOne Replace 'ownerOne'?
     * @param replaceOwnerTwo Replace 'ownerTwo'?
     */
    function transferOwnership(address newOwner, bool replaceOwnerOne, bool replaceOwnerTwo) onlyOwner public {
        require(newOwner != 0x0);
        require(replaceOwnerOne || replaceOwnerTwo);
        if(replaceOwnerOne) ownerOne = newOwner;
        if(replaceOwnerTwo) ownerTwo = newOwner;
    }
}


/**
 * @title Pausable
 * @dev Allows an emergency stop mechanism.
 * See https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public returns (bool) {
        paused = true;
        Pause();
        return true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public returns (bool) {
        paused = false;
        Unpause();
        return true;
    }
}

/**
 * @title PausableToken
 * @dev StandardToken with pausable transfers
 */
contract PausableToken is StandardToken, Pausable {
    function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
        super.transfer(_to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) {
        super.transferFrom(_from, _to, _value);
        return true;
    }
}


/**
 * @title PurchasableToken
 * @dev Allows buying IPC token from this contract
 */
contract PurchasableToken is PausableToken {
    event PurchaseUnlocked();
    event PurchaseLocked();
    event UpdatedExchangeRate(uint256 newPrice);
    event Purchase(address buyer, uint256 etherAmount, uint256 tokenAmount);
    
    bool public purchasable = false;
    // minimum amount of ether you have to spend to buy some tokens
    uint256 public minimumEtherAmount;
    address public vendorWallet;
    uint256 public exchangeRate; // 'exchangeRate' tokens = 1 ether
    
    /** @dev modifier to allow token purchase only when purchase is unlocked and rate > 0 */
    modifier isPurchasable {
        require(purchasable && exchangeRate > 0 && minimumEtherAmount > 0);
        _;
    }
    
    /** @dev called by the owner to lock purchase of ipc token */
    function lockPurchase() onlyOwner public returns (bool) {
        require(purchasable == true);
        purchasable = false;
        PurchaseLocked();
        return true;
    }
    
    /** @dev called by the owner to release purchase of ipc token */
    function unlockPurchase() onlyOwner public returns (bool) {
        require(purchasable == false);
        purchasable = true;
        PurchaseUnlocked();
        return true;
    }

    /** @dev called by the owner to set a new rate */
    function setExchangeRate(uint256 newExchangeRate) onlyOwner public returns (bool) {
        require(newExchangeRate > 0);
        exchangeRate = newExchangeRate;
        UpdatedExchangeRate(newExchangeRate);
        return true;
    }
    
    /** @dev called by the owner to set the minimum ether amount to buy some token */
    function setMinimumEtherAmount(uint256 newMinimumEtherAmount) onlyOwner public returns (bool) {
        require(newMinimumEtherAmount > 0);
        minimumEtherAmount = newMinimumEtherAmount;
        return true;
    }
    
    /** @dev called by the owner to set a new vendor */
    function setVendorWallet(address newVendorWallet) onlyOwner public returns (bool) {
        require(newVendorWallet != 0x0);
        vendorWallet = newVendorWallet;
        return true;
    }
    
    /** @dev buy ipc token by sending at least 'minimumEtherAmount' */
    function buyIPC() payable isPurchasable whenNotPaused public returns (uint256) {
        require(msg.value >= minimumEtherAmount);
        uint256 tokenAmount = safeMul(msg.value, exchangeRate);
        tokenAmount = safeDiv(tokenAmount, 1 ether);
        require(allowance[vendorWallet][this] >= tokenAmount);
        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], tokenAmount);
        balanceOf[vendorWallet] = safeSub(balanceOf[vendorWallet], tokenAmount);
        Purchase(msg.sender, msg.value, tokenAmount);
        return tokenAmount;
    }
    
    function () payable public {
        buyIPC();
    }
}

/**
 * @title Withdrawable
 * @dev Contract allows to withdraw ether and ERC20 token
 */
contract Withdrawable is Ownable {
    
    /** @dev withdraw ERC20 token from this contract */
    function withdrawToken(address beneficiary, address _token) onlyOwner public {
        ERC20 token = ERC20(_token);
        uint256 amount = token.balanceOf(this);
        require(amount>0);
        token.transfer(beneficiary, amount);
    }
    
    /** @dev called by the owner to transfer 'etherAmount' to 'beneficiary' */
    function withdrawEther(address beneficiary, uint256 etherAmount) onlyOwner public {
        beneficiary.transfer(etherAmount);
    }
}


/**
 * @title IPCToken
 * @dev IPC Token contract
 * @author Paysura - <