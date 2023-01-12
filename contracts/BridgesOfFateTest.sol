// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// contract BridgesOfFateTest is Ownable, ReentrancyGuard {
//     using SafeMath for uint256;
//     using Counters for Counters.Counter;
//     IERC20 public token;

//     Counters.Counter private _daysCounter;
//     Counters.Counter private _hybirdLevel;
//     Counters.Counter private _tokenCounter;
//     Counters.Counter private _dynamicLevel;
//     Counters.Counter private _adminCounter;

//     uint256 private constant TURN_PERIOD = 300; //Now we are use 5 minute //86400; // 24 HOURS
//     uint256 public start_period = 0; //
//     uint256 private constant STAGES = 2; // 13 stages
//     uint256 private constant LEVELSTAGES = 2; // 5 Level 2 stages
//     // use this private variable to check this (STAGES + LEVELSTAGES) constant value reach or not if reach then
//     //use  start the hybird Level
//     uint256 private _level; // 5 Level 2 stages
//     uint256 private constant _winnerRewarsds = 60;
//     uint256 private constant _ownerRewarsds = 25;
//     uint256 private constant _communityVaultRewarsds = 15;
//     uint256 public constant Fee = 0.01 ether;
//     // buyback price curve

//     uint256[] public buy_back = [
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

//     // uint256 public start_period = 0; // beacuse start_period period are noted in when Admin Game

//     uint256 public randomNumber;
//     uint256 public randomNumForResumePlayer;
//     uint256 public adminCounter;
//     uint256 public hybirdLevelCounter;
//     uint256 public dynamicLevelCounter;

//     uint256 private tokenCounter;
//     uint8 private clientCount;

//     address[] private winnersArray;

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
//         uint256 score;
//         uint256 startAt;
//         bool feeStatus;
//         bool chooes_side;
//         bool resumeStatus;
//     }
//     /*
//      * Admin Use Struct
//      */
//     struct GameStatus {
//         uint256 day;
//         uint256 startAt;
//         uint256 lastJumpAt;
//         uint256 GameLevel;
//         bool dynamic_hybirdLevelStatus;
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
//     mapping(address => mapping(uint256 => uint256)) private PlayerToken; // Current token of the player.

//     //mapping the RandomNumber Againest the Day's
//     mapping(uint256 => uint256) public RandomNumber;

//     //Series One && Series Two Nft Holder Count's.(****Make Seperate Count if require)
//     // mapping(address => uint256) public nftHoldersCount;

//     /*
//      * @notice Admin initialize Game into Smart contract
//      */

//     function initialize(
//         uint256 _startAT,
//         uint256 _gameLevel,
//         bool _dynamicHybirdStatus
//     ) public onlyOwner {
//         _adminCounter.increment();
//         adminCounter = _adminCounter.current();
//         GameStatus memory _admin = GameStatusInitialized[adminCounter];
//         _admin.startAt = _startAT;
//         _admin.dynamic_hybirdLevelStatus = _dynamicHybirdStatus;
//         _admin.GameLevel = _gameLevel;
//         if (_gameLevel == 2 && _dynamicHybirdStatus == true) {
//             randomNumber = 0;
//         }
//         _admin.day += 1;
//         GameStatusInitialized[adminCounter] = _admin;
//         emit Initialized(adminCounter, block.timestamp);
//     }

//     /*
//      * @dev Entery Fee for series one.
//      * @param _nftId
//      */
//     function enteryFee(uint256 _nftId) public {
//         _tokenCounter.increment();
//         tokenCounter = _tokenCounter.current();

//         bytes32 playerId = this.computeNextPlayerIdForHolder(
//             msg.sender,
//             tokenCounter,
//             _nftId,
//             1
//         );

//         PlayerToken[msg.sender][_nftId] = tokenCounter;
//         GameMember memory _member = Player[playerId];
//         // uint256 currentVestingCount = nftHoldersCount[msg.sender];
//         // nftHoldersCount[msg.sender] = currentVestingCount.add(1);
//         _member.day += 1;
//         _member.feeStatus = true;
//         _member.resumeStatus = true;
//         Player[playerId] = _member;
//         emit EntryFee(playerId, _nftId, 1);
//     }

//     /**
//      * @dev Entery Fee for series Two.
//      */
//     function enteryFeeSeriesTwo(uint256 _nftId, uint256 _wrappedAmount) public {
//         require(balanceOfUser(msg.sender) > 0, "You have insufficent balance");
//         _tokenCounter.increment();
//         tokenCounter = _tokenCounter.current();

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
//             tokenCounter,
//             _nftId,
//             2
//         );
//         PlayerToken[msg.sender][_nftId] = tokenCounter;
//         //Create Mapping for the Player which was paid the Fee
//         GameMember memory _member = Player[playerId];
//         // uint256 currentVestingCount = nftHoldersCount[msg.sender];
//         // nftHoldersCount[msg.sender] = currentVestingCount.add(1);
//         _member.day += 1;
//         _member.feeStatus = true;
//         _member.resumeStatus = true;
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
//     ) public {
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
//         GameInitialized
//         After24Hours(playerId)
//     {
//         adminCounter = _adminCounter.current();
//         GameMember memory _member = Player[playerId];
//         GameStatus memory _gameStatus = GameStatusInitialized[adminCounter];

