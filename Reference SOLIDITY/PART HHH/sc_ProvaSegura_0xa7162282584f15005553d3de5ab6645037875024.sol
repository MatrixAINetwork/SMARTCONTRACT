/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract ProvaSegura {

    struct Prova {
		bool existe;
        uint block_number;
    }

    mapping(address => Prova) public provas;
	address public owner;

    function ProvaSegura() public {
		owner = msg.sender;
    }

    function GuardaProva(address hash_) public {
        require(msg.sender == owner);
		require(!provas[hash_].existe);
		provas[hash_].existe = true;
		provas[hash_].block_number = block.number;
    }

    function ConsultaProva(address hash_) public constant returns (uint ret) {
        ret = provas[hash_].block_number;
    }
}