/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract CMHome {
address CMAdmin = 0xD97C2Ecbd1ba8C1785cf416a7111197fd677F638; 
////////////////////COYPRIGHT INFORMATION///////////////	
/*copyright 2016 @coinmechanics.com. All rights reserved*/	
///////////////DATA STRUCTURE & STORES/////////
struct WhiteList{
bool Valid;
bool Created;
bool Abitration;	
}
mapping(address => WhiteList) public whitelist;
	
struct MyContracts {
bool Created;
address Contr;	
}		
mapping(uint32 => mapping (address => MyContracts)) public mycontracts;

struct Factories {
bool Authorised;
bool Controlled;
}
mapping (address => Factories) public factory;

/////////////CONFIGURE FACTORY//////////////

function Config(uint8 control, address _factory){
if(msg.sender != CMAdmin)throw;

factory[_factory].Authorised = true;

if(control == 0){
factory[_factory].Controlled = false;
}
if(control == 1){
factory[_factory].Controlled = true;
}
}

/////////UPDATE ARBITRATION STATUS//////////////

function Auth(uint8 state, address _contract){
if(msg.sender != CMAdmin)throw;

if(state == 0){
whitelist[_contract].Abitration = false;
}
if(state == 1){
whitelist[_contract].Abitration = true;
}
}
		
///////////////START REGISTRATION////////////////

function RegisterOne(uint32 _id, address _owner, address _contract){

if(factory[msg.sender].Authorised == false) throw;

whitelist[_contract].Created = true;
whitelist[_contract].Valid = false;
whitelist[_contract].Abitration = false;
mycontracts[_id][_owner].Created = true;
mycontracts[_id][_owner].Contr = _contract;
}

//////////////COMPLETE REGISTERATION//////////

function RegisterTwo(address _contract, address _factr){

if(whitelist[_contract].Created == false)throw;
if(whitelist[_contract].Valid == true)throw;
whitelist[_contract].Valid = true;

if(factory[_factr].Controlled == true) {
whitelist[_contract].Abitration = false;
}

if(factory[_factr].Controlled == false) {
whitelist[_contract].Abitration = true;
}
}
function(){ throw; }	
}///////////////////////////////end of cm home contract


contract SkywalkerFactory {
address CMAdmin = 0xD97C2Ecbd1ba8C1785cf416a7111197fd677F638;
	
///////////////CONTRACT ADDRESS////
function GetContractAddr() constant returns (address){
return this;
}	
address ContrAddr2 = GetContractAddr();
	
//////CREATE SKYWALKER CONTRACT////////////

function Create(uint32 pin, address _cmhome){

address sender = msg.sender;
address atlantis = new Skywalker(sender,ContrAddr2);

CMHome
HomeCall = CMHome(_cmhome);	
(HomeCall.RegisterOne(pin,sender,atlantis));	
}

////////DATA STRUCTURE & STORES////////

struct Pricing {
uint32 ServiceFee;
uint32 DefaultFee;	
}
Pricing pri;

/////////UPDATE PRICES////////
function UpdatePrice(uint8 component, uint32 price){
if(msg.sender != CMAdmin) throw;       
if(component == 1) pri.ServiceFee = price;
if(component == 2) pri.DefaultFee = price;  
}

//////////GET PRICES////////
function GetPrice(uint8 get)returns (uint32){
if(get == 1) return pri.ServiceFee;
if(get == 2) return pri.DefaultFee;
}

function() { throw; }
}//////////////////////////end of moonraker factory

