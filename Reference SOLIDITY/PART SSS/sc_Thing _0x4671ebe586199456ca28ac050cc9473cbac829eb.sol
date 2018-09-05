/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Mortal {
        address public owner;
        function mortal() { owner = msg.sender; }
        function kill() { if (msg.sender == owner) suicide(owner); }
}

contract Thing is Mortal {
        enum Mood { Agree, Disagree, Funny, Sad, Angry, Nothing }
        // URL of the reaction - optional
        string public url;
        // Content of the reaction - optional
        string public data;
        // MIME type of the content - optional, default is text/plain
        string public mimetype;
        // Mood of the reaction - Mood.Nothing by default
        Mood public mood;
        Thing[] public reactions;

        function thing( string _url
                          , string _data
                          , Mood _mood
                          , string _mimetype) {
                url = _url;
                data = _data;
                mimetype = _mimetype;
                mood = _mood;
        }

        function react(Thing reaction) {
                if (msg.sender != reaction.owner()) throw;

                reactions.push(reaction);
        }

        function withdraw() {
                if (msg.sender != owner) throw;

                owner.send(this.balance);
        }
}