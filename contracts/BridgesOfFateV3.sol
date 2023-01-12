// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// contract BridgesOfFateV3 is Ownable, ReentrancyGuard {
//     using SafeMath for uint256;
//     using Counters for Counters.Counter;
//     IERC20 public token;

//     Counters.Counter private _daysCounter;
//     Counters.Counter private _hybirdLevel;
//     Counters.Counter private _dynamicLevel;
//     Counters.Counter private _gameIdCounter;

//     uint256 private constant TURN_PERIOD = 120; //Now we are use 2 minute //86400; // 24 HOURS
//     uint256 public startPeriod = 0; //
//     uint256 private constant STAGES = 13; // 13 stages
//     uint256 private constant THERSHOLD = 5;

//     uint256 private constant _winnerRewarsds = 60;
//     uint256 private constant _ownerRewarsds = 25;
//     uint256 private constant _communityVaultRewarsds = 15;
//     uint256 public constant Fee = 0.01 ether;

//     // buyBack price curve /Make the private this variable./
//     uint256[] public buyBackCurve = [
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

//     constructor(IERC20 _wrappedEther) {
//         token = _wrappedEther;
//     }

//     uint256 public dayCounter;
//     uint256 public randomNumber;
//     uint256 public gameIdCounter;
//     uint256 public randomNumForResumePlayer;

//     address[] public winnersList;

//     // 0 =========>>>>>>>>> Owner Address
//     // 1 =========>>>>>>>>> community vault Address
//     address[] private Contracts = [
//         0xBE0c66A87e5450f02741E4320c290b774339cE1C,
//         0x1eF17faED13F042E103BE34caa546107d390093F
//     ];

//     event Initialized(uint256 counter, uint256 startAt);
//     event EntryFee(bytes32 playerId, uint256 nftId, uint256 nftSeries);

//     struct GameMember {
//         uint256 day;
//         uint256 stage;
//         uint256 level;
//         uint256 startAt; // Jump Time
//         uint256 overAt; //Game Loss time
//         uint256 joinDay;
//         bool feeStatus;
//         bool chooes_side;
//         bool safeStatus;
//         address userWalletAddress;
//     }
//     /*
//      * Admin Use Struct
//      */
//     struct GameStatus {
//         uint256 stageNumber;
//         uint256 startAt;
//         uint256 lastJumpAt;
//     }

//     /*
//      * Admin Use Struct
//      */
//     mapping(uint256 => GameStatus) public GameStatusInitialized;
//     // Nft Owner Hash
//     mapping(bytes32 => GameMember) public Player;
//     mapping(address => uint256) private balances;
//     mapping(address => uint256) private winnerbalances;
//     mapping(address => uint256) private ownerbalances;
//     mapping(address => uint256) private vaultbalances;
//     mapping(uint256 => uint256) public RandomNumber; //make internal

//     //mapping the SAfe side Againest the Day's
//     mapping(uint256 => bool) public safeSide;

//     // mapping(uint256 => uint256) public timePeriod; // Time Slot createx
//     mapping(uint256 => mapping(bytes32 => bool))
//         public PlayerTimeStatusAgainestDay;

//     function _currentDay() public view returns (uint256) {
//         // gameIdCounter = _gameIdCounter.current();
//         GameStatus memory _gameStatus = GameStatusInitialized[
//             _gameIdCounter.current()
//         ];
//         return ((block.timestamp - _gameStatus.startAt) / TURN_PERIOD) + 1;
//     }

//     /*
//      * @notice Admin initialize Game into Smart contract
//      */
//     function initialize(uint256 _startAT) public onlyOwner {
//         _gameIdCounter.increment();
//         gameIdCounter = _gameIdCounter.current();
//         GameStatus storage _admin = GameStatusInitialized[gameIdCounter];

//         //extre
//         require(
//             _startAT > block.timestamp,
//             "Time must greater then current time."
//         );

//         _admin.startAt = _startAT;
//         _admin.lastJumpAt = _startAT;
//         // _admin.stageNumber = _admin.stageNumber + 1;
//         GameStatusInitialized[gameIdCounter] = _admin;
//         if (winnersList.length > 0) {
//             delete winnersList;
//         }
//         //check gas fee on these conditions
//         // winnersList = [];
//         emit Initialized(gameIdCounter, block.timestamp);
//     }

//     /*
//      * @dev Entery Fee for series one.
//      * @param _nftId
//      */
//     function enteryFeeForSeriesOne(uint256 _nftId)
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
//         _member.feeStatus = true;
//         _member.userWalletAddress = msg.sender;
//         _member.overAt = 0;
//         if (_member.stage >= 1) {
//             _member.stage = _member.stage - 1;
//         }
   
