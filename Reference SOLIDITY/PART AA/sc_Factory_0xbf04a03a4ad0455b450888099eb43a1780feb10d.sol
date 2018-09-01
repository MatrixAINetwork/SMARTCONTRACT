/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/* 
   Deposits are managed by a separate contract. Withdraws are manual, and can be automated 
   with the "Account" contracts. Manual withdrawals are since The DAO recommended as best practice for 
   security of Solidity based Smart Contracts,
   
   https://blog.ethereum.org/2016/06/19/thinking-smart-contract-security/
   
   http://ethereum.stackexchange.com/questions/6204/writing-secure-smart-contracts-in-solidity
*/

contract DepositGovernance { function registrationVote(address _registrant, uint _amount) {} }

contract RegistrationDeposits {
    
    DepositGovernance public governance;
    address registrationContract;
    
    mapping(address => uint256) deposit;
    
    function RegistrationDeposits(address _depositGovernance, address _registrationContract) {
        governance = DepositGovernance(_depositGovernance);
        registrationContract = _registrationContract;
    }
    
    function register(address _registrant) payable external {
        if(msg.sender != registrationContract) throw;
        deposit[_registrant] = msg.value;
        governance.registrationVote(_registrant, msg.value);
    }
    
    function withdrawDeposit() public {
        if(deposit[msg.sender] == 0) throw;
        if(!msg.sender.send(deposit[msg.sender])) throw;
        deposit[msg.sender] = 0;
    }
}

contract Factory {
    
    function newDepositContract(address _depositGovernance, address _registrationContract) returns (address) {
        return new RegistrationDeposits(_depositGovernance, _registrationContract);
    }
    
}