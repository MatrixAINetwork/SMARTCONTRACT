/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.15;


/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}


/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        owner = msg.sender;
    }

    address public newOwner;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    function changeOwner(address _newOwner) onlyOwner {
        if(msg.sender == owner) {
            owner = _newOwner;
        }
    }
}


contract DynamicCeiling is Owned {
    using SafeMath for uint256;

    struct Ceiling {
        bytes32 hash;
        uint256 limit;
        uint256 slopeFactor;
        uint256 collectMinimum;
    }

    address public saleAddress;

    Ceiling[] public ceilings;
    
    uint256 public currentIndex;
    uint256 public revealedCeilings;
    bool public allRevealed;

    modifier onlySaleAddress {
        require(msg.sender == saleAddress);
        _;
    }

    function DynamicCeiling(address _owner, address _saleAddress) {
        owner = _owner;
        saleAddress = _saleAddress;
    }

    /// @notice This should be called by the creator of the contract to commit
    ///  all the ceilings.
    /// @param _ceilingHashes Array of hashes of each ceiling. Each hash is calculated
    ///  by the `calculateHash` method. More hashes than actual ceilings can be
    ///  committed in order to hide also the number of ceilings.
    ///  The remaining hashes can be just random numbers.
    function setHiddenCeilings(bytes32[] _ceilingHashes) public onlyOwner {
        require(ceilings.length == 0);

        ceilings.length = _ceilingHashes.length;
        for (uint256 i = 0; i < _ceilingHashes.length; i = i.add(1)) {
            ceilings[i].hash = _ceilingHashes[i];
        }
    }

    /// @notice Anybody can reveal the next ceiling if he knows it.
    /// @param _limit Ceiling cap.
    ///  (must be greater or equal to the previous one).
    /// @param _last `true` if it's the last ceiling.
    /// @param _salt Random number used to commit the ceiling
    function revealCeiling(
        uint256 _limit, 
        uint256 _slopeFactor, 
        uint256 _collectMinimum,
        bool _last, 
        bytes32 _salt) 
        public 
        {
        require(!allRevealed);
        require(
            ceilings[revealedCeilings].hash == 
            calculateHash(
                _limit, 
                _slopeFactor, 
                _collectMinimum, 
                _last, 
                _salt
            )
        );

        require(_limit != 0 && _slopeFactor != 0 && _collectMinimum != 0);
        if (revealedCeilings > 0) {
            require(_limit >= ceilings[revealedCeilings.sub(1)].limit);
        }

        ceilings[revealedCeilings].limit = _limit;
        ceilings[revealedCeilings].slopeFactor = _slopeFactor;
        ceilings[revealedCeilings].collectMinimum = _collectMinimum;
        revealedCeilings = revealedCeilings.add(1);

        if (_last) {
            allRevealed = true;
        }
    }

    /// @notice Reveal multiple ceilings at once
    function revealMulti(
        uint256[] _limits,
        uint256[] _slopeFactors,
        uint256[] _collectMinimums,
        bool[] _lasts, 
        bytes32[] _salts) 
        public 
        {
        // Do not allow none and needs to be same length for all parameters
        require(
            _limits.length != 0 &&
            _limits.length == _slopeFactors.length &&
            _limits.length == _collectMinimums.length &&
            _limits.length == _lasts.length &&
            _limits.length == _salts.length
        );

        for (uint256 i = 0; i < _limits.length; i = i.add(1)) {
            
            revealCeiling(
                _limits[i],
                _slopeFactors[i],
                _collectMinimums[i],
                _lasts[i],
                _salts[i]
            );
        }
    }

    /// @notice Move to ceiling, used as a failsafe
    function moveToNextCeiling() public onlyOwner {

        currentIndex = currentIndex.add(1);
    }

    /// @return Return the funds to collect for the current point on the ceiling
    ///  (or 0 if no ceilings revealed yet)
    function availableAmountToCollect(uint256  totallCollected) public onlySaleAddress returns (uint256) {
    
        if (revealedCeilings == 0) {
            return 0;
        }

        if (totallCollected >= ceilings[currentIndex].limit) {  
            uint256 nextIndex = currentIndex.add(1);

            if (nextIndex >= revealedCeilings) {
                return 0; 
            }
            currentIndex = nextIndex;
            if (totallCollected >= ceilings[currentIndex].limit) {
                return 0;  
            }
        }        
        uint256 remainedFromCurrentCeiling = ceilings[currentIndex].limit.sub(totallCollected);
        uint256 reminderWithSlopeFactor = remainedFromCurrentCeiling.div(ceilings[currentIndex].slopeFactor);

        if (reminderWithSlopeFactor > ceilings[currentIndex].collectMinimum) {
            return reminderWithSlopeFactor;
        }
        
        if (remainedFromCurrentCeiling > ceilings[currentIndex].collectMinimum) {
            return ceilings[currentIndex].collectMinimum;
        } else {
            return remainedFromCurrentCeiling;
        }
    }

    /// @notice Calculates the hash of a ceiling.
    /// @param _limit Ceiling cap.
    /// @param _last `true` if it's the last ceiling.
    /// @param _collectMinimum the minimum amount to collect
    /// @param _salt Random number that will be needed to reveal this ceiling.
    /// @return The calculated hash of this ceiling to be used in the `setHiddenCurves` method
    function calculateHash(
        uint256 _limit, 
        uint256 _slopeFactor, 
        uint256 _collectMinimum,
        bool _last, 
        bytes32 _salt) 
        public 
        constant 
        returns (bytes32) 
        {
        return keccak256(
            _limit,
            _slopeFactor, 
            _collectMinimum,
            _last,
            _salt
        );
    }

    /// @return Return the total number of ceilings committed
    ///  (can be larger than the number of actual ceilings on the ceiling to hide
    ///  the real number of ceilings)
    function nCeilings() public constant returns (uint256) {
        return ceilings.length;
    }

}