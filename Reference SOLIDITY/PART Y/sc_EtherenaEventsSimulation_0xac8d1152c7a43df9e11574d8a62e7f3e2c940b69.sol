/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract EtherenaEventsSimulation {
    address owner;
    uint256 fights;
    uint32[4] p1_assets = [354972,348416,163714,144975];         
    uint32 p2_asset = 241339;
    
    event Fight_Results(uint256 indexed fight_number,
                        address indexed player_1,
                        address indexed player_2,
                        uint128 p1_strategy,
                        uint128 p2_strategy,
                        uint32 _a1_interface_ID,
                        uint256 _a1_ID,
                        uint32 _a2_interface_ID,
                        uint256 _a2_ID,
                        uint8 results);
                        
    function EtherenaEventsSimulation() {
        owner = msg.sender;
    }

    function fireFightResultsEvents(uint8[4] _results) public {
        for(uint8 i = 0; i < 4; i++) {
            if(_results[i] < 3) { //tie:0, p1:1, p2:2    send 3+ to ignore
            Fight_Results(fights++,
                          0x3A428Ec0AB92844de91d9116F8660DfccE42CD83,
                          0x826C1FD15e39A9cdda00532Df316DEE4BfC6a469,
                          12345678,
                          87654321,
                          0,
                          p1_assets[i],
                          0,
                          p2_asset,
                          _results[i]);
            }
        }
    }

    function Kill() public {
        require(msg.sender == owner);
        selfdestruct(owner);
    }
}