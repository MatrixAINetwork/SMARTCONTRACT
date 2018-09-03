/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.17;

contract GetEbola {
    
    address private creator = msg.sender;
    
    function getInfo() constant returns (string, string)
    {
        string memory developer = "Saluton, mia nomo estas Zach!"; // Tio estas mia nomo :)
        string memory genomeInfo = "Ebola virus - Zaire, cat.1976"; // Ebola virus name and date genome was cataloged
        return (developer, genomeInfo);
    }
    
    function getEbola() constant returns (string)
    {
        // Returns bit.ly URL to swarm file bzz:/0191e5bf83b4b172ac36921a4ba1ceab49ba6178fcc35404047c04e6e5e95771
        string memory genomeURL = "URL: http://bit.ly/0x4554482b45626f6c61";
        return (genomeURL);
    }
    
    function tipCreator() constant returns (string, address)
    {
        string memory tipMsg = "If you like you can tip me at this address :)";
        address tipJar = creator; // Address of creator tip jar
        return (tipMsg, tipJar);
    }
    
    /**********
     Standard kill() function to terminate contract 
     **********/
    
    function kill() public returns (string)
    { 
        if (msg.sender == creator)
        {
            suicide(creator);  // kills the contract and sends balance to creator
        }
        else {
            string memory nope = "Vi ne havas povon ĉi tie!";
            return (nope);
        }
    }
}