//         PlayerTimeStatusAgainestDay[_member.day][playerId] == false;
//         Player[playerId] = _member;
//         emit EntryFee(playerId, _nftId, 1);
//     }

//     /**
//      * @dev Entery Fee for series Two.
//      */
//     function enteryFeeSeriesTwo(uint256 _nftId, uint256 _wrappedAmount)
//         public
//         GameEndRules
//         GameInitialized
//     {
//         require(balanceOfUser(msg.sender) > 0, "You have insufficent balance");
//         /*
//        Shoiab
//         require(
//             _wrappedAmount == calculateBuyBackIn(),
//             "You have insufficent balance"
//         );
//         */

//         //Ether Deposit Amount transfer to smart contract
//         transferBalance(_wrappedAmount);
//         bytes32 playerId = this.computeNextPlayerIdForHolder(
//             msg.sender,
//             _nftId,
//             2
//         );

//         //Create Mapping for the Player which was paid the Fee
//         GameMember memory _member = Player[playerId];
//         _member.feeStatus = true;
//         _member.overAt = 0;
//         _member.userWalletAddress = msg.sender;
//         if (_member.stage >= 1) {
//             _member.stage = _member.stage - 1;
//         }
  
//         PlayerTimeStatusAgainestDay[_member.day][playerId] == false;
//         Player[playerId] = _member;
//         emit EntryFee(playerId, _nftId, 2);
//     }

//     /*
//      * @dev Entery Fee for series one.
//      * @param _nftId
//      */
//     function bulkEnteryFeeSeriesTwo(
//         uint256[] calldata _nftId,
//         uint256[] calldata _wrappedAmount
//     ) public GameInitialized {
//         for (uint256 i = 0; i < _nftId.length; i++) {
//             enteryFeeSeriesTwo(_nftId[i], _wrappedAmount[i]);
//         }
//     }

//     /*
//         0 --false-- Indicate left side
//         1 --true-- Indicate right side
//     */
//     function participateInGame(bool _chooes_side, bytes32 playerId)
//         public
//         After24Hours(playerId)
//         GameInitialized
//         GameEndRules
//     {
//         gameIdCounter = _gameIdCounter.current();
//         GameMember memory _member = Player[playerId];
//         GameStatus memory _gameStatus = GameStatusInitialized[gameIdCounter];
//         require(
//             block.timestamp >= _gameStatus.startAt && _member.feeStatus == true,
//             "You have been Failed."
//         );
//         require(STAGES >= _member.stage, "Reached maximum");
//         //Check Random Number On Day
//         if (RandomNumber[_member.stage + 1] <= 0) {
//             randomNumber = random() * 1e9;
//             RandomNumber[_gameStatus.stageNumber] = randomNumber;
//             //Global Data
//             _gameStatus.stageNumber = _gameStatus.stageNumber + 1;
//             _gameStatus.lastJumpAt = block.timestamp; // Use this time to Resume Players
//         }
//         _member.startAt = block.timestamp;
//         _member.stage = _member.stage + 1;
//         _member.day = _member.day + 1;
//         _member.chooes_side = _chooes_side;
//         //If Jump Postion Failed the Player
//         if (_member.chooes_side == true && randomNumber >= 50e9) {
//             _member.safeStatus = true;
//         } else if (_member.chooes_side == false && randomNumber <= 50e9) {
//             _member.safeStatus = true;
//         } else {
//             _member.feeStatus = false;
//             _member.overAt = block.timestamp;
//         }
//         //24 hours
//         PlayerTimeStatusAgainestDay[_member.day][playerId] = true;
//         Player[playerId] = _member;
//         GameStatusInitialized[gameIdCounter] = _gameStatus;
//     }

//     /*
//      * Check the same player(Same nft id, series, wallet) exist in Game
//      * Make this function internal
//      */
//     function isExists(address _sender) public view returns (bool) {
//         if (winnersList.length > 0) {
//             for (uint256 i = 0; i < winnersList.length; i++) {
//                 if (winnersList[i] == _sender) {
//                     return false;
//                 }
//             }
//         }
//         return true;
//     }

//     /*
//      * @notice Only owner set the reward currency (like wrapped ether token address set).
//      * @dev setTokem function use to set the wrapped token.
//      */

//     function setToken(IERC20 _token) public onlyOwner {
//         token = _token;
//     }

//     /*
//      * @notice calculate the winner reward and withdraw rewards
//      * @dev Internal func check the total deposit and calculate the reward
//      * and distribute to the winner and vault and owner
//      */

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

