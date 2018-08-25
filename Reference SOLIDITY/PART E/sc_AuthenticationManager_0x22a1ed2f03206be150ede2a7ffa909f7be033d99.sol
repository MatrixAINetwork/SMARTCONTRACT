/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

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

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

/* The authentication manager details user accounts that have access to certain priviledges and keeps a permanent ledger of who has and has had these rights. */
contract AuthenticationManager {
    /* Map addresses to admins */
    mapping (address => bool) adminAddresses;

    /* Map addresses to account readers */
    mapping (address => bool) accountReaderAddresses;

    /* Details of all admins that have ever existed */
    address[] adminAudit;

    /* Details of all account readers that have ever existed */
    address[] accountReaderAudit;

    /* Fired whenever an admin is added to the contract. */
    event AdminAdded(address addedBy, address admin);

    /* Fired whenever an admin is removed from the contract. */
    event AdminRemoved(address removedBy, address admin);

    /* Fired whenever an account-reader contract is added. */
    event AccountReaderAdded(address addedBy, address account);

    /* Fired whenever an account-reader contract is removed. */
    event AccountReaderRemoved(address removedBy, address account);

    /* When this contract is first setup we use the creator as the first admin */    
    function AuthenticationManager() {
        /* Set the first admin to be the person creating the contract */
        adminAddresses[msg.sender] = true;
        AdminAdded(0, msg.sender);
        adminAudit.length++;
        adminAudit[adminAudit.length - 1] = msg.sender;
    }

    /* Gets whether or not the specified address is currently an admin */
    function isCurrentAdmin(address _address) constant returns (bool) {
        return adminAddresses[_address];
    }

    /* Gets whether or not the specified address has ever been an admin */
    function isCurrentOrPastAdmin(address _address) constant returns (bool) {
        for (uint256 i = 0; i < adminAudit.length; i++)
            if (adminAudit[i] == _address)
                return true;
        return false;
    }

    /* Gets whether or not the specified address is currently an account reader */
    function isCurrentAccountReader(address _address) constant returns (bool) {
        return accountReaderAddresses[_address];
    }

    /* Gets whether or not the specified address has ever been an admin */
    function isCurrentOrPastAccountReader(address _address) constant returns (bool) {
        for (uint256 i = 0; i < accountReaderAudit.length; i++)
            if (accountReaderAudit[i] == _address)
                return true;
        return false;
    }

    /* Adds a user to our list of admins */
    function addAdmin(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        // Fail if this account is already admin
        if (adminAddresses[_address])
            throw;
        
        // Add the user
        adminAddresses[_address] = true;
        AdminAdded(msg.sender, _address);
        adminAudit.length++;
        adminAudit[adminAudit.length - 1] = _address;
    }

    /* Removes a user from our list of admins but keeps them in the history audit */
    function removeAdmin(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        /* Don't allow removal of self */
        if (_address == msg.sender)
            throw;

        // Fail if this account is already non-admin
        if (!adminAddresses[_address])
            throw;

        /* Remove this admin user */
        adminAddresses[_address] = false;
        AdminRemoved(msg.sender, _address);
    }

    /* Adds a user/contract to our list of account readers */
    function addAccountReader(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        // Fail if this account is already in the list
        if (accountReaderAddresses[_address])
            throw;
        
        // Add the user
        accountReaderAddresses[_address] = true;
        AccountReaderAdded(msg.sender, _address);
        accountReaderAudit.length++;
        accountReaderAudit[adminAudit.length - 1] = _address;
    }

    /* Removes a user/contracts from our list of account readers but keeps them in the history audit */
    function removeAccountReader(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        // Fail if this account is already not in the list
        if (!accountReaderAddresses[_address])
            throw;

        /* Remove this admin user */
        accountReaderAddresses[_address] = false;
        AccountReaderRemoved(msg.sender, _address);
    }
}

/* The XWIN Token itself is a simple extension of the ERC20 that allows for granting other XWIN Token contracts special rights to act on behalf of all transfers. */
contract XWinToken {
    using SafeMath for uint256;

    /* Map all our our balances for issued tokens */
    mapping (address => uint256) balances;

    /* Map between users and their approval addresses and amounts */
    mapping(address => mapping (address => uint256)) allowed;

    /* List of all token holders */
    address[] allTokenHolders;

    /* The name of the contract */
    string public name;

    /* The symbol for the contract */
    string public symbol;

    /* How many DPs are in use in this contract */
    uint8 public decimals;

    /* Defines the current supply of the token in its own units */
    uint256 totalSupplyAmount = 0;

    /* Defines the address of the ICO contract which is the only contract permitted to mint tokens. */
    address public icoContractAddress;

    /* Defines whether or not the fund is closed. */
    bool public isClosed;

    /* Defines the contract handling the ICO phase. */
    IcoPhaseManagement icoPhaseManagement;

    /* Defines the admin contract we interface with for credentails. */
    AuthenticationManager authenticationManager;

    /* Fired when the fund is eventually closed. */
    event FundClosed();
    
    /* Our transfer event to fire whenever we shift SMRT around */
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    /* Our approval event when one user approves another to control */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* Create a new instance of this fund with links to other contracts that are required. */
    function XWinToken(address _icoContractAddress, address _authenticationManagerAddress) {
        // Setup defaults
        name = "XWin CryptoBet";
        symbol = "XWIN";
        decimals = 8;

        /* Setup access to our other contracts and validate their versions */
        icoPhaseManagement = IcoPhaseManagement(_icoContractAddress);
        authenticationManager = AuthenticationManager(_authenticationManagerAddress);

        /* Store our special addresses */
        icoContractAddress = _icoContractAddress;
    }

    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    } 

    /* This modifier allows a method to only be called by account readers */
    modifier accountReaderOnly {
        if (!authenticationManager.isCurrentAccountReader(msg.sender)) throw;
        _;
    }

    modifier fundSendablePhase {
        // If it's in ICO phase, forbid it
        //if (icoPhaseManagement.icoPhase())
        //    throw;

        // If it's abandoned, forbid it
        if (icoPhaseManagement.icoAbandoned())
            throw;

        // We're good, funds can now be transferred
        _;
    }

    /* Transfer funds between two addresses that are not the current msg.sender - this requires approval to have been set separately and follows standard ERC20 guidelines */
    function transferFrom(address _from, address _to, uint256 _amount) fundSendablePhase onlyPayloadSize(3) returns (bool) {
        if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to].add(_amount) > balances[_to]) {
            bool isNew = balances[_to] == 0;
            balances[_from] = balances[_from].sub(_amount);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            if (isNew)
                tokenOwnerAdd(_to);
            if (balances[_from] == 0)
                tokenOwnerRemove(_from);
            Transfer(_from, _to, _amount);
            return true;
        }
        return false;
    }

    /* Returns the total number of holders of this currency. */
    function tokenHolderCount()  constant returns (uint256) {
        return allTokenHolders.length;
    }

    /* Gets the token holder at the specified index. */
    function tokenHolder(uint256 _index)  constant returns (address) {
        return allTokenHolders[_index];
    }
 
    /* Adds an approval for the specified account to spend money of the message sender up to the defined limit */
    function approve(address _spender, uint256 _amount) fundSendablePhase onlyPayloadSize(2) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /* Gets the current allowance that has been approved for the specified spender of the owner address */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /* Gets the total supply available of this token */
    function totalSupply() constant returns (uint256) {
        return totalSupplyAmount;
    }

    /* Gets the balance of a specified account */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /* Transfer the balance from owner's account to another account */
    function transfer(address _to, uint256 _amount) fundSendablePhase onlyPayloadSize(2) returns (bool) {
        /* Check if sender has balance and for overflows */
        if (balances[msg.sender] < _amount || balances[_to].add(_amount) < balances[_to])
            return false;

        /* Do a check to see if they are new, if so we'll want to add it to our array */
        bool isRecipientNew = balances[_to] == 0;

        /* Add and subtract new balances */
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);

        /* Consolidate arrays if they are new or if sender now has empty balance */
        if (isRecipientNew)
            tokenOwnerAdd(_to);
        if (balances[msg.sender] == 0)
            tokenOwnerRemove(msg.sender);

        /* Fire notification event */
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    /* If the specified address is not in our owner list, add them - this can be called by descendents to ensure the database is kept up to date. */
    function tokenOwnerAdd(address _addr) internal {
        /* First check if they already exist */
        uint256 tokenHolderCount = allTokenHolders.length;
        for (uint256 i = 0; i < tokenHolderCount; i++)
            if (allTokenHolders[i] == _addr)
                /* Already found so we can abort now */
                return;
        
        /* They don't seem to exist, so let's add them */
        allTokenHolders.length++;
        allTokenHolders[allTokenHolders.length - 1] = _addr;
    }

    /* If the specified address is in our owner list, remove them - this can be called by descendents to ensure the database is kept up to date. */
    function tokenOwnerRemove(address _addr) internal {
        /* Find out where in our array they are */
        uint256 tokenHolderCount = allTokenHolders.length;
        uint256 foundIndex = 0;
        bool found = false;
        uint256 i;
        for (i = 0; i < tokenHolderCount; i++)
            if (allTokenHolders[i] == _addr) {
                foundIndex = i;
                found = true;
                break;
            }
        
        /* If we didn't find them just return */
        if (!found)
            return;
        
        /* We now need to shuffle down the array */
        for (i = foundIndex; i < tokenHolderCount - 1; i++)
            allTokenHolders[i] = allTokenHolders[i + 1];
        allTokenHolders.length--;
    }

    /* Mint new tokens - this can only be done by special callers (i.e. the ICO management) during the ICO phase. */
    function mintTokens(address _address, uint256 _amount) onlyPayloadSize(2) {
        /* Ensure we are the ICO contract calling */
        if (msg.sender != icoContractAddress || !icoPhaseManagement.icoPhase())
            throw;

        /* Mint the tokens for the new address*/
        bool isNew = balances[_address] == 0;
        totalSupplyAmount = totalSupplyAmount.add(_amount);
        balances[_address] = balances[_address].add(_amount);
        if (isNew)
            tokenOwnerAdd(_address);
        Transfer(0, _address, _amount);
    }
}


