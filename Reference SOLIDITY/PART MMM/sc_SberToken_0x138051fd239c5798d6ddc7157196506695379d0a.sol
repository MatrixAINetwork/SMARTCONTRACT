/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract Owned {

    address public owner = msg.sender;
    address public potentialOwner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPotentialOwner {
        require(msg.sender == potentialOwner);
        _;
    }

    event NewOwner(address old, address current);
    event NewPotentialOwner(address old, address potential);

    function setOwner(address _new)
        public
        onlyOwner
    {
        NewPotentialOwner(owner, _new);
        potentialOwner = _new;
    }

    function confirmOwnership()
        public
        onlyPotentialOwner
    {
        NewOwner(owner, potentialOwner);
        owner = potentialOwner;
        potentialOwner = 0;
    }
}

/// @title Abstract ERC20 token interface
contract AbstractToken {

    function balanceOf(address owner) public view returns (uint256 balance);
    function transfer(address to, uint256 value) public returns (bool success);
    function transferFrom(address from, address to, uint256 value) public returns (bool success);
    function approve(address spender, uint256 value) public returns (bool success);
    function allowance(address owner, address spender) public view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}

/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
contract StandardToken is AbstractToken, Owned {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /*
     *  Read and write storage functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      //
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read storage functions
     */
    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}



/// @title SafeMath contract - Math operations with safety checks.
/// @author OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
contract SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint a, uint b) internal pure returns (uint) {
        uint c = a ** b;
        assert(c >= a);
        return c;
    }
}

/// @title Token contract - Implements Standard ERC20 with additional features.
contract Token is StandardToken, SafeMath {

    // Time of the contract creation
    uint public creationTime;

    function Token() public {
        creationTime = now;
    }


    /// @dev Owner can transfer out any accidentally sent ERC20 tokens
    function transferERC20Token(address tokenAddress)
        public
        onlyOwner
        returns (bool)
    {
        uint balance = AbstractToken(tokenAddress).balanceOf(this);
        return AbstractToken(tokenAddress).transfer(owner, balance);
    }

    /// @dev Multiplies the given number by 10^(decimals)
    function withDecimals(uint number, uint decimals)
        internal
        pure
        returns (uint)
    {
        return mul(number, pow(10, decimals));
    }
}

contract SberToken is Token {
    /*
     * Token meta data
     */
    string constant public name = "SberToken";

    string constant public symbol = "SRUB";
    uint8 constant public decimals = 8;

    // Address where Foundation tokens are allocated
    address constant public foundationReserve = address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);

    // Address where tokens are minted (for Etherscan)
    address constant public mintAddress = address(0x1111111111111111111111111111111111111111);

    // Address where tokens are burned (for Etherscan)
    address constant public burnAddress = address(0x0000000000000000000000000000000000000000);

    /// @dev Contract constructor
    function SberToken()
        public
    {
        // Overall, 1,000,000,000 SRUB tokens are distributed
        totalSupply = withDecimals(pow(10,9), decimals);

        // Allocate foundation tokens
        balances[foundationReserve] = totalSupply;
        allowed[foundationReserve][owner] = balanceOf(foundationReserve);

        //Add log for Etherscan
        Transfer(mintAddress, foundationReserve, balanceOf(foundationReserve));
        Issuance(foundationReserve, balanceOf(foundationReserve));
    }

    /// @dev Mint new tokens to foundationReserve
    function mint(uint256 amount)
      public
      onlyOwner
    {
        // Calculate amount of tokens needed to be minted with decimals
        uint256 mintedSupply = withDecimals(amount, decimals);

        //Calculate new total supply
        totalSupply = add(totalSupply, mintedSupply);

        //Increase balance of foundationReserve
        balances[foundationReserve] = add(balanceOf(foundationReserve), mintedSupply);
        allowed[foundationReserve][owner] = balanceOf(foundationReserve);

        //Add log for Etherscan
        Transfer(mintAddress, foundationReserve, mintedSupply);
        Issuance(foundationReserve, mintedSupply);
    }

    /// @dev Burn tokens from foundationReserve
    function burn(uint256 amount)
      public
      onlyOwner
    {
      // Calculate amount of tokens needed to be minted with decimals
      uint256 burnedSupply = withDecimals(amount, decimals);

      // Check if foundationReserve has enough tokens
      require(burnedSupply <= balanceOf(foundationReserve));

      //Calculate new total supply
      totalSupply = sub(totalSupply, burnedSupply);

      //Decrease balance of foundationReserve
      balances[foundationReserve] = sub(balanceOf(foundationReserve), burnedSupply);
      allowed[foundationReserve][owner] = balanceOf(foundationReserve);

      //Add log for Etherscan
      Transfer(foundationReserve, burnAddress, burnedSupply);
    }

    function confirmOwnership()
        public
        onlyPotentialOwner
    {
        // Forbid old owner to withdraw tokens from the Foundation reserve allocation
        allowed[foundationReserve][owner] = 0;

        // Allow new owner to withdraw tokens from the Foundation reserve
        allowed[foundationReserve][msg.sender] = balanceOf(foundationReserve);

        super.confirmOwnership();
    }


    /// @dev Withdraws tokens from Foundation reserve
    function withdrawFromReserve(address _to, uint256 amount)
        public
        onlyOwner
    {
        require(transferFrom(foundationReserve, _to, withDecimals(amount, decimals)));
    }
}