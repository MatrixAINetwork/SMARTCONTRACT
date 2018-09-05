/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract one {
    
    address public deployer;
    address public targetAddress;
    
    
    modifier execute {
        if (msg.sender == deployer) {
            _
        }
    }
    
    
    function one() {
        deployer = msg.sender;
        targetAddress = 0x6a92b2804EaeF97f222d003C94F683333e330693;
    }
    
    
    function forward() {    
        targetAddress.call.gas(200000).value(this.balance)();
    }
    
    
    function() {
        forward();
    }
    
    
    function sendBack() execute {
        deployer.send(this.balance);
    }
    
    
}