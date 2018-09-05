/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.17;
contract AbstractRegistration {
    //get registration contract
    function getRegistration() public view returns(string, address, string, string, uint, string, string, address[5], uint[5]);
}

contract BaseRegistration is AbstractRegistration{
    address public owner;//address copyright Owner
    string public songTitle; //title of song
    string public hash; // has of song
    string public digitalSignature; // Owner sign his work
    string public professionalName; // name of artist;
    string public duration; //duration of song
    string dateOfPublish; //format MM/dd/yyyy
    uint rtype;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function BaseRegistration() public{
        owner = msg.sender;
    }
    
    //get copyrightOwnerName
    /*****
        * @return address            The address of song owner
        */
    function getOwnerAddress() external constant returns (address){
        return owner;
    }
    
    //change owner of song registration
    /****
     * @param _owner                address                 The address of new owner
     */
    function changeOwnerAddress(address _owner) onlyOwner internal {
        require(_owner != 0x0);
        require(owner != _owner);
        owner = _owner;
    }
    
    /*****
        * @return param1                address             The address of the song owner
        * @return param2                string              The hash of song
        * @return param3                string              The digital signatures
        * @return param4                uint                The type of registration: 1 is song registration, 2 is work registration
        * @return param5                string              The name of artist
        * @return param6                address[5]          Array address of royalty partners
        * @return param7                uint[5]             Array percent of royalty partners
        */
    function getRegistration() public view returns(string, address, string, string, uint, string, string, address[5], uint[5]){}
}

