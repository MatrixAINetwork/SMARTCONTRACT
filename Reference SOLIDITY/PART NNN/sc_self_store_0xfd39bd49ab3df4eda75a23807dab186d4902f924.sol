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
    modifier onlyowner { if (msg.sender == owner) _ }
    
    function self_store() public { owner = msg.sender; }
    
    ///TODO: remove in release
    function kill() onlyowner { suicide(owner); }

    function flush() onlyowner {
        owner.send(this.balance);
    }

    function add(string datainfo) onlyowner {
        contentCount++;
        content(datainfo);
    }
}