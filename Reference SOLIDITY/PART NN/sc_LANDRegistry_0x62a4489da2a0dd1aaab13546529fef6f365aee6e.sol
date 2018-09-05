/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

// File: contracts/land/LANDStorage.sol

contract LANDStorage {

  mapping (address => uint) latestPing;

  uint256 constant clearLow = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
  uint256 constant clearHigh = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
  uint256 constant factor = 0x100000000000000000000000000000000;

}

// File: contracts/registry/AssetRegistryStorage.sol

contract AssetRegistryStorage {

  string internal _name;
  string internal _symbol;
  string internal _description;

  /**
   * Stores the total count of assets managed by this registry
   */
  uint256 internal _count;

  /**
   * Stores an array of assets owned by a given account
   */
  mapping(address => uint256[]) internal _assetsOf;

  /**
   * Stores the current holder of an asset
   */
  mapping(uint256 => address) internal _holderOf;

  /**
   * Stores the index of an asset in the `_assetsOf` array of its holder
   */
  mapping(uint256 => uint256) internal _indexOfAsset;

  /**
   * Stores the data associated with an asset
   */
  mapping(uint256 => string) internal _assetData;

  /**
   * For a given account, for a given opperator, store whether that operator is
   * allowed to transfer and modify assets on behalf of them.
   */
  mapping(address => mapping(address => bool)) internal _operators;

  /**
   * Simple reentrancy lock
   */
  bool internal _reentrancy;
}

// File: contracts/upgradable/OwnableStorage.sol

contract OwnableStorage {

  address public owner;

  function OwnableStorage() internal {
    owner = msg.sender;
  }

}

// File: contracts/upgradable/ProxyStorage.sol

contract ProxyStorage {

  /**
   * Current contract to which we are proxing
   */
  address currentContract;

}

// File: contracts/Storage.sol

contract Storage is ProxyStorage, OwnableStorage, AssetRegistryStorage, LANDStorage {
}

// File: contracts/registry/IAssetHolder.sol

interface IAssetHolder {
  function onAssetReceived(
    /* address _assetRegistry == msg.sender */
    uint256 _assetId,
    address _previousHolder,
    address _currentHolder,
    bytes   _userData,
    address _operator,
    bytes   _operatorData
  ) public;
}

// File: contracts/registry/IAssetRegistry.sol

interface IAssetRegistry {

  /**
   * Global Registry getter functions
   */
  function name() public constant returns (string);
  function symbol() public constant returns (string);
  function description() public constant returns (string);
  function totalSupply() public constant returns (uint256);

  /**
   * Asset-centric getter functions
   */
  function exists(uint256 assetId) public constant returns (bool);
  function holderOf(uint256 assetId) public constant returns (address);
  function assetData(uint256 assetId) public constant returns (string);

  /**
   * Holder-centric getter functions
   */
  function assetsCount(address holder) public constant returns (uint256);
  function assetByIndex(address holder, uint256 index) public constant returns (uint256);
  function allAssetsOf(address holder) public constant returns (uint256[]);

  /**
   * Transfer Operations
   */
  function transfer(address to, uint256 assetId) public;
  function transfer(address to, uint256 assetId, bytes userData) public;
  function operatorTransfer(address to, uint256 assetId, bytes userData, bytes operatorData) public;

  /**
   * Data modification operations
   */
  function update(uint256 assetId, string data) public;

  /**
   * Supply-altering operations
   */
  function generate(uint256 assetId, string data) public;
  function destroy(uint256 assetId) public;

  /**
   * Authorization operations
   */
  function authorizeOperator(address operator, bool authorized) public;

  /**
   * Authorization getters
   */
  function isOperatorAuthorizedFor(address operator, address assetHolder)
    public constant returns (bool);

