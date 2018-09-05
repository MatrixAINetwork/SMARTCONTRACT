/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.24;

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() public {owner = msg.sender;}

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

contract Precondition is Owned {

    string public name;
    uint public version;
    bool public active = false;

    constructor(string _name, uint _version, bool _active) public {
        name = _name;
        version = _version;
        active = _active;
    }

    function setActive(bool _active) external onlyOwner {
        active = _active;
    }

    function isValid(bytes32 _platform, string _platformId, address _token, uint256 _value, address _funder) external view returns (bool valid);
}

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <