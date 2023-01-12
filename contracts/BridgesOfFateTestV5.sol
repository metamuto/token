// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// contract BridgesOfFateTestV4 is ReentrancyGuard {
    
//     IERC20 private token;

//     uint256 public  gameIdCounter;
//     uint256 private randomNumber;
//     uint256 private lastActionAt;
//     uint256 private constant STAGES = 13; 
//     uint256 private constant THERSHOLD = 5;
//     uint256 private constant TURN_PERIOD = 300; //Now we are use 2 minute //86400; // 24 HOURS
//     uint256 public  constant Fee = 0.01 ether;
    
//     uint256 private constant _winnerRewarsds = 60;
//     uint256 private constant _ownerRewarsds = 25;
//     uint256 private constant _communityVaultRewarsds = 15;

//     address[] public winnersList;
//     bytes32[] public PlayerList;
//     address   public owner;

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
//         bool jumpSide;
//         bool entryStatus;
//         address userWalletAddress;
//     }
   
//     struct GameStatus {
//         uint256 startAt;
//         uint256 lastJumpAt;
//         uint256 stageNumber;
//         uint256 lastUpdationDay;
        
//     }

//     mapping(bytes32 => GameMember) public Player;
//     mapping(uint256 => GameStatus) public GameStatusInitialized;
//     mapping(address => uint256) private balances;
//     mapping(address => uint256) private winnerbalances;
//     mapping(address => uint256) private ownerbalances;
//     mapping(address => uint256) private vaultbalances;
//     mapping(uint256 => uint256) private RandomNumber;
//     mapping(bytes32 => bool)    public PlayerOverAtStatus; // change private
//     mapping(bytes32 => bool)    public PlayerFeeStatusAtStage; // change private
//     mapping(uint256 => mapping(bytes32 => bool)) public PlayerJumpStatusInTimeSilot;

//     event Initialized(uint256 CurrentGameID, uint256 StartAt);
//     event EntryFee(bytes32 PlayerId, uint256 NftId, uint256 NftSeries,uint256 FeeAmount);
//     event ParticipateOfPlayerInGame(bytes32 PlayerId, uint256 RandomNo);
    
//     constructor(IERC20 _wrappedEther) {
//         token = _wrappedEther;
//         owner = msg.sender;
//     }
//     function initialize(uint256 _startAT) public onlyOwner {
//         GameStatus storage _admin = GameStatusInitialized[1];
//         require(_admin.startAt >= 0,"Only One time Game has been initialized.");
//         require(_startAT > block.timestamp,"Time greater then current time.");
//         _admin.startAt      = _startAT;
//         _admin.lastJumpAt   = _startAT;
//         lastActionAt        = block.timestamp;
//         GameStatusInitialized[gameIdCounter] = _admin;
//         delete winnersList;
//         emit Initialized(gameIdCounter, block.timestamp);
//     }

//     function entryFeeForSeriesOne(uint256 _nftId) public GameInitialized GameEndRules
//     {
//         bytes32 playerId = this.computeNextPlayerIdForHolder(msg.sender,_nftId,1);
//         GameMember memory _member  = Player[playerId];
//         require(_member.entryStatus == false,"You have been already pay entry Fee.");

//         _member.userWalletAddress = msg.sender;
//         _member.entryStatus       = true;
//         lastActionAt              = block.timestamp;
//         Player[playerId]          = _member;
//         PlayerList.push(playerId);
//         PlayerFeeStatusAtStage[playerId] = true;
//         PlayerJumpStatusInTimeSilot[_member.day][playerId] = false;
//         emit EntryFee(playerId, _nftId, 1,0);
//     }

//     function entryFeeSeriesTwo(uint256 _nftId, uint256 _wrappedAmount) public GameInitialized GameEndRules
//     {
//         require(_wrappedAmount >= Fee, "You have insufficent balance");
//         require(balanceOfUser(msg.sender) >= _wrappedAmount, "You have insufficent balance");
//         token.transferFrom(msg.sender, address(this), _wrappedAmount);
//         bytes32 playerId = this.computeNextPlayerIdForHolder(msg.sender,_nftId,2);
//         GameMember memory _member = Player[playerId];
//         require(_member.entryStatus == false,"You have been already pay entry Fee.");
//         lastActionAt                = block.timestamp;
//         _member.userWalletAddress   = msg.sender;
//         _member.entryStatus         = true;
//         Player[playerId]            = _member;
//         PlayerList.push(playerId);
//         PlayerFeeStatusAtStage[playerId] = true;
//         PlayerJumpStatusInTimeSilot[_member.day][playerId] = false;
//         emit EntryFee(playerId, _nftId, 2,_wrappedAmount);
//     }
    
