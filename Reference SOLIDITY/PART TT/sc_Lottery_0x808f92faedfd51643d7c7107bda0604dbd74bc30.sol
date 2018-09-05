/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;
 
 
 
 contract Lottery {
     
     address owner;
     string public constant name = "BETA ETHEREUM LOTTERY";
     uint public tickets;
     uint public round;
     string public status;
     string public constant about = "Send exactly 0.05 ether directly to this contract address to buy a lottery ticket. Once 22 tickets are sold this contract will pick a random winner and pay the lucky winner 1 whole ether, and the lottery automatically restarts the next round with a new set of 22 tickets. 0.1 Ether (10%) is kept by the house which also covers gas costs.";
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
     address ticket13;
     address ticket14;
     address ticket15;
     address ticket16;
     address ticket17;
     address ticket18;
     address ticket19;
     address ticket20;
     address ticket21;
     address ticket22;
     uint winner;
     uint random_number = uint(block.blockhash(block.number-1))%22 + 1;
     uint constant price = 0.05 ether; 
     uint constant amount = 1; 
     
     
     
     function Lottery() {
         
         owner = msg.sender;
         tickets = 22;
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
         ticket13 = 0;
         ticket14 = 0;
         ticket15 = 0;
         ticket16 = 0;
         ticket17 = 0;
         ticket18 = 0;
         ticket19 = 0;
         ticket20 = 0;
         ticket21 = 0;
         ticket22 = 0;
     }
     
     event purchasedTicket(address a); 
     event winningTicket(address a); 
     event winningTicketNumber(uint a); 
     
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
         else if(ticket13 == 0) {
             ticket13 = msg.sender;
         }
         else if(ticket14 == 0) {
             ticket14 = msg.sender;
         }
         else if(ticket15 == 0) {
             ticket15 = msg.sender;
         }
         else if(ticket16 == 0) {
             ticket16 = msg.sender;
         }
         else if(ticket17 == 0) {
             ticket17 = msg.sender;
         }
         else if(ticket18 == 0) {
             ticket18 = msg.sender;
         }
         else if(ticket19 == 0) {
             ticket19 = msg.sender;
         }
         else if(ticket20 == 0) {
             ticket20 = msg.sender;
         }
         else if(ticket21 == 0) {
             ticket21 = msg.sender;
         }
         else if(ticket22 == 0) {
             ticket22 = msg.sender;
         }
         
         tickets -= amount;
         
         purchasedTicket(msg.sender); 
         
         if (tickets == 0) {
             

             tickets = 22; 
             round += 1; 
             
            
            random_number = uint(block.blockhash(block.number-1))%22 + 1;
            lastWiningTicketNumber = random_number; 
            winningTicketNumber(random_number); 
            
            
            if (random_number == 1) {
                ticket1.transfer(price * 20); 
                winningTicket(ticket1); 
                lastWinner = ticket1; 
             }
             else if(random_number == 2) {
                 ticket2.transfer(price * 20); 
                 winningTicket(ticket2); 
                 lastWinner = ticket2; 
             }
             else if(random_number == 3) {
                 ticket3.transfer(price * 20); 
                 winningTicket(ticket3); 
                 lastWinner = ticket3; 
             }
             else if(random_number == 4) {
                 ticket4.transfer(price * 20); 
                 winningTicket(ticket4); 
                 lastWinner = ticket4; 
             }
             else if(random_number == 5) {
                 ticket5.transfer(price * 20); 
                 winningTicket(ticket5); 
                 lastWinner = ticket5; 
             }
             else if(random_number == 6) {
                 ticket6.transfer(price * 20); 
                 winningTicket(ticket6); 
                 lastWinner = ticket6; 
             }
             else if(random_number == 7) {
                 ticket7.transfer(price * 20);
                 winningTicket(ticket7); 
                 lastWinner = ticket7; 
             }
             else if(random_number == 8) {
                 ticket8.transfer(price * 20); 
                 winningTicket(ticket8); 
                 lastWinner = ticket8; 
             }
             else if(random_number == 9) {
                 ticket9.transfer(price * 20); 
                 winningTicket(ticket9); 
                 lastWinner = ticket9; 
             }
             else if(random_number == 10) {
                 ticket10.transfer(price * 20); 
                 winningTicket(ticket10); 
                 lastWinner = ticket10; 
             }
             else if(random_number == 11) {
                 ticket11.transfer(price * 20); 
                 winningTicket(ticket11); 
                 lastWinner = ticket11; 
             }
             else if(random_number == 12) {
                 ticket12.transfer(price * 20); 
                 winningTicket(ticket12); 
                 lastWinner = ticket12; 
             }
             else if(random_number == 13) {
                 ticket13.transfer(price * 20); 
                 winningTicket(ticket13); 
                 lastWinner = ticket13; 
             }
             else if(random_number == 14) {
                 ticket14.transfer(price * 20); 
                 winningTicket(ticket14); 
                 lastWinner = ticket14; 
             }
             else if(random_number == 15) {
                 ticket15.transfer(price * 20); 
                 winningTicket(ticket15); 
                 lastWinner = ticket15; 
             }
             else if(random_number == 16) {
                 ticket16.transfer(price * 20); 
                 winningTicket(ticket16); 
                 lastWinner = ticket16; 
             }
             else if(random_number == 17) {
                 ticket17.transfer(price * 20);
                 winningTicket(ticket17); 
                 lastWinner = ticket17; 
             }
             else if(random_number == 18) {
                 ticket18.transfer(price * 20); 
                 winningTicket(ticket18); 
                 lastWinner = ticket18; 
             }
             else if(random_number == 19) {
                 ticket19.transfer(price * 20); 
                 winningTicket(ticket19); 
                 lastWinner = ticket19; 
             }
             else if(random_number == 20) {
                 ticket20.transfer(price * 20); 
                 winningTicket(ticket20); 
                 lastWinner = ticket20; 
             }
             else if(random_number == 21) {
                 ticket21.transfer(price * 20); 
                 winningTicket(ticket21); 
                 lastWinner = ticket21; 
             }
             else if(random_number == 22) {
                 ticket22.transfer(price * 20); 
                 winningTicket(ticket22); 
                 lastWinner = ticket22; 
             }
            
            
            owner.transfer(this.balance); 
            
            
            
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
             ticket13 = 0;
             ticket14 = 0;
             ticket15 = 0;
             ticket16 = 0;
             ticket17 = 0;
             ticket18 = 0;
             ticket19 = 0;
             ticket20 = 0;
             ticket21 = 0;
             ticket22 = 0;
            
            
            if (keccak256(status) != keccak256("Running")) {
                
                selfdestruct(owner);
            }
             
         }
     }
     
     
 }