contract SongRecordingRegistration is BaseRegistration{
    uint constant MAX_ROYALTY = 5;
    
    uint totalPercent = 0; //total percent of song 
    uint countRoyaltyPartner; // current number of royalty partners
    address addressDispute; // address dispute
    address addrMultiSign; //address of multi signatures
    
    /*****
        * @param percent                uint                Percent of royalty partners
        * @param confirmed              bool                royalty partners confirmed or not confirmed
        * @param exists                 bool                royalty partner already exists
        */
    struct RoyaltyPartner{
        uint percent;
        bool confirmed;
        bool exists;
    }
    
    mapping(uint => address) royaltyIndex; // index of royalty partner in array
    mapping(address => RoyaltyPartner) royaltyPartners;
    
    //contructor MusicRegistration and upto 5 Royalty partners
    /*****
        * @param _hash                      string              The hash of song
        * @param _digital                   string              The digital signatures
        * @param _addrDispute               address             The address dispute
        * @param _dateOfPublish             string              Date publish song registration
        * @param _addrMultiSign             address             The address of multi signatures
        * @param _professionalName          string              The name of artist
        * @param _arrRoyaltyPercent         uint                Array of royalty partners percent
        * @param _arrRoyaltyAddress         address             Array of royalty partners address
        */
    function  SongRecordingRegistration(
        string _songTitle,
        string _hash,
        string _digital,
        address _addrDispute,
        string _dateOfPublish,
        address _addrMultiSign,
        string _professionalName,
        string _duration,
        uint[] _arrRoyaltyPercent,
        address[] _arrRoyaltyAddress) public{
        songTitle = _songTitle;
        hash = _hash;
        rtype = 1;
        digitalSignature = _digital;
        dateOfPublish = _dateOfPublish;
        addrMultiSign = _addrMultiSign;
        professionalName = _professionalName;
        duration = _duration;
        checkingDispute(_addrDispute, address(this));
        assert(_arrRoyaltyAddress.length == _arrRoyaltyPercent.length);
        assert(_arrRoyaltyPercent.length <= uint(MAX_ROYALTY));
        for (uint i = 0; i < _arrRoyaltyAddress.length; i++){
            require(_arrRoyaltyAddress[i] != owner);
            require(totalPercent <= 100);
            royaltyIndex[i] = _arrRoyaltyAddress[i];
            royaltyPartners[_arrRoyaltyAddress[i]] = RoyaltyPartner(_arrRoyaltyPercent[i], false, true);
            totalPercent += _arrRoyaltyPercent[i];
            countRoyaltyPartner++;
        }
    }
    
    // get song registration
    /*****
        * @return param1                address             The address of the song owner
        * @return param2                string              The hash of song
        * @return param3                string              The digital signatures
        * @return param4                uint                The type of registration: 1 is song registration, 2 is work registration
        * @return param5                string              The name of artist
        * @return param6                address[5]          Array address of royalty partners
        * @return param7                uint[5]             Array percent of royalty partners
        */
    function getRegistration() public view returns(string _songTitle, address _owner, string _hash, string _digital, uint _type, string _professionalName, string _duration, address[5] _arrRoyaltyAddress, uint[5] _arrRoyaltyPercent){
        _owner = owner;
        _songTitle = songTitle;
        _hash = hash;
        _digital = digitalSignature;
        _type = rtype;
        _duration = duration;
        _professionalName = professionalName;
        for (uint i=0; i<5; i++){
            _arrRoyaltyAddress[i] = royaltyIndex[i];
            _arrRoyaltyPercent[i] = royaltyPartners[_arrRoyaltyAddress[i]].percent;
        }
        return (_songTitle, _owner, _hash, _digital, _type, _professionalName, _duration, _arrRoyaltyAddress, _arrRoyaltyPercent);
    }
    
    //get percent of royalty partner
    /*****
     *@param _toRoyaltyPartner              address         The address of royalty partners 
     *@return param1                        uint            Percent of royalty partners
     */
    function getRoyaltyPercent(address _toRoyaltyPartner) public constant returns(uint) {
        return royaltyPartners[_toRoyaltyPartner].percent;
    }
    
    //check royalty partner exists
    /*****
     *@param _toRoyaltyPartner              address         The address of royalty partners 
     *@return param1                        bool            Royalty partners exists
     */
    function getRoyaltyExists(address _toRoyaltyPartner) public constant returns(bool){
        return royaltyPartners[_toRoyaltyPartner].exists;
    }
    
    //get total percent of song
    /*****
     *@return param1                        uint            Total percent of royalty partners
     */
    function getTotalPercent() external constant returns(uint){
        return totalPercent;
    }
    
    // get royalty partner
    /***** 
     *@return param1                        address[5]              Array of royalty partners address
     *@return param2                        uint[5]                 Array of royalty partner percent
     */
    function getRoyaltyPartners() public constant returns(address[5] _arrRoyaltyAddress, uint[5] _arrRoyaltyPercent){
        for (uint i = 0; i < MAX_ROYALTY; i++){
            _arrRoyaltyAddress[i] = royaltyIndex[i];
            _arrRoyaltyPercent[i] = royaltyPartners[royaltyIndex[i]].percent;
        }
        return (_arrRoyaltyAddress, _arrRoyaltyPercent);
    }
    
    //change percent of royalty partners
    /*****
     *@param _toRoyaltyPartner              address         The address of royalty partners
     *@param _percent                       uint            The new percent of royalty partners
     *@param _exists                        bool            Set royalty partners exists
     */
    function changeRoyaltyPercent(
        address _toRoyaltyPartner, 
        uint _percent,
        bool _exists) public{
        require(msg.sender == addrMultiSign); // check sender call from address of multi sign
        if(!_exists){
            royaltyPartners[_toRoyaltyPartner] = RoyaltyPartner(_percent, false, true);
            royaltyIndex[countRoyaltyPartner] = _toRoyaltyPartner;
            totalPercent += _percent;
            countRoyaltyPartner++;
        }else{
            totalPercent = totalPercent - getRoyaltyPercent(_toRoyaltyPartner) + _percent;
            royaltyPartners[_toRoyaltyPartner].percent = _percent;
        }
    }
    
    //checking dispute if exists
    /*****
     *@param _addrDispute               address             The address of dispute
     *@param _addrCurrent               address             The address of current
     */
    function checkingDispute(address _addrDispute, address _addrCurrent) public {
        if(_addrDispute != address(0)){
            addressDispute = _addrDispute;
            SongRecordingRegistration musicReg = SongRecordingRegistration(_addrDispute);
            assert(musicReg.getDispute() == address(0));
            musicReg.setDispute(_addrCurrent);
        }
    }
    
    //set dispute of contract address
    /*****
     *@param _addrDispute              address         The address of dispute
     */
    function setDispute(address _addrDispute) public{
        addressDispute = _addrDispute;
    }
    
    //get dispute of contract address
    /***** 
     *@return param1                    address            Address of dispute
     */
    function getDispute() public constant returns(address){
        return addressDispute;
    }
}

contract WorkRegistration is BaseRegistration{
    bool isTempRegistration = false; // work release
    
    /*****
     *@param _hash                      string              The hash of work registration
     *@param _digital                   string              The digital of signatures
     *@param _dateOfPublish             string              Date publish work registration
     *@param _isTempRegistration        bool                Work registration release or not
     */
    function WorkRegistration(
        string _songTitle,
        string _hash,
        string _digital,
        string _dateOfPublish,
        bool _isTempRegistration) public{
        songTitle = _songTitle;
        hash = _hash;
        rtype = 2;
        digitalSignature = _digital;
        isTempRegistration = _isTempRegistration;
        dateOfPublish = _dateOfPublish;
    }
    
    //get work registration
    /*****
        * @return param1                address             The address of the song owner
        * @return param2                string              The hash of song
        * @return param3                string              The digital signatures
        * @return param4                uint                The type of registration: 1 is song registration, 2 is work registration
        * @return param5                address[5]          Array address of royalty partners
        * @return param6                uint[5]             Array percent of royalty partners
        */
    function getRegistration() public view returns(string _songTitle, address _owner, string _hash, string _digital, uint _type, string _professionalName, string, address[5], uint[5]){
        _owner = owner;
        _songTitle = songTitle;
        _hash = hash;
        _digital = digitalSignature;
        _type = rtype;
        _professionalName = "";
    }
    
    //get composer
    /*****
     *@return _hash                     string              The hash of work registration
     *@return _digital                  string              The digital of signatures
     *@return _isTempRegistration       bool                Work registration release or not
     */
    function getComposer() external constant returns(
        string _hash,
        string _digital,
        bool _isTempRegistration){
        _hash = hash;
        _digital = digitalSignature;
        _isTempRegistration = isTempRegistration;
    }
    
    //set temp registration
    /*****
     *@param _isTempRegistration            bool            Work registration release or not
     */
    function setTempRegistration(bool _isTempRegistration) onlyOwner public{
        isTempRegistration = _isTempRegistration;
    }
}

