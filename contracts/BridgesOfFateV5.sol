// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// contract BridgesOfFateTestV4 is Ownable, ReentrancyGuard {
//     using SafeMath for uint256;
//     using Counters for Counters.Counter;
//     IERC20 public token;

//     Counters.Counter private _gameIdCounter;

//     uint256 public gameIdCounter;
//     uint256 private randomNumber;
//     uint256 private constant STAGES = 5; // 13 stages
//     uint256 private constant TURN_PERIOD = 300; //Now we are use 2 minute //86400; // 24 HOURS
//     uint256 private constant THERSHOLD = 5;
//     uint256 public  constant Fee = 0.01 ether;
    
//     uint256 private constant _winnerRewarsds = 60;
//     uint256 private constant _ownerRewarsds = 25;
//     uint256 private constant _communityVaultRewarsds = 15;
//     bool private _isEnd;

//     address[] public winnersList;
//     // 0 =========>>>>>>>>> Owner Address
//     // 1 =========>>>>>>>>> community vault Address
//     address[2] private Contracts = [
//         0xBE0c66A87e5450f02741E4320c290b774339cE1C,
//         0x1eF17faED13F042E103BE34caa546107d390093F
//     ];

//     // buyBack price curve /Make the private this variable./
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

//     struct GameMember {
//         uint256 day;
//         uint256 stage;
//         uint256 startAt;
//         uint256 overAt; 
//         bool jumpSide;
//         address userWalletAddress;
//     }
   
//     struct GameStatus {
//         uint256 startAt;
//         uint256 lastJumpAt;
//         uint256 stageNumber;
//     }

//     mapping(bytes32 => GameMember) public Player;
//     mapping(uint256 => GameStatus) public GameStatusInitialized;

//     mapping(address => uint256) private balances;
//     mapping(address => uint256) private winnerbalances;
//     mapping(address => uint256) private ownerbalances;
//     mapping(address => uint256) private vaultbalances;
//     mapping(uint256 => uint256) private RandomNumber;
//     mapping(bytes32 => bool)    private PlayerFeeStatusAtStage;
//     mapping(uint256 => mapping(bytes32 => bool)) public PlayerJumpStatusInTimeSilot;

//     event Initialized(uint256 CurrentGameID, uint256 StartAt);
//     event EntryFee(bytes32 PlayerId, uint256 NftId, uint256 NftSeries,uint256 FeeAmount);
//     event ParticipateOfPlayerInGame(bytes32 PlayerId, uint256 RandomNo);
    
//     constructor(IERC20 _wrappedEther) {
//         token = _wrappedEther;
//     }
    
//     function initialize(uint256 _startAT) public onlyOwner {
//         _gameIdCounter.increment();
//         gameIdCounter = _gameIdCounter.current();
//         GameStatus storage _admin = GameStatusInitialized[gameIdCounter];
//         // require(_isEnd == false, "Game in progress");
//         require(_startAT > block.timestamp,"Time greater then current time.");
//         _admin.startAt      = _startAT;
//         _admin.lastJumpAt   = _startAT;
//         // _isEnd              = true;
//         GameStatusInitialized[gameIdCounter] = _admin;
//         delete winnersList;
//         emit Initialized(gameIdCounter, block.timestamp);
//     }

//     function entryFeeForSeriesOne(uint256 _nftId)
//         public
//         GameEndRules
//         GameInitialized
//     {
//         bytes32 playerId = this.computeNextPlayerIdForHolder(
//             msg.sender,
//             _nftId,
//             1
//         );

//         GameMember memory _member = Player[playerId];
//         _member.overAt = 0;
//         _member.userWalletAddress = msg.sender;
//         if (_member.stage >= 1) {
//             _member.stage = _member.stage - 1;
//         }
//         Player[playerId] = _member;
//         PlayerFeeStatusAtStage[playerId] = true;
//         PlayerJumpStatusInTimeSilot[_member.day][playerId] = false;
//         emit EntryFee(playerId, _nftId, 1,0);
//     }

//     function entryFeeSeriesTwo(uint256 _nftId, uint256 _wrappedAmount)
//         public
//         GameEndRules
//         GameInitialized
//     {
//         require(balanceOfUser(msg.sender) >= _wrappedAmount, "You have insufficent balance");
//         // require(_wrappedAmount == calculateBuyBackIn(),"You have insufficent balance");
//         token.transferFrom(msg.sender, address(this), _wrappedAmount);
//         bytes32 playerId = this.computeNextPlayerIdForHolder(
//             msg.sender,
//             _nftId,
//             2
//         );
//         GameMember memory _member = Player[playerId];
//         _member.overAt = 0;
//         _member.userWalletAddress = msg.sender;
//         if (_member.stage >= 1) {
//             _member.stage = _member.stage - 1;
//         }
//         Player[playerId] = _member;
//         PlayerFeeStatusAtStage[playerId] = true;
//         PlayerJumpStatusInTimeSilot[_member.day][playerId] = false;
//         emit EntryFee(playerId, _nftId, 2,_wrappedAmount);
//     }

//     function bulkEntryFeeSeriesTwo(
//         uint256[] calldata _nftId,
//         uint256[] calldata _wrappedAmount
//     ) public GameInitialized {
//         for (uint256 i = 0; i < _nftId.length; i++) {
//             entryFeeSeriesTwo(_nftId[i], _wrappedAmount[i]);
//         }
//     }

//     /*
//         false-- Indicate left side
//         true-- Indicate right side
//     */
//     function participateInGame(bool _jumpSide, bytes32 playerId)
//         public
//         GameInitialized
//         GameEndRules
//     {
//         GameMember memory _member = Player[playerId];
//         GameStatus memory _gameStatus = GameStatusInitialized[_gameIdCounter.current()];
        
//         require(PlayerJumpStatusInTimeSilot[this.dayDifferance(_gameStatus.startAt) + 1][playerId] == false, "Already jumped in this Slot");
//         require(block.timestamp >= _gameStatus.startAt && PlayerFeeStatusAtStage[playerId] == true,"You have been Failed.");
//         require(STAGES >= _member.stage, "Reached maximum");

//         if (RandomNumber[_member.stage] <= 0) {
//             randomNumber = random() * 1e9;
//             RandomNumber[_gameStatus.stageNumber] = randomNumber;
//             _gameStatus.stageNumber = _gameStatus.stageNumber + 1;
//             _gameStatus.lastJumpAt = block.timestamp;
//         }else{
//             randomNumber = RandomNumber[_member.stage];
//         }
//         _member.startAt = block.timestamp;
//         _member.stage = _member.stage + 1;
//         _member.day = _member.day + 1;
//         _member.jumpSide = _jumpSide;

//         //If Jump Postion Failed the Player
//         if ((_member.jumpSide == true && randomNumber >= 50e9) || (_member.jumpSide == false && randomNumber <= 50e9)) {
//             PlayerFeeStatusAtStage[playerId] = true;
//             if(_member.stage == STAGES){
//                 winnersList.push(msg.sender);
//             }
//             if(this.dayDifferance(_gameStatus.startAt) == STAGES || this.dayDifferance(_gameStatus.startAt) == STAGES + THERSHOLD){
//                 _isEnd = false;
//             }
//         }else {
//             if(this.dayDifferance(_gameStatus.startAt) == STAGES || this.dayDifferance(_gameStatus.startAt) == STAGES + THERSHOLD){
//                 _isEnd = false;
//             }
//             PlayerFeeStatusAtStage[playerId] = false;
//             _member.overAt = block.timestamp;
//         }
        
//         Player[playerId] = _member;
//         PlayerJumpStatusInTimeSilot[_member.day][playerId] = true; //Next Jump After set silce period. For this reason status change againest Player 
//         GameStatusInitialized[gameIdCounter] = _gameStatus;
//         emit ParticipateOfPlayerInGame(playerId,randomNumber);
//     }

//     function setToken(IERC20 _token) public onlyOwner {
//         token = _token;
//     }

//     function _calculateReward() internal {
//         uint256 _treasuryBalance = this.treasuryBalance();
//         // 60 % reward goes to winnner.
//         uint256 _winners = ((_winnerRewarsds.mul(_treasuryBalance)).div(100))
//             .div(winnersList.length);
//         // 25% to owner wallet
//         uint256 _ownerAmount = (_ownerRewarsds.mul(_treasuryBalance)).div(100);
//         ownerbalances[Contracts[0]] = _ownerAmount;
//         // 15% goes to community vault
//         uint256 _communityVault = (
//             _communityVaultRewarsds.mul(_treasuryBalance)
//         ).div(100);
//         vaultbalances[Contracts[1]] = _communityVault;

//         for (uint256 i = 0; i < winnersList.length; i++) {
//             winnerbalances[winnersList[i]] = _winners;
//         }
//     }

//     function treasuryBalance() public view returns (uint256) {
//         return balanceOfUser(address(this));
//     }

//     function _withdraw(uint256 withdrawAmount) internal {
//         if (withdrawAmount <= balances[msg.sender]) {
//             balances[msg.sender] -= withdrawAmount;
//             payable(msg.sender).transfer(withdrawAmount);
//         }
//     }

