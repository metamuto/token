// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// contract BridgesOfFate is Ownable, ReentrancyGuard {
//     IERC20 private token;
//     uint256 private latestGameId = 1;
//     uint256 public lastUpdateTimeStamp;

//     uint256 private constant STAGES = 13; // 13 stages
//     uint256 private constant TURN_PERIOD = 86400; //86400; // 24 HOURS
//     uint256 private constant THERSHOLD = 5; 
//     uint256 private constant SERIES_TWO_FEE = 0.01 ether;
//     uint256 private constant _winnerRewarsdsPercent = 60;
//     uint256 private constant _ownerRewarsdsPercent = 25;
//     uint256 private constant _communityVaultRewarsdsPercent = 15;
//     bytes32[] private gameWinners;
//     bytes32[] private participatePlayerList;


//     // 0 =========>>>>>>>>> Owner Address
//     // 1 =========>>>>>>>>> community vault Address
//     address[2] private communityOwnerWA = [
//         0xBE0c66A87e5450f02741E4320c290b774339cE1C,
//         0x1eF17faED13F042E103BE34caa546107d390093F
//     ];

//     uint256[11] public buyBackCurve = [
//         0.005 ether,
//         0.01 ether,
//         0.02 ether,
//         0.04 ether,
//         0.08 ether,
//         0.15 ether,
//         0.3 ether,
//         0.6 ether,
//         1.25 ether,
//         2.5 ether,
//         5 ether
//     ];

//     struct GameStatus {
//         //Game Start Time
//         uint256 startAt;
//         //To Handle Latest Stage
//         uint256 stageNumber;
//         //Last Update Number
//         uint256 lastUpdationDay;
//     }

//     struct GameItem {
//         uint256 day;
//         uint256 nftId;
//         uint256 stage;
//         uint256 startAt;
//         uint256 lastJumpTime;
//         bool lastJumpSide;
//         bool feeStatus;
//         address userWalletAddress;
//     }
    
//     mapping(uint256 => uint256) private GameMap;
//     mapping(bytes32 => uint256) private winnerbalances;
//     mapping(address => uint256) private ownerbalances;
//     mapping(address => uint256) private vaultbalances;
//     mapping(uint256 => bytes32[]) private allStagesData;

//     mapping(bytes32 => GameItem) public PlayerItem;
//     mapping(uint256 => GameStatus) public GameStatusInitialized;
    
//     event Initialized(uint256 currentGameID, uint256 startAt);
//     event ParticipateOfPlayerInGame(bytes32 playerId, uint256 _randomNo);
//     event ParticipateOfPlayerInBuyBackIn(bytes32 playerId, uint256 amount);
//     event EntryFee(bytes32 playerId,uint256 nftId,uint256 nftSeries,uint256 feeAmount);
//     event ParticipateOfNewPlayerInLateBuyBackIn(bytes32 playerId,uint256 moveAtStage,uint256 amount);

//     constructor(IERC20 _wrappedEther) {
//         token = _wrappedEther;
//     }
    
//     modifier GameEndRules() {
//         GameStatus storage _gameStatus = GameStatusInitialized[latestGameId];
//         require(block.timestamp >= _gameStatus.startAt,"Game start after intialized time.");
//         require(_dayDifferance(block.timestamp, lastUpdateTimeStamp) <= 2,"Game Ended !");
//         require(_dayDifferance(block.timestamp, _gameStatus.startAt) <= (STAGES + THERSHOLD) - 1, "Game Achived thershold!");
//         _;
//     }

//     function _dayDifferance(uint256 timeStampTo, uint256 timeStampFrom) internal pure returns (uint256)
//     {
//         return (timeStampTo - timeStampFrom) / TURN_PERIOD;
//     }

//     function initializeGame(uint256 _startAT) external onlyOwner {
//         GameStatus storage _gameStatus = GameStatusInitialized[latestGameId];
//         require(_gameStatus.startAt == 0, "Game Already Initilaized"); 
//         require(_startAT >= block.timestamp,"Time must be greater then current time.");
//         _gameStatus.startAt = _startAT;
//         lastUpdateTimeStamp = _startAT;
//         emit Initialized(latestGameId, block.timestamp);
//     }

