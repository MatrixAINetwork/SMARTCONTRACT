/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/*

Last contributor before the deadline gets all ether, stored in the contract!
Try your luck!

var raceAddress = "0x02e01e9a73ed2cb24b32628c935256e455b0a078 ";
var raceftwContract = web3.eth.contract([{"constant":false,"inputs":[],"name":"getCurrentWinner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[],"name":"claimReward","outputs":[],"type":"function"},{"constant":false,"inputs":[],"name":"getDisclaimer","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[],"name":"getRaceEndBlock","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"inputs":[],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"newWinner","type":"address"}],"name":"LastContributorChanged","type":"event"}]);
var raceftw = raceftwContract.at(raceAddress);

console.log("current winner: ", raceftw.getCurrentWinner.call());
console.log("race ends at block: ", raceftw.getRaceEndBlock.call(), " current block:", eth.blockNumber);
console.log("current balance: ", web3.fromWei(eth.getBalance(raceAddress), "ether"));



//To participate in the race:
eth.sendTransaction({from:<your address>, to:"0x02e01e9a73ed2cb24b32628c935256e455b0a078 ", value:web3.toWei(10, "finney"), gas:50000});

//The winner can claim their reward by sending the following transaction:
raceftw.claimReward.sendTransaction({from:<your address>, gas:50000})

*/
contract RaceFTW {
    
    /* Disclaimer */
    string disclaimer = "Copyright (c) 2016 \"The owner of this contract\" \nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.";
    
    function getDisclaimer() returns (string) {
        return disclaimer;
    }
    
    address lastContributor;
    uint fixedContribution = 10 finney;
    
    uint raceEnds = 0;
    
    // number of blocks. roughly 3 months at the contract creation blocks rate
    uint RACE_LENGTH = 555555;
    
    event LastContributorChanged(address newWinner);
    
    function RaceFTW () {
        raceEnds = block.number + RACE_LENGTH;
    }
    
    function getRaceEndBlock() returns (uint) {
        return raceEnds;
    }
    
    function getCurrentWinner() returns (address) {
        return lastContributor;
    }
    
    function () {
        //refund if the race ended
        if (block.number > raceEnds) {
            throw;
        }
        //refund if sent amount not equal to 1 finney
        if (msg.value != fixedContribution) {
            throw;
        }
        //raise event if needed
        if (lastContributor != msg.sender) {
            LastContributorChanged(msg.sender);
        }
        
        //change the last contributor
        lastContributor = msg.sender;
    }
    
    
    function claimReward() {
        //only lastContributor can claim
        if (msg.sender != lastContributor) {
            throw;
        }
        //refund if race is not over yet
        if (block.number < raceEnds) {
            throw;
        }
        if (this.balance > 0) {
            lastContributor.send(this.balance);
        }
    }
}