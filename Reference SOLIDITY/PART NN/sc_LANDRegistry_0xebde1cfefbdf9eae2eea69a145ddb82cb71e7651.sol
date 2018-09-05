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

  mapping (address => bool) authorizedDeploy;

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
  address public currentContract;
  address public proxyOwner;
}

// File: erc821/contracts/AssetRegistryStorage.sol

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

// File: contracts/Storage.sol

contract Storage is ProxyStorage, OwnableStorage, AssetRegistryStorage, LANDStorage {
}

// File: contracts/upgradable/IApplication.sol

contract IApplication {
  function initialize(bytes data) public;
}

// File: contracts/upgradable/Ownable.sol

contract Ownable is Storage {

  event OwnerUpdate(address _prevOwner, address _newOwner);

  function bytesToAddress (bytes b) pure public returns (address) {
    uint result = 0;
    for (uint i = b.length-1; i+1 > 0; i--) {
      uint c = uint(b[i]);
      uint to_inc = c * ( 16 ** ((b.length - i-1) * 2));
      result += to_inc;
    }
    return address(result);
  }

  modifier onlyOwner {
    assert(msg.sender == owner);
    _;
  }

  function initialize(bytes data) public {
    owner = bytesToAddress(data);
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != owner);
    owner = _newOwner;
  }
}

// File: contracts/land/ILANDRegistry.sol

interface ILANDRegistry {

  // LAND can be assigned by the owner
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
  function ownerOfLandMany(int[] x, int[] y) view public returns (address[]);
  function landOf(address owner) view public returns (int[], int[]);
  function landData(int x, int y) view public returns (string);

  // Transfer LAND
  function transferLand(int x, int y, address to) public;
  function transferManyLand(int[] x, int[] y, address to) public;

  // Update LAND
  function updateLandData(int x, int y, string data) public;
  function updateManyLandData(int[] x, int[] y, string data) public;
}

// File: erc821/contracts/IAssetHolder.sol

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

// File: erc821/contracts/IAssetRegistry.sol

interface IAssetRegistry {

  /**
   * Global Registry getter functions
   */
  function name() public view returns (string);
  function symbol() public view returns (string);
  function description() public view returns (string);
  function totalSupply() public view returns (uint256);

  /**
   * Asset-centric getter functions
   */
  function exists(uint256 assetId) public view returns (bool);

  function holderOf(uint256 assetId) public view returns (address);
  function safeHolderOf(uint256 assetId) public view returns (address);

  function assetData(uint256 assetId) public view returns (string);

  /**
   * Holder-centric getter functions
   */
  function assetCount(address holder) public view returns (uint256);
  function assetByIndex(address holder, uint256 index) public view returns (uint256);
  function assetsOf(address holder) external view returns (uint256[]);

  /**
   * Transfer Operations
   */
  function transfer(address to, uint256 assetId) public;
  function transfer(address to, uint256 assetId, bytes userData) public;
  function transfer(address to, uint256 assetId, bytes userData, bytes operatorData) public;

  /**
   * Authorization operations
   */
  function authorizeOperator(address operator, bool authorized) public;

  /**
   * Authorization getters
   */
  function isOperatorAuthorizedFor(address operator, address assetHolder)
    public view returns (bool);

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
  event Update(
    uint256 indexed assetId,
    address indexed holder,
    address indexed operator,
    string data
  );
  event AuthorizeOperator(
    address indexed operator,
    address indexed holder,
    bool authorized
  );
}

// File: eip820/contracts/InterfaceImplementationRegistry.sol

contract InterfaceImplementationRegistry {

    mapping (address => mapping(bytes32 => address)) interfaces;
    mapping (address => address) public managers;

    modifier canManage(address addr) {
        require(msg.sender == addr || msg.sender == managers[addr]);
        _;
    }

    function interfaceHash(string interfaceName) public pure returns(bytes32) {
        return keccak256(interfaceName);
    }


    /// @notice Query if an address implements an interface and thru which contract
    /// @param addr Address that is being queried for the implementation of an interface
    /// @param iHash SHA3 of the name of the interface as a string
    ///  Example `web3.utils.sha3('Ierc777`')`
    /// @return The address of the contract that implements a speficic interface
    ///  or 0x0 if `addr` does not implement this interface
    function getInterfaceImplementer(address addr, bytes32 iHash) public constant returns (address) {
        return interfaces[addr][iHash];
    }

    /// @notice Sets the contract that will handle a specific interface; only
    ///  the address itself or a `manager` defined for that address can set it
    /// @param addr Address that you want to define the interface for
    /// @param iHash SHA3 of the name of the interface as a string
    ///  For example `web3.utils.sha3('Ierc777')` for the Ierc777
    function setInterfaceImplementer(address addr, bytes32 iHash, address implementer) public canManage(addr)  {
        interfaces[addr][iHash] = implementer;
        InterfaceImplementerSet(addr, iHash, implementer);
    }

    /// @notice Sets an external `manager` that will be able to call `setInterfaceImplementer()`
    ///  on behalf of the address.
    /// @param addr Address that you are defining the manager for.
    /// @param newManager The address of the manager for the `addr` that will replace
    ///  the old one.  Set to 0x0 if you want to remove the manager.
    function changeManager(address addr, address newManager) public canManage(addr) {
        managers[addr] = newManager;
        ManagerChanged(addr, newManager);
    }

    event InterfaceImplementerSet(address indexed addr, bytes32 indexed interfaceHash, address indexed implementer);
    event ManagerChanged(address indexed addr, address indexed newManager);
}