//     function allParticipatePlayerID() external view returns(bytes32[] memory) {
//         return participatePlayerList;
//     }

//     function _updatePlayer(bytes32 _playerId) internal {
//         GameItem memory _member = PlayerItem[_playerId];
//         _member.day = 0;    
//         _member.stage = 0;
//         _member.startAt = 0;
//         _member.lastJumpTime = 0;
//         _member.lastJumpSide = false;
//         PlayerItem[_playerId] = _member;
//     }

//     function _deletePlayerIDForSpecifyStage(uint256 _stage, bytes32 _playerId) internal {
//         for (uint i = 0; i < allStagesData[_stage].length; i++) {
//             if(allStagesData[_stage][i] == _playerId){
//                 delete allStagesData[_stage][i];
//             }
//         }
//     }

//     function getStagesData(uint256 _stage) public view  returns (bytes32[] memory) {
//         return allStagesData[_stage];
//     }

//     function computeNextPlayerIdForHolder(address holder,uint256 _nftId,uint8 _seriesIndex) public pure returns (bytes32) {
//         return _computePlayerIdForAddressAndIndex(holder, _nftId, _seriesIndex);
//     }

//     function _computePlayerIdForAddressAndIndex(address holder,uint256 _nftId,uint8 _seriesIndex) internal pure returns (bytes32) {
//         return keccak256(abi.encodePacked(holder, _nftId, _seriesIndex));
//     }

//     function changeCommunityOwnerWA(address[2] calldata _communityOwnerWA) external onlyOwner {
//         for (uint i = 0; i < _communityOwnerWA.length; i++) {
//             communityOwnerWA[i] = _communityOwnerWA[i];
//         }
//     }

//     function _checkSide(uint256 stageNumber, bool userSide) internal view returns (bool)
//     {
//         uint256 stage_randomNumber = GameMap[stageNumber]; 
//         if ((userSide == true && stage_randomNumber >= 50e9) || (userSide == false && stage_randomNumber < 50e9)
//         ) {
//             return true;
//         } else {
//             return false;
//         }
//     }

//     function isExist(bytes32 _playerID) public view returns(bool){
//         for (uint i = 0; i < participatePlayerList.length; i++) {
//             if(participatePlayerList[i] == _playerID){
//                 return false;
//             }
//         }     
//         return true;
//     }

//     function entryFeeForSeriesOne(uint256 _nftId) public GameEndRules
//     {
//         bytes32 playerId = computeNextPlayerIdForHolder(msg.sender, _nftId, 1);
//         if(isExist(playerId)){
//             participatePlayerList.push(playerId);    
//         }
//         GameItem memory _member = PlayerItem[playerId];
//         if (_member.userWalletAddress != address(0)) {
//             GameStatus storage _admin = GameStatusInitialized[latestGameId];
//             require(_dayDifferance(block.timestamp, _admin.startAt) > _member.day, "Alreday In Game");
//             require(_checkSide(_member.stage, _member.lastJumpSide) == false, "Already In Game");
//             require(_dayDifferance(_member.lastJumpTime,_admin.startAt) + 1 < _dayDifferance(block.timestamp, _admin.startAt),"You Can only use Buy back in 24 hours");
//             _updatePlayer(playerId);
//         }
//         _member.nftId = _nftId;
//         _member.feeStatus = true;
//         _member.userWalletAddress = msg.sender;
//         PlayerItem[playerId] = _member;
//         allStagesData[_member.stage].push(playerId);
//         lastUpdateTimeStamp = block.timestamp;
//         emit EntryFee(playerId, _nftId, 1, 0);
//     }

//     function bulkEntryFeeForSeriesOne(uint256[] calldata _nftId) external {
//         for (uint256 i = 0; i < _nftId.length; i++) {
//             entryFeeForSeriesOne(_nftId[i]);
//         }
//     }

//     function _balanceOfUser(address _accountOf) internal view returns (uint256) {
//         return token.balanceOf(_accountOf);
//     }

//     function entryFeeSeriesTwo(uint256 _nftId) public GameEndRules
//     {
//         bytes32 playerId = computeNextPlayerIdForHolder(msg.sender, _nftId, 2);
//           if(isExist(playerId)){
//             participatePlayerList.push(playerId);    
//         }
//         GameItem memory _member = PlayerItem[playerId];

//         if (_member.userWalletAddress != address(0)) {
//             GameStatus storage _admin = GameStatusInitialized[latestGameId];
//             require(_dayDifferance(block.timestamp, _admin.startAt) > _member.day, "Alreday In Game");
//             require(_checkSide(_member.stage, _member.lastJumpSide) == false, "Already In Game");
//             require(_dayDifferance(_member.lastJumpTime,_admin.startAt) + 1 < _dayDifferance(block.timestamp, _admin.startAt),"You Can only use Buy back in 24 hours");
//             _updatePlayer(playerId);
//         } 
//         _member.feeStatus = true;
//         _member.nftId = _nftId;
//         _member.userWalletAddress = msg.sender;
//         _transferAmount(SERIES_TWO_FEE);
//         PlayerItem[playerId] = _member;
//         allStagesData[_member.stage].push(playerId);
//         lastUpdateTimeStamp = block.timestamp;
//         emit EntryFee(playerId, _nftId, 2, SERIES_TWO_FEE);
//     }


//     function bulkEntryFeeSeriesTwo(uint256[] calldata _nftId) external {
//         for (uint256 i = 0; i < _nftId.length; i++) {
//             entryFeeSeriesTwo(_nftId[i]);
//         }
//     }


//     function buyBackInFee(bytes32 playerId) public GameEndRules
//     {
//         uint256 buyBackFee = calculateBuyBackIn();
//         require(_balanceOfUser(msg.sender) >= buyBackFee,"You have insufficent balance");
//         GameItem memory _member = PlayerItem[playerId];
//         require((_member.userWalletAddress != address(0)) && (_member.userWalletAddress == msg.sender),"Only Player Trigger");
//         require(_dayDifferance(block.timestamp, _member.lastJumpTime) <= 1,"Buy Back can be used in 24 hours only");
//         require(_checkSide(_member.stage, _member.lastJumpSide) == false, "Already In Game");
//         token.transferFrom(msg.sender, address(this), buyBackFee);
//         if (GameMap[_member.stage - 1] >= 50e9) {
//             _member.lastJumpSide = true;
//         }
//         if (GameMap[_member.stage - 1] < 50e9) {
//             _member.lastJumpSide = false;
//         }
//         _member.stage = _member.stage - 1;
//         _member.day = 0;
//         _member.feeStatus = true;
//         _member.lastJumpTime = block.timestamp;
//         PlayerItem[playerId] = _member;
//         allStagesData[_member.stage].push(playerId);
//         _deletePlayerIDForSpecifyStage(_member.stage + 1,playerId);
//         emit ParticipateOfPlayerInBuyBackIn(playerId, buyBackFee);
//     }

//     function _random() internal view returns (uint256) {
//         return uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,msg.sender))) % 100;
//     }
    
//     function bulkParticipateInGame(bool _jumpSides, bytes32[] memory playerIds) external   GameEndRules {
//         for (uint256 i = 0; i < playerIds.length; i++) {
//             require(PlayerItem[playerIds[0]].stage == PlayerItem[playerIds[i]].stage, "Same Stage Players jump");
//             participateInGame(_jumpSides,playerIds[i]);
//         }
//     }

//     function switchSide(bool _jumpSide, bytes32 playerId) public  GameEndRules{
//         GameItem memory _member = PlayerItem[playerId];
//         require(_dayDifferance(block.timestamp,GameStatusInitialized[latestGameId].startAt) == _member.day, "Only Jump in this Slot");
//         require(_member.lastJumpSide != _jumpSide, "Opposite side jump would be possible");
//         require(_member.feeStatus == true, "Please Pay Entry Fee.");
//         require(_member.userWalletAddress == msg.sender,"Only Player Trigger");
//         require(_member.stage != STAGES, "Reached maximum");
//         _member.lastJumpSide = _jumpSide;
//         PlayerItem[playerId] = _member;
//         lastUpdateTimeStamp = block.timestamp;
//     }

