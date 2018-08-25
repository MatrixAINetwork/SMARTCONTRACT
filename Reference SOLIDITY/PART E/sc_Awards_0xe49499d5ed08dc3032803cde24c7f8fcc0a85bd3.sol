/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;


contract Awards {

	mapping (uint => uint16[17]) public awards;

	function Awards() public {
		awards[0] = [10000];
		//(100*100)
		awards[1] = [5500, 3500, 1000];
		awards[2] = [5000, 3000, 1500, 500];
		awards[3] = [4000, 2400, 1600, 1000, 600, 400];
		awards[4] = [3000, 2000, 1200, 925, 750, 625, 525, 425, 325, 225];
		awards[5] = [2850, 1850, 1250, 950, 825, 675, 500, 350, 250, 200, 180, 120];
		awards[6] = [2600, 1750, 1200, 900, 800, 650, 550, 400, 375, 275, 225, 175, 100];
		awards[7] = [2600, 1700, 1250, 900, 800, 650, 550, 400, 275, 225, 195, 175, 150, 130];
		awards[8] = [2600, 1600, 1200, 850, 750, 650, 550, 500, 275, 240, 195, 175, 150, 135, 130];
		awards[9] = [2600, 1600, 1050, 900, 800, 700, 500, 400, 275, 225, 195, 175, 160, 145, 140, 135];
		awards[10] = [2600, 1650, 1125, 875, 775, 575, 475, 375, 295, 225, 195, 175, 150, 135, 130, 125, 120];
	}

	function getAwards(uint maxPlayers) public view returns (uint16[17]) {
		assert(maxPlayers > 0);

		if (maxPlayers <= 2)
		return awards[0];

		uint index = ((maxPlayers - 1) / 10) + 1;

		return index > 10 ? awards[10] : awards[index];
	}
}