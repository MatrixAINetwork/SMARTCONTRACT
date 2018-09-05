/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

// File: contracts/Interfaces/MasterDepositInterface.sol

/**
 * @dev Interface of MasterDeposit that should be used in child contracts 
 * @dev this ensures that no duplication of code and implicit gasprice will be used for the dynamic creation of child contract
 */
contract MasterDepositInterface {
    address public coldWallet1;
    address public coldWallet2;
    uint public percentage;
    function fireDepositToChildEvent(uint _amount) public;
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: contracts/ChildDeposit.sol

/**
* @dev Should be dinamically created from master contract 
* @dev multiple payers can contribute here 
*/
contract ChildDeposit {
    
    /**
    * @dev prevents over and under flows
    */
    using SafeMath for uint;
    
    /**
    * @dev import only the interface for low gas cost
    */
    // MasterDepositInterface public master;
    address masterAddress;

    function ChildDeposit() public {
        masterAddress = msg.sender;
        // master = MasterDepositInterface(msg.sender);
    }

    /**
    * @dev any ETH income will fire a master deposit contract event
    * @dev the redirect of ETH will be split in the two wallets provided by the master with respect to the share percentage set for wallet 1 
    */
    function() public payable {

        MasterDepositInterface master = MasterDepositInterface(masterAddress);
        // fire transfer event
        master.fireDepositToChildEvent(msg.value);

        // trasnfer of ETH
        // with respect to the percentage set
        uint coldWallet1Share = msg.value.mul(master.percentage()).div(100);
        
        // actual transfer
        master.coldWallet1().transfer(coldWallet1Share);
        master.coldWallet2().transfer(msg.value.sub(coldWallet1Share));
    }

    /**
    * @dev function that can only be called by the creator of this contract
    * @dev the actual condition of transfer is in the logic of the master contract
    * @param _value ERC20 amount 
    * @param _tokenAddress ERC20 contract address 
    * @param _destination should be onbe of the 2 coldwallets
    */
    function withdraw(address _tokenAddress, uint _value, address _destination) public onlyMaster {
        ERC20(_tokenAddress).transfer(_destination, _value);
    }

    modifier onlyMaster() {
        require(msg.sender == address(masterAddress));
        _;
    }
    
}

// File: zeppelin-solidity/contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <