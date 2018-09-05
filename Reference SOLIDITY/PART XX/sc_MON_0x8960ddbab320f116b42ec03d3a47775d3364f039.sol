/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
library SafeMath {
  function mul(uint256 a, uint256 b) constant public returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) constant public returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) constant public returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) constant public returns (uint256) {
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
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    if(msg.sender == owner){
      _;
    }
    else{
      revert();
    }
  }

}
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant public returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return balances[_owner];
  }

}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}


contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    if(!mintingFinished){
      _;
    }
    else{
      revert();
    }
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) canMint internal returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0),_to,_amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


contract MON is MintableToken{
    
    struct Buy{
        uint256 amountOfEth;
        uint256 stage;
    }
    
	string public constant name = "MillionCoin";
	string public constant symbol = "MON";
	uint256 public constant DECIMALS = 8;
	uint256 public constant decimals = 8;
	address public beneficiary ;
    uint256 private alreadyRunned 	= 0;
    uint256 private _now =0;
    uint256 public stageIndex = 0;
    uint256[] public stageSum;
    uint256[] public stageCurrentSum;
    uint256[] public stagePrice;
    uint256[] public stageEnd;
    uint256 public period = 3600*24*7; //7days
    uint256 public start = 0;
    uint256 public sumMultiplayer = 10;//100000;
    mapping(address => Buy) stageBuys;
 
 modifier runOnce(uint256 bit){
     if((alreadyRunned & bit)==0){
        alreadyRunned = alreadyRunned | bit;   
         _;   
     }
     else{
         revert();
     }
 }
 
 
 function MON(address _benef,uint256 _start,uint256 _sumMul,uint256 _period) public{
     beneficiary = _benef;
     start = _start;
     if(_period!=0){
         period = _period;
     }
     if(_sumMul!=0){
         sumMultiplayer = _sumMul;
     }
     stageSum.push(216*sumMultiplayer);
     stageSum.push(260*sumMultiplayer);
     stageSum.push(252*sumMultiplayer);
     stageSum.push(270*sumMultiplayer);
     stageSum.push(204*sumMultiplayer);
     stagePrice.push(3600);
     stagePrice.push(2600);
     stagePrice.push(2100);
     stagePrice.push(1800);
     stagePrice.push(1600);
     stageEnd.push(_start+period*2);
     stageEnd.push(_start+period*6);
     stageEnd.push(_start+period*10);
     stageEnd.push(_start+period*16);
     stageEnd.push(_start+period*24);
     stageCurrentSum.push(0);
     stageCurrentSum.push(0);
     stageCurrentSum.push(0);
     stageCurrentSum.push(0);
     stageCurrentSum.push(0);
     
 }
 
 
 function GetMaxStageEthAmount() public constant returns(uint256){
     
     return (stageSum[stageIndex].mul(10**18)).div(stagePrice[stageIndex]);
 }
 
 
 function () public payable {
     uint256  status = 0;
     status = 0;
     bool transferToBenef = false;
     uint256  amountOfEthBeforeBuy = 0;
     uint256  stageMaxEthAmount = 0;
     if(GetNow()<start){
         revert();
     }
     if(this.balance <msg.value){
        amountOfEthBeforeBuy =0 ;
     }
     else{
        amountOfEthBeforeBuy = this.balance - msg.value;
     }
     stageMaxEthAmount = (stageSum[stageIndex].mul(10**18)).div(stagePrice[stageIndex]);
         uint256 amountToReturn =0;
         uint256 amountToMint =0;
         Buy b = stageBuys[msg.sender];
     if(stageEnd[stageIndex]<GetNow() && amountOfEthBeforeBuy<stageMaxEthAmount){
         status = 1;
         //current stage is unsuccessful money send in transaction should be returned plus 
         // all money spent in current round 
         amountToReturn = msg.value;
         if(b.stage==stageIndex){
             status = status*10+2;
             amountToReturn = amountToReturn.add(b.amountOfEth);
             burn(msg.sender,b.amountOfEth.mul(stagePrice[stageIndex]));
         }
         stageBuys[msg.sender].amountOfEth=0;
         msg.sender.transfer(amountToReturn);
     }
     else{
             status = 2;
         
         if(b.stage!=stageIndex){
             b.stage = stageIndex;
             b.amountOfEth = 0;
             status = status*10+3;
         }
         
         if(stageEnd[stageIndex]>now &&  this.balance < stageMaxEthAmount){
            //nothing special normal buy 
             b.amountOfEth = b.amountOfEth.add(msg.value);
            amountToMint = msg.value.mul(stagePrice[stageIndex]);
             status = status*10+4;
            mintCoins(msg.sender,amountToMint);
         }else{
             if( this.balance >=stageMaxEthAmount){
                 //we exceeded stage limit
                status = status*10+5;
                 transferToBenef = true;
                amountToMint = ((stageMaxEthAmount - amountOfEthBeforeBuy).mul(stagePrice[stageIndex]));
                mintCoins(msg.sender,amountToMint);
                stageIndex = stageIndex+1;
                if(stageIndex<5){
                    status = status*10+7;
                    //buys for rest of eth tokens in new prices
                    amountToMint = ((this.balance.sub(stageMaxEthAmount)).mul(stagePrice[stageIndex]));
                    b.stage = stageIndex;
                    b.amountOfEth =(this.balance.sub(stageMaxEthAmount));
                    mintCoins(msg.sender,amountToMint);
                }
                else{
                    status = status*10+8;
                    //returns rest of money if during buy hardcap is reached
                    amountToReturn = (this.balance.sub(stageMaxEthAmount));
                    msg.sender.transfer(amountToReturn);
                }
             }else{
                status = status*10+6;
           //     revert() ;// not implemented, should not happend
             }
         }
     }
     if(transferToBenef){
        beneficiary.transfer(stageMaxEthAmount);
     }
 }
 
 function GetNow() public constant returns(uint256){
    return now; 
 }
 
 function GetBalance() public constant returns(uint256){
     return this.balance;
 }

  uint256 public constant maxTokenSupply = (10**(18-DECIMALS))*(10**3)*150250 ;  
  
  function burn(address _from, uint256 _amount) private returns (bool){
      _amount = _amount.div(10**10);
      balances[_from] = balances[_from].sub(_amount);
      totalSupply = totalSupply.sub(_amount);
      Transfer(_from,address(0),_amount);
  }
  
  function GetStats()public constant returns (uint256,uint256,uint256,uint256){
      uint256 timeToEnd = 0;
      uint256 round =0;
      if(GetNow()>start){
        round = stageIndex+1;
        timeToEnd = stageEnd[stageIndex]-GetNow();
      }
      else{
        timeToEnd = start-GetNow();
      }
      return(timeToEnd,
       round,
       stageSum[stageIndex].div(stagePrice[stageIndex]).mul(1000),
       GetMaxStageEthAmount().div(10**15));
  }
  
  function mintCoins(address _to, uint256 _amount)  canMint internal returns (bool) {
      
    _amount = _amount.div(10**10);
  	if(totalSupply.add(_amount)<maxTokenSupply){
  	  super.mint(_to,_amount);
  	  super.mint(address(beneficiary),(_amount.mul(20)).div(80));
  	  
  	  return true;
  	}
  	else{
  		return false; 
  	}
  	
  	return true;
  }
  
  
}