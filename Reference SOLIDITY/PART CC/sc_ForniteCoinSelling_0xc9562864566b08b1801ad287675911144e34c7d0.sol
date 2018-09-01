/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

contract ForniteCoinSelling {
    
    Token public coin;
    address public coinOwner;
    address public owner;
    
    uint256 public pricePerCoin;
    
    constructor(address coinAddressToUse, address coinOwnerToUse, address ownerToUse, uint256 pricePerCoinToUse) public {
        coin = Token(coinAddressToUse);
        coinOwner = coinOwnerToUse;
        owner = ownerToUse;
        pricePerCoin = pricePerCoinToUse;
    }
    
    function newCoinOwner(address newCoinOwnerToUse) public {
        if(msg.sender == owner) {
            coinOwner = newCoinOwnerToUse;
        } else {
            revert();
        }
    }
    
    function newOwner(address newOwnerToUse) public {
        if(msg.sender == owner) {
            owner = newOwnerToUse;
        } else {
            revert();
        }
    }
    
    function newPrice(uint256 newPricePerCoinToUse) public {
        if(msg.sender == owner) {
            pricePerCoin = newPricePerCoinToUse;
        } else {
            revert();
        }
    }
    
    function payOut() public {
        if(msg.sender == owner) {
            owner.transfer(address(this).balance);
        } else {
            revert();
        }
    }
    
    function() public payable {
        uint256 numberOfCoin = msg.value/pricePerCoin;
        if(numberOfCoin<=0) revert();
        if(coin.balanceOf(coinOwner) < numberOfCoin) revert();
        if(!coin.transferFrom(coinOwner, msg.sender, numberOfCoin)) revert();
    }
}

contract Token {
    mapping (address => uint256) public balanceOf;
    function transferFrom(
         address _from,
         address _to,
         uint256 _amount
     ) public payable returns(bool success) {
        _from = _from;
        _to = _to;
        _amount = _amount;
        return true;
    }
}