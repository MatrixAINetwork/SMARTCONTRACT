/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.15;

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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    //Variables
    address public owner;

    address public newOwner;

    //    Modifiers
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}


contract TokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}


contract ERC20 is Ownable {

    using SafeMath for uint256;

    /* Public variables of the token */
    string public standard;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public initialSupply;

    bool public locked;

    uint256 public creationBlock;

    mapping (address => uint256) public balances;

    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords.mul(32).add(4));
        _;
    }

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function ERC20(
        uint256 _initialSupply,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transferAllSupplyToOwner,
        bool _locked
    ) {
        standard = "ERC20 0.1";

        initialSupply = _initialSupply;

        if (_transferAllSupplyToOwner) {
            setBalance(msg.sender, initialSupply);
        } else {
            setBalance(this, initialSupply);
        }

        name = _tokenName;
        // Set the name for display purposes
        symbol = _tokenSymbol;
        // Set the symbol for display purposes
        decimals = _decimalUnits;
        // Amount of decimals for display purposes
        locked = _locked;
        creationBlock = block.number;
    }

    /* public methods */
    function totalSupply() public constant returns (uint256) {
        return initialSupply;
    }

    function balanceOf(address _address) public constant returns (uint256) {
        return balances[_address];
    }

    function transfer(address _to, uint256 _value) public onlyPayloadSize(2) returns (bool) {
        require(locked == false);

        bool status = transferInternal(msg.sender, _to, _value);

        require(status == true);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (locked) {
            return false;
        }

        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        if (locked) {
            return false;
        }

        TokenRecipient spender = TokenRecipient(_spender);

        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (locked) {
            return false;
        }

        if (allowance[_from][msg.sender] < _value) {
            return false;
        }

        bool _success = transferInternal(_from, _to, _value);

        if (_success) {
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        }

        return _success;
    }

    /* internal balances */
    function setBalance(address _holder, uint256 _amount) internal {
        balances[_holder] = _amount;
    }

    function transferInternal(address _from, address _to, uint256 _value) internal returns (bool success) {
        if (_value == 0) {
            Transfer(_from, _to, 0);
            return true;
        }

        if (balances[_from] < _value) {
            return false;
        }

        setBalance(_from, balances[_from].sub(_value));
        setBalance(_to, balances[_to].add(_value));

        Transfer(_from, _to, _value);

        return true;
    }

}

/*
This contract manages the minters and the modifier to allow mint to happen only if called by minters
This contract contains basic minting functionality though
*/
contract MintingERC20 is ERC20 {

    using SafeMath for uint256;

    uint256 public maxSupply;

    mapping (address => bool) public minters;

    modifier onlyMinters () {
        require(true == minters[msg.sender]);
        _;
    }

    function MintingERC20(
        uint256 _initialSupply,
        uint256 _maxSupply,
        string _tokenName,
        uint8 _decimals,
        string _symbol,
        bool _transferAllSupplyToOwner,
        bool _locked
    )
        ERC20(_initialSupply, _tokenName, _decimals, _symbol, _transferAllSupplyToOwner, _locked)
    {
        minters[msg.sender] = true;
        maxSupply = _maxSupply;
    }

    function addMinter(address _newMinter) public onlyOwner {
        minters[_newMinter] = true;
    }

    function removeMinter(address _minter) public onlyOwner {
        minters[_minter] = false;
    }

    function mint(address _addr, uint256 _amount) public onlyMinters returns (uint256) {
        if (_amount == uint256(0)) {
            return uint256(0);
        }

        if (totalSupply().add(_amount) > maxSupply) {
            return uint256(0);
        }

        initialSupply = initialSupply.add(_amount);
        balances[_addr] = balances[_addr].add(_amount);
        Transfer(0, _addr, _amount);

        return _amount;
    }
}

