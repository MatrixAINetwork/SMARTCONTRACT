/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

/**
 * @title MyFriendships
 * @dev A contract for managing one's friendships.
 */
contract MyFriendships {
    address public me;
    uint public numberOfFriends;
    address public latestFriend;
    
    mapping(address => bool) myFriends;

    /**
    * @dev Create a contract to keep track of my friendships.
    */
    function MyFriendships() public {
        me = msg.sender;
    }
 
    /**
    * @dev Start an exciting new friendship with me.
    */
    function becomeFriendsWithMe () public {
        require(msg.sender != me); // I won't be friends with myself.
        myFriends[msg.sender] = true;
        latestFriend = msg.sender;
        numberOfFriends++;
    }
    
    /**
    * @dev Am I friends with this address?
    */
    function friendsWith (address addr) public view returns (bool) {
        return myFriends[addr];
    }
}