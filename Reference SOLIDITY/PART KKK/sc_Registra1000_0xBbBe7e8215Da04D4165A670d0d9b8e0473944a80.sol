/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract Registra1000 {

   struct Arquivo {
       bytes shacode;
   }

   bytes[] arquivos;
   
   function Registra() public {
       arquivos.length = 1;
   }

   function setArquivo(bytes shacode) public {
       arquivos.push(shacode);
   }
   
 
}