//         if (_gameStatus.startAt > 0) {
//             uint256 period_differance = block.timestamp - _gameStatus.startAt;
//             if (period_differance > TURN_PERIOD) {
//                 updatePlayer(playerId);
//             }
//         }

//         start_period = block.timestamp;

//         require(
//             _member.day >= 1 && _member.resumeStatus == true,
//             "You have been Failed."
//         );

//         if (_gameStatus.GameLevel == 1) {
//             require(STAGES >= _member.stage, "Reached maximum");
//             if (randomNumberForResumePlayer(playerId)) {
//                 if (randomNumForResumePlayer <= 0) {
//                     randomNumForResumePlayer = random() * 1e9;
//                     _gameStatus.lastJumpAt = block.timestamp; // Use this time to Resume Players
//                 }
//                 _member.score = randomNumForResumePlayer;
//             } else {
//                 if (randomNumber <= 0) {
//                     randomNumber = random() * 1e9;
//                     _gameStatus.lastJumpAt = block.timestamp; // Use this time to Resume Players
//                 }
//                 _member.score = randomNumber;
//             }
//             _member.level = 1;
//             _member.startAt = block.timestamp;
//         }

//         _level += 1;
//         _member.stage += 1;
//         _member.day += 1;
//         _member.chooes_side = _chooes_side;
//         Player[playerId] = _member;
//         GameStatusInitialized[adminCounter] = _gameStatus;

//         /** 
//         else if (
//             _gameStatus.GameLevel == 2 &&
//             _gameStatus.dynamic_hybirdLevelStatus == true
//         ) {
//             if (LEVELSTAGES <= _member.stage) {
//                 if (hybirdLevelCounter > 0) {
//                     require(
//                         hybirdLevelCounter != 0 && hybirdLevelCounter < 50e9,
//                         "Hybird Game End"
//                     );
//                 }
//                 hybirdLevelCounter = random() * 1e9;
//             }

//             if (randomNumber <= 0) {
//                 randomNumber = random() * 1e9;
//                 _member.score = randomNumber;
//                 // RandomNumber[daysCounter] = randomNumber;
//             }
//             _member.level = 2;
//         } else if (
//             _gameStatus.GameLevel == 3 &&
//             _gameStatus.dynamic_hybirdLevelStatus == true
//         ) {
//             if (dynamicLevelCounter > 0) {
//                 require(
//                     dynamicLevelCounter != 0 && dynamicLevelCounter < 50e9,
//                     "Hybird Game End"
//                 );
//             }
//             dynamicLevelCounter = random() * 1e9;

//             if (randomNumber <= 0) {
//                 randomNumber = random() * 1e9;
//                 _member.score = randomNumber;
//             }
//             _member.level = 3;
//         }

//         // Use this private variable to check this (STAGES + LEVELSTAGES) constant value reach or not if reach then
//         //use  start the hybird Level

//         */
//     }

//     /**
//      * This internal function use to Resume member of Game decide to use Random number.
//      */
//     function randomNumberForResumePlayer(bytes32 _playerId)
//         internal
//         returns (bool)
//     {
//         adminCounter = _adminCounter.current();
//         GameMember memory _member = Player[_playerId];
//         GameStatus memory _gameStatus = GameStatusInitialized[adminCounter];
//         uint256 timeDifferance = _gameStatus.lastJumpAt - _member.startAt;
//         return timeDifferance >= 600 ? true : false;
//     }

//     //UpdateAdmin
//     function updateAdmin() internal {
//         GameStatus memory _admin = GameStatusInitialized[adminCounter];
//         _admin.day += 1;
//         GameStatusInitialized[adminCounter] = _admin;
//     }

//     function updatePlayer(bytes32 playerId) internal {
//         adminCounter = _adminCounter.current();
//         GameStatus memory _gameStatus = GameStatusInitialized[adminCounter];
//         GameMember memory _member = Player[playerId];
//         /** Reenter into the Game
//          *  1) I have two option one user enter into the Game then set the start_period.
//          *  2) Second when Admin Start the Game GameStatus --> uint256 startAt (USE this)
//          */

//         if (_member.chooes_side == true && _member.score <= 50e9) {
//             //Safe and move next

//             if (_member.startAt > 0) {
//                 _member.resumeStatus = false;
//                 _member.stage -= 1;
//                 randomNumber = 0;
//                 Player[playerId] = _member;
//             }
//         } else if (_member.chooes_side == false && _member.score >= 50e9) {
//             //Safe and move next

