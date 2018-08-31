/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

interface ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

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

contract ERC223Token is owned {
    using SafeMath for uint256;
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

    mapping(address => uint) balances; // List of user balances.
    
    string _name;
    string _symbol;
    uint8 public constant DECIMALS = 6;
    // 6 decimals is the strongly suggested default, avoid changing it
    uint256 _totalSupply;
    address team_addr;
    uint256 team_keep_amount;
    uint256 _saledTotal = 0;
    uint256 _amounToSale = 0;
    uint _buyPrice = 10;
    uint256 _totalEther = 0;

    // Team钱包        300000000 个
    address addrTeam = 0xe926f9dbEB503c5b273ba496Af48E8f7d6995C64;

        // Funder钱包      900000000 个
    address addrFounder = 0x6AfD59bAa83d6e0F48cdcb791ABB88d43348c0b7;

        // Operation钱包   800000000 个
    address addrOper = 0x062fCa3A0f33087425837b0f88CfC0d1EE528EFb;

        // Lynch钱包       400000000 个
    address addrLynch = 0x6395075e827D7af7028Dd058C5B432EC624b0c53;

        // Pool钱包        400000000 个
    address addrPool = 0xaA008ba2A493849a2004Ea13E24C8adcBeE63EE6;


    function ERC223Token(
        string tokenName,
        string tokenSymbol
    ) public 
    {
        _totalSupply = 4000000000 * 10 ** uint256(DECIMALS);  // 实际供应总量
        balances[addrTeam] = 300000000 * 10 ** uint256(DECIMALS);
        balances[addrFounder] = 900000000 * 10 ** uint256(DECIMALS);
        balances[addrOper] = 800000000 * 10 ** uint256(DECIMALS);
        balances[addrLynch] = 400000000 * 10 ** uint256(DECIMALS);
        balances[addrPool] = 400000000 * 10 ** uint256(DECIMALS);

        _amounToSale = 1200000000 * 10 ** uint256(DECIMALS);
        _saledTotal = 0;

        _name = tokenName;                                       // 设置Token名字
        _symbol = tokenSymbol;                                   // 设置Token符号
    }

    function name() public constant returns (string) {
        return _name;
    }

    function symbol() public constant returns (string) {
        return _symbol;
    }

    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }

    function buyPrice() public constant returns (uint256) {
        return _buyPrice;
    }

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes _data) public returns (bool ok) {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        uint codeLength;
        require (_to != 0x0);
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }
        require(balances[msg.sender]>=_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    
    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      This function works the same with the previous one
     *      but doesn't contain `_data` param.
     *      Added due to backwards compatibility reasons.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint _value) public returns(bool ok) {
        uint codeLength;
        bytes memory empty;
        require (_to != 0x0);
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }
        require(balances[msg.sender]>=_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        Transfer(msg.sender, _to, _value, empty);
        return true;
    }

    
    /**
     * @dev Returns balance of the `_owner`.
     *
     * @param _owner   The address whose balance will be returned.
     * @return balance Balance of the `_owner`.
     */
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function setPrices(uint256 newBuyPrice) onlyOwner public {
        _buyPrice = newBuyPrice;
    }

    function transTo(address _from, address _to, uint256 _amount) onlyOwner public returns(bool ok) {
        require(balances[_from]>=_amount);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        return true;   
    }

    /// @notice Buy tokens from contract by sending ether
    function buyCoin() payable public returns (bool ok) {
        uint amount = ((msg.value * _buyPrice) * 10 ** uint256(DECIMALS))/1000000000000000000;               // calculates the amount
        require ((_amounToSale - _saledTotal)>=amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        _saledTotal = _saledTotal.add(amount);
        _totalEther += msg.value;
        return true;
    }

    function dispatchTo(address target, uint256 amount) onlyOwner public returns (bool ok) {
        require ((_amounToSale - _saledTotal)>=amount);
        balances[target] = balances[target].add(amount);
        _saledTotal = _saledTotal.add(amount);
        return true;
    }

    function withdrawTo(address _target, uint256 _value) onlyOwner public returns (bool ok) {
        require(_totalEther <= _value);
        _totalEther -= _value;
        _target.transfer(_value);
        return true;
    }
    
    function () payable public {
    }

}