//     function BuyBackInFee(bytes32 playerId) public GameEndRules {
        
//         GameMember memory _member = Player[playerId];
//         uint256 _amount = calculateBuyBackIn();
//         require(balanceOfUser(msg.sender) >= _amount ,"You have insufficent balance");
//         token.transferFrom(msg.sender, address(this), _amount);

//         if(_member.stage == 1){
//             _member.stage  = _member.stage ;
//         }if (_member.stage > 1) {
//             _member.stage = _member.stage - 1; 
//         } else {
//             _member.stage = _member.stage; 
//         }

//         if(RandomNumber[_member.stage] >= 50e9){
//             _member.jumpSide = true;
//         }
//         else{
//             _member.jumpSide = false;
//         }
//         Player[playerId]                 = _member;
//         PlayerFeeStatusAtStage[playerId] = true;
//         PlayerJumpStatusInTimeSilot[_member.day][playerId] = false;
//     }
//     function LateBuyBackInFee(uint256 _nftId,uint256 _seriesType) public GameEndRules {
//         GameStatus storage _admin = GameStatusInitialized[1];
//         uint256 _amount = calculateBuyBackIn();
//         uint256 _totalAmount; 
//         bytes32 playerId;
//         if (_seriesType  == 1) {
//                 _totalAmount =  _amount;
//                 playerId = this.computeNextPlayerIdForHolder(msg.sender,_nftId,1);
//                 emit EntryFee(playerId, _nftId, 1,0);
//         }if (_seriesType  == 2) {
//                 _totalAmount =  Fee + _amount;
//                 playerId = this.computeNextPlayerIdForHolder(msg.sender,_nftId,2);
//                 emit EntryFee(playerId, _nftId, 2,_totalAmount);
//         } 
//             require(balanceOfUser(msg.sender) >= _totalAmount, "You have insufficent balance");
//             token.transferFrom(msg.sender, address(this), _totalAmount);
//             GameMember memory _member  = Player[playerId];
//             require(_member.entryStatus == false,"You have been already pay entry Fee.");
//             _member.entryStatus       = true;
//             _member.userWalletAddress = msg.sender;
//             lastActionAt              = block.timestamp;
//             _member.stage             = _admin.stageNumber - 1; 
//             Player[playerId]          = _member;
//             PlayerList.push(playerId);
//             PlayerFeeStatusAtStage[playerId] = true;
//     }

//     function bulkEntryFeeSeriesTwo(uint256[] calldata _nftId,uint256[] calldata _wrappedAmount) public GameInitialized {
//         for (uint256 i = 0; i < _nftId.length; i++) {
//             entryFeeSeriesTwo(_nftId[i], _wrappedAmount[i]);
//         }
//     }

//     /*
//         false-- Indicate left side
//         true-- Indicate right side
//     */
//     function participateInGame(bool _jumpSide, bytes32 playerId) public GameInitialized GameEndRules
//     {
//         GameMember memory _member       = Player[playerId];
//         GameStatus memory _gameStatus   = GameStatusInitialized[1];
//         require(PlayerJumpStatusInTimeSilot[this.dayDifferance(_gameStatus.startAt) + 1][playerId] == false, "Already jumped in this Slot");
//         require(block.timestamp >= _gameStatus.startAt && PlayerFeeStatusAtStage[playerId] == true,"You have been Failed.");
//         require(STAGES >= _member.stage, "Reached maximum");
//         lastActionAt        = block.timestamp;
//         if (RandomNumber[_member.stage] <= 0) {
//             randomNumber = random() * 1e9;
//             RandomNumber[_gameStatus.stageNumber] = randomNumber;
//             _gameStatus.stageNumber = _gameStatus.stageNumber + 1;
//             _gameStatus.lastJumpAt = block.timestamp;
//             _gameStatus.lastUpdationDay = this.dayDifferance(_gameStatus.startAt);
//         }else{
//             randomNumber = RandomNumber[_member.stage];
//         }
//         _member.startAt = block.timestamp;
//         _member.stage = _member.stage + 1;
//         _member.day = _member.day + 1;
//         _member.jumpSide = _jumpSide;
//         if ((_member.jumpSide == true && randomNumber >= 50e9) || (_member.jumpSide == false && randomNumber < 50e9)) {
//             PlayerFeeStatusAtStage[playerId] = true;
//             if(_member.stage == STAGES){
//                 winnersList.push(msg.sender);
//             }
//         }else {
//             PlayerFeeStatusAtStage[playerId] = false;
//         }
        
