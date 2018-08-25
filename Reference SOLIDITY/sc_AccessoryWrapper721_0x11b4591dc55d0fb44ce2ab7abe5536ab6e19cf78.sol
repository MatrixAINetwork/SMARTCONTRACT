/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/**
 * @title ERC721 interface
 * @dev see https://github.com/ethereum/eips/issues/721
 */



contract AccessControl {
    address public creatorAddress;
    uint16 public totalSeraphims = 0;
    mapping (address => bool) public seraphims;

    bool public isMaintenanceMode = true;
 
    modifier onlyCREATOR() {
        require(msg.sender == creatorAddress);
        _;
    }

    modifier onlySERAPHIM() {
        require(seraphims[msg.sender] == true);
        _;
    }
    
    modifier isContractActive {
        require(!isMaintenanceMode);
        _;
    }
    
    // Constructor
    function AccessControl() public {
        creatorAddress = msg.sender;
    }
    

    function addSERAPHIM(address _newSeraphim) onlyCREATOR public {
        if (seraphims[_newSeraphim] == false) {
            seraphims[_newSeraphim] = true;
            totalSeraphims += 1;
        }
    }
    
    function removeSERAPHIM(address _oldSeraphim) onlyCREATOR public {
        if (seraphims[_oldSeraphim] == true) {
            seraphims[_oldSeraphim] = false;
            totalSeraphims -= 1;
        }
    }

    function updateMaintenanceMode(bool _isMaintaining) onlyCREATOR public {
        isMaintenanceMode = _isMaintaining;
    }

  
} 


contract SafeMath {
    function safeAdd(uint x, uint y) pure internal returns(uint) {
      uint z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint x, uint y) pure internal returns(uint) {
      assert(x >= y);
      uint z = x - y;
      return z;
    }

    function safeMult(uint x, uint y) pure internal returns(uint) {
      uint z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

    function getRandomNumber(uint16 maxRandom, uint8 min, address privateAddress) constant public returns(uint8) {
        uint256 genNum = uint256(block.blockhash(block.number-1)) + uint256(privateAddress);
        return uint8(genNum % (maxRandom - min + 1)+min);
    }
}

contract Enums {
    enum ResultCode {
        SUCCESS,
        ERROR_CLASS_NOT_FOUND,
        ERROR_LOW_BALANCE,
        ERROR_SEND_FAIL,
        ERROR_NOT_OWNER,
        ERROR_NOT_ENOUGH_MONEY,
        ERROR_INVALID_AMOUNT
    }

    enum AngelAura { 
        Blue, 
        Yellow, 
        Purple, 
        Orange, 
        Red, 
        Green 
    }
}

contract IAccessoryData is AccessControl, Enums {
    uint8 public totalAccessorySeries;    
    uint32 public totalAccessories;
    
 
    /*** FUNCTIONS ***/
    //*** Write Access ***//
    function createAccessorySeries(uint8 _AccessorySeriesId, uint32 _maxTotal, uint _price) onlyCREATOR public returns(uint8) ;
	function setAccessory(uint8 _AccessorySeriesId, address _owner) onlySERAPHIM external returns(uint64);
   function addAccessoryIdMapping(address _owner, uint64 _accessoryId) private;
	function transferAccessory(address _from, address _to, uint64 __accessoryId) onlySERAPHIM public returns(ResultCode);
    function ownerAccessoryTransfer (address _to, uint64 __accessoryId)  public;
    function updateAccessoryLock (uint64 _accessoryId, bool newValue) public;
    function removeCreator() onlyCREATOR external;
    
    //*** Read Access ***//
    function getAccessorySeries(uint8 _accessorySeriesId) constant public returns(uint8 accessorySeriesId, uint32 currentTotal, uint32 maxTotal, uint price) ;
	function getAccessory(uint _accessoryId) constant public returns(uint accessoryID, uint8 AccessorySeriesID, address owner);
	function getOwnerAccessoryCount(address _owner) constant public returns(uint);
	function getAccessoryByIndex(address _owner, uint _index) constant public returns(uint) ;
    function getTotalAccessorySeries() constant public returns (uint8) ;
    function getTotalAccessories() constant public returns (uint);
    function getAccessoryLockStatus(uint64 _acessoryId) constant public returns (bool);
}


  

   
	

 
contract AccessoryWrapper721 is AccessControl {
  //Events
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event MarketplaceTransfer(address indexed _from, address indexed _to, uint256 _tokenId, address _marketplace);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);


//Storage
 
   
    address public accessoryDataContract = 0x466c44812835f57b736ef9F63582b8a6693A14D0;
    
        struct Accessory {
        uint32 accessoryId;
        uint8 accessorySeriesId;
        address owner;
        bool ownerLock;
    }



    
    function SetAccessoryDataContact(address _accessoryDataContract) onlyCREATOR external {
       accessoryDataContract = _accessoryDataContract;
    }

  function balanceOf(address _owner) public view returns (uint256 _balance) {
           IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
           return accessoryData.getOwnerAccessoryCount(_owner);
  }
  
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
            IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
            address owner;
            (,,owner) = accessoryData.getAccessory(_tokenId);
            return owner;
  }
  
  function getTokenByIndex (address _owner, uint index) constant public returns (uint64) {
      //returns the accessory number of the index-th item in that addresses accessory list. 
        IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
        return uint64(accessoryData.getAccessoryByIndex(_owner, index));
        
  }
	
	function getAccessory(uint _accessoryId) constant public returns(uint accessoryID, uint8 AccessorySeriesID, address owner) {
       
        IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
        (accessoryID, AccessorySeriesID, owner) = accessoryData.getAccessory(_accessoryId);
       
    }
    function getTokenLockStatus(uint64 _tokenId) constant public returns (bool) {
       IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
       return accessoryData.getAccessoryLockStatus(_tokenId);
       
    }
    
   
 
  function transfer(address _to, uint256 _tokenId) public {
      
       IAccessoryData accessoryData = IAccessoryData(accessoryDataContract);
       address owner;
        (,, owner) = accessoryData.getAccessory(_tokenId);
      
       if ((seraphims[msg.sender] == true)  || (owner == msg.sender))
       {
         accessoryData.transferAccessory(owner,_to, uint64 (_tokenId)) ;
         Transfer(owner, _to, _tokenId);
         MarketplaceTransfer(owner,  _to, _tokenId, msg.sender);
           
       }
      else {revert();}
  }
  function approve(address _to, uint256 _tokenId) public
  {
      //this function should never be called - instead, use updateAccessoryLock from the accessoryData contract;
      revert();
      
  }
  function takeOwnership(uint256 _tokenId) public
  { 
     //this function should never be called - instead use transfer
     revert();
  }
    function kill() onlyCREATOR external {
        selfdestruct(creatorAddress);
    }
    }