contract Totum is MintingERC20 {

    using SafeMath for uint256;

    TotumPhases public totumPhases;

    // Block token transfers till ICO end.
    bool public transferFrozen = true;

    function Totum(
    uint256 _maxSupply,
    string _tokenName,
    string _tokenSymbol,
    uint8 _precision,
    bool _locked
    )
    MintingERC20(0, _maxSupply, _tokenName, _precision, _tokenSymbol, false, _locked)
    {
        standard = "Totum 0.1";
    }

    function setLocked(bool _locked) public onlyOwner {
        locked = _locked;
    }

    function setTotumPhases(address _totumPhases) public onlyOwner {
        totumPhases = TotumPhases(_totumPhases);
    }

    function unfreeze() public onlyOwner {
        if (totumPhases != address(0) && totumPhases.isFinished(1)) {
            transferFrozen = false;
        }
    }

    function buyBack(address _address) public onlyMinters returns (uint256) {
        require(address(_address) != 0x0);

        uint256 balance = balanceOf(_address);
        setBalance(_address, 0);
        setBalance(this, balanceOf(this).add(balance));
        Transfer(_address, this, balance);

        return balance;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        require(!transferFrozen);

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(!transferFrozen);

        return super.transferFrom(_from, _to, _value);
    }

}

contract TotumAllocation is Ownable {

    using SafeMath for uint256;

    address public bountyAddress;

    address public teamAddress;

    address public preICOAddress;

    address public icoAddress;

    address public icoAddress1;

    function TotumAllocation(
    address _bountyAddress, //5%
    address _teamAddress, //7%
    address _preICOAddress,
    address _icoAddress, //50%
    address _icoAddress1 //50%
    ) {
        require((address(_bountyAddress) != 0x0) && (address(_teamAddress) != 0x0));
        require((address(_preICOAddress) != 0x0) && (address(_icoAddress) != 0x0) && (address(_icoAddress1) != 0x0));

        bountyAddress = _bountyAddress;
        teamAddress = _teamAddress;
        preICOAddress = _preICOAddress;
        icoAddress = _icoAddress;
        icoAddress1 = _icoAddress1;
    }

}

contract TotumPhases is Ownable {

    using SafeMath for uint256;

    Totum public totum;

    TotumAllocation public totumAllocation;

    Phase[] public phases;

    uint256 public constant DAY = 86400;

    uint256 public collectedEthers;

    uint256 public soldTokens;

    uint256 public investorsCount;

    mapping (address => uint256) public icoEtherBalances;

    mapping (address => bool) private investors;

    event Refund(address holder, uint256 ethers, uint256 tokens);

    struct Phase {
    uint256 price;
    uint256 minInvest;
    uint256 softCap;
    uint256 hardCap;
    uint256 since;
    uint256 till;
    bool isSucceed;
    }

    function TotumPhases(
    address _totum,
    uint256 _minInvest,
    uint256 _tokenPrice, //0.0033 ethers
    uint256 _preIcoMaxCap,
    uint256 _preIcoSince,
    uint256 _preIcoTill,
    uint256 _icoMinCap,
    uint256 _icoMaxCap,
    uint256 _icoSince,
    uint256 _icoTill
    ) {
        require(address(_totum) != 0x0);
        totum = Totum(address(_totum));

        require((_preIcoSince < _preIcoTill) && (_icoSince < _icoTill) && (_preIcoTill <= _icoSince));
        require((_preIcoMaxCap < _icoMaxCap) && (_icoMaxCap < totum.maxSupply()));

        phases.push(Phase(_tokenPrice, _minInvest, 0, _preIcoMaxCap, _preIcoSince, _preIcoTill, false));
        phases.push(Phase(_tokenPrice, _minInvest, _icoMinCap, _icoMaxCap, _icoSince, _icoTill, false));
    }

    function() public payable {
        require(buy(msg.sender, msg.value) == true);
    }

    function setCurrentRate(uint256 _rate) public onlyOwner {
        require(_rate > 0);
        for (uint i = 0; i < phases.length; i++) {
            Phase storage phase = phases[i];
            phase.price = _rate;
        }
    }

    function setTotum(address _totum) public onlyOwner {
        totum = Totum(_totum);
    }

    function setTotumAllocation(address _totumAllocation) public onlyOwner {
        totumAllocation = TotumAllocation(_totumAllocation);
    }

    function setPhase(
    uint8 _phaseId,
    uint256 _since,
    uint256 _till,
    uint256 _price,
    uint256 _softCap,
    uint256 _hardCap
    ) public onlyOwner returns (bool) {
        require((phases.length > _phaseId) && (_price > 0));
        require((_till > _since) && (_since > 0));
        require((totum.maxSupply() > _hardCap) && (_hardCap > _softCap) && (_softCap >= 0));

        Phase storage phase = phases[_phaseId];

        if (phase.isSucceed == true) {
            return false;
        }
        phase.since = _since;
        phase.till = _till;
        phase.price = _price;
        phase.softCap = _softCap;
        phase.hardCap = _hardCap;

        return true;
    }

    function sendToAddress(address _address, uint256 _tokens) public onlyOwner returns (bool) {
        if (_tokens == 0 || address(_address) == 0x0) {
            return false;
        }
        uint256 totalAmount = _tokens.add(getBonusAmount(_tokens, now));
        if (getTokens().add(totalAmount) > totum.maxSupply()) {
            return false;
        }

        bool status = (totalAmount != totum.mint(_address, totalAmount));
        if (status) {
            soldTokens = soldTokens.add(totalAmount);
            increaseInvestorsCount(_address);
        }

        return status;
    }

    function sendToAddressWithTime(address _address, uint256 _tokens, uint256 _time) public onlyOwner returns (bool) {
        if (_tokens == 0 || address(_address) == 0x0 || _time == 0) {
            return false;
        }

        uint256 totalAmount = _tokens.add(getBonusAmount(_tokens, _time));

        if (getTokens().add(totalAmount) > totum.maxSupply()) {
            return false;
        }

        bool status = (totalAmount != totum.mint(_address, totalAmount));

        if (status) {
            soldTokens = soldTokens.add(totalAmount);
            increaseInvestorsCount(_address);
        }

        return status;
    }

    function sendToAddressWithBonus(
    address _address,
    uint256 _tokens,
    uint256 _bonus
    ) public onlyOwner returns (bool) {
        if (_tokens == 0 || address(_address) == 0x0 || _bonus == 0) {
            return false;
        }

        uint256 totalAmount = _tokens.add(_bonus);

        if (getTokens().add(totalAmount) > totum.maxSupply()) {
            return false;
        }

        bool status = (totalAmount != totum.mint(_address, totalAmount));

        if (status) {
            soldTokens = soldTokens.add(totalAmount);
            increaseInvestorsCount(_address);
        }

        return status;
    }

    function getCurrentPhase(uint256 _time) public constant returns (uint8) {
        if (_time == 0) {
            return uint8(phases.length);
        }
        for (uint8 i = 0; i < phases.length; i++) {
            Phase storage phase = phases[i];
            if (phase.since > _time) {
                continue;
            }

            if (phase.till < _time) {
                continue;
            }

            return i;
        }

        return uint8(phases.length);
    }

    function getTokens() public constant returns (uint256) {
        return totum.totalSupply();
    }

    function getSoldToken() public constant returns (uint256) {
        return soldTokens;
    }

    function getAllInvestors() public constant returns (uint256) {
        return investorsCount;
    }

    function getBalanceContract() public constant returns (uint256) {
        return collectedEthers;
    }

    function isSucceed(uint8 _phaseId) public returns (bool) {
        if (phases.length <= _phaseId) {
            return false;
        }
        Phase storage phase = phases[_phaseId];
        if (phase.isSucceed == true) {
            return true;
        }
        if (phase.till > now) {
            return false;
        }
        if (phase.softCap != 0 && phase.softCap > getTokens()) {
            return false;
        }
        phase.isSucceed = true;
        if (_phaseId == 1) {
            allocateBounty();
        }

        return true;
    }

    function refund() public returns (bool) {
        Phase storage icoPhase = phases[1];
        if (icoPhase.till > now) {
            return false;
        }
        if (icoPhase.softCap < getTokens()) {
            return false;
        }
        if (icoEtherBalances[msg.sender] == 0) {
            return false;
        }
        uint256 refundAmount = icoEtherBalances[msg.sender];
        uint256 tokens = totum.buyBack(msg.sender);
        icoEtherBalances[msg.sender] = 0;
        msg.sender.transfer(refundAmount);
        Refund(msg.sender, refundAmount, tokens);

        return true;
    }

    function isFinished(uint8 _phaseId) public constant returns (bool) {
        if (phases.length <= _phaseId) {
            return false;
        }
        Phase storage phase = phases[_phaseId];

        return (phase.isSucceed || now > phase.till);
    }

    function buy(address _address, uint256 _value) internal returns (bool) {
        if (_value == 0) {
            return false;
        }

        uint8 currentPhase = getCurrentPhase(now);

        if (phases.length <= currentPhase) {
            return false;
        }

        uint256 amount = getTokensAmount(_value, currentPhase);

        if (amount == 0) {
            return false;
        }

        uint256 bonus = getBonusAmount(amount, now);

        if (currentPhase == 1) {
            bonus = bonus.add(getVolumeBasedBonusAmount(_value, amount));
        }

        amount = amount.add(bonus);

        bool status = (amount == totum.mint(_address, amount));

        if (status) {
            onSuccessfulBuy(_address, _value, amount, currentPhase);
            allocate(currentPhase);
        }

        return status;
    }

    function onSuccessfulBuy(address _address, uint256 _value, uint256 _amount, uint8 _currentPhase) internal {
        collectedEthers = collectedEthers.add(_value);
        soldTokens = soldTokens.add(_amount);
        increaseInvestorsCount(_address);

        if (_currentPhase == 1) {
            icoEtherBalances[_address] = icoEtherBalances[_address].add(_value);
        }
    }

    function increaseInvestorsCount(address _address) internal {
        if (address(_address) != 0x0 && investors[_address] == false) {
            investors[_address] = true;
            investorsCount = investorsCount.add(1);
        }
    }

    function getVolumeBasedBonusAmount(uint256 _value, uint256 _amount) internal returns (uint256) {
        if (_amount == 0) {
            return 0;
        }
        if (_value < 3 ether) {
            return 0;
        } else if (_value < 15 ether) {
            return _amount.mul(3).div(100);
        } else if (_value < 30 ether) {
            return _amount.mul(5).div(100);
        } else {
            return _amount.mul(7).div(100);
        }
    }

    function getTokensAmount(uint256 _value, uint8 _currentPhase) internal returns (uint256) {
        if (_value == 0 || phases.length <= _currentPhase) {
            return uint256(0);
        }

        Phase storage phase = phases[_currentPhase];

        uint256 amount = _value.mul(uint256(10) ** totum.decimals()).div(phase.price);

        if (amount < phase.minInvest) {
            return uint256(0);
        }

        if (getTokens().add(amount) > phase.hardCap) {
            return uint256(0);
        }

        return amount;
    }

    function getBonusAmount(uint256 _amount, uint256 _time) internal returns (uint256) {
        uint8 currentPhase = getCurrentPhase(_time);
        if (_amount == 0 || _time == 0 || phases.length <= currentPhase) {
            return uint256(0);
        }

        if (currentPhase == 0) {
            return _amount.mul(50).div(100);
        }
        if (currentPhase == 1) {
            return getICOBonusAmount(_amount, _time);
        }

        return uint256(0);
    }

    function getICOBonusAmount(uint256 _amount, uint256 _time) internal returns (uint256) {
        Phase storage ico = phases[1];
        if (_time.sub(ico.since) < 11 * DAY) {// 11d since ico => reward 20%;
            return _amount.mul(20).div(100);
        }
        if (_time.sub(ico.since) < 21 * DAY) {// 21d since ico => reward 15%
            return _amount.mul(15).div(100);
        }
        if (_time.sub(ico.since) < 31 * DAY) {// 31d since ico => reward 10%
            return _amount.mul(10).div(100);
        }
        if (_time.sub(ico.since) < 41 * DAY) {// 41d since ico => reward 5%
            return _amount.mul(5).div(100);
        }

        return 0;
    }

    function allocate(uint8 _currentPhase) internal {
        if (this.balance > 0 && phases.length > _currentPhase) {
            Phase storage phase = phases[_currentPhase];

            if (_currentPhase == 0) {
                totumAllocation.preICOAddress().transfer(this.balance);
            } else if (_currentPhase == 1 && soldTokens >= phase.softCap) {
                totumAllocation.icoAddress().transfer(this.balance.mul(5).div(10));
                totumAllocation.icoAddress1().transfer(this.balance);
            }
        }
    }

    function allocateBounty() internal {
        if (isFinished(1)) {
            uint256 amount = totum.maxSupply().mul(5).div(100);
            uint256 mintedAmount = totum.mint(totumAllocation.bountyAddress(), amount);

            require(mintedAmount == amount);

            amount = totum.maxSupply().mul(7).div(100);
            mintedAmount = totum.mint(totumAllocation.teamAddress(), amount);

            require(mintedAmount == amount);
        }
    }

}