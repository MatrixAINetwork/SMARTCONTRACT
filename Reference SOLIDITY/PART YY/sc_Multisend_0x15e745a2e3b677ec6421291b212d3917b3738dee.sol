/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Multisend {
    mapping(address => uint) public balances;
    mapping(address => uint) public nonces;

    
    function send(address[] addrs, uint[] amounts, uint nonce) {
        if(addrs.length != amounts.length || nonce != nonces[msg.sender]) throw;
        uint val = msg.value;
        
        for(uint i = 0; i<addrs.length; i++){
            if(val < amounts[i]) throw;
            
            if(!addrs[i].send(amounts[i])){
                balances[addrs[i]] += amounts[i];
            }
            val -= amounts[i];
        }
        
        if(!msg.sender.send(val)){
            balances[msg.sender] += val;
        }
        nonces[msg.sender]++;
    }
    
    function withdraw(){
        uint balance = balances[msg.sender];
        balances[msg.sender] = 0;
        if(!msg.sender.send(balance)) throw;
    }
    
    function(){
        withdraw();
    }
}