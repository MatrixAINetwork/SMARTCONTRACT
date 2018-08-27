/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
   @title ERC827 interface, an extension of ERC20 token standard

   Interface of a ERC827 token, following the ERC20 standard with extra
   methods to transfer value and data and execute calls in transfers and
   approvals.
 */
contract ERC827 is ERC20 {

  function approve( address _spender, uint256 _value, bytes _data ) public returns (bool);
  function transfer( address _to, uint256 _value, bytes _data ) public returns (bool);
  function transferFrom( address _from, address _to, uint256 _value, bytes _data ) public returns (bool);

}

contract AccessControl {
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
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
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
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}

/// @title 
contract TournamentInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isTournament() public pure returns (bool);
    function isPlayerIdle(address _owner, uint256 _playerId) public view returns (bool);
}

/// @title Base contract for BS. Holds all common structs, events and base variables.
contract BSBase is AccessControl {
    /*** EVENTS ***/

    /// @dev The Birth event is fired whenever a new player comes into existence. 
    event Birth(address owner, uint32 playerId, uint16 typeId, uint8 attack, uint8 defense, uint8 stamina, uint8 xp, uint8 isKeeper, uint16 skillId);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a player
    ///  ownership is assigned, including births.
    event Transfer(address from, address to, uint256 tokenId);

    struct Player {
        uint16 typeId;
        uint8 attack;
        uint8 defense;
        uint8 stamina;
        uint8 xp;
        uint8 isKeeper;
        uint16 skillId;
        uint8 isSkillOn;
    }

    Player[] players;
    uint256 constant commonPlayerCount = 10;
    uint256 constant totalPlayerSupplyLimit = 80000000;
    mapping (uint256 => address) public playerIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;
    mapping (uint256 => address) public playerIndexToApproved;
    /// SaleClockAuction public saleAuction;
    ERC827 public joyTokenContract;
    TournamentInterface public tournamentContract;

    /// @dev Assigns ownership of a specific Player to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // since the number of players is capped to 2^32
        // there is no way to overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        playerIndexToOwner[_tokenId] = _to;
        // When creating new player _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete playerIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    function _createPlayer(
        address _owner,
        uint256 _typeId,
        uint256 _attack,
        uint256 _defense,
        uint256 _stamina,
        uint256 _xp,
        uint256 _isKeeper,
        uint256 _skillId
    )
        internal
        returns (uint256)
    {
        Player memory _player = Player({
            typeId: uint16(_typeId), 
            attack: uint8(_attack), 
            defense: uint8(_defense), 
            stamina: uint8(_stamina),
            xp: uint8(_xp),
            isKeeper: uint8(_isKeeper),
            skillId: uint16(_skillId),
            isSkillOn: 0
        });
        uint256 newPlayerId = players.push(_player) - 1;

        require(newPlayerId <= totalPlayerSupplyLimit);

        // emit the birth event
        Birth(
            _owner,
            uint32(newPlayerId),
            _player.typeId,
            _player.attack,
            _player.defense,
            _player.stamina,
            _player.xp,
            _player.isKeeper,
            _player.skillId
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newPlayerId);

        return newPlayerId;
    }
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <