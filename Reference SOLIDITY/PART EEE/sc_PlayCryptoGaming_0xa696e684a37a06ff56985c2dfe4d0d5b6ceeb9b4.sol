/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

/*
Game Name: PlayCryptoGaming
Game Link: https://playcryptogaming.com/
*/

contract PlayCryptoGaming {

    address contractOwnerAddress = 0x46d9112533ef677059c430E515775e358888e38b;
    uint256 priceContract = 26000000000000000000;


    modifier onlyOwner() {
        require (msg.sender == contractOwnerAddress);
        _;
    }
    
    struct CryptoGamer {
        string name;
        address ownerAddress;
        uint256 curPrice;
        address CryptoGamerAddress;
    }
    CryptoGamer[] cryptoGamers;

    bool cryptoGamersAreInitiated;
    bool isPaused;
    
    /*
    We use the following functions to pause and unpause the game.
    */
    function pauseGame() public onlyOwner {
        isPaused = true;
    }
    function unPauseGame() public onlyOwner {
        isPaused = false;
    }
    function GetIsPaused() public view returns(bool) {
       return(isPaused);
    }

    /*
    This function allows players to purchase cryptogamers from other players. 
    The price is automatically multiplied by 1.5 after each purchase.
    */
    function purchaseCryptoGamer(uint _cryptoGamerId) public payable {
        require(msg.value == cryptoGamers[_cryptoGamerId].curPrice);
        require(isPaused == false);

        // Calculate the 5% value
        uint256 commission1percent = (msg.value / 100);
        
        // Transfer the 5% commission to the owner of the least expensive and most expensive cryptogame
        address leastExpensiveCryptoGamerOwner = cryptoGamers[getLeastExpensiveCryptoGamer()].ownerAddress;
        address mostExpensiveCryptoGamerOwner = cryptoGamers[getMostExpensiveCryptoGamer()].ownerAddress;
        
        // We check if the contract is still the owner of the most/least expensive cryptogamers 
        if(leastExpensiveCryptoGamerOwner == address(this)) { 
            leastExpensiveCryptoGamerOwner = contractOwnerAddress; 
        }
        if(mostExpensiveCryptoGamerOwner == address(this)) { 
            mostExpensiveCryptoGamerOwner = contractOwnerAddress; 
        }
        
        leastExpensiveCryptoGamerOwner.transfer(commission1percent * 5); // => 5%  
        mostExpensiveCryptoGamerOwner.transfer(commission1percent * 5); // => 5%  

        // Calculate the owner commission on this sale & transfer the commission to the owner.      
        uint256 commissionOwner = msg.value - (commission1percent * 15); // => 85%
        
        // This cryptoGamer is still owned by the contract, we transfer the commission to the ownerAddress
        if(cryptoGamers[_cryptoGamerId].ownerAddress == address(this)) {
            contractOwnerAddress.transfer(commissionOwner);

        } else {
            // This cryptogamer is owned by a user, we transfer the commission to this player
            cryptoGamers[_cryptoGamerId].ownerAddress.transfer(commissionOwner);
        }
        

        // Transfer the 3% commission to the developer
        contractOwnerAddress.transfer(commission1percent * 3); // => 3%
        
        // Transfer the 2% commission to the actual cryptogamer
        if(cryptoGamers[_cryptoGamerId].CryptoGamerAddress != 0x0) {
            cryptoGamers[_cryptoGamerId].CryptoGamerAddress.transfer(commission1percent * 2); // => 2%
        } else {
            // We don't konw the address of the crypto gamer yet, we transfer the commission to the owner
            contractOwnerAddress.transfer(commission1percent * 2); // => 2%
        }
        

        // Update the company owner and set the new price
        cryptoGamers[_cryptoGamerId].ownerAddress = msg.sender;
        cryptoGamers[_cryptoGamerId].curPrice = cryptoGamers[_cryptoGamerId].curPrice + (cryptoGamers[_cryptoGamerId].curPrice / 2);
    }

    /*
    This is the function that will allow players to purchase the contract. 
    The initial price is set to 26ETH (26000000000000000000 WEI).
    The owner of the contract can create new players and will receive a 5% commission on every sales
    */
    function purchaseContract() public payable {
        require(msg.value == priceContract);
        
        // Calculate the 5% value
        uint256 commission5percent = ((msg.value / 10)/2);
        
        // Transfer the 5% commission to the owner of the least expensive and most expensive cryptogame
        address leastExpensiveCryptoGamerOwner = cryptoGamers[getLeastExpensiveCryptoGamer()].ownerAddress;
        address mostExpensiveCryptoGamerOwner = cryptoGamers[getMostExpensiveCryptoGamer()].ownerAddress;
        
        // We check if the contract is still the owner of the most/least expensive cryptogamers 
        if(leastExpensiveCryptoGamerOwner == address(this)) { 
            leastExpensiveCryptoGamerOwner = contractOwnerAddress; 
        }
        if(mostExpensiveCryptoGamerOwner == address(this)) { 
            mostExpensiveCryptoGamerOwner = contractOwnerAddress; 
        }
        
        // Transfer the commission
        leastExpensiveCryptoGamerOwner.transfer(commission5percent); // => 5%  
        mostExpensiveCryptoGamerOwner.transfer(commission5percent); // => 5%  

        // Calculate the owner commission on this sale & transfer the commission to the owner.      
        uint256 commissionOwner = msg.value - (commission5percent * 2); // => 85%
        
        contractOwnerAddress.transfer(commissionOwner);
        contractOwnerAddress = msg.sender;
    }

    function getPriceContract() public view returns(uint) {
        return(priceContract);
    }

    /*
    The owner of the contract can use this function to modify the price of the contract.
    The price is set in WEI
    */
    function updatePriceContract(uint256 _newPrice) public onlyOwner {
        priceContract = _newPrice;
    }

    // Simply returns the current owner address
    function getContractOwnerAddress() public view returns(address) {
        return(contractOwnerAddress);
    }

    /*
    The owner of a company can reduce the price of the company using this function.
    The price can be reduced but cannot be bigger.
    The price is set in WEI.
    */
    function updateCryptoGamerPrice(uint _cryptoGamerId, uint256 _newPrice) public {
        require(_newPrice > 0);
        require(cryptoGamers[_cryptoGamerId].ownerAddress == msg.sender);
        require(_newPrice < cryptoGamers[_cryptoGamerId].curPrice);
        cryptoGamers[_cryptoGamerId].curPrice = _newPrice;
    }
    
    // This function will return the details of a cryptogamer
    function getCryptoGamer(uint _cryptoGamerId) public view returns (
        string name,
        address ownerAddress,
        uint256 curPrice,
        address CryptoGamerAddress
    ) {
        CryptoGamer storage _cryptoGamer = cryptoGamers[_cryptoGamerId];

        name = _cryptoGamer.name;
        ownerAddress = _cryptoGamer.ownerAddress;
        curPrice = _cryptoGamer.curPrice;
        CryptoGamerAddress = _cryptoGamer.CryptoGamerAddress;
    }
    
    /*
    Get least expensive crypto gamers (to transfer the owner 5% of the transaction)
    If multiple cryptogamers have the same price, the selected one will be the cryptogamer with the smalled id 
    */
    function getLeastExpensiveCryptoGamer() public view returns(uint) {
        uint _leastExpensiveGamerId = 0;
        uint256 _leastExpensiveGamerPrice = 9999000000000000000000;

        // Loop through all the shares of this company
        for (uint8 i = 0; i < cryptoGamers.length; i++) {
            if(cryptoGamers[i].curPrice < _leastExpensiveGamerPrice) {
                _leastExpensiveGamerPrice = cryptoGamers[i].curPrice;
                _leastExpensiveGamerId = i;
            }
        }
        return(_leastExpensiveGamerId);
    }

    /* 
    Get most expensive crypto gamers (to transfer the owner 5% of the transaction)
     If multiple cryptogamers have the same price, the selected one will be the cryptogamer with the smalled id 
     */
    function getMostExpensiveCryptoGamer() public view returns(uint) {
        uint _mostExpensiveGamerId = 0;
        uint256 _mostExpensiveGamerPrice = 9999000000000000000000;

        // Loop through all the shares of this company
        for (uint8 i = 0; i < cryptoGamers.length; i++) {
            if(cryptoGamers[i].curPrice > _mostExpensiveGamerPrice) {
                _mostExpensiveGamerPrice = cryptoGamers[i].curPrice;
                _mostExpensiveGamerId = i;
            }
        }
        return(_mostExpensiveGamerId);
    }
    
    /**
    @dev Multiplies two numbers, throws on overflow. => From the SafeMath library
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
    @dev Integer division of two numbers, truncating the quotient. => From the SafeMath library
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    /*
    The dev can update the verified address of the crypto gamer. Email me at 