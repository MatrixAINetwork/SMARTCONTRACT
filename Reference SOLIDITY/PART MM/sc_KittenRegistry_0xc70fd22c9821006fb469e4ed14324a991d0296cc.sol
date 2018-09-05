/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract AssetStorage {
    function addTrustedIssuer(address addr, string name);
    function removeTrustedIssuer(address addr, string name);
    function assertFact(uint id, string fact);
}

contract KittenRegistry is AssetStorage {
   address owner;
   modifier onlyowner { if(msg.sender == owner) _ } 

   struct KittenAuthority {
       string name;
       bool trusted;
       uint timestamp;
   }
   struct KittenFact {
       address issuer;
       bool trusted;
       string fact;
       uint timestamp;
   }

   mapping(address => KittenAuthority) authorities;
   mapping(uint => KittenFact[]) facts;
   mapping(uint => uint) factCounts; 
   uint totalKittens;

   function KittenRegistry() {
       owner = msg.sender;
   }
   function addTrustedIssuer(address addr, string name) onlyowner {
       authorities[addr] = KittenAuthority({ name: name, timestamp: now, trusted: true });
   }
   function removeTrustedIssuer(address addr, string name) onlyowner {
       delete authorities[addr];
   }
   function assertFact(uint id /* kittenId */, string fact) {
       if(facts[id].length == 0) {
           totalKittens++;
       }
       factCounts[id] = facts[id].push(KittenFact({
           issuer: msg.sender, 
           trusted: authorities[msg.sender].trusted,
           timestamp: now,
           fact: fact
       }));
   }
}