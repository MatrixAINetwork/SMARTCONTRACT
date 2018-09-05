/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Powerball {
    struct Round {
        uint endTime;
        uint drawBlock;
        uint[6] winningNumbers;
        mapping(address => uint[6][]) tickets;
    }

    uint public constant TICKET_PRICE = 2e15;
    uint public constant MAX_NUMBER = 69;
    uint public constant MAX_POWERBALL_NUMBER = 26;
    uint public constant ROUND_LENGTH = 3 days;

    uint public round;
    mapping(uint => Round) public rounds;

    function Powerball () public {
        round = 1;
        rounds[round].endTime = now + ROUND_LENGTH;
    }

    function buy (uint[6][] numbers) payable public {
        require(numbers.length * TICKET_PRICE == msg.value);

        for (uint i=0; i < numbers.length; i++) {
            for (uint j=0; j < 6; j++)
                require(numbers[i][j] > 0);
            for (j=0; j < 5; j++)
                require(numbers[i][j] <= MAX_NUMBER);
            require(numbers[i][5] <= MAX_POWERBALL_NUMBER);
        }

        // check for round expiry
        if (now > rounds[round].endTime) {
            rounds[round].drawBlock = block.number + 5;
            round += 1;
            rounds[round].endTime = now + ROUND_LENGTH;
        }

        for (i=0; i < numbers.length; i++)
            rounds[round].tickets[msg.sender].push(numbers[i]);
    }

    function drawNumbers (uint _round) public {
        uint drawBlock = rounds[_round].drawBlock;
        require(now > rounds[_round].endTime);
        require(block.number >= drawBlock);
        require(rounds[_round].winningNumbers[0] == 0);

        for (uint i=0; i < 5; i++) {
            bytes32 rand = keccak256(block.blockhash(drawBlock), i);
            uint numberDraw = uint(rand) % MAX_NUMBER + 1;
            rounds[_round].winningNumbers[i] = numberDraw;
        }
        rand = keccak256(block.blockhash(drawBlock), uint(5));
        uint powerballDraw = uint(rand) % MAX_POWERBALL_NUMBER + 1;
        rounds[_round].winningNumbers[5] = powerballDraw;
    }

    function claim (uint _round) public {
        require(rounds[_round].tickets[msg.sender].length > 0);
        require(rounds[_round].winningNumbers[0] != 0);

        uint[6][] storage myNumbers = rounds[_round].tickets[msg.sender];
        uint[6] storage winningNumbers = rounds[_round].winningNumbers;

        uint payout = 0;
        for (uint i=0; i < myNumbers.length; i++) {
            uint numberMatches = 0;
            for (uint j=0; j < 5; j++) {
                for (uint k=0; k < 5; k++) {
                    if (myNumbers[i][j] == winningNumbers[k])
                        numberMatches += 1;
                }
            }
            bool powerballMatches = (myNumbers[i][5] == winningNumbers[5]);

            // win conditions
            if (numberMatches == 5 && powerballMatches) {
                payout = this.balance;
                break;
            }
            else if (numberMatches == 5)
                payout += 1000 ether;
            else if (numberMatches == 4 && powerballMatches)
                payout += 50 ether;
            else if (numberMatches == 4)
                payout += 1e17; // .1 ether
            else if (numberMatches == 3 && powerballMatches)
                payout += 1e17; // .1 ether
            else if (numberMatches == 3)
                payout += 7e15; // .007 ether
            else if (numberMatches == 2 && powerballMatches)
                payout += 7e15; // .007 ether
            else if (powerballMatches)
                payout += 4e15; // .004 ether
        }

        msg.sender.transfer(payout);
        delete rounds[_round].tickets[msg.sender];
    }

    function ticketsFor(uint _round, address user) public view 
      returns (uint[6][] tickets) {
        return rounds[_round].tickets[user];
    }

    function winningNumbersFor(uint _round) public view
      returns (uint[6] winningNumbers) {
        return rounds[_round].winningNumbers;
    }
}