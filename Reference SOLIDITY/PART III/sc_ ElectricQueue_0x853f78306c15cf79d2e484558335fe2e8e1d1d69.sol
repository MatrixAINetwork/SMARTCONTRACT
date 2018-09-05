/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

contract IElectricCharger {
   
   
    function setInvestors(uint[] ids,address[] addresses,uint[] balances,uint investmentsCount);
   function getPrice() constant external returns (uint price);
 
}
//contract
contract ElectricQueue  {
       address public Owner;
       uint public syncDate;
       uint public InvestmentsCount;
       uint public ChargersCount;
       Investment[] Investments;
       uint[]  ChargersIds ; 
       mapping (uint=>Charger) Chargers;
       address public Proxy;
       address public Manager;
       //contract of electrochargers , which state
       struct Charger{
          IElectricCharger Address;
          bool IsActive;
       }
  //    'Investment' describes investment from uniq address to uniq charger.
      struct Investment {
           uint InvestmentId;
           address Address;
           uint ChargerId;
           uint Balance;
           uint TotalSum;
           bool IsTransfered;
           uint LastUpdateDate;
           bool IsReturned;
       }
           
        function ElectricQueue(address proxy){
             Owner = msg.sender;
             syncDate = now;
             Proxy = proxy;
        }
        function setManager(address manager) external{
             if (msg.sender != Owner) return ;
             Manager = manager;
        }
        //return the information about each charger in queue contract
       function getChargers() external constant returns (uint [] chargers ,address[] addresses ,bool [] states) {
        uint length = ChargersIds.length;
        address []  memory _addresses = new address[](length);
        bool []  memory _states = new bool[](length);
          for(uint i = 0 ; i < ChargersIds.length;i++){
              _addresses[i] = Chargers[ChargersIds[i]].Address;
              _states[i] = Chargers[ChargersIds[i]].IsActive;
          }
           return (ChargersIds,_addresses,_states);
       }
       //create new investment  and push it to array 'Investments' 
       function createInvestment(address _address,uint _chargerId) internal returns (Investment investor) {
        checkCharger(_chargerId);
        InvestmentsCount++;
        Investment memory _newInvestment;
        _newInvestment.Address = _address;
        _newInvestment.ChargerId = _chargerId;
        _newInvestment.InvestmentId = InvestmentsCount;
        Investments.push(_newInvestment);
        return _newInvestment;
      }
      //external function that gives possibility to invest in queue or concret charger
      function  investInQueue(address _from , uint _charger) payable returns(bool success) {
          var investmentId = getInvestment(_from,_charger);
          Investments[investmentId-1].Balance+=msg.value;
          Investments[investmentId-1].TotalSum+=msg.value;
          Investments[investmentId-1].IsTransfered=false;
          Investments[investmentId-1].IsReturned=false;
          Investments[investmentId-1].LastUpdateDate =now;
          syncDate = now;
          return true;
      }
      //check for exting charger and create new if , mapping hasn't it
      function checkCharger(uint _chargerId) internal{
          if(!Chargers[_chargerId].IsActive ){
              Chargers[_chargerId].IsActive = true;
              ChargersIds.push(_chargerId);
              ChargersCount++;
          }
      }
      //get investment by two key (address and charger)
      function  getInvestment(address _address,uint _charger) internal returns (uint investmentId ) {
          for(uint i =0 ; i < InvestmentsCount ; i++){
                if(Investments[i].Address ==_address && Investments[i].ChargerId == _charger){
                    return Investments[i].InvestmentId;
                }
          }
          var _investment = createInvestment(_address,_charger);
          return _investment.InvestmentId;
      }
      //return information about all investments in queue contract
      function getAllInvestments() external constant returns( uint [] ids , address[] addresses, uint[] chargerIds, uint [] balances , bool [] states , uint[] lastUpdateDates,uint[] totalSum) {
               uint length = InvestmentsCount;
               uint []  memory _ids  = new uint[](length);
               address []  memory _addresses = new address[](length);
               uint []  memory _chargerIds = new uint[](length);
               uint []  memory _balances= new uint[](length);
               bool []  memory _states = new bool[](length);
               uint []  memory _lastUpdateDates= new uint[](length);
               uint []  memory _totalSums= new uint[](length);
               for(uint i =0 ; i < InvestmentsCount ; i++){
                 _ids[i]= Investments[i].InvestmentId;
                 _addresses[i]= Investments[i].Address;
                 _chargerIds[i]=Investments[i].ChargerId;
                 _balances[i]=Investments[i].Balance;
                 _states[i]=Investments[i].IsTransfered;
                 _totalSums[i]=Investments[i].TotalSum;
                 _lastUpdateDates[i]=Investments[i].LastUpdateDate;
                }
                return(_ids,_addresses,_chargerIds,_balances,_states,_lastUpdateDates,_totalSums);
          }   
     
      //setting charger address
      function setChargerAddress(uint id , address chargerAddress) {
         if (msg.sender != Owner && msg.sender != Manager) return ;
          Chargers[id].Address = IElectricCharger(chargerAddress);
      }
      //transer money to cherger
      function sendToCharger(uint id){
                 if (msg.sender != Owner && msg.sender != Manager) return ;
                 var _amountForCharger = getAmountForCharger(id);

                uint _priceOfCharger = Chargers[id].Address.getPrice() ;
                 if(_priceOfCharger> _amountForCharger){
                        uint difference  = _priceOfCharger - _amountForCharger;
                       calculateCountOfInvestmetnsInQueue(difference,id);
                 }            
                 if(!Chargers[id].Address.call.value(_priceOfCharger)())
                       throw;
      }
  
      function calculateCountOfInvestmetnsInQueue(uint difference ,uint id) internal{
             uint queueInvestments=0;
             uint i =0;  uint investmantBalance=0;
            uint length = InvestmentsCount;
            uint []  memory _ids  = new uint[](length);
            address []  memory _addresses = new address[](length);
            uint []  memory _balances= new uint[](length);

             while(i <InvestmentsCount && difference > 0){
                     if(Investments[i].ChargerId == 0 && Investments[i].Balance >= 1 ether){
                         if(difference>Investments[i].Balance){
                            investmantBalance=Investments[i].Balance;
                            Investments[i].Balance=0;
                           Investments[i].IsTransfered =true;
                         }
                         else{
                               investmantBalance=difference ;
                              Investments[i].Balance-=difference;
                         }
                        _ids[queueInvestments]=Investments[i].InvestmentId;
                        _addresses[queueInvestments]=Investments[i].Address;
                        _balances[queueInvestments]=investmantBalance;
                         queueInvestments++;
                     }
                    i++;
             }
             Chargers[id].Address.setInvestors(_ids,_addresses,_balances,queueInvestments);
               
      }
      //calculate amount for charger
      function getAmountForCharger(uint id) internal returns (uint sumBalance) {
            sumBalance = 0;
            uint chargerInvestments=0;
            uint length = InvestmentsCount;
            uint []  memory _ids  = new uint[](length);
            address []  memory _addresses = new address[](length);
            uint []  memory _balances= new uint[](length);

             for(uint i =0 ; i < InvestmentsCount ; i++){
                if(Investments[i].ChargerId == id && Investments[i].Balance >= 1 ether){
                    _ids[chargerInvestments]=Investments[i].InvestmentId;
                    _addresses[chargerInvestments]=Investments[i].Address;
                    _balances[chargerInvestments]=Investments[i].Balance;
                  
                   sumBalance +=Investments[i].Balance;
                   Investments[i].Balance=0;
                   Investments[i].IsTransfered = true;
                   
                   chargerInvestments++;
                }
            }
         Chargers[id].Address.setInvestors(_ids,_addresses,_balances,chargerInvestments);
   
      }
       function  returnMoney(address _to) payable returns(bool success) {
        if(msg.sender != Proxy) return false;
         for(uint i =0 ; i < InvestmentsCount ; i++){
                if(Investments[i].Address ==_to){
                        if(!_to.send(Investments[i].Balance)){
                            return false;
                        }
                        Investments[i].Balance = 0;
                        Investments[i].IsReturned= true;

                }
          }
          
          return true;
       }
}