  /**
   * Events
   */
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed assetId,
    address operator,
    bytes userData,
    bytes operatorData
  );
  event Create(
    address indexed holder,
    uint256 indexed assetId,
    address indexed operator,
    string data
  );
  event Update(
    uint256 indexed assetId,
    address indexed holder,
    address indexed operator,
    string data
  );
  event Destroy(
    address indexed holder,
    uint256 indexed assetId,
    address indexed operator
  );
  event AuthorizeOperator(
    address indexed operator,
    address indexed holder,
    bool authorized
  );
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/registry/StandardAssetRegistry.sol

contract StandardAssetRegistry is Storage, IAssetRegistry {
  using SafeMath for uint256;

  //
  // Global Getters
  //

  function name() public view returns (string) {
    return _name;
  }

  function symbol() public view returns (string) {
    return _symbol;
  }

  function description() public view returns (string) {
    return _description;
  }

  function totalSupply() public view returns (uint256) {
    return _count;
  }

  //
  // Asset-centric getter functions
  //

  function exists(uint256 assetId) public view returns (bool) {
    return _holderOf[assetId] != 0;
  }

  function holderOf(uint256 assetId) public view returns (address) {
    return _holderOf[assetId];
  }

  function assetData(uint256 assetId) public view returns (string) {
    return _assetData[assetId];
  }

  //
  // Holder-centric getter functions
  //

  function assetsCount(address holder) public view returns (uint256) {
    return _assetsOf[holder].length;
  }

  function assetByIndex(address holder, uint256 index) public view returns (uint256) {
    return _assetsOf[holder][index];
  }

  function assetsOf(address holder) public view returns (uint256[]) {
    return allAssetsOf(holder);
  }

  function allAssetsOf(address holder) public view returns (uint256[]) {
    uint size = _assetsOf[holder].length;
    uint[] memory result = new uint[](size);
    for (uint i = 0; i < size; i++) {
      result[i] = _assetsOf[holder][i];
    }
    return result;
  }

  //
  // Authorization getters
  //

  function isOperatorAuthorizedFor(address operator, address assetHolder)
    public view returns (bool)
  {
    return _operators[assetHolder][operator];
  }

  function authorizeOperator(address operator, bool _authorized) public {
    if (_authorized) {
      require(!isOperatorAuthorizedFor(operator, msg.sender));
      _addAuthorization(operator, msg.sender);
    } else {
      require(isOperatorAuthorizedFor(operator, msg.sender));
      _clearAuthorization(operator, msg.sender);
    }
    AuthorizeOperator(operator, msg.sender, _authorized);
  }

  function _addAuthorization(address operator, address holder) private {
    _operators[holder][operator] = true;
  }

  function _clearAuthorization(address operator, address holder) private {
    _operators[holder][operator] = false;
  }

  //
  // Internal Operations
  //

  function _addAssetTo(address to, uint256 assetId) internal {
    _holderOf[assetId] = to;

    uint256 length = assetsCount(to);

    _assetsOf[to].push(assetId);

    _indexOfAsset[assetId] = length;

    _count = _count.add(1);
  }

  function _addAssetTo(address to, uint256 assetId, string data) internal {
    _addAssetTo(to, assetId);

    _assetData[assetId] = data;
  }

  function _removeAssetFrom(address from, uint256 assetId) internal {
    uint256 assetIndex = _indexOfAsset[assetId];
    uint256 lastAssetIndex = assetsCount(from).sub(1);
    uint256 lastAssetId = _assetsOf[from][lastAssetIndex];

    _holderOf[assetId] = 0;

    // Insert the last asset into the position previously occupied by the asset to be removed
    _assetsOf[from][assetIndex] = lastAssetId;

    // Resize the array
    _assetsOf[from][lastAssetIndex] = 0;
    _assetsOf[from].length--;

    // Remove the array if no more assets are owned to prevent pollution
    if (_assetsOf[from].length == 0) {
      delete _assetsOf[from];
    }

    // Update the index of positions for the asset
    _indexOfAsset[assetId] = 0;
    _indexOfAsset[lastAssetId] = assetIndex;

    _count = _count.sub(1);
  }

  //
  // Supply-altering functions
  //

  function generate(uint256 assetId) public {
    generate(assetId, msg.sender, '');
  }

  function generate(uint256 assetId, string data) public {
    generate(assetId, msg.sender, data);
  }

  function generate(uint256 assetId, address _beneficiary, string data) public {
    doGenerate(assetId, _beneficiary, data);
  }

  function doGenerate(uint256 assetId, address _beneficiary, string data) internal {
    require(_holderOf[assetId] == 0);

    _addAssetTo(_beneficiary, assetId, data);

    Create(_beneficiary, assetId, msg.sender, data);
  }

  function destroy(uint256 assetId) public {
    address holder = _holderOf[assetId];
    require(holder != 0);

    require(holder == msg.sender
         || isOperatorAuthorizedFor(msg.sender, holder));

    _removeAssetFrom(holder, assetId);

    Destroy(holder, assetId, msg.sender);
  }

  //
  // Transaction related operations
  //

  modifier onlyHolder(uint256 assetId) {
    require(_holderOf[assetId] == msg.sender);
    _;
  }

  modifier onlyOperator(uint256 assetId) {
    require(_holderOf[assetId] == msg.sender
         || isOperatorAuthorizedFor(msg.sender, _holderOf[assetId]));
    _;
  }

  function transfer(address to, uint256 assetId)
    onlyHolder(assetId)
    public
  {
    return doSend(to, assetId, '', 0, '');
  }

  function transfer(address to, uint256 assetId, bytes _userData)
    onlyHolder(assetId)
    public
  {
    return doSend(to, assetId, _userData, 0, '');
  }

  function operatorTransfer(
    address to, uint256 assetId, bytes userData, bytes operatorData
  )
    onlyOperator(assetId)
    public
  {
    return doSend(to, assetId, userData, msg.sender, operatorData);
  }

  function doSend(
    address to, uint256 assetId, bytes userData, address operator, bytes operatorData
  )
    internal
  {
    address holder = _holderOf[assetId];
    _removeAssetFrom(holder, assetId);
    _addAssetTo(to, assetId);

    // TODO: Implement EIP 820
    if (isContract(to)) {
      require(_reentrancy == false);
      _reentrancy = true;
      IAssetHolder(to).onAssetReceived(assetId, holder, to, userData, operator, operatorData);
      _reentrancy = false;
    }

    Transfer(holder, to, assetId, operator, userData, operatorData);
  }

  //
  // Update related functions
  //

  modifier onlyIfUpdateAllowed(uint256 assetId) {
    require(_holderOf[assetId] == msg.sender
         || isOperatorAuthorizedFor(msg.sender, _holderOf[assetId]));
    _;
  }

  function update(uint256 assetId, string data) onlyIfUpdateAllowed(assetId) public {
    _assetData[assetId] = data;
    Update(assetId, _holderOf[assetId], msg.sender, data);
  }

  //
  // Utilities
  //

  function isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}

