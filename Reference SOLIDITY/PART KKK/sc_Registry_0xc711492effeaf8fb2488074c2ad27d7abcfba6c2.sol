/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

 contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// @title Register for contract names.
contract Registry is Ownable {
	struct Record {
		address contractAddress;

		// note: IPFS hash is stored as Base58 decoded hex value, with the first two bytes removed
		// (0x1220), see https://ethereum.stackexchange.com/questions/17094/how-to-store-ipfs-hash-using-bytes
		bytes32 ipfsHash;
	}
	
	//namelist for exporting mapping
	bytes32[] public namelist;

	// publicly available register
	mapping (bytes32 => Record) public registry;

	// event for update function
	event RegistryUpdated(bytes32 _name, address _address, bytes32 _ipfsHash);

	// events for getting data into JS
	event GetRecord(bytes32 _name, address contractAddress, bytes32 ipfsHash);

	// get namelist length for exporting mapping
	function getNamelistLength() public view returns(uint namelistLength) {
		return namelist.length;
	}
	
	// get addeess from name
	function getAddress(bytes32 _name) public view returns(address) {
		Record memory record = registry[keccak256(_name)];
		// return event so we can use JS
		GetRecord(_name, record.contractAddress, record.ipfsHash);
		return record.contractAddress;
	}

	// get ipfs hash from name
	function getIPFSHash(bytes32 _name) public view returns(bytes32) {
		Record memory record = registry[keccak256(_name)];
		// return event so we can use JS
		GetRecord(_name, record.contractAddress, record.ipfsHash);
		return record.ipfsHash;
	}

	// update address for name, or create new name->address mapping
	function updateRegistry(bytes32 _name, address _address, bytes32 _ipfsHash) public onlyOwner {
		require(_address != address(0x0));
		if (registry[keccak256(_name)].contractAddress == 0) {
			namelist.push(_name);
		}
		registry[keccak256(_name)] = Record(_address, _ipfsHash);
		RegistryUpdated(_name, _address, _ipfsHash);
	}
}