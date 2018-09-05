/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract SafetherStorage {
    
    /*
    * Depositor Struct is Storage for User.
    * 
    * _token is access key required for find assets.
    * _data is storage for depositor.
    *
    * _data[0] : Register Block Number
    * _data[1] : Period holding assets
    * _data[2] : Amount of holding assets
    *
    */
    struct Depositor {
        bytes8     _token;
        uint256[3]  _data;
    }
    
    mapping (address=>Depositor) internal _depositor;
}

contract SafetherModifier is SafetherStorage {
    modifier isRegisterd {
        require(_depositor[msg.sender]._token != 0x0);
        _;
    }
    
    modifier isNotRegisterd {
        require(_depositor[msg.sender]._token == 0x0);
        _;
    }
    
    modifier isValidDepositor(address depositor, bytes8 token) {
        require(_depositor[depositor]._token == token);
        require(_depositor[depositor]._data[2] > 0);
        require(block.number >= _depositor[depositor]._data[1]);
        _;
    }
}

contract SafetherAbstract {
    function authentication(bytes8 token) public constant returns(bool);
    function getDepositor() public constant returns(uint256[3]);
    
    function register(bytes7 password) public;
    function deposit(uint256 period) public payable;
    function withdraw(address depositor, bytes8 token) public payable;
    function cancel() public payable;
}

contract Safether is SafetherModifier, SafetherAbstract {
    function authentication(bytes8 token) public constant returns(bool) {
        return _depositor[msg.sender]._token == token;
    }
    
    function getDepositor() public constant returns (uint256[3]) {
        return (_depositor[msg.sender]._data);
    }
    
    function register(bytes7 password) public isNotRegisterd {
        _depositor[msg.sender]._token = bytes8(keccak256(block.number, msg.sender, password));
        _depositor[msg.sender]._data[0] = block.number;
    }
    
    function deposit(uint256 period) public payable isRegisterd {
        _depositor[msg.sender]._data[1] = block.number + period;
        _depositor[msg.sender]._data[2] += msg.value;
    }
    
    function withdraw(address depositor, bytes8 token) public payable isValidDepositor(depositor, token) {
        uint256 tempDeposit = _depositor[depositor]._data[2];
         _depositor[depositor]._data[2] = 0;
         msg.sender.transfer(tempDeposit + msg.value);
    }
    
    function cancel() public payable isRegisterd {
        uint256 tempDeposit = _depositor[msg.sender]._data[2];
        delete _depositor[msg.sender];
        msg.sender.transfer(tempDeposit + msg.value);
    }
}