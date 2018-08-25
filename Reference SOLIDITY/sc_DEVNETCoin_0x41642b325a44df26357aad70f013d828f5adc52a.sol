/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

// Code borrowed and modified from https://theethereum.wiki/w/index.php/ERC20_Token_Standard
// Use is just an example for Cisco Live DEVNET class and is provided as is. 

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

// ----------------------------------------------------------------------------

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


contract DEVNETCoin is ERC20Interface {
    // add some function to uint to make it safe. 
    using SafeMath for uint;
    // information about the coin.
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public _totalSupply;
    // people that own our coin.
    uint16 userCount;
    address[] public accounts;
    mapping(address => uint256) balances;
    // mapping of who can withdraw from who.
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => uint) pendingWithdrawals;
    address public val;
    address public tom;
    address public chris;
    address public roger;
    address public bryan;
    address public hank;

    // Constructor when contract is created. 
    function DEVNETCoin(address _val, address _tom, address _chris, address _hank, address _roger, address _bryan) public {
      name = "DEVNET|Coin";
      symbol = "DEV";
      decimals = 18;
      _totalSupply = 24000000 * 10**uint(decimals);
      val = _val;
      tom = _tom;
      chris = _chris;
      hank = _hank;
      bryan = _bryan;
      roger = _roger;
      balances[val] = _totalSupply / 12;
      balances[tom] = _totalSupply / 12;
      balances[chris] = _totalSupply / 12;
      balances[hank] = _totalSupply / 12;
      balances[bryan] = _totalSupply / 12;
      balances[roger] = _totalSupply / 12;
      accounts.push(val);
      accounts.push(tom);
      userCount = 2;
      Transfer(address(0), val, _totalSupply / 12);
      Transfer(address(0), tom, _totalSupply / 12);
      Transfer(address(0), chris, _totalSupply / 12);
      Transfer(address(0), hank, _totalSupply / 12);
      Transfer(address(0), bryan, _totalSupply / 12);
      Transfer(address(0), roger, _totalSupply / 12);
      // 10,500,000,000,000
    }

    // get item count
    function getAccountQuantity() public constant returns (uint count) {
      return userCount;
    }

    // get the total supply 
    function totalSupply() public constant returns (uint) {
      return _totalSupply - balances[address(0)];
    }

    // get the token balance for a token owner.
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
      return balances[tokenOwner];
    }

    // send tokens from one account to another address. 
    function transfer(address to, uint tokens) public returns (bool success) {
      // notice we use the safemath here 
      //tokens = tokens;
      balances[msg.sender] = balances[msg.sender].sub(tokens);
      balances[to] = balances[to].add(tokens);
      Transfer(msg.sender, to, tokens);
      return true;
    }

    // approve someone to be able to transfer tokens from your account. 
    function approve(address spender, uint tokens) public returns (bool success) {
      allowed[msg.sender][spender] = tokens;
      Approval(msg.sender, spender, tokens); 
      return true;
    }
   
    // called by the person claiming the tokens.   
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
      balances[from] = balances[from].sub(tokens);
      allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
      balances[to] = balances[to].add(tokens);
      Transfer(from, to, tokens);
      return true;
    }

    // returns the amount of tokens approved by the owners that can be transferred to 
    // the spender's account. 
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
      return allowed[tokenOwner][spender];
    }
 
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
      allowed[msg.sender][spender] = tokens;
      Approval(msg.sender, spender, tokens);
      ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
      return true;
    } 

   
    function buyDEV() public payable {

        uint tokensRemaining = _totalSupply;
        uint tokensBought = 0;
        require(_totalSupply > 0);
        uint etherReceived = msg.value; 
        
        if (tokensRemaining >= etherReceived * 100) {
          tokensBought = etherReceived * 100;
          tokensRemaining -= etherReceived;
        } else {
          tokensBought = tokensRemaining;
          tokensRemaining = 0;
        }
        // make sure sender doesnt already exist.  If they don't, add new.  

        if (balances[msg.sender] == 0) {
          accounts.push(msg.sender);
          userCount++;
        }
        
        balances[msg.sender] = balances[msg.sender] + tokensBought;
  
      
        Transfer(address(0), msg.sender, tokensBought);

        pendingWithdrawals[val] += msg.value / 3;
        pendingWithdrawals[chris] += msg.value / 3;
        pendingWithdrawals[tom] += msg.value / 3;
    } 

    // if people want to buy eth then we will send them tokens. 
    function () public payable {
      buyDEV();
    }

    // give all them money to val or tom
    function withdraw() public {
      uint amount  = pendingWithdrawals[msg.sender];
      pendingWithdrawals[msg.sender] = 0;
      msg.sender.transfer(amount);
    }

    modifier usOnly() {
      require(msg.sender == val || msg.sender == chris || msg.sender == tom);
      _;
    }
    
    function kill() public usOnly {
      selfdestruct(val);
    }
}