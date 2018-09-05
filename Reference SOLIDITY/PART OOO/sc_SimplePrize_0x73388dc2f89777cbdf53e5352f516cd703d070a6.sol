/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract SimplePrize {
    bytes32 public constant salt = bytes32(987463829);
    bytes32 public commitment;

    function SimplePrize(bytes32 _commitment) public payable {
        commitment = _commitment;   
    }

    function createCommitment(uint answer) 
      public pure returns (bytes32) {
        return keccak256(salt, answer);
    }

    function guess (uint answer) public {
        require(createCommitment(answer) == commitment);
        msg.sender.transfer(this.balance);
    }

    function () public payable {}
}