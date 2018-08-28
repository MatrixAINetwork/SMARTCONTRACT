/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
interface tokenRecipient { function receiveApproval(address from, uint256 value, address token, bytes extraData) public; }

contract CoinDump {
    mapping (address => uint256) public balanceOf;
    
    string public name = 'CoinDump';
    string public symbol = 'CD';
    uint8 public decimals = 6;
    
    function transfer(address _to, uint256 _value) public {
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }
    
    function CoinDump() public {
        balanceOf[msg.sender] = 1000000000000000;                   // Amount of decimals for display purposes
    }
    
    event Transfer(address indexed from, address indexed to, uint256 value);
}