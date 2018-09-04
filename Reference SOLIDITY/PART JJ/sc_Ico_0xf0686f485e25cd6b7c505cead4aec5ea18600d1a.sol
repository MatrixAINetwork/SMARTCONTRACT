/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;


contract Owned
{
    address public owner;

    modifier onlyOwner
	{
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner()
	{
        owner = newOwner;
    }
}

contract EIP20Interface {
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
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract EIP20 is EIP20Interface {

    uint256 constant MAX_UINT256 = 2**256 - 1;

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

     function EIP20(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
    view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract Gabicoin is Owned, EIP20
{
    // Struct for ico minting.
    struct IcoBalance
    {
        bool hasTransformed;// Has transformed ico balances to real balance for this user?
        uint[3] balances;// Balances.
    }

    // Mint event.
    event Mint(address indexed to, uint value, uint phaseNumber);

    // Activate event.
    event Activate();

    // Constructor.
    function Gabicoin() EIP20(0, "Gabicoin", 2, "GCO") public
    {
        owner = msg.sender;
    }

    // Mint function for ICO.
    function mint(address to, uint value, uint phase) onlyOwner() external
    {
        require(!isActive);

        icoBalances[to].balances[phase] += value;// Increase ICO balance.

        Mint(to, value, phase);
    }

    // Activation function after successful ICO.
    function activate(bool i0, bool i1, bool i2) onlyOwner() external
    {
        require(!isActive);// Only for not yet activated token.

        activatedPhases[0] = i0;
        activatedPhases[1] = i1;
        activatedPhases[2] = i2;

        Activate();
        
        isActive = true;// Activate token.
    }

    // Transform ico balance to standard balance.
    function transform(address addr) public
    {
        require(isActive);// Only after activation.
        require(!icoBalances[addr].hasTransformed);// Only for not transfromed structs.

        for (uint i = 0; i < 3; i++)
        {
            if (activatedPhases[i])// Check phase activation.
            {
                balances[addr] += icoBalances[addr].balances[i];// Increase balance.
                Transfer(0x00, addr, icoBalances[addr].balances[i]);
                icoBalances[addr].balances[i] = 0;// Set ico balance to zero.
            }
        }

        icoBalances[addr].hasTransformed = true;// Set struct to transformed status.
    }

    // For simple call transform().
    function () payable external
    {
        transform(msg.sender);
        msg.sender.transfer(msg.value);
    }

    // Activated on ICO phases.
    bool[3] public activatedPhases;

    // Token activation status.
    bool public isActive;

    // Ico balances.
    mapping (address => IcoBalance) public icoBalances;
}

contract Bounty is Owned
{
    // Get bounty event.
    event GetBounty(address indexed bountyHunter, uint amount);

    // Add bounty event.
    event AddBounty(address indexed bountyHunter, uint amount);

    // Constructor.
    function Bounty(address gabicoinAddress) public
    {
        owner = msg.sender;
        token = gabicoinAddress;
    }

    // Add bounty for hunter.
    function addBountyForHunter(address hunter, uint bounty) onlyOwner() external returns (bool)
    {
        require(!Gabicoin(token).isActive());// Check token activity.

        bounties[hunter] += bounty;// Increase bounty for hunter.
        bountyTotal += bounty;// Increase total bounty value.

        AddBounty(hunter, bounty);// Call add bounty event.

        return true;
    }

    // Get bounty.
    function getBounty() external returns (uint)
    {
        require(Gabicoin(token).isActive());// Check token activity.
        require(bounties[msg.sender] != 0);// Check balance of bounty hunter.
        
        if (Gabicoin(token).transfer(msg.sender, bounties[msg.sender]))// Transfer bounty tokens to bounty hunter.
        {
            uint amount = bounties[msg.sender];
            bountyTotal -= amount;// Decrease total bounty.

            GetBounty(msg.sender, amount);// Get bounty event.
            
            bounties[msg.sender] = 0;// Set bounty for hunter to zero.

            return amount;
        }
        else
        {
            return 0;
        }
    }

    // Bounties.
    mapping (address => uint) public bounties;

    // Total bounty.
    uint public bountyTotal = 0;

    // Gabicoin token.
    address public token;
}

contract Ico is Owned
{
    // Posible ICO states.
    enum State
    {
        Runned,
        Paused,
        Finished,
        Failed
    }

    // Refund event.
    event Refund(address indexed investor, uint value);

    // Update event.
    event UpdateState(State oldState, State newState);

    // Activation event.
    event Activate();

    // Buying token event.
    event BuyTokens(address indexed buyer, uint value, uint indexed phaseNumber);

    // Geting ethereum from ICO or Pre-ICO event.
    event GetEthereum(address indexed recipient, uint value);

    // Contracutor.
    function Ico(address _token, address _bounty, uint[3] _startDates, uint[3] _endDates, uint[3] _prices, uint[3] _hardCaps) public
    {
        // Save addresses.
        owner = msg.sender;
        token = _token;
        bounty = _bounty;

        // Save info abount phases.
        for (uint i = 0; i < 3; i++)
        {
            startDates[i] = _startDates[i];
            endDates[i] = _endDates[i];
            prices[i] = _prices[i];
            hardCaps[i] = _hardCaps[i];
        }

        state = State.Runned;
    }

    // Return true if date in phase with given number.
    function isPhase(uint number, uint date) view public returns (bool)
    {
        return startDates[number] <= date && date <= endDates[number];
    }

    // Return true for succesfull Pre-ICO.
    function preIcoWasSuccessful() view public returns (bool)
    {
        return ((totalInvested[0] / prices[0]) / 2 >= preIcoSoftCap);
    }

    // Return true for succesfull ICO.
    function icoWasSuccessful() view public returns (bool)
    {
        return ((totalInvested[1] / prices[1]) + (totalInvested[2] * 5 / prices[2] / 4) >= icoSoftCap);
    }

    // Return ether funds
    function refund() public
    {
        uint amount = 0;

        if (state == State.Failed)// Check failed state.
        {
            if (!preIcoCashedOut)// Check cash out from ICO.
            {
                amount += invested[msg.sender][0];// Add Pre-ICO funds.
                invested[msg.sender][0] = 0;// Set Pre-ICO funds to zero.
            }

            amount += invested[msg.sender][1];
            amount += invested[msg.sender][2];
            
            // Set invested funds to zero.
            invested[msg.sender][1] = 0;
            invested[msg.sender][2] = 0;
            
            Refund(msg.sender, amount);

            msg.sender.transfer(amount);// Send funds.
        }
        else if (state == State.Finished)// Check finished state.
        {
            if (!preIcoWasSuccessful())
            {
                amount += invested[msg.sender][0];// Add Pre-ICO funds.
                invested[msg.sender][0] = 0;// Set Pre-ICO funds to zero.
            }

            if (!icoWasSuccessful())
            {
                amount += invested[msg.sender][1];
                amount += invested[msg.sender][2];

                // Set invested funds to zero.
                invested[msg.sender][1] = 0;
                invested[msg.sender][2] = 0;
            }
            
            Refund(msg.sender, amount);

            msg.sender.transfer(amount);// Send funds.
        }
        else
        {
            revert();
        }
    }

    // Update state.
    function updateState() public
    {
        require(state == State.Runned);

        if (now >= endDates[2])// ICO and Pre-ICO softcaps have achieved.
        {
            if (preIcoWasSuccessful() || icoWasSuccessful())
            {
                UpdateState(state, State.Finished);
                state = State.Finished;
            }
            else
            {
                UpdateState(state, State.Failed);
                state = State.Failed;
            }
        }
    }
    
    // Activate Gabicoin if that's posible.
    function activate() public
    {
        require(!Gabicoin(token).isActive());// Check token activity.
        require(state == State.Finished);// Check state.

        Activate();

        Gabicoin(token).mint(bounty, 3 * 100 * 10 ** 6, preIcoWasSuccessful() ? 0 : 1);

        Gabicoin(token).activate(preIcoWasSuccessful(), icoWasSuccessful(), icoWasSuccessful());// Activate Gabicoin.
    }

    // Fallback payable function.
    function () payable external
    {
        if (state == State.Failed)// Check state for Failed or Expired states.
        {
            refund();// Refund invested funds for sender.
            return;
        }
        else if (state == State.Finished)// Check finished state.
        {
            refund();// Refund invested funds for sender.
            return;
        }
        else if (state == State.Runned)// Check runned state.
        {
            if (isPhase(0, now))
            {
                buyTokens(msg.sender, msg.value, 0);
            }
            else if (isPhase(1, now))
            {
                buyTokens(msg.sender, msg.value, 1);
            }
            else if (isPhase(2, now))
            {
                buyTokens(msg.sender, msg.value, 2);
            }
            else
            {
                msg.sender.transfer(msg.value);
            }

            updateState();// Update ICO state after payable transactions.
        }
        else
        {
            msg.sender.transfer(msg.value);
        }
    }

    // Buy tokens function.
    function buyTokens(address buyer, uint value, uint phaseNumber) internal
    {
        require(totalInvested[phaseNumber] < hardCaps[phaseNumber]);// Check investment posibility.

        // Define local variables here.
        uint amount;
        uint rest;

        // Compute rest.
        if (totalInvested[phaseNumber] + value / prices[phaseNumber] > hardCaps[phaseNumber])
        {
            rest = hardCaps[phaseNumber] * prices[phaseNumber] - totalInvested[phaseNumber];
        }
        else
        {
            rest = value % prices[phaseNumber];
        }

        amount = value - rest;
        require(amount > 0);
        invested[buyer][phaseNumber] += amount;
        totalInvested[phaseNumber] += amount;
        BuyTokens(buyer, amount, phaseNumber);
        Gabicoin(token).mint(buyer, amount / prices[phaseNumber], phaseNumber);
        msg.sender.transfer(rest);// Return changes.
    }

    // Pause contract.
    function pauseIco() onlyOwner() external
    {
        require(state == State.Runned);// Only from Runned state.
        UpdateState(state, State.Paused);
        state = State.Paused;// Set state to Paused.
    }

    // Continue paused contract.
    function continueIco() onlyOwner() external
    {
        require(state == State.Paused);// Only from Paused state.
        UpdateState(state, State.Runned);
        state = State.Runned;// Set state to Runned.
    }

    // End contract unsuccessfully.
    function endIco() onlyOwner() external
    {
        require(state == State.Paused);// Only from Paused state.
        UpdateState(state, State.Failed);
        state = State.Failed;// Set state to Expired.
    }

    // Get funds from successful Pre-ICO.
    function getPreIcoFunds() onlyOwner() external returns (uint)
    {
        require(state != State.Failed && state != State.Paused);// Check state.
        require(now >= endDates[0]);// Check ending of Pre-ICO.
        require(!preIcoCashedOut);// Check cash out from Pre-ICO.

        if (preIcoWasSuccessful())
        {
            uint value = totalInvested[0];
            preIcoCashedOut = true;
            msg.sender.transfer(value);
            GetEthereum(msg.sender, value);
            return value;
        }

        return 0;
    }

    // Get ethereum funds from ICO.
    function getEtherum() onlyOwner() external returns (uint)
    {
        require(state == State.Finished);// Check state.
        require(now >= endDates[2]);// Check end of ICO.

        if (icoWasSuccessful())
        {
            uint value = totalInvested[1] + totalInvested[2];
            msg.sender.transfer(value);
            GetEthereum(msg.sender, value);
            return value;
        }
        
        return 0;
    }

    // Crowdsale state.
    State public state;

    // Invested from address.
    mapping (address => uint[3]) public invested;

    // Total invested at each phase.
    uint[3] public totalInvested;

    // Pre-ICO softcap.
    uint public preIcoSoftCap = 2 * 100 * 10 ** 5;

    // ICO softcap.
    uint public icoSoftCap = 100 * 10 ** 6;

    // Bounty contract address.
    address public bounty;

    // Token contract address.
    address public token;

    // Start dates of ICO phases.
    uint[3] public startDates;

    // End dates of ICO phases.
    uint[3] public endDates;

    // Prices of token at each phase.
    uint[3] public prices;

    // Hard caps of ICO phases.
    uint[3] public hardCaps;

    // Pre-ICO cashed out.
    bool public preIcoCashedOut;
}