/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;

contract Bestowal
{
    struct Data 
    {
        bytes8 token;
        uint8[] access;
        uint256 balance;
        uint256 limit;
    }
    
    mapping(address=>Data) private data;
    mapping(bytes8=>address) private donor;

    modifier isRegistered {
        require(donor[data[msg.sender].token] == msg.sender);
        _;
    }

    modifier isNotRegistered {
        require(donor[data[msg.sender].token] == 0x0);
        _;
    }

    modifier validBlockNumber(uint256 _blockNumber) {
        require(_blockNumber >= block.number);
        _;
    }

    modifier validDonor(address _address, bytes8 _token) {
        require(donor[_token] == _address);
        _;
    }

    modifier validBalance(bytes8 _token) {
        require(data[donor[_token]].balance > 0);
        _;
    }
    
    modifier validLimit(bytes8 _token) {
        require(block.number >= data[donor[_token]].limit);
        _;
    }
    
    function getData() public constant returns(bytes8, uint8[], uint256, uint256) {
        return (data[msg.sender].token, data[msg.sender].access, data[msg.sender].balance, data[msg.sender].limit);
    }
    
    function register(uint256 _rand) public isNotRegistered {
        bytes32 _seed = keccak256(block.blockhash(block.number), msg.sender, block.difficulty, _rand);
        uint8[] memory _access = new uint8[](11);
            
        for(uint8 i=0; i<_access.length; i++)
            _access[i] = uint8(uint(_seed) * (i + 1) % 16);
            
        data[msg.sender].token = bytes8(_seed);
        data[msg.sender].access = _access;
        data[msg.sender].balance = 0;
            
        donor[bytes8(_seed)] = msg.sender;
    }
    
    function holding(uint256 _blockNumber) public payable isRegistered validBlockNumber(_blockNumber) {
        data[msg.sender].balance += msg.value;
        data[msg.sender].limit = _blockNumber;
    }
    
    function finding(address _address, bytes8 _token, uint8[] _access) public payable validDonor(_address, _token) validBalance(_token) validLimit(_token) {
        address _donor = donor[_token];
        uint256 _balance = data[_donor].balance;
        
        for(uint8 i=0; i<data[_donor].access.length; i++)
            if(data[_donor].access[i] != _access[i]) { revert(); }
        
        data[_donor].balance = 0;
        msg.sender.transfer(_balance + msg.value);
    }

    function termination() public payable isRegistered {
        uint256 _balance = data[msg.sender].balance;
        
        delete donor[data[msg.sender].token];
        delete data[msg.sender];
        
        msg.sender.transfer(_balance + msg.value);
    }
}