// File: contracts/upgradable/IApplication.sol

contract IApplication {
  function initialize(bytes data) public;
}

// File: contracts/upgradable/Ownable.sol

contract Ownable is Storage {

  event OwnerUpdate(address _prevOwner, address _newOwner);

  modifier onlyOwner {
    assert(msg.sender == owner);
    _;
  }

  function initialize(bytes) public {
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != owner);
    owner = _newOwner;
  }
}

// File: contracts/land/ILANDRegistry.sol

interface ILANDRegistry {

  // LAND can be assigned by the owner
  function assignNewParcel(int x, int y, address beneficiary, string data) public;
  function assignNewParcel(int x, int y, address beneficiary) public;
  function assignMultipleParcels(int[] x, int[] y, address beneficiary) public;

  // After one year, land can be claimed from an inactive public key
  function ping() public;
  function clearLand(int[] x, int[] y) public;

  // LAND-centric getters
  function encodeTokenId(int x, int y) view public returns (uint256);
  function decodeTokenId(uint value) view public returns (int, int);
  function exists(int x, int y) view public returns (bool);
  function ownerOfLand(int x, int y) view public returns (address);
  function landData(int x, int y) view public returns (string);

  // Transfer LAND
  function transferLand(int x, int y, address to) public;
  function transferManyLand(int[] x, int[] y, address to) public;

