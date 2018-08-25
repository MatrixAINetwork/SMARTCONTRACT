/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

// File: contracts-origin/AetherAccessControl.sol

/// @title A facet of AetherCore that manages special access privileges.
/// @dev See the AetherCore contract documentation to understand how the various contract facets are arranged.
contract AetherAccessControl {
    // This facet controls access control for Laputa. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the AetherCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from AetherCore and its auction contracts.
    //
    //     - The COO: The COO can release properties to auction.
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    /// @dev Emited when contract is upgraded - See README.md for updgrade plan
    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) public onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) public onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    function withdrawBalance() external onlyCFO {
        cfoAddress.transfer(this.balance);
    }


    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() public onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}

// File: contracts-origin/AetherBase.sol

/// @title Base contract for Aether. Holds all common structs, events and base variables.
/// @author Project Aether (https://www.aether.city)
/// @dev See the PropertyCore contract documentation to understand how the various contract facets are arranged.
contract AetherBase is AetherAccessControl {
    /*** EVENTS ***/

    /// @dev The Construct event is fired whenever a property updates.
    event Construct (
      address indexed owner,
      uint256 propertyId,
      PropertyClass class,
      uint8 x,
      uint8 y,
      uint8 z,
      uint8 dx,
      uint8 dz,
      string data
    );

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every
    ///  time a property ownership is assigned.
    event Transfer(
      address indexed from,
      address indexed to,
      uint256 indexed tokenId
    );

    /*** DATA ***/

    enum PropertyClass { DISTRICT, BUILDING, UNIT }

    /// @dev The main Property struct. Every property in Aether is represented
    ///  by a variant of this structure.
    struct Property {
        uint32 parent;
        PropertyClass class;
        uint8 x;
        uint8 y;
        uint8 z;
        uint8 dx;
        uint8 dz;
    }

    /*** STORAGE ***/

    /// @dev Ensures that property occupies unique part of the universe.
    bool[100][100][100] public world;

    /// @dev An array containing the Property struct for all properties in existence. The ID
    ///  of each property is actually an index into this array.
    Property[] properties;

    /// @dev An array containing the district addresses in existence.
    uint256[] districts;

    /// @dev A measure of world progression.
    uint256 public progress;

    /// @dev The fee associated with constructing a unit property.
    uint256 public unitCreationFee = 0.05 ether;

    /// @dev Keeps track whether updating data is paused.
    bool public updateEnabled = true;

    /// @dev A mapping from property IDs to the address that owns them. All properties have
    ///  some valid owner address, even gen0 properties are created with a non-zero owner.
    mapping (uint256 => address) public propertyIndexToOwner;

    /// @dev A mapping from property IDs to the data that is stored on them.
    mapping (uint256 => string) public propertyIndexToData;

    /// @dev A mapping from owner address to count of tokens that address owns.
    ///  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    /// @dev Mappings between property nodes.
    mapping (uint256 => uint256) public districtToBuildingsCount;
    mapping (uint256 => uint256[]) public districtToBuildings;
    mapping (uint256 => uint256) public buildingToUnitCount;
    mapping (uint256 => uint256[]) public buildingToUnits;

    /// @dev A mapping from building propertyId to unit construction privacy.
    mapping (uint256 => bool) public buildingIsPublic;

    /// @dev A mapping from PropertyIDs to an address that has been approved to call
    ///  transferFrom(). Each Property can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public propertyIndexToApproved;

    /// @dev Assigns ownership of a specific Property to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
      // since the number of properties is capped to 2^32
      // there is no way to overflow this
      ownershipTokenCount[_to]++;
      // transfer ownership
      propertyIndexToOwner[_tokenId] = _to;
      // When creating new properties _from is 0x0, but we can't account that address.
      if (_from != address(0)) {
          ownershipTokenCount[_from]--;
          // clear any previously approved ownership exchange
          delete propertyIndexToApproved[_tokenId];
      }
      // Emit the transfer event.
      Transfer(_from, _to, _tokenId);
    }

    function _createUnit(
      uint256 _parent,
      uint256 _x,
      uint256 _y,
      uint256 _z,
      address _owner
    )
        internal
        returns (uint)
    {
      require(_x == uint256(uint8(_x)));
      require(_y == uint256(uint8(_y)));
      require(_z == uint256(uint8(_z)));
      require(!world[_x][_y][_z]);
      world[_x][_y][_z] = true;
      return _createProperty(
        _parent,
        PropertyClass.UNIT,
        _x,
        _y,
        _z,
        0,
        0,
        _owner
      );
    }

    function _createBuilding(
      uint256 _parent,
      uint256 _x,
      uint256 _y,
      uint256 _z,
      uint256 _dx,
      uint256 _dz,
      address _owner,
      bool _public
    )
        internal
        returns (uint)
    {
      require(_x == uint256(uint8(_x)));
      require(_y == uint256(uint8(_y)));
      require(_z == uint256(uint8(_z)));
      require(_dx == uint256(uint8(_dx)));
      require(_dz == uint256(uint8(_dz)));

      // Looping over world space.
      for(uint256 i = 0; i < _dx; i++) {
          for(uint256 j = 0; j <_dz; j++) {
              if (world[_x + i][0][_z + j]) {
                  revert();
              }
              world[_x + i][0][_z + j] = true;
          }
      }

      uint propertyId = _createProperty(
        _parent,
        PropertyClass.BUILDING,
        _x,
        _y,
        _z,
        _dx,
        _dz,
        _owner
      );

      districtToBuildingsCount[_parent]++;
      districtToBuildings[_parent].push(propertyId);
      buildingIsPublic[propertyId] = _public;
      return propertyId;
    }

    function _createDistrict(
      uint256 _x,
      uint256 _z,
      uint256 _dx,
      uint256 _dz
    )
        internal
        returns (uint)
    {
      require(_x == uint256(uint8(_x)));
      require(_z == uint256(uint8(_z)));
      require(_dx == uint256(uint8(_dx)));
      require(_dz == uint256(uint8(_dz)));

      uint propertyId = _createProperty(
        districts.length,
        PropertyClass.DISTRICT,
        _x,
        0,
        _z,
        _dx,
        _dz,
        cooAddress
      );

      districts.push(propertyId);
      return propertyId;

    }


    /// @dev An internal method that creates a new property and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Construct event
    ///  and a Transfer event.
    function _createProperty(
        uint256 _parent,
        PropertyClass _class,
        uint256 _x,
        uint256 _y,
        uint256 _z,
        uint256 _dx,
        uint256 _dz,
        address _owner
    )
        internal
        returns (uint)
    {
        require(_x == uint256(uint8(_x)));
        require(_y == uint256(uint8(_y)));
        require(_z == uint256(uint8(_z)));
        require(_dx == uint256(uint8(_dx)));
        require(_dz == uint256(uint8(_dz)));
        require(_parent == uint256(uint32(_parent)));
        require(uint256(_class) <= 3);

        Property memory _property = Property({
            parent: uint32(_parent),
            class: _class,
            x: uint8(_x),
            y: uint8(_y),
            z: uint8(_z),
            dx: uint8(_dx),
            dz: uint8(_dz)
        });
        uint256 _tokenId = properties.push(_property) - 1;

        // It's never going to happen, 4 billion properties is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(_tokenId <= 4294967295);

        Construct(
            _owner,
            _tokenId,
            _property.class,
            _property.x,
            _property.y,
            _property.z,
            _property.dx,
            _property.dz,
            ""
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, _tokenId);

        return _tokenId;
    }

    /// @dev Computing height of a building with respect to city progression.
    function _computeHeight(
      uint256 _x,
      uint256 _z,
      uint256 _height
    ) internal view returns (uint256) {
        uint256 x = _x < 50 ? 50 - _x : _x - 50;
        uint256 z = _z < 50 ? 50 - _z : _z - 50;
        uint256 distance = x > z ? x : z;
        if (distance > progress) {
          return 1;
        }
        uint256 scale = 100 - (distance * 100) / progress ;
        uint256 height = 2 * progress * _height * scale / 10000;
        return height > 0 ? height : 1;
    }

    /// @dev Convenience function to see if this building has room for a unit.
    function canCreateUnit(uint256 _buildingId)
        public
        view
        returns(bool)
    {
      Property storage _property = properties[_buildingId];
      if (_property.class == PropertyClass.BUILDING &&
            (buildingIsPublic[_buildingId] ||
              propertyIndexToOwner[_buildingId] == msg.sender)
      ) {
        uint256 totalVolume = _property.dx * _property.dz *
          (_computeHeight(_property.x, _property.z, _property.y) - 1);
        uint256 totalUnits = buildingToUnitCount[_buildingId];
        return totalUnits < totalVolume;
      }
      return false;
    }

    /// @dev This internal function skips all validation checks. Ensure that
    //   canCreateUnit() is required before calling this method.
    function _createUnitHelper(uint256 _buildingId, address _owner)
        internal
        returns(uint256)
    {
        // Grab a reference to the property in storage.
        Property storage _property = properties[_buildingId];
        uint256 totalArea = _property.dx * _property.dz;
        uint256 index = buildingToUnitCount[_buildingId];

        // Calculate next location.
        uint256 y = index / totalArea + 1;
        uint256 intermediate = index % totalArea;
        uint256 z = intermediate / _property.dx;
        uint256 x = intermediate % _property.dx;

        uint256 unitId = _createUnit(
          _buildingId,
          x + _property.x,
          y,
          z + _property.z,
          _owner
        );

        buildingToUnitCount[_buildingId]++;
        buildingToUnits[_buildingId].push(unitId);

        // Return the new unit's ID.
        return unitId;
    }

    /// @dev Update allows for setting a building privacy.
    function updateBuildingPrivacy(uint _tokenId, bool _public) public {
        require(propertyIndexToOwner[_tokenId] == msg.sender);
        buildingIsPublic[_tokenId] = _public;
    }

    /// @dev Update allows for setting the data associated to a property.
    function updatePropertyData(uint _tokenId, string _data) public {
        require(updateEnabled);
        address _owner = propertyIndexToOwner[_tokenId];
        require(msg.sender == _owner);
        propertyIndexToData[_tokenId] = _data;
        Property memory _property = properties[_tokenId];
        Construct(
            _owner,
            _tokenId,
            _property.class,
            _property.x,
            _property.y,
            _property.z,
            _property.dx,
            _property.dz,
            _data
        );
    }
}

// File: contracts-origin/ERC721Draft.sol

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <