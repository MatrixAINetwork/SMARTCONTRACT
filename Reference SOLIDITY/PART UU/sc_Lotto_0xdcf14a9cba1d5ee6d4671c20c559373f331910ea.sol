/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract Lotto {

    //	Play lottery.
    //	Rules:
    //	-Address plays between minPlay & mayPlay in order to increase stack amount.
    //	-Address can play many times.
    //	-A fee is directly withrawn from incoming amounts (see feesPerMillion).
    //	-As soon as the jackpot goes beyond the target, an address is chosen randomly proportionally to its stack amount.
    //	-The winner address get paid with the jackpot.
    //	-gameNumber is increased and minPlay,maxPlay,target get the values from nextMinPlay,nextMaxPlay,nextTarget.
    //	-nextMinPlay,nextMaxPlay,nextTarget can only be changed by the owner for the next game.


    address public owner;
    uint256 public gameNumber;
    uint256 public feesPerMillion;
    uint256 public nextFeesPerMillion;
    uint256 public jackpot;
    uint256 public target;
    uint256 public nextTarget;
    uint256 public minPlay;
    uint256 public nextMinPlay;
    uint256 public maxPlay;
    uint256 public nextMaxPlay;
    mapping(address => uint256) public playersAmounts;
    address[] public playersList;
    uint256 private vMillion;


    event newGame(uint256 ts, uint256 game);
    event newPlay(uint256 ts, uint256 game, address player, uint256 grossAmount, uint256 amount, uint256 stack, uint256 jackpot, uint256 target);
    event newWinner(uint256 ts, uint256 game, address player, uint256 amount);
    event forceGame(uint256 ts,  uint256 game);
    event payment(uint256 ts, address addr, uint256 amount, bool status);



    function Lotto(){
        owner=msg.sender;
        gameNumber=1;
        vMillion=1000000;
        feesPerMillion=5000;
        nextFeesPerMillion=feesPerMillion;
        minPlay=1 ether;
        nextMinPlay=minPlay;
        maxPlay=3 ether;
        nextMaxPlay=maxPlay;
        target=10 ether;
        nextTarget=target;
        jackpot=0;
        newGame(block.timestamp, gameNumber);
    }



    function() payable public{}



    function play() payable public {
        if(msg.sender==owner) throw;
        if(msg.value<minPlay || msg.value>maxPlay) throw;

        if(playersAmounts[msg.sender]==0){
            playersList.push(msg.sender);
        }
        uint256 amount;
        amount=(vMillion-feesPerMillion)*msg.value/vMillion;
        playersAmounts[msg.sender]=playersAmounts[msg.sender]+amount;
        jackpot=jackpot+amount;
        newPlay(block.timestamp, gameNumber, msg.sender, msg.value, amount, playersAmounts[msg.sender], jackpot, target);
        if(jackpot>=target){
            _pickWinner();
        }
    }



    function _pickWinner() private{
        uint256 random;
        random=(uint256(sha256(block.blockhash(block.number-1), block.coinbase, block.difficulty, block.gaslimit, block.number, block.timestamp, msg.data, msg.gas, msg.sender, msg.sig, msg.value))%jackpot)+1;
        uint256 playerNumber;
        bool keepGoing;
        playerNumber=0;
        keepGoing=true;
        while(keepGoing && playerNumber<playersList.length){
            if(random<=playersAmounts[playersList[playerNumber]]){
                keepGoing=false;
            }else{
                random=random-playersAmounts[playersList[playerNumber]];
                playerNumber=playerNumber+1;
            }
        }
        if(!keepGoing){
            newWinner(block.timestamp, gameNumber, playersList[playerNumber], jackpot);
            if(playersList[playerNumber].send(jackpot)){
                payment(block.timestamp, playersList[playerNumber], jackpot, true);
            }else{
                payment(block.timestamp, playersList[playerNumber], jackpot, false);
            }
        }
        target=nextTarget;
        minPlay=nextMinPlay;
        maxPlay=nextMaxPlay;
        feesPerMillion=nextFeesPerMillion;
        jackpot=0;
        gameNumber=gameNumber+1;
        for(uint256 i; i<playersList.length; i++){
            playersAmounts[playersList[i]]=0;
        }
        delete playersList;
    }



    function _admin(uint256 cmd, uint256 value) public{
       if(msg.sender!=owner) throw;
       if(cmd==1){
           nextTarget=value;
       }else if(cmd==2){
           nextMinPlay=value;
       }else if(cmd==3){
           nextMaxPlay=value;
       }else if(cmd==4){
           nextFeesPerMillion=value;
       }else if(cmd==5){
           forceGame(block.timestamp, gameNumber);
           _pickWinner();
       }
    }



    function _withdraw(address destination, uint256 value) public{
       if(msg.sender!=owner) throw;
       if(value>=(this.balance-jackpot)) throw;
       if(destination.send(value)){
           payment(block.timestamp, destination, value, true);
       }else{
           payment(block.timestamp, destination, value, false);
       }
    }

}