/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.6;

//
//  This is an Ethereum Race ( and coder challenge )
//
//  To support this game please make sure you check out the sponsor in the public sponsor variable of each game
//
//  how to play:
//
//  1) 20 racers can register, race starting fee is 50 ether per entry (only one entry per person allowed!)
//  2) Once 20 racers have registered, anyone can start the race by hitting the start_the_race() function
//  3) Once the race has started, every racer has to hit the drive() function as often as they can
//  4) After approx 30 mins (~126 blocks) the race ends, and the winner can claim his price
//         (price is all entry fees, as well as whatever was in the additional_price_money pool to start with )
//      
//  Please note that we'll try to find a different sponsor for each race (who contributes to the additional_price_money pool)
//  Dont forget to check out the sponsor of this game!
//
//  Please send any comments or questions about this game to 