//     // @return The balance of the Simple Smart contract contract
//     function treasuryBalance() public view returns (uint256) {
//         return balanceOfUser(address(this));
//     }

//     // @notice Withdraw ether from Smart contract
//     // @return The balance remaining for the user
//     function _withdraw(uint256 withdrawAmount) internal {
//         // Check enough balance available, otherwise just return balance
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

//     /*
//      * @notice Calculate the numebr of days after initialize the game into Smart contract
//      * @dev if user enter into the advance stage mediun way after game start.
//      * @return They return buyback price curve price in eth
//      * This fucntion is use to determined how many ether payed to enter into the game
//      */

//     function calculateBuyBackIn() public view returns (uint256) {
//         uint256 days_ = this.dayDifferance();
//         if (days_ > 0) {
//             if (days_ <= buyBackCurve.length) {
//                 return buyBackCurve[days_ - 1];
//             } else {
//                 uint256 lastIndex = buyBackCurve.length - 1;
//                 return buyBackCurve[lastIndex];
//             }
//         } else {
//             return 0;
//         }
//     }

//     /*
//      * @notice Calculate the numebr of days.
//      * @dev Read functon.
//      * @return They return number of days
//      */
//     function dayDifferance() public view returns (uint256) {
//         // gameIdCounter = _gameIdCounter.current();
//         // return 12;
//         GameStatus memory _admin = GameStatusInitialized[gameIdCounter];
//         if (_admin.startAt > 0) {
//             uint256 day_ = (block.timestamp - _admin.startAt) / TURN_PERIOD;
//             //86400;
//             return day_;
//         } else {
//             return 0;
//         }
//     }

//     /*
//      * Generate a randomish number between 0 and 10.
//      * Make internal
//      */
//     // Warning: It is trivial to know the number this function returns BEFORE calling it.

//     function random() public view returns (uint256) {
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

//     /**
//      * @dev Computes NFT the Next Game Partipcate identifier for a given Player address.
//      */
//     function computeNextPlayerIdForHolder(
//         address holder,
//         uint256 _nftId,
//         uint8 _sersionIndex
//     ) public pure returns (bytes32) {
//         return computePlayerIdForAddressAndIndex(holder, _nftId, _sersionIndex);
//     }

//     /**
//      * @dev Computes NFT the Game Partipcate identifier for an address and an index.
//      */
//     function computePlayerIdForAddressAndIndex(
//         address holder,
//         uint256 _nftId,
//         uint8 _sersionIndex
//     ) internal pure returns (bytes32) {
//         return keccak256(abi.encodePacked(holder, _nftId, _sersionIndex));
//     }

//     function balanceOfUser(address _accountOf) public view returns (uint256) {
//         return token.balanceOf(_accountOf);
//     }

//     function transferBalance(uint256 _amount) public {
//         token.approve(address(this), _amount);
//         token.transferFrom(msg.sender, address(this), _amount);
//     }

//     /*
//      * @dev getCurrentStage function returns the current stage
//      */
//     function getCurrentStage(bytes32 playerId) public view returns (uint256) {
//         GameMember memory _member = Player[playerId];
//         if (_member.feeStatus == false && _member.stage >= 1) {
//             return _member.stage - 1;
//         } else {
//             return _member.stage;
//         }
//     }

//     function getAll() public view returns (uint256[] memory) {
//         GameStatus memory _gameStatus = GameStatusInitialized[gameIdCounter];
//         uint256 lastUpdateDayDifference = (block.timestamp - _gameStatus.lastJumpAt) / TURN_PERIOD;
//         uint256[] memory ret;
//         uint256 _stageNumber;
//         if(lastUpdateDayDifference > 0){
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

//     modifier After24Hours(bytes32 playerId) {
//         require(PlayerTimeStatusAgainestDay[_currentDay()][playerId] == false, "Already jumped in this 60 seconds.");
//         _;
//     }

//     modifier GameEndRules() {
//         GameStatus memory _gameStatus = GameStatusInitialized[gameIdCounter];
//         uint256 lastUpdateDayDifference = (block.timestamp - _gameStatus.lastJumpAt) / TURN_PERIOD;
//         require(this.dayDifferance() <= STAGES + THERSHOLD, "Game Ended !");
//         _;
//     }

//     modifier GameInitialized() {
//         GameStatus memory _gameStatus = GameStatusInitialized[gameIdCounter];
//         require((_gameStatus.startAt > 0 && block.timestamp >= _gameStatus.startAt),"Game start after intialized time.");
//         _;
//     }
// }
