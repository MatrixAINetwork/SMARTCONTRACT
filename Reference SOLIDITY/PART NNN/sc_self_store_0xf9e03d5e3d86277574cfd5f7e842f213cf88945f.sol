/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/* A contract to store only messages approved by owner */
contract self_store {

    address owner;

    uint16 public contentCount = 0;
    
    event content(string datainfo); 
    
    function self_store() public { owner = msg.sender; }
    
    ///TODO: remove in release
    function kill() { if (msg.sender == owner) suicide(owner); }

    function add(string datainfo) {
        if (msg.sender != owner) return;
        contentCount++;
        content(datainfo);
    }

    function flush() {
        owner.send(this.balance);
    }
}