//     function participateInGame(bool _jumpSide, bytes32 playerId) public  GameEndRules
//     {
//         GameItem memory _member = PlayerItem[playerId];
//         GameStatus memory  _gameStatus = GameStatusInitialized[latestGameId];
//         uint256 currentDay = _dayDifferance(block.timestamp,_gameStatus.startAt);
//         require(_member.userWalletAddress == msg.sender,"Only Player Trigger");
//         require(_member.feeStatus == true, "Please Pay Entry Fee.");
//         if (_member.startAt == 0 && _member.lastJumpTime == 0) {
//             //On First Day when current day & member day = 0
//             require(currentDay >= _member.day, "Already Jump Once In Slot");
//         } else {
//             //for other conditions
//             require(currentDay > _member.day, "Already Jump Once In Slot");
//         }
//         if (_member.stage != 0) {
//             require((_member.lastJumpSide == true && GameMap[_member.stage] >= 50e9) || (_member.lastJumpSide == false && GameMap[_member.stage] < 50e9), "You are Failed" );
//         }
//         if((_gameStatus.stageNumber == STAGES) && (_dayDifferance(block.timestamp,_gameStatus.startAt) > _gameStatus.lastUpdationDay)){
//             revert("Game Reached maximum && End.");
//         }
//         require(_member.stage != STAGES, "Reached maximum");
//         if (GameMap[_member.stage + 1] <= 0) {
//             GameMap[_gameStatus.stageNumber + 1] = _random() * 1e9;
//             _gameStatus.stageNumber = _gameStatus.stageNumber + 1;
//             _gameStatus.lastUpdationDay = currentDay;
//         }

//         allStagesData[_member.stage + 1].push(playerId);
//         _deletePlayerIDForSpecifyStage(_member.stage,playerId);
//         _member.startAt = block.timestamp;
//         _member.stage = _member.stage + 1;
//         _member.day = currentDay;
//         _member.lastJumpSide = _jumpSide;
//         _member.lastJumpTime = block.timestamp;
//         PlayerItem[playerId] = _member;
//         GameStatusInitialized[latestGameId] = _gameStatus;
//         lastUpdateTimeStamp = block.timestamp;
//         //Push winner into the Array list 
//         if(_checkSide(GameMap[_gameStatus.stageNumber],_jumpSide) && (_member.stage  == STAGES)){
//             gameWinners.push(playerId);
//         }
//         emit ParticipateOfPlayerInGame(playerId,GameMap[_gameStatus.stageNumber + 1]);
//     }

//     function getAll() external view returns (uint256[] memory) {
//         GameStatus storage _gameStatus = GameStatusInitialized[latestGameId];
//         uint256[] memory ret;
//         uint256 _stageNumber;
//         if (_gameStatus.stageNumber > 0) {
//             if (_dayDifferance(block.timestamp, _gameStatus.startAt) > _gameStatus.lastUpdationDay) {
//                 _stageNumber = _gameStatus.stageNumber;
//             } else {
//                 _stageNumber = _gameStatus.stageNumber - 1;
//             }

//             ret = new uint256[](_stageNumber);
//             for (uint256 i = 0; i < _stageNumber; i++) {
//                 ret[i] = GameMap[i + 1];
//             }
//         }
//         return ret;
//     }

//     function calculateBuyBackIn() public view returns (uint256) {
//         if (GameStatusInitialized[latestGameId].stageNumber > 0) {
//             if (GameStatusInitialized[latestGameId].stageNumber <= buyBackCurve.length) {
//                 return buyBackCurve[GameStatusInitialized[latestGameId].stageNumber - 1];
//             }
//         }
//         return 0;
//     }

