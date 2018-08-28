/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract CapWhitelist {
    address public owner;
    mapping (address => uint256) public whitelist;

    event Set(address _address, uint256 _amount);

    function CapWhitelist() {
        owner = msg.sender;
        // Set in prod
    }

    function destruct() {
        require(msg.sender == owner);
        selfdestruct(owner);
    }

    function setWhitelisted(address _address, uint256 _amount) {
        require(msg.sender == owner);
        setWhitelistInternal(_address, _amount);
    }

    function setWhitelistInternal(address _address, uint256 _amount) private {
        whitelist[_address] = _amount;
        Set(_address, _amount);
    }
}