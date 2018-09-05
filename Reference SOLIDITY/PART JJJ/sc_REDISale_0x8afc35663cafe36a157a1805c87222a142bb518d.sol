/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
   function  transfer(address _to, uint256 _value) returns (bool success);
  function balanceOf(address _owner) constant returns (uint256 balance);
}


contract REDISale {

    using SafeMath for uint256;

    address             public admin;
    uint                public raisedWei;
    uint                public rate; 
    bool                public haltSale = false; 
    bool                private enableTransfer = true; 


    ERC20               public token;
    
    address wallet ; 
    
    function REDISale(){
        token = ERC20(0x4d5c907a460B0844cc99b95003819c2AA2b2b77A);
        wallet   = 0x03C7d48F9710AE7c706e2e8F95F293Fe39e928C4;
        rate  =  400000; 
        admin = msg.sender;
    }

    function setHaltSale( bool halt ) {
        require( msg.sender == admin );
        haltSale = halt;
    }

    function seEnableTransfer( bool _transfer ) {
        require( msg.sender == admin );
        enableTransfer = _transfer; 
    }    

    function seIcoAddress( address _wallet) {
        require( msg.sender == admin );
        wallet = _wallet ;
    }    

    function drain(uint _amount) {
        require( msg.sender == admin );
        if ( _amount == 0 ){
            admin.transfer(this.balance);
        }else{
            token.transfer(admin,_amount);
        }
    }
    
    function sendTo(address _to, uint _amount){
        require( msg.sender == admin );

        token.transfer(_to, _amount);
  
    }
    
    function() payable {
        buy( msg.sender );
    }

    event Buy( address _buyer, uint _tokens, uint _payedWei );
    function buy( address recipient ) payable returns(uint){

        require( ! haltSale );
        uint weiPayment =  msg.value ;
        require( weiPayment > 0 );
        raisedWei = raisedWei.add( weiPayment );
        
   
        if ( raisedWei > 185000 * 10 ** 18 ){
            rate = 40000; 
        }else if ( raisedWei > 145000 * 10 ** 18){
            rate = 50000; 
        }else if ( raisedWei >  75000 * 10 ** 18 ){
            rate = 80000; 
        }
        
    
        uint recievedTokens = weiPayment.mul( rate );
        assert( token.transfer( recipient, recievedTokens ) );
        Buy( recipient, recievedTokens, weiPayment );
        if(enableTransfer){
            wallet.transfer(msg.value);
        }
        return weiPayment;
    }
}