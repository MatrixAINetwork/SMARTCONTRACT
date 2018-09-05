/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract Tikr {

    mapping (bytes32 => uint256) tokenValues;
    address adminAddress;
    address managerAddress;

    constructor () public {
        adminAddress = msg.sender;
        managerAddress = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress);
        _;
    }

    modifier onlyManager() {
        require(msg.sender == managerAddress);
        _;
    }

    function updateAdmin (address _adminAddress) public onlyAdmin {
        adminAddress = _adminAddress;
    }

    function updateManager (address _managerAddress) public onlyAdmin {
        managerAddress = _managerAddress;
    }

    function getPrice (bytes32 _ticker) public view returns (uint256) {
        return tokenValues[_ticker];
    }

    function updatePrice (bytes32 _ticker, uint256 _price) public onlyManager {
        tokenValues[_ticker] = _price;
    }

}