contract Skywalker {
address CMAccount = 0x346a16921af2db3788d29FB171604f1251A25aBF;
address CMAdmin = 0xD97C2Ecbd1ba8C1785cf416a7111197fd677F638;
uint256 WeiConverter = 1000000000000000000;
uint32 Factor = 100000000;
uint32 ServiceFee;
uint32 DefaultFee;
uint256 Fee;	
uint256 Pay;
uint256 NetPayout;
////////////CONTRACT ADDRESS///////////////////////////
function GetContractAddr() constant returns (address){
return this;
}	
address ContrAddr = GetContractAddr();

/////////////CONTRACT DATA STRUCTURE//////////////////

struct Core {
address Owner;
address Factory;
address Home;
bool SetUp;
}

struct fContr1 {
uint256 ContractID;	
string ContractType;
string AssetAndCurrency;
string OwnerPosition;
string PriceAddress;
}	
	
struct fContr2 {
uint32 Units;
uint32 CounterPartyDeposit;
uint32 OwnerDeposit;
}

struct fContr3 {
string MovementRange;	
string ActivationTime;
string ExpirationTime;
}

struct Status {
bool Dispute;
bool ActivePro;
bool ActiveSet;
bool ActiveArb;
}

struct Deposits {
bool CounterPartyFunded;
bool OwnerFunded;
address CounterPartyAddr;
address OwnerAddr;
}

struct Settlement {
bool CounterPartySettled; 
bool OwnerSettled;
uint32 CounterPartyPayout;
uint32 OwnerPayout;
} 

struct Arbitration {
bool OwnerDefault;
uint32 PayCounterParty;
uint32 PayOwner;
}
///////////////MAP DATA STORES///////////////////
mapping (uint256 => fContr1) public contractPartOne;	
mapping (uint256 => fContr2) public contractPartTwo;
mapping (uint256 => fContr3) public contractPartThree;
mapping (uint256 => Settlement) public settlement;
mapping (uint256 => Arbitration) public arbitration;
mapping (uint256 => Deposits) public deposits;
mapping (uint256 => Status) public status;	
	
////////////INITIALIZE DATA STORES/////////////
fContr1 c1;	
fContr2 c2;
fContr3 c3;
Settlement se;
Arbitration ar;
Deposits de;
Status st;
Core co;

////////////////CONSTRUCTOR///////////////////////
function Skywalker(address _sender,address _factory){
co.Owner = _sender;
co.Factory = _factory;
}

//////////////////COMPLETE REGISTRATION////////////////////
function Register(address cmhome){
CMHome
HomeCall = CMHome(cmhome);	
(HomeCall.RegisterTwo(ContrAddr,co.Factory));
co.Home = cmhome;
co.SetUp = true;
}

//////////////////////////CONTRACT REFERENCE///////////////////
uint256 ContractNum = 1;	
event ProposalLog(uint256 contract_id);			
////////////////////////////PROPOSAL//////////////////////////
function CreateProposal(
string AssetAndCurrency,
string OwnerPosition,
string PriceAddress,
uint32 Units,
string ActivationTime,
string ExpirationTime,
string MovementRange,
uint32 CounterPartyDeposit,
uint32 OwnerDeposit) {
if(msg.sender != co.Owner) throw;   
if(co.SetUp != true) throw;        
if(st.ActivePro == true) throw;   
if(st.ActiveSet == true) throw;   
if(st.ActiveArb == true) throw; 
c1.ContractID = ContractNum;	
c1.ContractType = 'CONTRACT FOR DIFFERENCE';	
c1.AssetAndCurrency = AssetAndCurrency;
c1.OwnerPosition = OwnerPosition;
c1.PriceAddress = PriceAddress;
c2.Units = Units;	
c2.CounterPartyDeposit = CounterPartyDeposit;	
c2.OwnerDeposit = OwnerDeposit;	
c3.ActivationTime = ActivationTime ;
c3.ExpirationTime = ExpirationTime;
c3.MovementRange = MovementRange;
contractPartOne[ContractNum].ContractID = ContractNum;
contractPartOne[ContractNum].ContractType = 'CONTRACT FOR DIFFERENCE';	
contractPartOne[ContractNum].AssetAndCurrency = AssetAndCurrency; 
contractPartOne[ContractNum].OwnerPosition = OwnerPosition; 
contractPartOne[ContractNum].PriceAddress = PriceAddress; 
contractPartTwo[ContractNum].Units = Units;
contractPartTwo[ContractNum].CounterPartyDeposit = CounterPartyDeposit;
contractPartTwo[ContractNum].OwnerDeposit = OwnerDeposit;
contractPartThree[ContractNum].ActivationTime = ActivationTime;
contractPartThree[ContractNum].ExpirationTime = ExpirationTime;
contractPartThree[ContractNum].MovementRange = MovementRange;
st.ActivePro = true;
status[ContractNum].ActivePro = true;
ProposalLog(ContractNum);	
}
	
////////////////OWNER DEPOSIT//////////////

function OwnerDeposit(){
uint256 _OwnerDeposit = c2.OwnerDeposit *  WeiConverter;

if(st.ActivePro == false) throw; 
if(msg.sender != co.Owner) throw;
if(msg.value != _OwnerDeposit) throw;
if(deposits[ContractNum].OwnerFunded == true) throw;
se.OwnerSettled = false;
de.OwnerAddr = co.Owner;
de.OwnerFunded = true;
deposits[ContractNum].OwnerFunded = true;	
deposits[ContractNum].OwnerAddr = co.Owner;
}

/////////COUNTER PARTY DEPOSIT/////////////

function CounterPartyDeposit(){
uint256 _CounterPartyDeposit = c2.CounterPartyDeposit * WeiConverter ;

if(st.ActivePro == false) throw; 
if(msg.sender == co.Owner) throw;
if(msg.value != _CounterPartyDeposit) throw;
if(deposits[ContractNum].CounterPartyFunded == true) throw;
se.CounterPartySettled = false;
de.CounterPartyAddr = msg.sender;
de.CounterPartyFunded = true;
deposits[ContractNum].CounterPartyFunded = true;	
deposits[ContractNum].CounterPartyAddr = msg.sender;		
}

////////////////////////////SETTLEMENT//////////////////

function Settle (
uint32 CounterPartyPayout,
uint32 OwnerPayout){
if(msg.sender != co.Owner) throw;
if(st.Dispute == true) throw;	
if(st.ActivePro == false) throw;   
if(st.ActiveSet == true) throw;   
if(de.CounterPartyFunded == false) throw;   
if(de.OwnerFunded == false) throw;        
if(CounterPartyPayout < 100) throw; 
if(OwnerPayout < 100) throw;       
se.CounterPartyPayout = CounterPartyPayout;
se.OwnerPayout = OwnerPayout;
settlement[ContractNum].CounterPartyPayout = CounterPartyPayout;
settlement[ContractNum].OwnerPayout = OwnerPayout;
st.ActiveSet = true;
status[ContractNum].ActiveSet = true;	
}

///////////SETTLEMENT PAYOUT/////////////////
function Payout (){
if(st.ActiveSet != true) throw;
if(st.Dispute == true) throw;
if(st.ActiveArb == true) throw;
if((msg.sender != de.CounterPartyAddr) && (msg.sender != de.OwnerAddr))throw; 
if(msg.sender == de.OwnerAddr && se.CounterPartySettled == false)throw;

SkywalkerFactory
FactoryCall = SkywalkerFactory(co.Factory);	
ServiceFee = (FactoryCall.GetPrice(1));
	
if((msg.sender == de.OwnerAddr) && (se.OwnerSettled == false)){
Pay = ((se.OwnerPayout * WeiConverter) / 100);
se.OwnerSettled = true;
settlement[ContractNum].OwnerSettled = true;
if(!de.OwnerAddr.send(Pay)) throw;
}
if((msg.sender == de.CounterPartyAddr) && (se.CounterPartySettled == false)){
Fee = ((se.CounterPartyPayout * ServiceFee * WeiConverter) / Factor);
Pay = ((se.CounterPartyPayout * WeiConverter) / 100);
NetPayout = Pay - Fee;
se.CounterPartySettled = true;
settlement[ContractNum].CounterPartySettled = true;
if(!de.CounterPartyAddr.send(NetPayout)) throw;
if(!CMAccount.send(Fee)) throw;
}
}	
/////////////DISPUTE/////////////////
function Dispute() {
if((msg.sender != co.Owner) && (msg.sender != de.CounterPartyAddr)) throw;     
if(st.Dispute == true) throw; 
if(se.CounterPartySettled == true) throw;
if(se.OwnerSettled == true) throw;
if(de.OwnerFunded == false && msg.sender == co.Owner)throw; 
if(de.CounterPartyFunded == false && msg.sender == de.CounterPartyAddr)throw;
if(de.OwnerFunded != true && de.CounterPartyFunded != true)throw; 
st.Dispute = true;
status[ContractNum].Dispute = true;
}
////////////////////////////ARBITRATION////////////////////

function Arbitrate(
uint32 PayCounterParty,
uint32 PayOwner,
bool OwnerDefault){
if(msg.sender != CMAdmin) throw;   
if(st.ActivePro == false) throw;  
if(st.Dispute == false) throw;    
if(st.ActiveArb == true) throw;  
if(PayCounterParty < 100) throw; 
if(PayOwner < 100) throw;       
ar.PayCounterParty = PayCounterParty;
ar.PayOwner = PayOwner;
ar.OwnerDefault = OwnerDefault;	
arbitration[ContractNum].PayCounterParty = PayCounterParty;	
arbitration[ContractNum].PayOwner = PayOwner;
arbitration[ContractNum].OwnerDefault = OwnerDefault;
st.ActiveArb = true;	
status[ContractNum].ActiveArb = true;	
}

///////////COUNTER PARTY ARBITRATION PAYOUT/////////////
function CCPayoutArb (){	
if(st.Dispute == false) throw;
if(st.ActiveArb == false) throw;
if(msg.sender != de.CounterPartyAddr)throw; 

SkywalkerFactory
FactoryCall = SkywalkerFactory(co.Factory);	
ServiceFee = (FactoryCall.GetPrice(1));
DefaultFee = (FactoryCall.GetPrice(2));

if((ar.OwnerDefault == true) && (se.CounterPartySettled == false)){
Fee = ((ar.PayCounterParty * ServiceFee * WeiConverter) / Factor);	
Pay = ((ar.PayCounterParty * WeiConverter) / 100);
NetPayout = Pay - Fee;
se.CounterPartySettled = true;
settlement[ContractNum].CounterPartySettled = true;
if(!de.CounterPartyAddr.send(NetPayout)) throw;
if(!CMAccount.send(Fee)) throw;
}
if((ar.OwnerDefault == false) && (se.CounterPartySettled == false)){
Fee = ((ar.PayCounterParty * DefaultFee * WeiConverter) / Factor);
Pay = ((ar.PayCounterParty * WeiConverter) / 100);
NetPayout = Pay - Fee;
se.CounterPartySettled = true;
settlement[ContractNum].CounterPartySettled = true;
if(!de.CounterPartyAddr.send(NetPayout)) throw;
if(!CMAccount.send(Fee)) throw;
}
}

//////////////////OWNER ARBITRATION PAYOUT////////////	
function OWPayoutArb (){		
if(st.Dispute == false) throw;
if(st.ActiveArb == false) throw;
if(msg.sender != de.OwnerAddr)throw; 

SkywalkerFactory
FactoryCall = SkywalkerFactory(co.Factory);	
ServiceFee = (FactoryCall.GetPrice(1));
DefaultFee = (FactoryCall.GetPrice(2));

if((ar.OwnerDefault == false) && (se.OwnerSettled == false)){
Pay = ((ar.PayOwner * WeiConverter) / 100);
if(!de.OwnerAddr.send(Pay)) throw;
se.OwnerSettled = true;
settlement[ContractNum].OwnerSettled = true;
}

if((ar.OwnerDefault == true) && (se.OwnerSettled == false)){
Fee = ((ar.PayOwner * DefaultFee * WeiConverter) / Factor);	
Pay = ((ar.PayOwner * WeiConverter) / 100); 
NetPayout = Pay - Fee;
if(!de.OwnerAddr.send(NetPayout)) throw;
if(!CMAccount.send(Fee)) throw;
se.OwnerSettled = true;
settlement[ContractNum].OwnerSettled = true;
}
}
	
//////////////////////////REFUNDS////////////////////////
function Refund(){
if(st.ActivePro == false) throw;	
if(st.ActiveSet == true) throw;
if(st.ActiveArb == true) throw;
if(st.Dispute == true) throw;

if(msg.sender == co.Owner && de.CounterPartyFunded == false 
&& de.OwnerFunded == true){
uint256 _OwnerDeposit = c2.OwnerDeposit * WeiConverter;
if(!de.OwnerAddr.send(_OwnerDeposit)) throw;
deposits[ContractNum].OwnerFunded = false;
de.OwnerFunded = false;
settlement[ContractNum].OwnerSettled = true;
se.OwnerSettled = true;
}

if(msg.sender == de.CounterPartyAddr && de.CounterPartyFunded == true 
&& de.OwnerFunded == false){
uint256 _CounterPartyDeposit = c2.CounterPartyDeposit * WeiConverter;
if(!de.CounterPartyAddr.send(_CounterPartyDeposit)) throw;
deposits[ContractNum].CounterPartyFunded = false;
deposits[ContractNum].CounterPartyAddr = 0;
de.CounterPartyFunded = false;
de.CounterPartyAddr = 0;
se.CounterPartySettled = true;
settlement[ContractNum].CounterPartySettled = true;
}
}
////////////////OWNER ADMINISTRATION////////////////
function Reset(){
if(msg.sender != co.Owner)throw;
if(de.CounterPartyFunded == true && se.CounterPartySettled == false) throw;	
if(de.OwnerFunded == true && se.OwnerSettled == false) throw;
st.Dispute = false;
st.ActivePro = false;
st.ActiveSet = false;
st.ActiveArb = false;	
ContractNum++;	
}

function() { throw; }		
}/////////////////////////////end of skywalker contract