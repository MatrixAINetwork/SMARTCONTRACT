/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;
 
 
 
 contract ProgressiveJackpotLottery {
     
     address owner;
     string public constant name = "PROGRESSIVE JACKPOT ETHEREUM LOTTERY";
     uint public tickets;
     uint public round;
     uint contractProfitBalance;
     uint public jackpot;
     uint public lastJackpotPayout;
     uint public lastJackpotRound;
     uint eachJackpotPayout;
     string public status;
     string public constant about = "Send exactly 0.1 ether directly to this contract address to buy a lottery ticket. Once 12 tickets are sold this contract will pick a random winner and pay the lucky winner 1 Ether, rounds have a 1/1500 chance of the Jackpot being hit, and pays 70% of jackpot value is shared with all tickets in that round.";
     uint public lastWiningTicketNumber;
     address public lastWinner;
     address ticket1;
     address ticket2;
     address ticket3;
     address ticket4;
     address ticket5;
     address ticket6;
     address ticket7;
     address ticket8;
     address ticket9;
     address ticket10;
     address ticket11;
     address ticket12;
     uint winner;
     uint random_number;
     uint random_jackpot_number;
     uint constant price = 0.1 ether; 
     uint constant amount = 1; 
     
     
     
     function ProgressiveJackpotLottery() {
         
         owner = msg.sender;
         tickets = 12;
         round = 1;
         lastWinner = 0;
         lastWiningTicketNumber = 0;
         status = "Running";
         ticket1 = 0;
         ticket2 = 0;
         ticket3 = 0;
         ticket4 = 0;
         ticket5 = 0;
         ticket6 = 0;
         ticket7 = 0;
         ticket8 = 0;
         ticket9 = 0;
         ticket10 = 0;
         ticket11 = 0;
         ticket12 = 0;
         lastJackpotPayout = 0;
         jackpot = 0;
     }
     
     event purchasedTicket(address a); 
     event winningTicket(address a); 
     event winningTicketNumber(uint a); 
     event jackpotRoundNumber(uint a); 
     
     modifier onlyOwner {
         
         require(msg.sender == owner);
         _;
     }
     
     function changeStatus(string w) onlyOwner {
         status = w;
     }
     
     function () payable {
         
         buyTickets();
     }
     
     function buyTickets() payable {
         
         if (msg.value != (price)) {
             
             throw;
         }

         
         if (ticket1 == 0) {
             ticket1 = msg.sender;
         }
         else if(ticket2 == 0) {
             ticket2 = msg.sender;
         }
         else if(ticket3 == 0) {
             ticket3 = msg.sender;
         }
         else if(ticket4 == 0) {
             ticket4 = msg.sender;
         }
         else if(ticket5 == 0) {
             ticket5 = msg.sender;
         }
         else if(ticket6 == 0) {
             ticket6 = msg.sender;
         }
         else if(ticket7 == 0) {
             ticket7 = msg.sender;
         }
         else if(ticket8 == 0) {
             ticket8 = msg.sender;
         }
         else if(ticket9 == 0) {
             ticket9 = msg.sender;
         }
         else if(ticket10 == 0) {
             ticket10 = msg.sender;
         }
         else if(ticket11 == 0) {
             ticket11 = msg.sender;
         }
         else if(ticket12 == 0) {
             ticket12 = msg.sender;
         }
         
         tickets -= amount;
         
         
         
         purchasedTicket(msg.sender); 
         
         if (tickets == 0) {
             

             tickets = 12; 
             round += 1; 
             
            
            random_number = uint(block.blockhash(block.number-1))%12 + 1;
            random_jackpot_number = uint(block.blockhash(block.number-2))%1500 + 1;
            lastWiningTicketNumber = random_number; 
            winningTicketNumber(random_number); 
            if (random_jackpot_number == 1) {
                
                lastJackpotRound = (round);
                jackpotRoundNumber(round);
                lastJackpotPayout = (jackpot * 70/100); 
                jackpot -= (jackpot * 75/100); 
                eachJackpotPayout = (lastJackpotPayout * 1/12);
                
                
                
                ticket1.transfer(eachJackpotPayout); 
                ticket2.transfer(eachJackpotPayout); 
                ticket3.transfer(eachJackpotPayout); 
                ticket4.transfer(eachJackpotPayout); 
                ticket5.transfer(eachJackpotPayout); 
                ticket6.transfer(eachJackpotPayout); 
                ticket7.transfer(eachJackpotPayout); 
                ticket8.transfer(eachJackpotPayout); 
                ticket9.transfer(eachJackpotPayout); 
                ticket10.transfer(eachJackpotPayout); 
                ticket11.transfer(eachJackpotPayout); 
                ticket12.transfer(eachJackpotPayout); 
            }
            else {
                
                jackpot += price;
            }
            
            
            if (random_number == 1) {
                ticket1.transfer(price * 10); 
                winningTicket(ticket1); 
                lastWinner = ticket1; 
             }
             else if(random_number == 2) {
                 ticket2.transfer(price * 10); 
                 winningTicket(ticket2); 
                 lastWinner = ticket2; 
             }
             else if(random_number == 3) {
                 ticket3.transfer(price * 10); 
                 winningTicket(ticket3); 
                 lastWinner = ticket3; 
             }
             else if(random_number == 4) {
                 ticket4.transfer(price * 10); 
                 winningTicket(ticket4); 
                 lastWinner = ticket4; 
             }
             else if(random_number == 5) {
                 ticket5.transfer(price * 10); 
                 winningTicket(ticket5); 
                 lastWinner = ticket5; 
             }
             else if(random_number == 6) {
                 ticket6.transfer(price * 10); 
                 winningTicket(ticket6); 
                 lastWinner = ticket6; 
             }
             else if(random_number == 7) {
                 ticket7.transfer(price * 10);
                 winningTicket(ticket7); 
                 lastWinner = ticket7; 
             }
             else if(random_number == 8) {
                 ticket8.transfer(price * 10); 
                 winningTicket(ticket8); 
                 lastWinner = ticket8; 
             }
             else if(random_number == 9) {
                 ticket9.transfer(price * 10); 
                 winningTicket(ticket9); 
                 lastWinner = ticket9; 
             }
             else if(random_number == 10) {
                 ticket10.transfer(price * 10); 
                 winningTicket(ticket10); 
                 lastWinner = ticket10; 
             }
             else if(random_number == 11) {
                 ticket11.transfer(price * 10); 
                 winningTicket(ticket11); 
                 lastWinner = ticket11; 
             }
             else if(random_number == 12) {
                 ticket12.transfer(price * 10); 
                 winningTicket(ticket12); 
                 lastWinner = ticket12; 
             }
            
            
            contractProfitBalance = (this.balance - jackpot);
            owner.transfer((contractProfitBalance) * 8/10); 
            if ((contractProfitBalance) > 1 ether) {
                owner.transfer((contractProfitBalance)* 5/10); 
            }
            
            
            
             ticket1 = 0;
             ticket2 = 0;
             ticket3 = 0;
             ticket4 = 0;
             ticket5 = 0;
             ticket6 = 0;
             ticket7 = 0;
             ticket8 = 0;
             ticket9 = 0;
             ticket10 = 0;
             ticket11 = 0;
             ticket12 = 0;
            
            
            if (keccak256(status) != keccak256("Running")) {
                
                selfdestruct(owner);
            }
             
         }
     }
     
     
 }