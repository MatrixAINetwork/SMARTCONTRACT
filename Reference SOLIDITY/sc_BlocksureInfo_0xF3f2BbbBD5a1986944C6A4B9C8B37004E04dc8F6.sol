/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract BlocksureInfo {

    address public owner;
    string public name;
    
    mapping (string => string) strings;

    function BlocksureInfo() {
        owner = tx.origin;
    }
    
    modifier onlyowner { if (tx.origin == owner) _ }

    function addString(string _key, string _value) onlyowner {
        strings[_key] = _value;
    }
    
    function setOwner(address _owner) onlyowner {
        owner = _owner;
    }
    
    function setName(string _name) onlyowner {
        name = _name;
    }
    
    function destroy() onlyowner {
        suicide(owner);
    }
}