//     function withdrawWrappedEther(uint8 withdrawtype)
//         public
//         nonReentrant
//         returns (bool)
//     {
//         // Check enough balance available, otherwise just return false
//         if (withdrawtype == 0) {
//             //owner
//             require(Contracts[0] == msg.sender, "Only Owner use this");
//             _withdraw(ownerbalances[msg.sender]);
//             return true;
//         } else if (withdrawtype == 1) {
//             //vault
//             require(Contracts[1] == msg.sender, "Only vault use this");
//             _withdraw(vaultbalances[msg.sender]);
//             return true;
//         } else {
//             //owners
//             _withdraw(winnerbalances[msg.sender]);
//             return true;
//         }
//     }


//     function calculateBuyBackIn() public view returns (uint256) {
//         GameStatus memory _admin = GameStatusInitialized[gameIdCounter];
//         uint256 days_ = this.dayDifferance(_admin.startAt);
//         if (days_ > 0) {
//             if (days_ <= buyBackCurve.length) {
//                 return buyBackCurve[days_ - 1];
//             } else {
//                 uint256 lastIndex = buyBackCurve.length - 1;
//                 return buyBackCurve[lastIndex];
//             }
//         } else {
//             return buyBackCurve[0];
//             // return 0;
//         }
//     }

//     function dayDifferance(uint256 dayTimeStamp) public view returns (uint256) {
//         // GameStatus memory _admin = GameStatusInitialized[gameIdCounter];
//             uint256 day_ = (block.timestamp - dayTimeStamp) / TURN_PERIOD;
//             return day_;
//     }

//     function random() internal view returns (uint256) {
//         return
//             uint256(
//                 keccak256(
//                     abi.encodePacked(
//                         block.timestamp,
//                         block.difficulty,
//                         msg.sender
//                     )
//                 )
//             ) % 100;
//     }

 
//     function computeNextPlayerIdForHolder(
//         address holder,
//         uint256 _nftId,
//         uint8 _seriesIndex
//     ) public pure returns (bytes32) {
//         return computePlayerIdForAddressAndIndex(holder, _nftId, _seriesIndex);
//     }

//     function computePlayerIdForAddressAndIndex(
//         address holder,
//         uint256 _nftId,
//         uint8 _seriesIndex
//     ) internal pure returns (bytes32) {
//         return keccak256(abi.encodePacked(holder, _nftId, _seriesIndex));
//     }

//     function balanceOfUser(address _accountOf) public view returns (uint256) {
//         return token.balanceOf(_accountOf);
//     }

//     /*
//      * @dev getCurrentStage function returns the current stage
//      */
//     function getCurrentStage(bytes32 playerId) public view returns (uint256) {
//         GameMember memory _member = Player[playerId];

//             if (PlayerFeeStatusAtStage[playerId] == false && _member.stage >= 1) {
//                 return _member.stage - 1;
//             } else {
//                 return _member.stage;
//             }
        
//     }

//     function isSafed(bytes32 playerID) public view returns (bool) {
//         GameStatus memory _gameStatus = GameStatusInitialized[gameIdCounter];
//         if(this.dayDifferance(_gameStatus.startAt) > 0){
//             return PlayerFeeStatusAtStage[playerID];
//         }
//         return false;
//     }
//     function getAll() public view returns (uint256[] memory) {
//         GameStatus memory _gameStatus   = GameStatusInitialized[gameIdCounter];
//         uint256[] memory ret;
//         uint256 _stageNumber;
//         if(this.dayDifferance(_gameStatus.lastJumpAt) > 0){
//             _stageNumber = _gameStatus.stageNumber;
//         }else{
//             _stageNumber = _gameStatus.stageNumber - 1;
//         }
//         if (_gameStatus.stageNumber > 0) {
//             ret = new uint256[](_stageNumber);
//             for (uint256 i = 0; i < _stageNumber; i++) {
//                 ret[i] = RandomNumber[i];
//             }
//         }
//         return ret;
//     }

//     modifier GameEndRules() {
//         GameStatus memory _gameStatus = GameStatusInitialized[gameIdCounter];
//         require(this.dayDifferance(_gameStatus.lastJumpAt) <= 2, "Game Ended !");
//         require(this.dayDifferance(_gameStatus.startAt) <= (STAGES + THERSHOLD) - 1, "Game Ended !");
//         _;
//     }

//     modifier GameInitialized() {
//         GameStatus memory _gameStatus = GameStatusInitialized[gameIdCounter];
//         require((_gameStatus.startAt > 0 && block.timestamp >= _gameStatus.startAt),"Game start after intialized time.");
//         _;
//     }
// }