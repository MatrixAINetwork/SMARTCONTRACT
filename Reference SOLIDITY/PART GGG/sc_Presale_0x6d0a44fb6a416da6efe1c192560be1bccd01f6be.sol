/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

/**
 * https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * license: MIT
 */
contract OwnableSimple {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function OwnableSimple() public {
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

// based on axiomzen, MIT license
contract RandomApi {
    uint64 _seed = 0;

    function random(uint64 maxExclusive) public returns (uint64 randomNumber) {
        // the blockhash of the current block (and future block) is 0 because it doesn't exist
        _seed = uint64(keccak256(keccak256(block.blockhash(block.number - 1), _seed), block.timestamp));
        return _seed % maxExclusive;
    }

    function random256() public returns (uint256 randomNumber) {
        uint256 rand = uint256(keccak256(keccak256(block.blockhash(block.number - 1), _seed), block.timestamp));
        _seed = uint64(rand);
        return rand;
    }
}

// @title ERC-165: Standard interface detection
// https://github.com/ethereum/EIPs/issues/165
contract ERC165 {
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

// @title ERC-721: Non-Fungible Tokens
// @author Dieter Shirley (https://github.com/dete)
// @dev https://github.com/ethereum/eips/issues/721
contract ERC721 is ERC165 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 count);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    
    // described in old version of the standard
    // use the more flexible transferFrom
    function takeOwnership(uint256 _tokenId) external;

    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    // Optional
    // function name() public view returns (string);
    // function symbol() public view returns (string);
    function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    function tokenMetadata(uint256 _tokenId, string _preferredTransport) external view returns (string infoUrl);
    
    // Optional, described in old version of the standard
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);
    function tokenMetadata(uint256 _tokenId) external view returns (string infoUrl);
}

// Based on strings library by Nick Johnson <