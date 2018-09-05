/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract primoContratto {
    address private proprietario;
    mapping (uint256 => string) private frasi;
    uint256 private frasiTotali = 0;
    
    function primoContratto() public {
        proprietario = msg.sender;
    }
    
    function aggiungiFrase(string _frase) public returns (uint256) {
        frasi[frasiTotali] = _frase;
        frasiTotali++;
        return frasiTotali-1;
    }
    
    function totaleFrasi() public view returns (uint256) {
        return frasiTotali;
    }
    
    function leggiFrase(uint256 _numeroFrase) public view returns (string) {
        return frasi[_numeroFrase];
    }
    
    function kill() public {
        if (proprietario != msg.sender) return;
        selfdestruct(proprietario);
    }
}