// File: eip820/contracts/EIP820.sol

contract EIP820 {
    InterfaceImplementationRegistry interfaceImplementationRegistry = InterfaceImplementationRegistry(0x94405C3223089A942B7597dB96Dc60FcA17B0E3A);

    function setInterfaceImplementation(string ifaceLabel, address impl) internal {
        interfaceImplementationRegistry.setInterfaceImplementer(this, keccak256(ifaceLabel), impl);
    }

    function interfaceAddr(address addr, string ifaceLabel) internal constant returns(address) {
        return interfaceImplementationRegistry.getInterfaceImplementer(addr, keccak256(ifaceLabel));
    }

    function delegateManagement(address newManager) internal {
        interfaceImplementationRegistry.changeManager(this, newManager);
    }
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

// File: erc821/contracts/StandardAssetRegistry.sol

contract StandardAssetRegistry is AssetRegistryStorage, IAssetRegistry, EIP820 {
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

  function safeHolderOf(uint256 assetId) public view returns (address) {
    address holder = _holderOf[assetId];
    require(holder != 0);
    return holder;
  }

  function assetData(uint256 assetId) public view returns (string) {
    return _assetData[assetId];
  }

  function safeAssetData(uint256 assetId) public view returns (string) {
    require(_holderOf[assetId] != 0);
    return _assetData[assetId];
  }

  //
  // Holder-centric getter functions
  //

  function assetCount(address holder) public view returns (uint256) {
    return _assetsOf[holder].length;
  }

  function assetByIndex(address holder, uint256 index) public view returns (uint256) {
    require(index < _assetsOf[holder].length);
    require(index < (1<<127));
    return _assetsOf[holder][index];
  }

  function assetsOf(address holder) external view returns (uint256[]) {
    return _assetsOf[holder];
  }

  //
  // Authorization getters
  //

  function isOperatorAuthorizedFor(address operator, address assetHolder)
    public view returns (bool)
  {
    return _operators[assetHolder][operator];
  }

  function authorizeOperator(address operator, bool authorized) public {
    if (authorized) {
      require(!isOperatorAuthorizedFor(operator, msg.sender));
      _addAuthorization(operator, msg.sender);
    } else {
      require(isOperatorAuthorizedFor(operator, msg.sender));
      _clearAuthorization(operator, msg.sender);
    }
    AuthorizeOperator(operator, msg.sender, authorized);
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

    uint256 length = assetCount(to);

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
    uint256 lastAssetIndex = assetCount(from).sub(1);
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

  function _removeAssetData(uint256 assetId) internal {
    _assetData[assetId] = '';
  }

  //
  // Supply-altering functions
  //

  function _generate(uint256 assetId, address beneficiary, string data) internal {
    require(_holderOf[assetId] == 0);

    _addAssetTo(beneficiary, assetId, data);

    Transfer(0, beneficiary, assetId, msg.sender, bytes(data), '');
  }

  function _destroy(uint256 assetId) internal {
    address holder = _holderOf[assetId];
    require(holder != 0);

    _removeAssetFrom(holder, assetId);
    _removeAssetData(assetId);

    Transfer(holder, 0, assetId, msg.sender, '', '');
  }

  //
  // Transaction related operations
  //

  modifier onlyHolder(uint256 assetId) {
    require(_holderOf[assetId] == msg.sender);
    _;
  }

  modifier onlyOperatorOrHolder(uint256 assetId) {
    require(_holderOf[assetId] == msg.sender
         || isOperatorAuthorizedFor(msg.sender, _holderOf[assetId]));
    _;
  }

  modifier isDestinataryDefined(address destinatary) {
    require(destinatary != 0);
    _;
  }

  modifier destinataryIsNotHolder(uint256 assetId, address to) {
    require(_holderOf[assetId] != to);
    _;
  }

  function transfer(address to, uint256 assetId) public {
    return _doTransfer(to, assetId, '', 0, '');
  }

  function transfer(address to, uint256 assetId, bytes userData) public {
    return _doTransfer(to, assetId, userData, 0, '');
  }

  function transfer(address to, uint256 assetId, bytes userData, bytes operatorData) public {
    return _doTransfer(to, assetId, userData, msg.sender, operatorData);
  }

  function _doTransfer(
    address to, uint256 assetId, bytes userData, address operator, bytes operatorData
  )
    isDestinataryDefined(to)
    destinataryIsNotHolder(assetId, to)
    onlyOperatorOrHolder(assetId)
    internal
  {
    return _doSend(to, assetId, userData, operator, operatorData);
  }


  function _doSend(
    address to, uint256 assetId, bytes userData, address operator, bytes operatorData
  )
    internal
  {
    address holder = _holderOf[assetId];
    _removeAssetFrom(holder, assetId);
    _addAssetTo(to, assetId);

    if (_isContract(to)) {
      require(!_reentrancy);
      _reentrancy = true;

      address recipient = interfaceAddr(to, 'IAssetHolder');
      require(recipient != 0);

      IAssetHolder(recipient).onAssetReceived(assetId, holder, to, userData, operator, operatorData);

      _reentrancy = false;
    }

    Transfer(holder, to, assetId, operator, userData, operatorData);
  }

  //
  // Update related functions
  //

  function _update(uint256 assetId, string data) internal {
    require(exists(assetId));
    _assetData[assetId] = data;
    Update(assetId, _holderOf[assetId], msg.sender, data);
  }

  //
  // Utilities
  //

  function _isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}

// File: contracts/land/LANDRegistry.sol

contract LANDRegistry is Storage,
  Ownable, StandardAssetRegistry,
  ILANDRegistry
{

  function initialize(bytes data) public {
    _name = 'Decentraland LAND';
    _symbol = 'LAND';
    _description = 'Contract that stores the Decentraland LAND registry';
    owner = 0x55ed2910cc807e4596024266ebdf7b1753405a11;
  }

  function authorizeDeploy(address beneficiary) public onlyOwner {
    authorizedDeploy[beneficiary] = true;
  }
  function forbidDeploy(address beneficiary) public onlyOwner {
    authorizedDeploy[beneficiary] = false;
  }

  function assignNewParcel(int x, int y, address beneficiary) public {
    require(authorizedDeploy[msg.sender]);
    _generate(encodeTokenId(x, y), beneficiary, '');
  }

  function assignMultipleParcels(int[] x, int[] y, address beneficiary) public {
    require(authorizedDeploy[msg.sender]);
    for (uint i = 0; i < x.length; i++) {
      _generate(encodeTokenId(x[i], y[i]), beneficiary, '');
    }
  }

  function destroy(uint256 assetId) onlyOwner public {
    _destroy(assetId);
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

  function multiplePing(address[] users) public {
    require(authorizedDeploy[msg.sender]);
    for (uint i = 0; i < users.length; i++) {
      latestPing[users[i]] = now;
    }
  }

  function clearLand(int[] x, int[] y) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      uint landId = encodeTokenId(x[i], y[i]);
      address holder = holderOf(landId);
      if (latestPing[holder] < now - 1 years) {
        _destroy(landId);
      }
    }
  }

  // ERC20 compatibility functions
  function decimals() view public returns (uint8) {
    return 0;
  }

  function balanceOf(address user) view public returns (uint256) {
    return assetCount(user);
  }

  //
  // LAND Getters
  //

  function encodeTokenId(int x, int y) view public returns (uint) {
    return ((uint(x) * factor) & clearLow) | (uint(y) & clearHigh);
  }

  function decodeTokenId(uint value) view public returns (int, int) {
    uint x = (value & clearLow) >> 128;
    uint y = (value & clearHigh);
    return (expandNegative128BitCast(x), expandNegative128BitCast(y));
  }

  function expandNegative128BitCast(uint value) view public returns (int) {
    if (value & (1<<127) != 0) {
      return int(value | clearLow);
    }
    return int(value);
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

  function landOf(address owner) public view returns (int[], int[]) {
    int[] memory x = new int[](_assetsOf[owner].length);
    int[] memory y = new int[](_assetsOf[owner].length);

    int assetX;
    int assetY;
    uint length = _assetsOf[owner].length;
    for (uint i = 0; i < length; i++) {
      (assetX, assetY) = decodeTokenId(_assetsOf[owner][i]);
      x[i] = assetX;
      y[i] = assetY;
    }

    return (x, y);
  }

  function landData(int x, int y) view public returns (string) {
    return assetData(encodeTokenId(x, y));
  }

  //
  // Transfer LAND
  //

  function transferLand(int x, int y, address to) public {
    transfer(to, encodeTokenId(x, y));
  }

  function transferManyLand(int[] x, int[] y, address to) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      transfer(to, encodeTokenId(x[i], y[i]));
    }
  }

  //
  // Update LAND
  //

  function updateLandData(int x, int y, string data) public onlyOperatorOrHolder(encodeTokenId(x, y)) {
    return _update(encodeTokenId(x, y), data);
  }

  function updateManyLandData(int[] x, int[] y, string data) public {
    require(x.length == y.length);
    for (uint i = 0; i < x.length; i++) {
      updateLandData(x[i], y[i], data);
    }
  }
}