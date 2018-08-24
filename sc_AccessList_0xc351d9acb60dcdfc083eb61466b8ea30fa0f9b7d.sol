#These solidity codes have been obtained from Etherscan for extracting the smartcontract related info. The data will be used by MATRIX AI team as the reference basis for MATRIX model analysis, extraction of contract semantics, as well as AI based data analysis, etc.
pragma solidity ^0.4.20;

contract AccessList {
    event Added(address _user);
    event Removed(address _user);

    mapping(address => bool) public access;

    function isSet(address addr) external view returns(bool) {
        return access[addr];
    }

    function add() external {
        require(!access[msg.sender]);
        access[msg.sender] = true;
        emit Added(msg.sender);
    }

    function remove() external {
        require(access[msg.sender]);
        access[msg.sender] = false;
        emit Removed(msg.sender);
    }
}