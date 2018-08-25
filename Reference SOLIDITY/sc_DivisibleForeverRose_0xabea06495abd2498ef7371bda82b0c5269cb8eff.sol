/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;


/*============================================================================= */
/*=============================ERC721 interface==================================== */
/*============================================================================= */

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Yumin.yang
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    //function ownerOf(uint256 _tokenId) external view returns (address owner);
    //function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    //function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    //event Approval(address owner, address approved, uint256 tokenId);

}


/*============================================================================= */
/*=============================Forever Rose==================================== */
/*============================================================================= */

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Yumin.yang
contract DivisibleForeverRose is ERC721 {
  
    //This contract's owner
    address private contractOwner;

    
    //Gift token storage.
    mapping(uint => GiftToken) giftStorage;

    // Total supply of this token. 
	uint public totalSupply = 10; 

    bool public tradable = false;

    uint foreverRoseId = 1;

    // Divisibility of ownership over a token  
	mapping(address => mapping(uint => uint)) ownerToTokenShare;

	// How much owners have of a token
	mapping(uint => mapping(address => uint)) tokenToOwnersHoldings;

    // If Forever Rose has been created
	mapping(uint => bool) foreverRoseCreated;

    string public name;  
    string public symbol;           
    uint8 public decimals = 1;                                 
    string public version = "1.0";    

    //Special gift token
    struct GiftToken {
        uint256 giftId;
    } 

    //@dev Constructor 
    function DivisibleForeverRose() public {
        contractOwner = msg.sender;
        name = "ForeverRose";
        symbol = "ROSE";  

        // Create Forever rose
        GiftToken memory newGift = GiftToken({
            giftId: foreverRoseId
        });
        giftStorage[foreverRoseId] = newGift;

        
        foreverRoseCreated[foreverRoseId] = true;
        _addNewOwnerHoldingsToToken(contractOwner, foreverRoseId, totalSupply);
        _addShareToNewOwner(contractOwner, foreverRoseId, totalSupply);

    }
    
    // Fallback funciton
    function() public {
        revert();
    }

    function totalSupply() public view returns (uint256 total) {
        return totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return ownerToTokenShare[_owner][foreverRoseId];
    }

    // We use parameter '_tokenId' as the divisibility
    function transfer(address _to, uint256 _tokenId) external {

        // Requiring this contract be tradable
        require(tradable == true);

        require(_to != address(0));
        require(msg.sender != _to);

        // Take _tokenId as divisibility
        uint256 _divisibility = _tokenId;

        // Requiring msg.sender has Holdings of Forever rose
        require(tokenToOwnersHoldings[foreverRoseId][msg.sender] >= _divisibility);

    
        // Remove divisibilitys from old owner
        _removeShareFromLastOwner(msg.sender, foreverRoseId, _divisibility);
        _removeLastOwnerHoldingsFromToken(msg.sender, foreverRoseId, _divisibility);

        // Add divisibilitys to new owner
        _addNewOwnerHoldingsToToken(_to, foreverRoseId, _divisibility);
        _addShareToNewOwner(_to, foreverRoseId, _divisibility);

        // Trigger Ethereum Event
        Transfer(msg.sender, _to, foreverRoseId);

    }

    // Transfer gift to a new owner.
    function assignSharedOwnership(address _to, uint256 _divisibility)
                               onlyOwner external returns (bool success) 
                               {

        require(_to != address(0));
        require(msg.sender != _to);
        require(_to != address(this));
        
        // Requiring msg.sender has Holdings of Forever rose
        require(tokenToOwnersHoldings[foreverRoseId][msg.sender] >= _divisibility);

        //Remove ownership from oldOwner(msg.sender)
        _removeLastOwnerHoldingsFromToken(msg.sender, foreverRoseId, _divisibility);
        _removeShareFromLastOwner(msg.sender, foreverRoseId, _divisibility);

         //Add ownership to NewOwner(address _to)
        _addShareToNewOwner(_to, foreverRoseId, _divisibility); 
        _addNewOwnerHoldingsToToken(_to, foreverRoseId, _divisibility);

        // Trigger Ethereum Event
        Transfer(msg.sender, _to, foreverRoseId);

        return true;
    }

    function getForeverRose() public view returns(uint256 _foreverRoseId) {
        return giftStorage[foreverRoseId].giftId;
    }

    // Turn on this contract to be tradable, so owners can transfer their token
    function turnOnTradable() public onlyOwner {
        tradable = true;
    }
    
    // ------------------------------ Helper functions (internal functions) ------------------------------

	// Add divisibility to new owner
	function _addShareToNewOwner(address _owner, uint _tokenId, uint _units) internal {
		ownerToTokenShare[_owner][_tokenId] += _units;
	}

	
	// Add the divisibility to new owner
	function _addNewOwnerHoldingsToToken(address _owner, uint _tokenId, uint _units) internal {
		tokenToOwnersHoldings[_tokenId][_owner] += _units;
	}
    
    // Remove divisibility from last owner
	function _removeShareFromLastOwner(address _owner, uint _tokenId, uint _units) internal {
		ownerToTokenShare[_owner][_tokenId] -= _units;
	}
    
    // Remove divisibility from last owner 
	function _removeLastOwnerHoldingsFromToken(address _owner, uint _tokenId, uint _units) internal {
		tokenToOwnersHoldings[_tokenId][_owner] -= _units;
	}

    // Withdraw Ether from this contract to Multi sigin wallet
    function withdrawEther() onlyOwner public returns(bool) {
        return contractOwner.send(this.balance);
    }

    // ------------------------------ Modifier -----------------------------------


     modifier onlyExistentToken(uint _tokenId) {
	    require(foreverRoseCreated[_tokenId] == true);
	    _;
	}

    modifier onlyOwner(){
         require(msg.sender == contractOwner);
         _;
     }

}


/*============================================================================= */
/*=============================MultiSig Wallet================================= */
/*============================================================================= */

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <