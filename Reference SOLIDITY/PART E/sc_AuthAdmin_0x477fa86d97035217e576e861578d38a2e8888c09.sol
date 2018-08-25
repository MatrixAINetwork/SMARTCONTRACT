/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

contract AuthAdmin {
    
    address[] admins_array;
    address[] users_array;
    
    mapping (address => bool) admin_addresses;
    mapping (address => bool) user_addresses;

    event NewAdmin(address addedBy, address admin);
    event RemoveAdmin(address removedBy, address admin);
    event NewUserAdded(address addedBy, address account);
    event RemoveUser(address removedBy, address account);

    function AuthAdmin() public {
        admin_addresses[msg.sender] = true;
        NewAdmin(0, msg.sender);
        admins_array.push(msg.sender);
    }

    function addAdmin(address _address) public {
        require (isCurrentAdmin(msg.sender));
        require (!admin_addresses[_address]);
        admin_addresses[_address] = true;
        NewAdmin(msg.sender, _address);
        admins_array.push(_address);
    }

    function removeAdmin(address _address) public {
        require(isCurrentAdmin(msg.sender));
        require (_address != msg.sender);
        require (admin_addresses[_address]);
        admin_addresses[_address] = false;
        RemoveAdmin(msg.sender, _address);
    }

    function add_user(address _address) public {
        require (isCurrentAdmin(msg.sender));
        require (!user_addresses[_address]);
        user_addresses[_address] = true;
        NewUserAdded(msg.sender, _address);
        users_array.push(_address);
    }

    function remove_user(address _address) public {
        require (isCurrentAdmin(msg.sender));
        require (user_addresses[_address]);
        user_addresses[_address] = false;
        RemoveUser(msg.sender, _address);
    }
                    /*----------------------------
                                Getters
                    ----------------------------*/
    
    function isCurrentAdmin(address _address) public constant returns (bool) {
        return admin_addresses[_address];
    }

    function isCurrentOrPastAdmin(address _address) public constant returns (bool) {
        for (uint256 i = 0; i < admins_array.length; i++)
            require (admins_array[i] == _address);
                return true;
        return false;
    }

    function isCurrentUser(address _address) public constant returns (bool) {
        return user_addresses[_address];
    }

    function isCurrentOrPastUser(address _address) public constant returns (bool) {
        for (uint256 i = 0; i < users_array.length; i++)
            require (users_array[i] == _address);
                return true;
        return false;
    }
}