/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract DemoUSDPricedCrowdsale is Ownable {

        using SafeMath for uint256;

        /* the number of tokens already sold through this contract*/
        uint256 public tokensSold = 0;

        /* How many wei of funding we have raised */
        uint256 public weiRaised = 0;
        uint256 public centsRaised = 0;

        uint256 public centsPerEther = 30400;
        uint256 public bonusPercent = 0;
        uint256 public centsPerToken = 30;
        uint256 public debugLatestPurchaseCentsValue;

        address public wallet;

        ERC20Basic tokenContract;

        event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

        event EventCentsPerEtherChanged(uint256 _oldcentsPerEther, uint256 _centsPerEther);
        event EventCentsPerTokenChanged(uint256 _oldcentsPerEther, uint256 _centsPerEther);
        event EventBonusPercentChanged(uint256 _oldcentsPerEther, uint256 _centsPerEther);
        event ChangeWallet(address _oldWallet, address _newWallet);


        function DemoUSDPricedCrowdsale(
                uint256 _centsPerEther,
                uint256 _centsPerToken,
                address _tokenContract,
                address _wallet
        ) {
                require(_centsPerEther > 0);
                require(_centsPerToken > 0);
                require(_tokenContract != 0x0);
                require(_wallet != 0x0);

                centsPerEther = _centsPerEther;
                centsPerToken = _centsPerToken;
                tokenContract = ERC20Basic(_tokenContract);
                wallet = _wallet;
        }

        function setCentsPerEther(uint256 _centsPerEther) onlyOwner {
                require(_centsPerEther > 0);
                uint256 oldCentsPerEther = centsPerEther;
                centsPerEther = _centsPerEther;
                EventCentsPerEtherChanged(oldCentsPerEther, centsPerEther);
        }

        function setCentsPerToken(uint256 _centsPerToken) onlyOwner {
                require(_centsPerToken > 0);
                uint256 oldCentsPerToken = centsPerToken;
                centsPerToken = _centsPerToken;
                EventCentsPerTokenChanged(oldCentsPerToken, centsPerToken);
        }

        function setBonusPercent(uint256 _bonusPercent) onlyOwner {
                require(_bonusPercent > 0);
                uint256 oldBonusPercent = _bonusPercent;
                bonusPercent = _bonusPercent;
                EventBonusPercentChanged(oldBonusPercent, bonusPercent);
        }

        function changeWallet(address _wallet) onlyOwner {
                require(_wallet != 0x0);
                address oldWallet = _wallet;
                wallet = _wallet;
                ChangeWallet(oldWallet, wallet);
        }

        // fallback function can be used to buy tokens
        function () payable {
                buyTokens(msg.sender);
        }

        // low level token purchase function
        function buyTokens(address beneficiary) payable {
                require(beneficiary != 0x0);
                require(msg.value != 0);

                uint256 weiAmount = msg.value;
                uint256 centsAmount = weiAmount.mul(centsPerEther).div(1E18);
                debugLatestPurchaseCentsValue = centsAmount;
                // calculate token amount to be created

                uint256 tokens = centsAmount.div(centsPerToken).mul(getBonusCoefficient()).div(100);

                // update state
                weiRaised = weiRaised.add(weiAmount);
                weiRaised = centsAmount.add(weiAmount);

                tokenContract.transfer(beneficiary, tokens);
                forwardFunds();
        }

        function getBonusCoefficient() constant returns (uint256) {
                return 100 + bonusPercent;
        }

        function forwardFunds() internal {
                wallet.transfer(msg.value);
        }

        function withdrawTokens(address where) onlyOwner {
                tokenContract.transfer(where, tokenContract.balanceOf(this));
        }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}