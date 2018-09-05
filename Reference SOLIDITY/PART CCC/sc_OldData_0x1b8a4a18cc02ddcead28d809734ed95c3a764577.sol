/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract OldData {
    mapping(bytes32 => address) public oldUsers;
    bytes32[] public allOldUsers;
    
    function OldData() public {
        allOldUsers.push("anatalist");
        allOldUsers.push("djoney_");
        allOldUsers.push("Luit03");
        allOldUsers.push("bquimper");
        allOldUsers.push("oblomov1");
        allOldUsers.push("myownman");
        allOldUsers.push("saxis");
        allOldUsers.push("bobanm");
        allOldUsers.push("screaming_for_memes");
        allOldUsers.push("playingethereum");
        allOldUsers.push("eli0tz");
        allOldUsers.push("BrBaumann");
        allOldUsers.push("sunstrikuuu");
        allOldUsers.push("RexetBlell");
        allOldUsers.push("some_random_user_0");
        allOldUsers.push("SterLu");
        allOldUsers.push("besoisinovi");
        allOldUsers.push("Matko95");
        
        oldUsers["anatalist"] = 0xC11B1890aE2c0F8FCf1ceD3917D92d652e5e7E11;
        oldUsers["djoney_"] = 0x0400c514D8a63CF6e33B5C42994257e9F4f66dE0;
        oldUsers["Luit03"] = 0x19DB8629bCCDd0EFc8F89cE1af298D31329320Ec;
        oldUsers["bquimper"] = 0xaB001dAb0D919A9e9CafE79AeE6f6919845624f8;
        oldUsers["oblomov1"] = 0xC471df16A1B1082F9Be13e70dAa07372C7AC355f;
        oldUsers["myownman"] = 0x174252aE3327DD8cD16fE3883362D0BAB7Fb6f3b;
        oldUsers["saxis"] = 0x27cb2A354E2907B0b5F03BB03d1B740a55A5a562;
        oldUsers["bobanm"] = 0x45E0F19aDfeaD31eB091381FCE05C5DE4197DD9c;
        oldUsers["screaming_for_memes"] = 0xfF3a0d4F244fe663F1a2E2d87D04FFbAC0910e0E;
        oldUsers["playingethereum"] = 0x23dEd0678B7e41DC348D1D3F2259F2991cB21018;
        oldUsers["eli0tz"] = 0x0b4F0F9CE55c3439Cf293Ee17d9917Eaf4803188;
        oldUsers["BrBaumann"] = 0xE6AC244d854Ccd3de29A638a5A8F7124A508c61D;
        oldUsers["sunstrikuuu"] = 0xf6246dfb1F6E26c87564C0BB739c1E237f5F621c;
        oldUsers["RexetBlell"] = 0xc4C929484e16BD693d94f9903ecd5976E9FB4987;
        oldUsers["some_random_user_0"] = 0x69CC780Bf4F63380c4bC745Ee338CB678752301a;
        oldUsers["SterLu"] = 0xe07caB35275C4f0Be90D6F4900639EC301Fc9b69;
        oldUsers["besoisinovi"] = 0xC834b38ba4470b43537169cd404FffB4d5615f12;
        oldUsers["Matko95"] = 0xC26bf0FA0413d9a81470353589a50d4fb3f92a30;
    }
    
    function getArrayLength() public view returns(uint) {
        return allOldUsers.length;
    }
}