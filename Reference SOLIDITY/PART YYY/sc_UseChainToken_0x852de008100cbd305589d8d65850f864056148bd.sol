/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

// Owned contract
// -----------------------------------------------------------------------------
contract Controlled {

    address public controller;

    function Controlled() public {
        controller = msg.sender;
    }

    modifier onlyController() {
        require(msg.sender == controller);
        _;
    }

    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}

// Safe maths, borrowed from OpenZeppelin
// ----------------------------------------------------------------------------
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
}
// tokenRecipient contract
// ----------------------------------------------------------------------------
contract tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

// standard ERC20 Token interface
// ----------------------------------------------------------------------------
contract ERC20Token {
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
    function balanceOf(address _owner) constant public returns (uint256 balance);

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
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// AddressLimit contract
// ----------------------------------------------------------------------------
contract AddressLimit {
    modifier notContractAddress(address _addr) {
        require (!isContractAddress(_addr));
        _;
    }
    
    function isContractAddress(address _addr) internal constant returns(bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}

// standard ERC20 Token
// ----------------------------------------------------------------------------
contract standardToken is ERC20Token, AddressLimit {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    bool public tokenFrozen = true;
    
    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(
        address _owner) 
        constant 
        public 
        returns (uint256) 
    {
        return balances[_owner];
    }

    /// @notice Send `_value` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(
        address _to,
        uint256 _value) 
        public 
        notContractAddress(_to) 
        returns (bool success) 
    {
        require (!tokenFrozen);                             // Throw if token is frozen
        require (balances[msg.sender] >= _value);           // Throw if sender has insufficient balance
        require (balances[_to] + _value >= balances[_to]);  // Throw if owerflow detected
        balances[msg.sender] -= _value;                     // Deduct senders balance
        balances[_to] += _value;                            // Add recivers balance
        Transfer(msg.sender, _to, _value);                  // Raise Transfer event
        return true;
    }
    
    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(
        address _spender, 
        uint256 _value) 
        public 
        returns (bool success) 
    {
        require (!tokenFrozen);                             // Throw if token is frozen
        allowances[msg.sender][_spender] = _value;          // Set allowance
        Approval(msg.sender, _spender, _value);             // Raise Approval event
        return true;
    }

    /// @notice `msg.sender` approves `_spender` to send `_value` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param _spender The address of the contract able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return True if the function call was successful
    function approveAndCall(
        address _spender, 
        uint256 _value, 
        bytes _extraData) 
        public 
        returns (bool success) 
    {
        require (!tokenFrozen);                                         // Throw if token is frozen
        tokenRecipient spender = tokenRecipient(_spender);              // Cast spender to tokenRecipient contract
        approve(_spender, _value);                                      // Set approval to contract for _value
        spender.receiveApproval(msg.sender, _value, this, _extraData);  // Raise method on _spender contract
        return true;
    }

    /// @notice Send `_value` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _value The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value) 
        public 
        notContractAddress(_to)
        returns (bool success) 
    {
        require (!tokenFrozen);                             // Throw if token is frozen
        require (balances[_from] >= _value);                // Throw if sender does not have enough balance
        require (balances[_to] + _value >= balances[_to]);  // Throw if overflow detected
        require (_value <= allowances[_from][msg.sender]);  // Throw if you do not have allowance
        balances[_from] -= _value;                          // Deduct senders balance
        balances[_to] += _value;                            // Add recipient balance
        allowances[_from][msg.sender] -= _value;            // Deduct allowance for this address
        Transfer(_from, _to, _value);                       // Raise Transfer event
        return true;
    }

    /// @dev This function makes it easy to read the `allowances[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed to spend
    function allowance(
        address _owner, 
        address _spender) 
        constant 
        public 
        returns (uint256) 
    {
        return allowances[_owner][_spender];
    }

}

contract UseChainToken is standardToken, Controlled {
    
    ///          startCrowdsaleTime                                                          stopCrowdsaleTime          
    ///                  |<private placement>|     |<private presale>|         |<public sale>|
    ///               o-----------------------o----------------------o------------------------------o
    ///                      <10% OFF>                <5%  OFF>   
    ///  payment accepted:   <BTC/ETH>                <BTC/ETH>                <BTC/ETH> 
    
    using SafeMath for uint;

    string constant public name   = "UseChainToken";
    string constant public symbol = "UST";
    uint constant public decimals = 18;

    uint256 public totalSupply = 0;
    uint256 constant public topTotalSupply = 2*10**7*10**decimals;
    uint public corporateSupply        = percent(topTotalSupply, 20);
    uint public privatePlacementSupply = percent(topTotalSupply, 8);
    uint public privatePresaleSupply   = percent(topTotalSupply, 12);
    uint public publicSaleSupply       = percent(topTotalSupply, 10);
    uint public ecoFundSupply          = percent(topTotalSupply, 50);
    uint public softCap                = percent(topTotalSupply, 6);
    uint public startCrowdsaleTime;
    uint public stopCrowdsaleTime;
    address public walletAddress;
    bool    public finalized; 
    
    /// @notice Several stages
    enum stageAt {
        notStart,
        privatePlacement,
        privatePresale,
        publicSale,
        finalState
    }
    
    /// @notice only Wallet address
    modifier onlyWalletAddr() {
        require (walletAddress == msg.sender);
        _;
    }
    
    /// @dev Fallback to calling deposit when ether is sent directly to contract.
    function() public payable {
        require(!finalized);
        depositToken(msg.value);
        if(this.balance >= 10 ether) {
            walletAddress.transfer(this.balance);
        }
    }
    
    /// @notice Initial function
    function UseChainToken(uint _startCrowdsaleTime, uint _stopCrowdsaleTime, address _walletAddress) public {
        controller = msg.sender;
        startCrowdsaleTime = _startCrowdsaleTime;
        stopCrowdsaleTime = _stopCrowdsaleTime;
        walletAddress = _walletAddress;
    }
    
    /// @dev Buys tokens with Ether.
    function depositToken(uint _value) internal {
        require(_value >= minimalRequire());
        uint tokenAlloc = buyPriceAt(exchangePrice * _value);
        require (tokenAlloc != 0);
        mintTokens(msg.sender, tokenAlloc);
    }

    /// @dev Issue new tokens
    function mintTokens(address _to, uint _amount) internal {
        require (balances[_to] + _amount >= balances[_to]);      // Check for overflows
        totalSupply = totalSupply.add(_amount);
        require(totalSupply <= topTotalSupply);
        balances[_to] = balances[_to].add(_amount);             // Set minted coins to target
        Transfer(0x0, _to, _amount);                            // Create Transfer event from 0x0
    }
    
    /// @notice Minimal requirement
    function minimalRequire() internal constant returns(uint) {
        if (stageNow() == stageAt.publicSale) {
            return 1 ether;
        }
        if (stageNow() == stageAt.privatePresale) {
            return 10 ether;
        }
        if (stageNow() == stageAt.privatePlacement) {
            return 100 ether;
        }
    }
    
    uint public publicAllocatingToken;
    uint public privatePlacementAllocatingToken;
    uint public privatePresaleAllocatingToken;
    
    /// @notice Calculate exchange:
    /// private Placement Stage : 10% OFF
    /// private Presale Stage   : 5% OFF
    function buyPriceAt(uint256 _tokenAllocWithoutDiscount) internal returns(uint) {
        if (stageNow() == stageAt.publicSale) {
            publicAllocatingToken = publicAllocatingToken.add(_tokenAllocWithoutDiscount);
            require(publicAllocatingToken <= publicSaleSupply);
            return _tokenAllocWithoutDiscount;
        }
        if (stageNow() == stageAt.privatePresale) {
            uint _privatePresaleAlloc = _tokenAllocWithoutDiscount + percent(_tokenAllocWithoutDiscount, 5);
            privatePresaleAllocatingToken = privatePresaleAllocatingToken.add(_privatePresaleAlloc);
            require(privatePresaleAllocatingToken <= privatePresaleSupply);
            return _privatePresaleAlloc;
        }
        if (stageNow() == stageAt.privatePlacement) {
            uint _privatePlacementAlloc = _tokenAllocWithoutDiscount + percent(_tokenAllocWithoutDiscount, 10);
            privatePlacementAllocatingToken = privatePlacementAllocatingToken.add(_privatePlacementAlloc);
            require(privatePlacementAllocatingToken <= privatePlacementSupply);
            return _privatePlacementAlloc;
        }
        if (stageNow() == stageAt.notStart) {
            return 0;
        }
        if (stageNow() == stageAt.finalState) {
            return 0;
        }
    }
    
    /// @dev Check the current stage
    function stageNow() constant internal returns (stageAt) {
        if (getTimestamp() < startCrowdsaleTime) {
            return stageAt.notStart;
        }
        else if(getTimestamp() < startCrowdsaleTime + 27 days) {
            return stageAt.privatePlacement;
        }
        else if(getTimestamp() < startCrowdsaleTime + 71 days) {
            return stageAt.privatePresale;
        }
        else if(getTimestamp() < stopCrowdsaleTime) {
            return stageAt.publicSale;
        }
        else {
            return stageAt.finalState;
        }
    }
    
    /// @dev calcute the tokens
    function percent(uint _token, uint _percentage) internal pure returns (uint) {
        return _percentage.mul(_token).div(100);
    }
    
    uint public exchangePrice = 90;
    
    /// @dev Set exchange Price
    function setExchangePrice( uint _price) public onlyController returns(uint) {
        exchangePrice = _price;
    }
    
    /// @dev Get current timestamp
    function getTimestamp() internal constant returns(uint) {
        return now;
    }
    
    function withDraw() public payable onlyController {
        require (walletAddress != address(0));
        walletAddress.transfer(this.balance);
    }
    
    /// @notice unfreeze token transfer
    function unfreezeTokenTransfer(bool _freeze) public onlyController {
        tokenFrozen = !_freeze;
    }
    
    /// @notice only wallet address can set new wallet address
    function setWalletAddress(address _walletAddress) public onlyWalletAddr {
        walletAddress = _walletAddress;
    }
    
    /// @dev allocate private stage tokens
    function allocateTokens(address[] _owners, uint256[] _values) public onlyController {
        require (_owners.length == _values.length);
        for(uint i = 0; i < _owners.length ; i++){
            address owner = _owners[i];
            uint value = _values[i];
            mintTokens(owner, value);
        }
    }
    

    function allocateCorporateToken(address _corAccount, uint256 _amount) public onlyController {
        require(_corAccount != address(0));
        require(balances[_corAccount] + _amount <= corporateSupply);
        mintTokens(_corAccount, _amount);
    }
    
    uint public ecoFundingSupply;
    
    function allocateEcoFundToken(address[] _owners, uint256[] _values) public onlyController {
        require (_owners.length == _values.length);
        for(uint i = 0; i < _owners.length ; i++){
            address owner = _owners[i];
            uint256 value = _values[i];
            ecoFundingSupply = ecoFundingSupply.add(value);
            require(ecoFundingSupply <= ecoFundSupply);
            mintTokens(owner, value);
        }
    }
        
    /// @notice finalize
    function finalize() public onlyController {
        // only after closed stage
        require(stageNow() == stageAt.finalState);     
        require(totalSupply + ecoFundSupply >= softCap);
        finalized = true;
    }
    
}