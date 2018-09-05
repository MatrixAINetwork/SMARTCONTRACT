/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

library SafeMathMod {// Partial SafeMath Library

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) < a);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) > a);
    }
}

contract Token {//is inherently ERC20
    using SafeMathMod for uint256;

    /**
    * @constant name The name of the token
    * @constant symbol  The symbol used to display the currency
    * @constant decimals  The number of decimals used to dispay a balance
    * @variable totalSupply The total number of tokens times 10 times of the number of decimals
    * @variable presaleAddress  Address of the presale contract
    * @variable crowdsaleAddress  Address of the crowdsale contract
    * @variable crowdsaleSuccessful  has there been a successful crowdsale
    * @constant MAX_UINT256 Magic number for unlimited allowance
    * @storage balanceOf Holds the balances of all token holders
    * @storage Approval Holds the allowed balance to be transferable by another address.
    */

    string constant public name = "Smart City Token";

    string constant public symbol = "SCT";

    uint8 constant public decimals = 18;

    uint256 public totalSupply;

    address public presaleAddress;
    
    address public crowdsaleAddress;
    
    bool public crowdsaleSuccessful;
    
    uint256 constant private MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event TransferFrom(address indexed _spender, address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    event Mint(address indexed _to, uint256 _value, uint256 _totalSupply);

    event Burn(address indexed _from, uint256 _value, uint256 _totalSupply);



    function Token(address _presaleAddress, address _crowdsaleAddress) public {
        totalSupply = 0;
        presaleAddress = _presaleAddress;
        crowdsaleAddress = _crowdsaleAddress;
    }
    
    /**
    * @notice send `_value` tokens to `_to` address from `msg.sender`
    *
    * @param _to The address of the recipient
    * @param _value The amount of token to be transferred
    * @return Whether the transfer was successful
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(crowdsaleSuccessful);
        /* Ensures that tokens are not sent to address "0x0" */
        require(_to != address(0));
        /* SafeMathMOd.sub will throw if there is not enough balance and if the transfer value is 0. */
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        success = true;
    }
    
    /**
    * @notice send `_value` tokens to `_to` address from `_from` address if allowance allows
    *
    * @param _from The address of the sender
    * @param _to The address of the recipient
    * @param _value The amount of token to be transferred
    * @return Whether the transfer was successful
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(crowdsaleSuccessful);
        /* Ensures that tokens are not sent to address "0x0" */
        require(_to != address(0));
        /* Ensures tokens are not sent to this contract */
        require(_to != address(this));
        
        uint256 allowed = allowance[_from][msg.sender];
        /* Ensures sender has enough available allowance OR sender is balance holder allowing single transsaction send to contracts*/
        require(_value <= allowed || _from == msg.sender);

        /* Use SafeMathMod to add and subtract from the _to and _from addresses respectively. Prevents under/overflow and 0 transfers */
        balanceOf[_to] = balanceOf[_to].add(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);

        /* Only reduce allowance if not MAX_UINT256 in order to save gas on unlimited allowance */
        /* Balance holder does not need allowance to send from self. */
        if (allowed != MAX_UINT256 && _from != msg.sender) {
            allowance[_from][msg.sender] = allowed.sub(_value);
        }
        Transfer(_from, _to, _value);
        success = true;
    }

    /**
    * @notice approve `_value` tokens for `_spender` address to send from 'msg.sender'
    *
    * @param _spender The address of the approved
    * @param _value The amount of token to be allowed
    * @return Whether the allowance was successful
    */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        /* Ensures address "0x0" is not assigned allowance. */
        require(_spender != address(0));

        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        success = true;
    }
    
    /**
    * @notice mint `_value` tokens into `_to` address possession
    *
    * @param _to The address of the recipient
    * @param _value The amount of token to be minted
    * @return Whether the minting was successful
    */
    function mintTokens(address _to, uint256 _value) external returns(bool success) {
        require(msg.sender == presaleAddress || msg.sender == crowdsaleAddress);
        balanceOf[_to] = balanceOf[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        Mint(_to,  _value, totalSupply);
        success = true;
    }
    
    /**
    * @notice burn all tokens assigned to '_address'
    *
    * @param _address whose tokens will be burned
    * @return Whether the burning was successful
    */
    function burnAllTokens(address _address) external returns(bool success) {
        require(msg.sender == crowdsaleAddress);
        uint256 amount = balanceOf[_address];
        balanceOf[_address] = 0;
        totalSupply = totalSupply.sub(amount);
        Burn(_address,  amount, totalSupply);
        success = true;
    }

    /**
    * @notice set crowdsaleSuccessful to true
    */
    function crowdsaleSucceeded() public {
        require(msg.sender == crowdsaleAddress);
        crowdsaleSuccessful = true;
    }
    
    // revert on eth transfers to this contract
    function() public payable {revert();}
}