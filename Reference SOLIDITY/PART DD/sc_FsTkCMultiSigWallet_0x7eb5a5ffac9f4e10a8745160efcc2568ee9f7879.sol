/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

// FundersToken MultiSig Wallet Contract v1.0.0
// 2017/11/18

contract FsTkCMultiSigWallet {
    // deployer = wallet deployer
    address public deployer = address(0);

    // initialized
    bool public initialized = false;

    // committeesMap               = committees' addresses -> indices
    // committeesArray             = index -> committee's address
    // committeesArrayIndexCounter = counter for committeesArray
    // committeesNumber            = number of committees
    // committeesArray [ committeesMap [ testAddress ] ] == 0x0 ? NotCommittee : IsCommittee
    mapping (address => uint256) public committeesMap;
    address[] public committeesArray;
    uint256 public committeesArrayIndexCounter = 0;
    uint256 public committeesNumber = 0;

    // committeeJoinVotes  = votes for joining a committee
    // committeeKickVotes  = votes for kicking a committee
    // committeeJoinVoters = newCommittee    -> voter -> voted
    // committeeKickVoters = kickedCommittee -> voter -> voted
    mapping (address => uint256) public committeeJoinVotes;
    mapping (address => uint256) public committeeKickVotes;
    mapping (address => mapping (address => bool)) public committeeJoinVoters;
    mapping (address => mapping (address => bool)) public committeeKickVoters;

    // txCounter = this multigis wallet's tx counter
    uint256 public txCounter = 0;

    // txTaskMap = tx's index to the task
    mapping (uint256 => Task) public txTaskMap;

    // tokenTransferFunctionIdentifierMap = sha3(ercVersion) to function identifier
    mapping (bytes32 => bytes4) public tokenTransferFunctionIdentifierMap;

    // tx task structure
    struct Task {
        uint256 taskType;
        address receiver;
        uint256 value;
        address tokenContractAddress;
        bytes4  functionIdentifier;
        uint256 acceptedCounter;
        mapping (address => bool) acceptedCommitteesMap;
        bool    completed;
    }

    function FsTkCMultiSigWallet () public {
        deployer = msg.sender;

        // add void address at array[0]
        // and 0x0 is not a committee
        addCommitteeToMapAndArray(address(0));
        committeesNumber--;

        // add deployer at array[1]
        addCommitteeToMapAndArray(deployer);

        // set default erc20 token function identifier
        setTokenTransferIdentifier("erc20", 0xa9059cbb);

        initialized = true;
    }

    event AddCommitteeToMapAndArrayEvent (address newCommittee);
    function addCommitteeToMapAndArray (address _newCommittee) onlyCommitteesAfterInitialization private {
        committeesMap[_newCommittee] = committeesArrayIndexCounter;
        committeesArray.push(_newCommittee);
        committeesArrayIndexCounter++;

        committeesNumber++;

        committeeJoinVotes[_newCommittee] = 0;
        for (uint i = 0; i < committeesArrayIndexCounter; i++) {
            if (committeesArray[i] != address(0)) {
                committeeJoinVoters[_newCommittee][committeesArray[i]] = false;
            }
        }

        AddCommitteeToMapAndArrayEvent(_newCommittee);
    }

    event KickCommitteeFromMapAndArrayEvent (address kickedCommittee);
    function kickCommitteeFromMapAndArray (address _kickedCommittee) onlyCommitteesAfterInitialization private {
        // 0x0 cannot be kicked
        require(_kickedCommittee != address(0));

        committeesArray[committeesMap[_kickedCommittee]] = address(0);
        committeesMap[_kickedCommittee] = 0;

        committeesNumber--;

        committeeKickVotes[_kickedCommittee] = 0;
        for (uint i = 0; i < committeesArrayIndexCounter; i++) {
            if (committeesArray[i] != address(0)) {
                committeeKickVoters[_kickedCommittee][committeesArray[i]] = false;
            }
        }

        KickCommitteeFromMapAndArrayEvent(_kickedCommittee);
    }

    event AddCommitteeVoteEvent (address committee, address newCommittee);
    function addCommitteeVote (address _newCommittee) onlyCommitteesAfterInitialization public returns (bool) {
        // the _newCommittee should not be in the map and array
        require(isNotCommittee(_newCommittee));
        require(committeeJoinVoters[_newCommittee][msg.sender] == false);

        committeeJoinVoters[_newCommittee][msg.sender] = true;

        if (committeeJoinVotes[_newCommittee] == 0) {
            committeeJoinVotes[_newCommittee] = 1;
        } else {
            committeeJoinVotes[_newCommittee]++;
        }

        if (committeeJoinVotes[_newCommittee] == getCommitteesNumber()) {
            addCommitteeToMapAndArray(_newCommittee);
        }

        AddCommitteeVoteEvent(msg.sender, _newCommittee);

        return true;
    }

    event KickCommitteeVoteEvent (address committee, address kickedCommittee);
    function kickCommitteeVote (address _kickedCommittee) onlyCommitteesAfterInitialization public returns (bool) {
        // the _kickedCommittee should be in the map and array
        require(isCommittee(_kickedCommittee));
        require(committeeKickVoters[_kickedCommittee][msg.sender] == false);

        committeeKickVoters[_kickedCommittee][msg.sender] = true;

        if (committeeKickVotes[_kickedCommittee] == 0) {
            committeeKickVotes[_kickedCommittee] = 1;
        } else {
            committeeKickVotes[_kickedCommittee]++;
        }

        // except for _kickedCommittee
        if (committeeKickVotes[_kickedCommittee] == getCommitteesNumber() - 1) {
            kickCommitteeFromMapAndArray(_kickedCommittee);
        }

        KickCommitteeVoteEvent(msg.sender, _kickedCommittee);

        return true;
    }

    function getCommitteesNumber () view public returns (uint256) {
        return committeesNumber;
    }

    function isCommittee (address _testAddress) view public returns (bool) {
        return committeesArray[committeesMap[_testAddress]] != address(0);
    }

    function isNotCommittee (address _testAddress) view public returns (bool) {
        return committeesArray[committeesMap[_testAddress]] == address(0);
    }

    // task type 1
    event TransferERCXTokenInitiationEvent (uint256 txNumber, address initiator, string ercVersion, address tokenContractAddress, address to, uint256 tokenValue);
    function transferERCXTokenInitiation (string _ercVersion, address _tokenContractAddress, address _to, uint256 _tokenValue) onlyCommitteesAfterInitialization public returns (bool) {
        var tmpIdentifier = tokenTransferFunctionIdentifierMap[keccak256(_ercVersion)];

        require(tmpIdentifier != bytes4(0));

        txTaskMap[txCounter] = Task({
            taskType: 1,
            receiver: _to,
            value: _tokenValue,
            tokenContractAddress: _tokenContractAddress,
            functionIdentifier: tmpIdentifier,
            acceptedCounter: 0,
            completed: false
        });

        TransferERCXTokenInitiationEvent(txCounter, msg.sender, _ercVersion, _tokenContractAddress, _to, _tokenValue);

        acceptTxTask(txCounter);

        txCounter++;

        return true;
    }

    // task type 2
    event TransferEtherInitiationEvent (uint256 txNumber, address initiator, address to, uint256 weiValue);
    function transferEtherInitiation (address _to, uint256 _weiValue) onlyCommitteesAfterInitialization public returns (bool) {
        require(_weiValue <= this.balance);

        txTaskMap[txCounter] = Task({
            taskType: 2,
            receiver: _to,
            value: _weiValue,
            tokenContractAddress: address(0),
            functionIdentifier: bytes4(0),
            acceptedCounter: 0,
            completed: false
        });

        TransferEtherInitiationEvent(txCounter, msg.sender, _to, _weiValue);

        acceptTxTask(txCounter);

        txCounter++;

        return true;
    }

    event AcceptTxTaskEvent (address committee, uint256 txNumber);
    event TaskCompletedEvent (uint256 txNumber);
    function acceptTxTask (uint256 _txNumber) onlyCommitteesAfterInitialization public returns (bool) {
        require(txTaskMap[_txNumber].taskType != 0);
        require(txTaskMap[_txNumber].completed == false);
        require(txTaskMap[_txNumber].acceptedCommitteesMap[msg.sender] == false);

        AcceptTxTaskEvent(msg.sender, _txNumber);

        txTaskMap[_txNumber].acceptedCounter++;
        txTaskMap[_txNumber].acceptedCommitteesMap[msg.sender] = true;

        var theTask = txTaskMap[_txNumber];

        if (theTask.acceptedCounter == getCommitteesNumber()) {
            if (theTask.taskType == 1) {
                txTaskMap[_txNumber].completed = true;

                if (!theTask.tokenContractAddress.call(theTask.functionIdentifier, theTask.receiver, theTask.value)) {
                    revert();
                }

                TaskCompletedEvent(_txNumber);
            }

            if (theTask.taskType == 2) {
                txTaskMap[_txNumber].completed = true;

                theTask.receiver.transfer(theTask.value);

                TaskCompletedEvent(_txNumber);
            }
        }

        return true;
    }

    // _ercVersion is like:
    // erc20
    // erc223
    function setTokenTransferIdentifier (string _ercVersion, bytes4 _functionIdentifier) onlyDeployer public returns (bool) {
        tokenTransferFunctionIdentifierMap[keccak256(_ercVersion)] = _functionIdentifier;
        return true;
    }

    function getFunctionIdentifier (string _functionRawString) pure public returns (bytes4) {
        return bytes4(keccak256(_functionRawString));
    }

    function getStringHash (string _input) pure public returns (bytes32) {
        return keccak256(_input);
    }

    modifier onlyCommitteesAfterInitialization {
        if (initialized == false) {
            _;
        } else {
            require(isCommittee(msg.sender));
            _;
        }
    }

    modifier onlyDeployer {
        require(msg.sender == deployer);
        _;
    }

    function () payable public {}

}