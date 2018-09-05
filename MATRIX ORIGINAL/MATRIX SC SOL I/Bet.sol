pragma solidity ^0.4.8;
contract Bet {

    //status enums
    enum BetStatusEnum {STATUS_UNKNOWN,STATUS_WINNER,STATUS_LOSE,STATUS_TIE,STATUS_PENDING, STATUS_ERROR}
    enum GameStatusEnum {STATUS_NOT_STARTED, STATUS_STARTED, STATUS_COMPLETE, STATUS_ERROR }

    //the 'better' structure
    struct JediBet {
        uint guess;
        address addr;
        BetStatusEnum status;
        uint betAmount;
    }

    //the 'game' structure
    struct Game {
        uint pot;
        uint outcome;
        GameStatusEnum status;
        JediBet originator;
        JediBet taker;
    }

    //bet status event
    event BetStatus (
        GameStatusEnum gameStatus, 
        BetStatusEnum originatorStatus, 
        address originatorAddress, 
        uint originatorGuess,
        address takerAddress, 
        BetStatusEnum takerStatus, 
        uint takerGuess, 
        uint betAmount, 
        uint actualNumber, 
        uint pot
    );

    //the game
    Game game;

    //fallback function
    function() public payable {}

    function resetGame() private {
        //reset game
        game.status = GameStatusEnum.STATUS_NOT_STARTED;
        game.outcome = 0;
        game.pot = 0;

        game.originator.guess = 0;
        game.originator.betAmount = 0;
        game.originator.addr = 0;
        game.originator.status = BetStatusEnum.STATUS_UNKNOWN;

        game.taker.guess = 0; 
        game.taker.addr = 0;
        game.taker.status = BetStatusEnum.STATUS_UNKNOWN;
    }

    function createBet(uint8 _guess) public payable {
        require(
            game.status == GameStatusEnum.STATUS_NOT_STARTED && 
            game.originator.status == BetStatusEnum.STATUS_UNKNOWN &&
            game.taker.status == BetStatusEnum.STATUS_UNKNOWN,
            "A Bet is already in process");    
        game = Game(
            0, 0, GameStatusEnum.STATUS_STARTED, 
            JediBet(_guess, msg.sender,  BetStatusEnum.STATUS_PENDING, msg.value), 
            JediBet(0, 0, BetStatusEnum.STATUS_UNKNOWN, 0));
        getBetOutcome();
    }

    function takeBet(uint8 _guess) public payable { 
        require(
            game.status == GameStatusEnum.STATUS_STARTED && 
            game.originator.status == BetStatusEnum.STATUS_PENDING && 
            game.taker.status == BetStatusEnum.STATUS_UNKNOWN && 
            msg.value == game.originator.betAmount,
            "A Bet has not been started yet");
        game.taker = JediBet(_guess, msg.sender, BetStatusEnum.STATUS_PENDING, msg.value);
        game.pot = game.originator.betAmount + game.taker.betAmount;
        generateBetOutcome();
        getBetOutcome();
    }

    function payout() public payable {
        checkPermissions(msg.sender);
        require(
            game.status == GameStatusEnum.STATUS_COMPLETE && 
            game.originator.status > BetStatusEnum.STATUS_UNKNOWN && 
            game.originator.status < BetStatusEnum.STATUS_PENDING &&
            game.taker.status > BetStatusEnum.STATUS_UNKNOWN && 
            game.taker.status < BetStatusEnum.STATUS_PENDING,
            "No one has taken the Bet yet");
      
        uint256 origPot = game.pot;
        BetStatusEnum origStatus = game.originator.status; 
        BetStatusEnum takerStatus = game.taker.status;
        address origAddress = game.originator.addr;
        address takerAddress = game.taker.addr;
      
        resetGame(); // optimistic accounting
        
        if (origStatus == BetStatusEnum.STATUS_TIE && takerStatus == BetStatusEnum.STATUS_TIE) {
            origAddress.transfer(origPot/2);
            takerAddress.transfer(origPot/2);
        } else {
            if (origStatus == BetStatusEnum.STATUS_WINNER) {
                origAddress.transfer(origPot);
            } else if (takerStatus == BetStatusEnum.STATUS_WINNER) {
                takerAddress.transfer(origPot);
            } else {
                origAddress.transfer(origPot/2);
                takerAddress.transfer(origPot/2);
            }
        }
        getBetOutcome();
    }

    function getBetOutcome() public {

        //hide the bets and outcome
        uint actualNumber = 0;
        uint takerGuess = 0;
        uint originatorGuess = 0;

        if (game.status == GameStatusEnum.STATUS_COMPLETE) {
            //allow the bets and outcome to be visible
            actualNumber = game.outcome;
            takerGuess = game.taker.guess;
            originatorGuess = game.originator.guess;
        }

        emit BetStatus (
            game.status, 
            game.originator.status, 
            game.originator.addr, 
            originatorGuess,
            game.taker.addr, 
            game.taker.status, 
            takerGuess, 
            game.originator.betAmount, 
            actualNumber, 
            game.pot);
    }

    function checkPermissions(address sender) private view {
        //only the originator or taker can call this function
        require(
            sender == game.originator.addr || sender == game.taker.addr,
            "Only the Bet originator or taker can call this function");  
    }

    function generateBetOutcome() private {
        //todo - not a great way to generate a random number but ok for now
        game.outcome = uint8(blockhash(block.number-1))%10 + 1;
        game.status = GameStatusEnum.STATUS_COMPLETE;

        if (game.originator.guess == game.taker.guess) {
            game.originator.status = BetStatusEnum.STATUS_TIE;
            game.taker.status = BetStatusEnum.STATUS_TIE;
        } else if (game.originator.guess > game.outcome && game.taker.guess > game.outcome) {
            game.originator.status = BetStatusEnum.STATUS_TIE;
            game.taker.status = BetStatusEnum.STATUS_TIE;
        } else {
            if ((game.outcome - game.originator.guess) < (game.outcome - game.taker.guess)) {
                game.originator.status = BetStatusEnum.STATUS_WINNER;
                game.taker.status = BetStatusEnum.STATUS_LOSE;
            } else if ((game.outcome - game.taker.guess) < (game.outcome - game.originator.guess)) {
                game.originator.status = BetStatusEnum.STATUS_LOSE;
                game.taker.status = BetStatusEnum.STATUS_WINNER;
            } else {
                game.originator.status = BetStatusEnum.STATUS_ERROR;
                game.taker.status = BetStatusEnum.STATUS_ERROR;
                game.status = GameStatusEnum.STATUS_ERROR;
            }
        }
    }
}