contract IcoPhaseManagement {
    using SafeMath for uint256;
    
    /* Defines whether or not we are in the ICO phase */
    bool public icoPhase = true;

    /* Defines whether or not the ICO has been abandoned */
    bool public icoAbandoned = false;

    /* Defines whether or not the XWIN Token contract address has yet been set.  */
    bool xwinContractDefined = false;
    
    /* Defines the sale price during ICO */
    uint256 public icoUnitPrice = 3 finney;
    
    /* Main wallet for collecting ethers*/
    address mainWallet="0x20ce46Bce85BFf0CA13b02401164D96B3806f56e";
    
    // contract manager address
    address manager = "0xE3ff0BA0C6E7673f46C7c94A5155b4CA84a5bE0C";
    /* Wallets wor reserved tokens */
    address reservedWallet1 = "0x43Ceb8b8f755518e325898d95F3912aF16b6110C";
    address reservedWallet2 = "0x11F386d6c7950369E8Da56F401d1727cf131816D";
    // flag - reserved tokens already distributed (can be distributed only once)
    bool public reservedTokensDistributed;

    /* If an ICO is abandoned and some withdrawals fail then this map allows people to request withdrawal of locked-in ether. */
    mapping(address => uint256) public abandonedIcoBalances;

    /* Defines our interface to the XWIN Token contract. */
    XWinToken xWinToken;

    /* Defines the admin contract we interface with for credentails. */
    AuthenticationManager authenticationManager;

    /* Defines the time that the ICO starts. */
    uint256 public icoStartTime; 

    /* Defines the time that the ICO ends. */
    uint256 public icoEndTime; 

    /* Defines our event fired when the ICO is closed */
    event IcoClosed();

    /* Defines our event fired if the ICO is abandoned */
    event IcoAbandoned(string details);
    
    /* Ensures that once the ICO is over this contract cannot be used until the point it is destructed. */
    modifier onlyDuringIco {
        bool contractValid = xwinContractDefined && !xWinToken.isClosed();
        if (!contractValid || (!icoPhase && !icoAbandoned)) throw;
        _;
    }

    /* This code can be executed only after ICO */
    modifier onlyAfterIco {
        if ( icoEndTime  > now) throw;
        _;
    }

    /* This modifier allows a method to only be called by current admins */
    modifier adminOnly {
        if (!authenticationManager.isCurrentAdmin(msg.sender)) throw;
        _;
    }
    
    modifier managerOnly {
        require (msg.sender==manager);
        _;
    }
    

    /* Create the ICO phase managerment and define the address of the main XWIN Token contract. */
    function IcoPhaseManagement(address _authenticationManagerAddress) {
        /* A basic sanity check */
        icoStartTime = now;
        icoEndTime = 1517270400;
        /* Setup access to our other contracts and validate their versions */
        authenticationManager = AuthenticationManager(_authenticationManagerAddress);
        reservedTokensDistributed = false;
    }

    /* Set the XWIN Token contract address as a one-time operation.  This happens after all the contracts are created and no
       other functionality can be used until this is set. */
    function setXWinContractAddress(address _xwinContractAddress) adminOnly {
        /* This can only happen once in the lifetime of this contract */
        if (xwinContractDefined)
            throw;

        /* Setup access to our other contracts and validate their versions */
        xWinToken = XWinToken(_xwinContractAddress);

        xwinContractDefined = true;
    }
    
    function setTokenPrice(uint newPriceInWei) managerOnly {
        icoUnitPrice = newPriceInWei;
    }

    /* Close the ICO phase and transition to execution phase */
    function close() managerOnly onlyDuringIco {
        // Forbid closing contract before the end of ICO
        if (now <= icoEndTime)
            throw;

        // Close the ICO
        icoPhase = false;
        IcoClosed();

        // Withdraw funds to the caller
        // if (!msg.sender.send(this.balance))
        //    throw;
    }
    
    /* Sending reserved tokens (20% from all tokens was reserved in preICO) */
    function distributeReservedTokens() managerOnly onlyAfterIco {
        
        require (!reservedTokensDistributed);
        
        uint extraTwentyPercents = xWinToken.totalSupply().div(4);
        xWinToken.mintTokens(reservedWallet1,extraTwentyPercents.div(2));
        xWinToken.mintTokens(reservedWallet2,extraTwentyPercents.div(2));
        
        reservedTokensDistributed = true;
    }
    
    /* Handle receiving ether in ICO phase - we work out how much the user has bought, allocate a suitable balance and send their change */
    function () onlyDuringIco payable {
        // Forbid funding outside of ICO
        if (now < icoStartTime || now > icoEndTime)
            throw;

        /* Determine how much they've actually purhcased and any ether change */
        //uint256 tokensPurchased = msg.value.div(icoUnitPrice);
        //uint256 purchaseTotalPrice = tokensPurchased * icoUnitPrice;
        //uint256 change = msg.value.sub(purchaseTotalPrice);

        /* Increase their new balance if they actually purchased any */
        //if (tokensPurchased > 0)
        xWinToken.mintTokens(msg.sender, msg.value.mul(100000000).div(icoUnitPrice));

        mainWallet.send(msg.value);
        /* Send change back to recipient */
        /*if (change > 0 && !msg.sender.send(change))
            throw;*/
    }
    
}

contract DividendManager {
    using SafeMath for uint256;

    /* Our handle to the XWIN Token contract. */
    XWinToken xwinContract;

    /* Handle payments we couldn't make. */
    mapping (address => uint256) public dividends;

    /* Indicates a payment is now available to a shareholder */
    event PaymentAvailable(address addr, uint256 amount);

    /* Indicates a dividend payment was made. */
    event DividendPayment(uint256 paymentPerShare, uint256 timestamp);

    /* Create our contract with references to other contracts as required. */
    function DividendManager(address _xwinContractAddress) {
        /* Setup access to our other contracts and validate their versions */
        xwinContract = XWinToken(_xwinContractAddress);
    }

    /* Makes a dividend payment - we make it available to all senders then send the change back to the caller.  We don't actually send the payments to everyone to reduce gas cost and also to 
       prevent potentially getting into a situation where we have recipients throwing causing dividend failures and having to consolidate their dividends in a separate process. */
    function () payable {
        if (xwinContract.isClosed())
            throw;

        /* Determine how much to pay each shareholder. */
        uint256 validSupply = xwinContract.totalSupply();
        uint256 paymentPerShare = msg.value.div(validSupply);
        if (paymentPerShare == 0)
            throw;

        /* Enum all accounts and send them payment */
        uint256 totalPaidOut = 0;
        for (uint256 i = 0; i < xwinContract.tokenHolderCount(); i++) {
            address addr = xwinContract.tokenHolder(i);
            uint256 dividend = paymentPerShare * xwinContract.balanceOf(addr);
            dividends[addr] = dividends[addr].add(dividend);
            PaymentAvailable(addr, dividend);
            totalPaidOut = totalPaidOut.add(dividend);
        }

        // Attempt to send change
        /*uint256 remainder = msg.value.sub(totalPaidOut);
        if (remainder > 0 && !msg.sender.send(remainder)) {
            dividends[msg.sender] = dividends[msg.sender].add(remainder);
            PaymentAvailable(msg.sender, remainder);
        }*/

        /* Audit this */
        DividendPayment(paymentPerShare, now);
    }

    /* Allows a user to request a withdrawal of their dividend in full. */
    function withdrawDividend() {
        // Ensure we have dividends available
        if (dividends[msg.sender] == 0)
            throw;
        
        // Determine how much we're sending and reset the count
        uint256 dividend = dividends[msg.sender];
        dividends[msg.sender] = 0;

        // Attempt to withdraw
        if (!msg.sender.send(dividend))
            throw;
    }
}

//interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

/**
 * The shareholder association contract 
 */
contract XWinAssociation {
    
    address public manager = "0xE3ff0BA0C6E7673f46C7c94A5155b4CA84a5bE0C";

    uint public changeManagerQuorum = 80; // in % of tokens
    
    uint public debatingPeriod = 3 days;
    Proposal[] public proposals;
    uint public numProposals;
    XWinToken public sharesTokenAddress;

    event ProposalAdded(uint proposalID, address newManager, string description);
    event Voted(uint proposalID, bool position, address voter);
    event ProposalTallied(uint proposalID, uint result,bool active);
    event ChangeOfRules(uint newMinimumQuorum, uint newDebatingPeriodInMinutes, address newSharesTokenAddress);

    struct Proposal {
        address newManager;
        string description;
        uint votingDeadline;
        bool executed;
        bool proposalPassed;
        uint numberOfVotes;
        bytes32 proposalHash;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Vote {
        bool inSupport;
        address voter;
    }

    // Modifier that allows only shareholders to vote and create new proposals
    modifier onlyShareholders {
        require(sharesTokenAddress.balanceOf(msg.sender) > 0);
        _;
    }

    // Modifier that allows only manager
    modifier onlyManager {
        require(msg.sender == manager);
        _;
    }

    /**
     * Constructor function
     */
    function XWinAssociation(address _xwinContractAddress)  {
        sharesTokenAddress = XWinToken(_xwinContractAddress);
    }
    
    // change debating period by manager
    function changeVoteRules (uint debatingPeriodInDays) onlyManager {
        debatingPeriod = debatingPeriodInDays * 1 days;
    }

    // transfer ethers from contract account    
    function transferEthers(address receiver, uint valueInWei) onlyManager {
        uint value = valueInWei;
        require ( this.balance > value);
        receiver.send(value);
    }
    
    function () payable {
        
    }

    /**
     * Add Proposal
     */
    function newProposal(
        address newManager,
        string managerDescription
    )
        onlyShareholders
        returns (uint proposalID)
    {
        proposalID = proposals.length++;
        Proposal storage p = proposals[proposalID];
        p.newManager = newManager;
        p.description = managerDescription;
        p.proposalHash = sha3(newManager);
        p.votingDeadline = now + debatingPeriod;
        p.executed = false;
        p.proposalPassed = false;
        p.numberOfVotes = 0;
        ProposalAdded(proposalID, newManager, managerDescription);
        numProposals = proposalID+1;

        return proposalID;
    }

    /**
     * Check if a proposal code matches
     */
    function checkProposalCode(
        uint proposalNumber,
        address newManager
    )
        constant
        returns (bool codeChecksOut)
    {
        Proposal storage p = proposals[proposalNumber];
        return p.proposalHash == sha3(newManager);
    }

    /**
     * Log a vote for a proposal
     *
     * Vote `supportsProposal? in support of : against` proposal #`proposalNumber`
     *
     * @param proposalNumber number of proposal
     * @param supportsProposal either in favor or against it
     */
    function vote(
        uint proposalNumber,
        bool supportsProposal
    )
        onlyShareholders
        returns (uint voteID)
    {
        Proposal storage p = proposals[proposalNumber];
        require(p.voted[msg.sender] != true);

        voteID = p.votes.length++;
        p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
        p.voted[msg.sender] = true;
        p.numberOfVotes = voteID +1;
        Voted(proposalNumber,  supportsProposal, msg.sender);
        return voteID;
    }

    /**
     * Finish vote
     */
    function executeProposal(uint proposalNumber, address newManager) {
        Proposal storage p = proposals[proposalNumber];

        require(now > p.votingDeadline                                          // If it is past the voting deadline
            && !p.executed                                                      // and it has not already been executed
            && p.proposalHash == sha3(newManager));                             // and the supplied code matches the proposal...

        // ...then tally the results
        uint yea = 0;
 
        for (uint i = 0; i <  p.votes.length; ++i) {
            Vote storage v = p.votes[i];
            uint voteWeight = sharesTokenAddress.balanceOf(v.voter);
            if (v.inSupport) 
                yea += voteWeight;
        }

        if ( yea > changeManagerQuorum * 10**sharesTokenAddress.decimals() ) {
            // Proposal passed; execute the transaction

            manager = newManager;
            p.executed = true;

            p.proposalPassed = true;
        }

        // Fire Events
        ProposalTallied(proposalNumber, yea , p.proposalPassed);
    }
}


contract XWinBet {
    
    using SafeMath for uint256;
    
    event BetAdded(uint betId, address bettor, uint value, uint rate, uint deadline);
    event BetExecuted(uint betId, address bettor, uint winValue);
    event FoundsTransferd(address dao, uint value);
    
    XWinAssociation dao;        // address of XWin Association contract
    
    uint public numBets;        // count of bets
    uint public reservedWeis;   // reserved weis for actual bets
    
    struct Bet {
        address bettor;
        uint value;
        uint rate;      // with 3 symbols after point, for example: 1234 = 1.234
        uint deadline;
        bytes32 betHash;
        bool executed;
    }
    
    Bet[] public bets;
    
    // Modifier that allows only manager
    modifier onlyManager {
        require(msg.sender == dao.manager());
        _;
    }
    
    function XWinBet(address daoContract) {
        dao = XWinAssociation(daoContract);
    }
    
    function () payable {
    }
    
    function transferEthersToDao(uint valueInEthers) onlyManager {
        require(this.balance.sub(reservedWeis) >= valueInEthers * 1 ether);
        dao.transfer(valueInEthers * 1 ether);
        FoundsTransferd(dao, valueInEthers * 1 ether);
    }
    
    function bet (uint rate, uint timeLimitInMinutes) payable returns (uint betID)
    {
        uint reserved =  msg.value.mul(rate).div(1000);
        require ( this.balance > reservedWeis.add(reserved));
        reservedWeis = reservedWeis.add(reserved);
        
        betID = bets.length++;
        Bet storage b = bets[betID];
        b.bettor = msg.sender;
        b.value = msg.value;
        b.rate = rate;
        b.deadline = now + timeLimitInMinutes * 1 minutes;
        b.betHash = sha3(betID,msg.sender,msg.value,rate,b.deadline);
        b.executed = false;

        BetAdded(betID, msg.sender,msg.value,rate,b.deadline);
        numBets = betID+1;

        return betID;
    }
    
    function executeBet (uint betId, bool win) 
    {
        
        Bet b = bets[betId];
        require (now > b.deadline);
        require (!b.executed);
        require (msg.sender == b.bettor);
        require (sha3(betId,msg.sender,b.value,b.rate,b.deadline)==b.betHash);
    
        uint winValue = b.value.mul(b.rate).div(1000);
        reservedWeis = reservedWeis.sub(winValue);
        if (win)
        {
            msg.sender.transfer(winValue);
            BetExecuted(betId,msg.sender,winValue);
        }
        else
        {
            BetExecuted(betId, msg.sender,0);
        }
        
        b.executed = true;
    }
}