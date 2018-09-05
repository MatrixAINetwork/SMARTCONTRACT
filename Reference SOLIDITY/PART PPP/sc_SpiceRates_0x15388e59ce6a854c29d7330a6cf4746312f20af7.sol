/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.2;

contract SpiceMembers {
    enum MemberLevel { None, Member, Manager, Director }
    struct Member {
        uint id;
        MemberLevel level;
        bytes32 info;
    }

    mapping (address => Member) member;

    address public owner;
    mapping (uint => address) public memberAddress;
    uint public memberCount;

    event TransferOwnership(address indexed sender, address indexed owner);
    event AddMember(address indexed sender, address indexed member);
    event RemoveMember(address indexed sender, address indexed member);
    event SetMemberLevel(address indexed sender, address indexed member, MemberLevel level);
    event SetMemberInfo(address indexed sender, address indexed member, bytes32 info);

    function SpiceMembers() {
        owner = msg.sender;

        memberCount = 1;
        memberAddress[memberCount] = owner;
        member[owner] = Member(memberCount, MemberLevel.None, 0);
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    modifier onlyManager {
        if (msg.sender != owner && memberLevel(msg.sender) < MemberLevel.Manager) throw;
        _;
    }

    function transferOwnership(address _target) onlyOwner {
        // If new owner has no memberId, create one
        if (member[_target].id == 0) {
            memberCount++;
            memberAddress[memberCount] = _target;
            member[_target] = Member(memberCount, MemberLevel.None, 0);
        }
        owner = _target;
        TransferOwnership(msg.sender, owner);
    }

    function addMember(address _target) onlyManager {
        // Make sure trying to add an existing member throws an error
        if (memberLevel(_target) != MemberLevel.None) throw;

        // If added member has no memberId, create one
        if (member[_target].id == 0) {
            memberCount++;
            memberAddress[memberCount] = _target;
            member[_target] = Member(memberCount, MemberLevel.None, 0);
        }

        // Set memberLevel to initial value with basic access
        member[_target].level = MemberLevel.Member;
        AddMember(msg.sender, _target);
    }

    function removeMember(address _target) {
        // Make sure trying to remove a non-existing member throws an error
        if (memberLevel(_target) == MemberLevel.None) throw;
        // Make sure members are only allowed to delete members lower than their level
        if (msg.sender != owner && memberLevel(msg.sender) <= memberLevel(_target)) throw;

        member[_target].level = MemberLevel.None;
        RemoveMember(msg.sender, _target);
    }

    function setMemberLevel(address _target, MemberLevel level) {
        // Make sure all levels are larger than None but not higher than Director
        if (level == MemberLevel.None || level > MemberLevel.Director) throw;
        // Make sure the _target is currently already a member
        if (memberLevel(_target) == MemberLevel.None) throw;
        // Make sure the new level is lower level than we are (we cannot overpromote)
        if (msg.sender != owner && memberLevel(msg.sender) <= level) throw;
        // Make sure the member is currently on lower level than we are
        if (msg.sender != owner && memberLevel(msg.sender) <= memberLevel(_target)) throw;

        member[_target].level = level;
        SetMemberLevel(msg.sender, _target, level);
    }

    function setMemberInfo(address _target, bytes32 info) {
        // Make sure the target is currently already a member
        if (memberLevel(_target) == MemberLevel.None) throw;
        // Make sure the member is currently on lower level than we are
        if (msg.sender != owner && msg.sender != _target && memberLevel(msg.sender) <= memberLevel(_target)) throw;

        member[_target].info = info;
        SetMemberInfo(msg.sender, _target, info);
    }

    function memberId(address _target) constant returns (uint) {
        return member[_target].id;
    }

    function memberLevel(address _target) constant returns (MemberLevel) {
        return member[_target].level;
    }

    function memberInfo(address _target) constant returns (bytes32) {
        return member[_target].info;
    }
}

contract SpiceControlled {
    SpiceMembers members;

    modifier onlyOwner {
        if (!hasOwnerAccess(msg.sender)) throw;
        _;
    }

    modifier onlyDirector {
        if (!hasDirectorAccess(msg.sender)) throw;
        _;
    }

    modifier onlyManager {
        if (!hasManagerAccess(msg.sender)) throw;
        _;
    }

    modifier onlyMember {
        if (!hasMemberAccess(msg.sender)) throw;
        _;
    }

    function SpiceControlled(address membersAddress) {
        members = SpiceMembers(membersAddress);
    }

    function hasOwnerAccess(address _target) internal returns (bool) {
        return (_target == members.owner());
    }

    function hasDirectorAccess(address _target) internal returns (bool) {
        return (members.memberLevel(_target) >= SpiceMembers.MemberLevel.Director || hasOwnerAccess(_target));
    }

    function hasManagerAccess(address _target) internal returns (bool) {
        return (members.memberLevel(_target) >= SpiceMembers.MemberLevel.Manager || hasOwnerAccess(_target));
    }

    function hasMemberAccess(address _target) internal returns (bool) {
        return (members.memberLevel(_target) >= SpiceMembers.MemberLevel.Member || hasOwnerAccess(_target));
    }
}

contract IPayoutCalculator {
    function calculatePayout(bytes32 _info, uint _duration) returns (uint);
}

contract SpiceRates is SpiceControlled, IPayoutCalculator {
    struct RatesEntry {
        bool available;
        uint8 unpaidPercentage;
    }

    uint public hourlyRate;
    mapping(bytes32 => RatesEntry) entries;
    bytes32[] infos;

    event SetHourlyRate(uint hourlyRate);
    event SetUnpaidPercentage(bytes32 indexed info, uint8 unpaidPercentage);
    event CalculatePayout(bytes32 indexed info, uint duration, uint hourlyRate, uint8 unpaidPercentage);

    function SpiceRates(
        address _members,
        uint _hourlyRate
    ) SpiceControlled(_members) {
        hourlyRate = _hourlyRate;
        SetHourlyRate(hourlyRate);
    }

    function setHourlyRate(uint _hourlyRate) onlyDirector {
        hourlyRate = _hourlyRate;
    }

    function setUnpaidPercentage(bytes32 _info, uint8 _percentage) onlyManager {
        if (_percentage > 100) throw;
        if (_info == 0) throw;

        RatesEntry entry = entries[_info];
        if (!entry.available) {
            entry.available = true;
            infos.push(_info);
        }
        entry.unpaidPercentage = _percentage;
        SetUnpaidPercentage(_info, _percentage);
    }

    function unpaidPercentage(bytes32 _info) constant returns (uint8) {
        return entries[_info].unpaidPercentage;
    }

    function entryInfo(uint _index) constant returns (bytes32) {
        return infos[_index];
    }

    function entryCount() constant returns (uint) {
        return infos.length;
    }

    // This is the main function implementing IPayoutCalculator
    function calculatePayout(bytes32 _info, uint _duration) returns (uint) {
        uint8 unpaid = unpaidPercentage(_info);
        CalculatePayout(_info, _duration, hourlyRate, unpaid);

        uint fullTimeOutput = _duration * hourlyRate / 3600;
        return (fullTimeOutput * (100 - unpaid)) / 100;
    }
}