//         Player[playerId] = _member;
//         PlayerJumpStatusInTimeSilot[this.dayDifferance(_gameStatus.startAt) + 1][playerId] = true; //Next Jump After set silce period. For this reason status change againest Player 
//         GameStatusInitialized[1] = _gameStatus;
//         emit ParticipateOfPlayerInGame(playerId,randomNumber);
//     }

//     function setToken(IERC20 _token) public onlyOwner {
//         token = _token;
//     }

//     function _calculateReward() internal {
//         uint256 _treasuryBalance = this.treasuryBalance();
//         // 60 % reward goes to winnner.
//         uint256 _winners = (((_winnerRewarsds * _treasuryBalance)) / 100) / (winnersList.length);
//         // 25% to owner wallet
//         uint256 _ownerAmount = (_ownerRewarsds * _treasuryBalance) / 100;
//         ownerbalances[Contracts[0]] = _ownerAmount;
//         // 15% goes to community vault
//         uint256 _communityVault = (_communityVaultRewarsds * _treasuryBalance) / 100;
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

//     function withdrawWrappedEther(uint8 withdrawtype) public nonReentrant returns (bool)
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
//         GameStatus memory _admin = GameStatusInitialized[1];
//         if (_admin.stageNumber <= buyBackCurve.length) {
//             return buyBackCurve[_admin.stageNumber - 1];
//         } else {
//             return buyBackCurve[0];
//         }
//     }

//     function dayDifferance(uint256 dayTimeStamp) public view returns (uint256) {
//         uint256 day_ = (block.timestamp - dayTimeStamp) / TURN_PERIOD;
//         return day_;
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

//     function getCurrentStage(bytes32 playerId) public view returns (uint256) {
//         GameMember memory _member = Player[playerId];
//         if (PlayerFeeStatusAtStage[playerId] == false && _member.stage >= 1) {
//             return _member.stage - 1;
//         } else {
//             return _member.stage;
//         }
        
//     }

//     function isSafed(bytes32 playerID) public view returns (bool) {
//         GameStatus memory _gameStatus = GameStatusInitialized[1];
//         if(this.dayDifferance(_gameStatus.startAt) > 0){
//             return PlayerFeeStatusAtStage[playerID];
//         }
//         return false;
//     }

//     function getAll() public view returns (uint256[] memory) {
//         GameStatus memory _gameStatus = GameStatusInitialized[1];
//         uint256[] memory ret;
//         uint256 _stageNumber;
//         if (_gameStatus.stageNumber > 0) {
//             if (this.dayDifferance(_gameStatus.startAt) > _gameStatus.lastUpdationDay ) {
//                 _stageNumber = _gameStatus.stageNumber;
//             } else {
//                 _stageNumber = _gameStatus.stageNumber - 1;
//             }

//             ret = new uint256[](_stageNumber);
//             for (uint256 i = 0; i < _stageNumber; i++) {
//                 ret[i] = RandomNumber[i];
//             }
//         }
//         return ret;
//     }

//     // function getAll() public view returns (uint256[] memory) {
//     //     GameStatus memory _gameStatus   = GameStatusInitialized[1];
//     //     uint256[] memory ret;
//     //     uint256 _stageNumber = this.dayDifferance(_gameStatus.startAt);
//     //     // if(this.dayDifferance(_gameStatus.lastJumpAt) > 0){
//     //     //     _stageNumber = _gameStatus.stageNumber;
//     //     // }else{
//     //     //     _stageNumber = _gameStatus.stageNumber - 1;
//     //     // }
//     //     // if (_gameStatus.stageNumber > 0) {
//     //         ret = new uint256[](_stageNumber);
//     //         if(_stageNumber > 0 ){
//     //             for (uint256 i = 0; i < _stageNumber; i++) {
//     //                 if(RandomNumber[i] > 0)
//     //                 ret[i] = RandomNumber[i];
//     //             }
//     //         }
//     //     // }
//     //     return ret;
//     // }

//     modifier GameEndRules() {
//         GameStatus memory _gameStatus = GameStatusInitialized[1];
//         require(this.dayDifferance(lastActionAt) <= 2, "Game Ended !");
//         require(this.dayDifferance(_gameStatus.startAt) <= (STAGES + THERSHOLD) - 1, "Game Ended !");
//         _;
//     }

//     modifier GameInitialized() {
//         GameStatus memory _gameStatus = GameStatusInitialized[1];
//         require((_gameStatus.startAt > 0 && block.timestamp >= _gameStatus.startAt),"Game start after intialized time.");
//         _;
//     }

//     modifier onlyOwner() {
//         require(owner == msg.sender, "Ownable: caller is not the owner");
//         _;
//     }
// }