/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

// ----------------------------------------------------------------------------------------------
// A collaboration between Incent and Bok :)
// Enjoy. (c) Incent Loyalty Pty Ltd, and Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------------------------

//config contract
contract TokenConfig {

    string public constant name = "BlockSwap Wrapped Golem Network Token";
    string public constant symbol = "BSGNT";

}


// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
// matches Golem
contract GNTInterface {

    // Get the total token supply
    function totalSupply() constant returns (uint256 totalSupply);

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance);

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) returns (bool success);

    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //setup decimals as defined in GNT contract
    function decimals() constant returns (uint8);

}

contract BlockSwapWrapperGolemNetworkToken is TokenConfig {

    //public GNT contract address
    GNTInterface public gntContractAddress = GNTInterface(0xa74476443119a942de498590fe1f2454d7d4ac0d);

    // Owner of this contract
    address public owner;

    function decimals() constant returns (uint8) {
        return gntContractAddress.decimals();
    }

    function totalSupply() external constant returns (uint256) {
        return gntContractAddress.totalSupply();
    }

    function balanceOf(address _owner) external constant returns (uint256) {
        return  gntContractAddress.balanceOf(_owner);
    }

    function transfer(address _to, uint256 _value) returns (bool) {
        return gntContractAddress.transfer(_to, _value);
    }

    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    function moveToWaves(string wavesAddress, uint256 amount) {
        if (!gntContractAddress.transfer(owner, amount)) throw;
        WavesTransfer(msg.sender, wavesAddress, amount);
    }
    event WavesTransfer(address indexed _from, string wavesAddress, uint256 amount);

}