//     function LateBuyInFee(uint256 _nftId, uint8 seriesType) public GameEndRules
//     {
//         require(seriesType == 1 || seriesType == 2, "Invalid seriseType");
//         bytes32 playerId = computeNextPlayerIdForHolder(msg.sender,_nftId,seriesType);
//         if(isExist(playerId)){
//             participatePlayerList.push(playerId);    
//         }
//         uint256 buyBackFee = calculateBuyBackIn();
//         uint256 totalAmount;
//         if (seriesType == 1) {
//             totalAmount = buyBackFee;
//         }
//         if (seriesType == 2) {
//             totalAmount = buyBackFee + SERIES_TWO_FEE;
//         }
//         _transferAmount(totalAmount);
//         GameStatus storage _gameStatus = GameStatusInitialized[latestGameId];
//         GameItem memory _member = PlayerItem[playerId];
//         _member.userWalletAddress = msg.sender;
//         _member.startAt = block.timestamp;
//         _member.stage = _gameStatus.stageNumber - 1;
//         _member.day = 0;
//         if (GameMap[_gameStatus.stageNumber - 1] >= 50e9) {
//             _member.lastJumpSide = true;
//         }
//         if (GameMap[_gameStatus.stageNumber - 1] < 50e9) {
//             _member.lastJumpSide = false;
//         }
//         _member.feeStatus = true;
//         _member.lastJumpTime = block.timestamp;
//         PlayerItem[playerId] = _member;
//         lastUpdateTimeStamp = block.timestamp;
//         allStagesData[_member.stage].push(playerId);
//         emit ParticipateOfNewPlayerInLateBuyBackIn(playerId,_gameStatus.stageNumber - 1,totalAmount);
//     }

//     function bulkLateBuyInFee(uint256[] calldata _nftId,uint8[] calldata seriesType) external {
//         for (uint256 i = 0; i < _nftId.length; i++) {
//             LateBuyInFee(_nftId[i], seriesType[i]);
//         }
//     }

//     function _transferAmount(uint256 _amount) internal {
//         require(_balanceOfUser(msg.sender) >= _amount,"You have insufficent balance");
//         token.transferFrom(msg.sender, address(this), _amount);
//     }

//     function treasuryBalance() public view returns (uint256) {
//         return _balanceOfUser(address(this));
//     }

//     function calculateReward() public onlyOwner  {
//         uint256 _treasuryBalance = treasuryBalance();
//         // 60 % reward goes to winnner.
//         require(_treasuryBalance > 0 ,"Insufficient Balance");
//         require(GameStatusInitialized[latestGameId].stageNumber == STAGES,"It's not time to Distribution");
//         // 25% to owner wallet
//         ownerbalances[communityOwnerWA[0]] = (_ownerRewarsdsPercent * _treasuryBalance) / 100;
//         // 15% goes to community vault
//         vaultbalances[communityOwnerWA[1]] = (_communityVaultRewarsdsPercent * _treasuryBalance) / 100;
//         if(gameWinners.length > 0){
//             uint256 _winners = (((_winnerRewarsdsPercent * _treasuryBalance)) / 100) / (gameWinners.length);
//             for (uint256 i = 0; i < gameWinners.length; i++) {
//                 winnerbalances[gameWinners[i]] = _winners;
//             }
//         }
        
//     }

//     function _withdraw(uint256 withdrawAmount) internal {
//         token.transfer(msg.sender, withdrawAmount);
//     }

//     function withdrawWrappedEtherOFCommunity(uint8 withdrawtype) public nonReentrant 
//     {
//         // Check enough balance available, otherwise just return false
//         if (withdrawtype == 0) {
//             //owner
//             require(ownerbalances[communityOwnerWA[0]] > 0,"Insufficient Owner Balance");
//             require(communityOwnerWA[0] == msg.sender, "Only Owner use this");
//             _withdraw(ownerbalances[msg.sender]);
//         } else if (withdrawtype == 1) {
//             //vault
//             require(vaultbalances[communityOwnerWA[1]] > 0,"Insufficient Vault Balance");
//             require(communityOwnerWA[1] == msg.sender, "Only vault use this");
//             _withdraw(vaultbalances[msg.sender]);
//         } 
//     }

//     function claimWinnerEther(bytes32 playerId) external nonReentrant {
//         require(winnerbalances[playerId] > 0,"Insufficient Plyer Balance");
//         require(PlayerItem[playerId].userWalletAddress == msg.sender,"Only Player Trigger");
//         _withdraw(winnerbalances[playerId]);
//     }    
// }