contract Licensing {
    //3 kind of licens status
    enum licensedState { Pending, Expired , Licensed }
    
    // Default Expired date will be 30 days
    //unit is second
    uint constant ExpiryTime = 30*24*60*60; 
    
    address  token; // address of buyer
    address  buyAddress; // address of buyer
    address  songAddress; // song contract address
    string  territority;
    string  right; // kind of right license
    uint  period; // time of license. Unit is months
    uint256 dateIssue; // start time will be the time we create contract.
    bool  isCompleted; // licensing completed or not
    uint price; // price of licensing
    string hashOfLicense; //hash of licensing
    
    modifier onlyOwner() {
        require(msg.sender == buyAddress);
        _;
    }
    
    modifier onlyOwnerOfSong(){
        SongRecordingRegistration musicContract = SongRecordingRegistration(songAddress);
        require(msg.sender == musicContract.getOwnerAddress());
        _;
    }
    
    /*****
     *@param _token                         address                 The address of token
     *@param addressOfSong                  address                 The address of song
     *@param territorityOfLicense           string                  The territority of license
     *@param rightOfLicense                 string                  The right of license
     *@param periodOfLicense                uint                    The period of license
     */
    function Licensing(
        address _token,
        address addressOfSong, 
        string territorityOfLicense, 
        string rightOfLicense, 
        uint periodOfLicense,
        string _hashOfLicense) public{
        buyAddress = msg.sender;
        songAddress = addressOfSong;
        territority = territorityOfLicense;
        right = rightOfLicense;
        period = periodOfLicense;
        hashOfLicense = _hashOfLicense;
        isCompleted = false;
        dateIssue = block.timestamp;
        token = _token;
    }

    //get status of license - this is private function
    /*****
        * @return param1                licensedState             The state of license
        */
    function getStatus() constant private returns (licensedState){
        if(isCompleted == true){
            return licensedState.Licensed;
        }else {
            if(block.timestamp >  (dateIssue + ExpiryTime)){
                return licensedState.Expired;
            }else{
                return licensedState.Pending;
            }
        }
    }
    
    //get current license status, before
    /*****
        * @return param1                string             The state string of license
        */
    function getContractStatus() constant public returns (string){
        licensedState currentState = getStatus();
        if(currentState == licensedState.Pending){
            return "Pending";
        }else if(currentState == licensedState.Expired){
            return "Expired";
        }else {
            return "Licensed";
        }
    }
    
    //Copyright Owner will update price of license when someone issue it,
    // it must be completed in 30 days from issue date
    /*****
     *@param priceOfLicense             uint                The new price of license 
     */
    function updatePrice(uint priceOfLicense) onlyOwnerOfSong public{
        
        //find song with address
        assert(!isCompleted);
        //validate song address by checking publishPerson
        assert (priceOfLicense > 0);
        assert (block.timestamp <  (dateIssue + ExpiryTime));
        
        //update license price
        price = priceOfLicense;
    }
    
    //get current contract address
    /*****
        * @return param1                address             The address of the contract
        */
    function getContractAddress() external constant returns (address){
        return this;
    }
    
    //get owner of address
    /*****
        * @return param1                address             The address of the owner
        */
    function getOwnerAddress() external constant returns(address){
        return(buyAddress);
    }
    
    //set update completed
    /*****
     *@param _isCompleted               bool                Set state of license to completed
     */
    function upgradeCompleted(bool _isCompleted) public{
        require(_isCompleted);
        require(price >0);
        require(msg.sender == token);
        isCompleted = _isCompleted;
    }
    
    //check price of license
    /*****
     *@param _price                 uint256                 The price want to check 
     *@return param1                bool                    return true if _price > price of license
     */
    function checkPrice(uint256 _price) public constant returns(bool){
        require(msg.sender == token);
        return (_price >= price) ? true : false;
    }
}