  // Update LAND
  function updateLandData(int x, int y, string data) public;
  function updateManyLandData(int[] x, int[] y, string data) public;
}

// File: contracts/land/LANDRegistry.sol

contract LANDRegistry is Storage,
  Ownable, StandardAssetRegistry,
  ILANDRegistry
{

  function initialize(bytes /* data */) public {
    _name = 'Decentraland LAND';
    _symbol = 'LAND';
    _description = 'Contract that stores the Decentraland LAND registry';
  }

  //
  // Land is assignable by the owner
  //

  function assignNewParcel(int x, int y, address beneficiary, string data) public {
    generate(encodeTokenId(x, y), beneficiary, data);
  }

  function assignNewParcel(int x, int y, address beneficiary) public {
    generate(encodeTokenId(x, y), beneficiary, '');
  }

  function assignMultipleParcels(int[] x, int[] y, address beneficiary) public {
    for (uint i = 0; i < x.length; i++) {
      generate(encodeTokenId(x[i], y[i]), beneficiary, '');
    }
  }

  function generate(uint256 assetId, address beneficiary, string data) onlyOwner public {
    doGenerate(assetId, beneficiary, data);
  }

  function destroy(uint256 assetId) onlyOwner public {
    _removeAssetFrom(_holderOf[assetId], assetId);
    Destroy(_holderOf[assetId], assetId, msg.sender);
  }

  //
  // Inactive keys after 1 year lose ownership
  //

  function ping() public {
    latestPing[msg.sender] = now;
  }

  function setLatestToNow(address user) onlyOwner public {
    latestPing[user] = now;
  }

  function clearLand(int[] x, int[] y) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      uint landId = encodeTokenId(x[i], y[i]);
      address holder = holderOf(landId);
      if (latestPing[holder] < now - 1 years) {
        _removeAssetFrom(holder, landId);
        Destroy(holder, landId, msg.sender);
      }
    }
  }

  //
  // LAND Getters
  //

  function encodeTokenId(int x, int y) view public returns (uint) {
    return ((uint(x) * factor) & clearLow) | (uint(y) & clearHigh);
  }

  function decodeTokenId(uint value) view public returns (int, int) {
    int x = int((value & clearLow) >> 128);
    int y = int(value & clearHigh);
    return (x, y);
  }

  function exists(int x, int y) view public returns (bool) {
    return exists(encodeTokenId(x, y));
  }

  function ownerOfLand(int x, int y) view public returns (address) {
    return holderOf(encodeTokenId(x, y));
  }

  function ownerOfLandMany(int[] x, int[] y) view public returns (address[]) {
    require(x.length > 0);
    require(x.length == y.length);

    address[] memory addrs = new address[](x.length);
    for (uint i = 0; i < x.length; i++) {
      addrs[i] = ownerOfLand(x[i], y[i]);
    }

    return addrs;
  }

  function landData(int x, int y) view public returns (string) {
    return assetData(encodeTokenId(x, y));
  }

  //
  // Transfer LAND
  //

  function transferLand(int x, int y, address to) public {
    return transfer(to, encodeTokenId(x, y));
  }

  function transferManyLand(int[] x, int[] y, address to) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      return transfer(to, encodeTokenId(x[i], y[i]));
    }
  }

  //
  // Update LAND
  //

  function updateLandData(int x, int y, string data) public {
    return update(encodeTokenId(x, y), data);
  }

  function updateManyLandData(int[] x, int[] y, string data) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      update(encodeTokenId(x[i], y[i]), data);
    }
  }
}