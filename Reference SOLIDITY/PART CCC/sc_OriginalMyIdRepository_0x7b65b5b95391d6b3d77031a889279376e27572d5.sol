/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.10;

contract accessControlled {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if ( msg.sender != owner ) throw;
        /* o caracter "_" é substituído pelo corpo da funcao onde o modifier é utilizado */
        _;
    }

    function transferOwnership( address newOwner ) onlyOwner {
        owner = newOwner;
    }

}

contract OriginalMyIdRepository is accessControlled{
    using strings for *;

    uint256 public totalUsers;
    uint256 public totalWallets;
    idRepository[] public userIds;

    mapping ( uint256 => uint256 ) public userIdIndex;
	mapping ( string => uint256 )  userByWallet;
    //mapping ( uint256 => string[] ) public walletsFromUser;


    struct idRepository {
        uint256 userId;
        string[] userWallets;
    }

	event User( uint256 id );
	event CheckUserByWallet( uint256 id );
    event ShowLastWallet( string wallet );
    event LogS( string text );
    event LogN( uint number );

	function OriginalMyIdRepository() {
		owner = msg.sender;
		newUser( 0, 'Invalid index 0' );
		totalUsers -= 1;
		totalWallets -= 1;
	}

    /* Criar usuário ou adicionar wallet a usuario existente */
    function newUser( uint256 id, string wallet ) onlyOwner returns ( bool ) {
        if ( userByWallet[wallet] > 0 ) throw;

        uint userIndex;
        if ( userIdIndex[id] > 0 ) {
            userIndex = userIdIndex[id];
        } else {
            userIndex = userIds.length++;
        }
        
        idRepository i = userIds[userIndex];
        
        if ( userIdIndex[id] == 0 ){
            i.userId = id;
            userIdIndex[id] = userIndex;
            totalUsers++;
        }

        string[] walletList = i.userWallets; 
        uint w = walletList.length++;
        if ( userByWallet[wallet] > 0 ) throw;
        i.userWallets[w] = wallet;
        userByWallet[wallet] = id;
        //walletsFromUser[id] = i.userWallets;
        totalWallets++;

        User(id);

        return true;
    }
    
    function checkUserByWallet( string wallet ) returns ( uint256 ) {
        uint256 userId = userByWallet[wallet];
        CheckUserByWallet( userId );
        return userId;
    }

    function getLastWallet( uint256 id ) returns ( string ) {
        uint userIndex = userIdIndex[id];
        idRepository i = userIds[userIndex];
        return i.userWallets[i.userWallets.length-1];
    }

    function getWalletsFromUser( uint256 id ) returns (string wallets){
        string memory separator;
        separator = ',';
        uint userIndex = userIdIndex[id];
        idRepository i = userIds[userIndex];
        for (uint j=0; j < i.userWallets.length; j++){
            ShowLastWallet( i.userWallets[j] );
            if (j > 0 ) wallets = wallets.toSlice().concat(separator.toSlice());
            wallets = wallets.toSlice().concat(i.userWallets[j].toSlice());
        }
        return;
    }

    function isWalletFromUser( uint256 id, string wallet ) returns ( bool ){
        if ( userByWallet[wallet] == id ) return true;
        return false;
    }


    /* Se tentarem enviar ether para o end desse contrato, ele rejeita */
    function () {
        throw;
    }
}

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <