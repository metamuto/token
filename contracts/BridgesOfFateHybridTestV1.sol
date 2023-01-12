// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


// contract BridgesOfFate is Ownable, ReentrancyGuard {
//     IERC20 private token;

//     bool public isEnd = false;
//     uint256 public latestGameId = 0;
//     uint256 public lastUpdateTimeStamp;
//     uint256 private _hybirdGameMap;

//     uint256 private constant STAGES = 2; // 13 stages
//     uint256 private constant TURN_PERIOD = 120; //Now we are use 5 minute //86400; // 24 HOURS
//     uint256 private constant THERSHOLD = 5;
//     uint256 private constant SERIES_TWO_FEE = 0.01 ether;
//     uint256 private constant _winnerRewarsdsPercent = 60;
//     uint256 private constant _ownerRewarsdsPercent = 25;
//     uint256 private constant _communityVaultRewarsdsPercent = 15;

//     bytes32[] private gameWinners;
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
//     mapping(address => uint256) private balances;
//     mapping(bytes32 => uint256) private winnerbalances;
//     mapping(address => uint256) private ownerbalances;
//     mapping(address => uint256) private vaultbalances;


//     mapping(bytes32 => GameItem) public PlayerItem;
//     mapping(uint256 => GameStatus) public GameStatusInitialized;
    
//     event Initialized(uint256 currentGameID, uint256 startAt);
//     event ParticipateOfPlayerInGame(bytes32 playerId, uint256 randomNo);
//     event ParticipateOfPlayerInBuyBackIn(bytes32 playerId, uint256 amount);
//     event EntryFee(bytes32 playerId,uint256 nftId,uint256 nftSeries,uint256 feeAmount);
//     event ParticipateOfNewPlayerInLateBuyBackIn(bytes32 playerId,uint256 moveAtStage,uint256 amount);

//     constructor(IERC20 _wrappedEther) {
//         token = _wrappedEther;
//     }

//     modifier GameEndRules() {
//         GameStatus memory _gameStatus = GameStatusInitialized[latestGameId];
//         require(dayDifferance(block.timestamp, lastUpdateTimeStamp) <= 2,"Game Ended !");
//         require(dayDifferance(block.timestamp, _gameStatus.startAt) <= (STAGES + THERSHOLD) - 1, "Game Achived thershold!");
//         _;
//     }

//     modifier GameInitialized() {
//         GameStatus memory _gameStatus = GameStatusInitialized[latestGameId];
//         require(block.timestamp >= _gameStatus.startAt,"Game start after intialized time.");
//         _;
//     }

//     function dayDifferance(uint256 timeStampTo, uint256 timeStampFrom) internal pure returns (uint256)
//     {
//         return (timeStampTo - timeStampFrom) / TURN_PERIOD;
//     }

//     function changeCommunityOwnerWA(address[2] calldata _communityOwnerWA) external onlyOwner {
//         for (uint i = 0; i < _communityOwnerWA.length; i++) {
//             communityOwnerWA[i] = _communityOwnerWA[i];
//         }
//     }

//     function initializeGame(uint256 _startAT) external onlyOwner {
//         require(isEnd == false, "Game Already Initilaized"); //extra
//         require(_startAT >= block.timestamp,"Time must be greater then current time.");
//         latestGameId++; //extra
//         GameStatus storage _gameStatus = GameStatusInitialized[latestGameId];
//         _gameStatus.startAt = _startAT;
//         lastUpdateTimeStamp = _startAT;
//         isEnd = true;
//         emit Initialized(latestGameId, block.timestamp);
//     }

//     function computeNextPlayerIdForHolder(address holder,uint256 _nftId,uint8 _seriesIndex) public pure returns (bytes32) {
//         return computePlayerIdForAddressAndIndex(holder, _nftId, _seriesIndex);
//     }

//     function computePlayerIdForAddressAndIndex(address holder,uint256 _nftId,uint8 _seriesIndex) internal pure returns (bytes32) {
//         return keccak256(abi.encodePacked(holder, _nftId, _seriesIndex));
//     }

//     function checkSide(uint256 stageNumber, bool userSide) internal view returns (bool)
//     {
//         if ((userSide == true && GameMap[stageNumber] >= 50e9) || (userSide == false && GameMap[stageNumber] < 50e9)
//         ) {
//             return true;
//         } else {
//             return false;
//         }
//     }

//     function entryFeeForSeriesOne(uint256 _nftId) public GameInitialized GameEndRules
//     {
//         bytes32 playerId = computeNextPlayerIdForHolder(msg.sender, _nftId, 1);
//         GameItem storage _member = PlayerItem[playerId];
//         if (_member.userWalletAddress != address(0)) {
//             GameStatus storage _gameStatus = GameStatusInitialized[latestGameId];
//             uint256 dayPassedAfterJump = dayDifferance(_member.lastJumpTime,_gameStatus.startAt);
//             require(dayDifferance(block.timestamp, _gameStatus.startAt) > _member.day, "Alreday In Game");
//             require(checkSide(_member.stage, _member.lastJumpSide) == false, "Already In Game");
//             require(dayPassedAfterJump + 1 < dayDifferance(block.timestamp, _gameStatus.startAt),"You Can only use Buy back in 24 hours");
//             _member.day = 0;
//             _member.stage = 0;
//             _member.startAt = 0;
//             _member.lastJumpSide = false;
//             _member.userWalletAddress = msg.sender;
//             _member.lastJumpTime = 0;
//             _member.feeStatus = true;
//             _member.nftId = _nftId;
//         } else {
//             _member.feeStatus = true;
//             _member.userWalletAddress = msg.sender;
//             _member.nftId = _nftId;
//         }
//         lastUpdateTimeStamp = block.timestamp;
//         emit EntryFee(playerId, _nftId, 1, 0);
//     }

//     function bulkEntryFeeForSeriesOne(uint256[] calldata _nftId) external {
//         for (uint256 i = 0; i < _nftId.length; i++) {
//             entryFeeForSeriesOne(_nftId[i]);
//         }
//     }

//     function balanceOfUser(address _accountOf) public view returns (uint256) {
//         return token.balanceOf(_accountOf);
//     }

//     function entryFeeSeriesTwo(uint256 _nftId) public GameInitialized GameEndRules
//     {
//         require(balanceOfUser(msg.sender) >= SERIES_TWO_FEE,"You have insufficent balance");
//         bytes32 playerId = computeNextPlayerIdForHolder(msg.sender, _nftId, 2);
//         GameItem storage _member = PlayerItem[playerId];

//         if (_member.userWalletAddress != address(0)) {
//             GameStatus storage _gameStatus = GameStatusInitialized[latestGameId];
//             uint256 dayPassedAfterJump = dayDifferance(_member.lastJumpTime,_gameStatus.startAt);
//             require(dayDifferance(block.timestamp, _gameStatus.startAt) > _member.day, "Alreday In Game");
//             require(checkSide(_member.stage, _member.lastJumpSide) == false, "Already In Game");
//             require(dayPassedAfterJump + 1 < dayDifferance(block.timestamp, _gameStatus.startAt),"You Can only use Buy back in 24 hours");            
//             _member.day = 0;
//             _member.stage = 0;
//             _member.startAt = 0;
//             _member.lastJumpSide = false;
//             _member.userWalletAddress = msg.sender;
//             _member.lastJumpTime = 0;
//             _member.feeStatus = true;
//             _member.nftId = _nftId;
//         } else {
//             _member.feeStatus = true;
//             _member.userWalletAddress = msg.sender;
//             _member.nftId = _nftId;
//         }
//         token.transferFrom(msg.sender, address(this), SERIES_TWO_FEE);
//         lastUpdateTimeStamp = block.timestamp;
//         emit EntryFee(playerId, _nftId, 2, SERIES_TWO_FEE);
//     }

//     function bulkEntryFeeSeriesTwo(uint256[] calldata _nftId) external {
//         for (uint256 i = 0; i < _nftId.length; i++) {
//             entryFeeSeriesTwo(_nftId[i]);
//         }
//     }

//     function buyBackInFee(bytes32 playerId) external GameInitialized GameEndRules
//     {
//         uint256 buyBackFee = calculateBuyBackIn();
//         require(balanceOfUser(msg.sender) >= buyBackFee,"You have insufficent balance");
//         GameItem memory _member = PlayerItem[playerId];
//         require(_member.userWalletAddress != address(0), "Record Not Found");
//         require(dayDifferance(block.timestamp, _member.lastJumpTime) <= 1,"Buy Back can be used in 24 hours only");
//         require(checkSide(_member.stage, _member.lastJumpSide) == false, "Already In Game");
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
//         emit ParticipateOfPlayerInBuyBackIn(playerId, buyBackFee);
//     }

//     function random() internal view returns (uint256) {
//         return uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty,msg.sender))) % 100;
//     }

//     function participateInGame(bool _jumpSide, bytes32 playerId) external GameInitialized GameEndRules
//     {
//         GameItem memory _member = PlayerItem[playerId];
//         GameStatus memory _gameStatus = GameStatusInitialized[latestGameId];
//         uint256 currentDay = dayDifferance(block.timestamp,_gameStatus.startAt);
//         require(_member.feeStatus == true, "Please Pay Entry Fee.");
//         require(_hybirdGameMap < 50e9,"Hybird Game Ended.");
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
//         if (GameMap[_member.stage + 1] <= 0) {
//             if(_gameStatus.stageNumber >= STAGES){
//                 _hybirdGameMap = random() * 1e9;
//             }
//             GameMap[_gameStatus.stageNumber + 1] = random() * 1e9;
//             _gameStatus.stageNumber = _gameStatus.stageNumber + 1;
//             _gameStatus.lastUpdationDay = currentDay;
//         }
//         _member.startAt = block.timestamp;
//         _member.stage = _member.stage + 1;
//         //Day Count of Member Playing Game
//         _member.day = currentDay;
//         _member.lastJumpSide = _jumpSide;
//         _member.lastJumpTime = block.timestamp;
//         PlayerItem[playerId] = _member;
//         GameStatusInitialized[latestGameId] = _gameStatus;
//         lastUpdateTimeStamp = block.timestamp;

//         //Push winner into the Array list 
//         if(checkSide(GameMap[_gameStatus.stageNumber],_jumpSide) && (_member.stage  > STAGES && _hybirdGameMap > 50e9 )){
//             gameWinners.push(playerId);
//         }

//         emit ParticipateOfPlayerInGame(playerId,GameMap[_gameStatus.stageNumber + 1]);
//     }

//     function getAll() external view returns (uint256[] memory) {
//         GameStatus memory _gameStatus = GameStatusInitialized[latestGameId];
//         uint256[] memory ret;
//         uint256 _stageNumber;
//         if (_gameStatus.stageNumber > 0) {
//             if (dayDifferance(block.timestamp, _gameStatus.startAt) > _gameStatus.lastUpdationDay) {
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
//         GameStatus memory _gameStatus = GameStatusInitialized[latestGameId];
//         if (_gameStatus.stageNumber > 0) {
//             if (_gameStatus.stageNumber <= buyBackCurve.length) {
//                 return buyBackCurve[_gameStatus.stageNumber - 1];
//             }
//         }
//         return 0;
//     }

//     function LateBuyInFee(uint256 _nftId, uint8 seriesType) public GameEndRules
//     {
//         require(seriesType == 1 || seriesType == 2, "Invalid seriseType");
//         bytes32 playerId = computeNextPlayerIdForHolder(msg.sender,_nftId,seriesType);
//         uint256 buyBackFee = calculateBuyBackIn();
//         uint256 totalAmount;
//         if (seriesType == 1) {
//             totalAmount = buyBackFee;
//             require(balanceOfUser(msg.sender) >= buyBackFee,"You have insufficent balance");
//             token.transferFrom(msg.sender, address(this), buyBackFee);
//         }

//         if (seriesType == 2) {
//             totalAmount = buyBackFee + SERIES_TWO_FEE;
//             require(balanceOfUser(msg.sender) >= buyBackFee + SERIES_TWO_FEE,"You have insufficent balance");
//             token.transferFrom(msg.sender,address(this),buyBackFee + SERIES_TWO_FEE);
//         }
//         GameStatus memory _gameStatus = GameStatusInitialized[latestGameId];
//         GameItem storage _member = PlayerItem[playerId];
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
//         emit ParticipateOfNewPlayerInLateBuyBackIn(playerId,_gameStatus.stageNumber - 1,totalAmount);
//     }

//     function bulkLateBuyInFee(uint256[] calldata _nftId,uint8[] calldata seriesType) external {
//         for (uint256 i = 0; i < _nftId.length; i++) {
//             LateBuyInFee(_nftId[i], seriesType[i]);
//         }
//     }

//     function restartGame(uint256 _nftId, uint8 seriesType) external {
//         require(seriesType == 1 || seriesType == 2, "Invalid seriseType");
//         bytes32 playerId = computeNextPlayerIdForHolder(msg.sender,_nftId,seriesType);
//         GameItem storage _member = PlayerItem[playerId];
//         require(_member.userWalletAddress != address(0), "Record Not Found");
//         require(_member.stage == 1, "Only used if u fail on first stage");
//         GameStatus storage _gameStatus = GameStatusInitialized[latestGameId];
//         uint256 currentDay = dayDifferance(block.timestamp, _gameStatus.startAt);
//         require(currentDay > _member.day, "Alreday In Game");
//         bool check = checkSide(_member.stage, _member.lastJumpSide);
//         require(check == false, "Already In Game");
//         _member.day = 0;
//         _member.stage = 0;
//         _member.startAt = 0;
//         _member.lastJumpSide = false;
//         _member.userWalletAddress = msg.sender;
//         _member.lastJumpTime = 0;
//         _member.nftId = _nftId;
//     }

//     function treasuryBalance() public view returns (uint256) {
//         return balanceOfUser(address(this));
//     }

//     function calculateReward() public {
//         GameStatus memory _gameStatus = GameStatusInitialized[latestGameId];
//         uint256 _treasuryBalance = treasuryBalance();
//         // 60 % reward goes to winnner.
//         require(_treasuryBalance > 0 ,"Insufficient Balance");
//         require(_gameStatus.stageNumber == STAGES,"It's not time to Distribution");
//         uint256 _winners = (((_winnerRewarsdsPercent * _treasuryBalance)) / 100) / (gameWinners.length);
//         // 25% to owner wallet
//         // require(ownerbalances[Contracts[0]] > 0,"Already amount distribute in commuinty");
//         uint256 _ownerAmount = (_ownerRewarsdsPercent * _treasuryBalance) / 100;
//         ownerbalances[communityOwnerWA[0]] = _ownerAmount;
//         // 15% goes to community vault
//         uint256 _communityVault = (_communityVaultRewarsdsPercent * _treasuryBalance) / 100;
//         vaultbalances[communityOwnerWA[1]] = _communityVault;

//         for (uint256 i = 0; i < gameWinners.length; i++) {
//             winnerbalances[gameWinners[i]] = _winners;
//         }
//     }

//     function _withdraw(uint256 withdrawAmount) internal {
//         if (withdrawAmount <= balances[msg.sender]) {
//             balances[msg.sender] -= withdrawAmount;
//             token.transferFrom(address(this), msg.sender, withdrawAmount);
//         }
//     }

//     function withdrawWrappedEtherOFCommunity(uint8 withdrawtype) public onlyOwner nonReentrant 
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

//     function claimWinnerEther(bytes32 playerId) public nonReentrant {
//         require(winnerbalances[playerId] > 0,"Insufficient Plyer Balance");
//         GameItem storage _member = PlayerItem[playerId];
//         if(_member.userWalletAddress == msg.sender){
//             _withdraw(winnerbalances[playerId]);
//         }
//     }    
// }