//             if (_member.startAt > 0) {
//                 _member.resumeStatus = false;
//                 _member.stage -= 1;
//                 randomNumber = 0;
//                 Player[playerId] = _member;
//             }
//         } else {
//             if (_gameStatus.GameLevel == 1) {
//                 randomNumber = 0;
//             } else if (
//                 _gameStatus.GameLevel == 2 &&
//                 _gameStatus.dynamic_hybirdLevelStatus == true
//             ) {
//                 randomNumber = 0;
//                 hybirdLevelCounter = 0;
//             } else if (
//                 _gameStatus.GameLevel == 3 &&
//                 _gameStatus.dynamic_hybirdLevelStatus == true
//             ) {
//                 randomNumber = 0;
//                 dynamicLevelCounter = 0;
//             }
//         }
//     }

//     /**
//      * Minner function and use to just check the Progress after the Jump
//      */
//     function checkProgres(bytes32 playerId)
//         public
//         view
//         returns (string memory, uint256)
//     {
//         uint256 period_differance = block.timestamp - start_period;
//         GameMember memory _member = Player[playerId];

//         if (period_differance > TURN_PERIOD) {
//             if (
//                 (_member.chooes_side == true && _member.score <= 50e9) ||
//                 (_member.chooes_side == false && _member.score >= 50e9)
//             ) {
//                 return ("Complete with safe :)", 0);
//             } else {
//                 return ("Complete with unsafe :)", 0);
//             }
//         } else {
//             return ("You are in progress.Please Wait !", 0);
//         }
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
//             .div(winnersArray.length);
//         // 25% to ownerΓÇÖs wallet
//         uint256 _ownerAmount = (_ownerRewarsds.mul(_treasuryBalance)).div(100);
//         ownerbalances[Contracts[0]] = _ownerAmount;
//         // 15% goes to community vault
//         uint256 _communityVault = (
//             _communityVaultRewarsds.mul(_treasuryBalance)
//         ).div(100);
//         vaultbalances[Contracts[1]] = _communityVault;

//         for (uint256 i = 0; i < winnersArray.length; i++) {
//             winnerbalances[winnersArray[i]] = _winners;
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
//         // return balances[msg.sender];
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
//             if (days_ <= buy_back.length) {
//                 return buy_back[days_ - 1];
//             } else {
//                 uint256 lastIndex = buy_back.length - 1;
//                 return buy_back[lastIndex];
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
//         // adminCounter = _adminCounter.current();
//         // return 12;
//         GameStatus memory _admin = GameStatusInitialized[adminCounter];
//         if (_admin.startAt > 0) {
//             uint256 day_ = (block.timestamp - _admin.startAt) / 300;
//             //86400;
//             return day_;
//         } else {
//             return 0;
//         }
//     }

//     /*
//      * Generate a randomish number between 0 and 10.
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
//         uint256 _tokenId,
//         uint256 _nftId,
//         uint8 _sersionIndex
//     ) public pure returns (bytes32) {
//         return
//             computePlayerIdForAddressAndIndex(
//                 holder,
//                 _tokenId,
//                 _nftId,
//                 _sersionIndex
//             );
//     }

//     /**
//      * @dev Computes NFT the Game Partipcate identifier for an address and an index.
//      */
//     function computePlayerIdForAddressAndIndex(
//         address holder,
//         uint256 _tokenId,
//         uint256 _nftId,
//         uint8 _sersionIndex
//     ) public pure returns (bytes32) {
//         return
//             keccak256(
//                 abi.encodePacked(holder, _tokenId, _nftId, _sersionIndex)
//             );
//     }

//     /**
//      * @dev Get the Player token ID againest nft owner address & nft ID's.
//      */
//     function getPlayerTokenID(address _nftOwner, uint256 _nftID)
//         public
//         view
//         returns (uint256)
//     {
//         return PlayerToken[_nftOwner][_nftID];
//     }

//     function balanceOfUser(address _accountOf) public view returns (uint256) {
//         return token.balanceOf(_accountOf);
//     }

//     function transferBalance(uint256 _amount) public {
//         token.approve(address(this), _amount);
//         token.transferFrom(msg.sender, address(this), _amount);
//     }

//     /*
//      * @dev getCurrentTime function returns the current block.timestamp
//      */
//     function getCurrentTime() public view returns (uint256) {
//         return block.timestamp;
//     }

//     modifier After24Hours(bytes32 playerId) {
//         GameMember memory _member = Player[playerId];
//         uint256 calTimer = block.timestamp - _member.startAt;
//         // Jump after 24 hours.
//         require(calTimer >= 300, "Jump after 5 mintues.");
//         _;
//     }

//     /*
//      * Paused
//      */

//     modifier Resume(bytes32 playerId) {
//         GameMember memory _member = Player[playerId];
//         require(_member.resumeStatus, "Player is Resume Status.");
//         _;
//     }

//     modifier GameInitialized() {
//         //Check Admin time start = ?
//         GameStatus memory _admin = GameStatusInitialized[adminCounter];
//         require(
//             (_admin.startAt > 0 && block.timestamp >= _admin.startAt),
//             "Game start after intialized time."
//         );
//         _;
//     }
// }
