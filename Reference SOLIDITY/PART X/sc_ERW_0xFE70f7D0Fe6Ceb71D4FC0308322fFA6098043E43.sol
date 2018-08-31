/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract ERW {
    string public EdgarRichardWunsche;
    string public Parents;
    string public DateOfBirth;
    string public DateOfDeath;
    string public Location;
    
    function ERW() {
        EdgarRichardWunsche = "Edgar Richard Wunsche (12.11.1930-22.04.2016). Rest in Peace Dad. Love Alan.";
        DateOfBirth = "12.11.1930";
        DateOfDeath = "22.04.2016";
        Parents = "Beloved son of Anna Wunsche (Moser) and Antonin Wunsche.";
        Location = "Toronto, Ontario, Canada";
    }

    function () {
        throw;     // Prevents accidental sending of ether
    }
}