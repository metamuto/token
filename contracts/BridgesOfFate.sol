// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// contract squidGame is Ownable {
//     using SafeMath for uint256;
//     using Counters for Counters.Counter;
//     IERC20 public token;
//     IERC721 public seriesOne;
//     IERC721 public seriesTwo;

//     Counters.Counter private _tokenIds;
//     Counters.Counter private _daysCounter;
//     Counters.Counter private _hybirdLevel;
//     Counters.Counter private _adminCounter;

//     uint256 private constant TURN_PERIOD = 30; //86400; // 24 HOURS
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

//     // uint256 public start_period = 0; // beacuse start_period period are noted in when Admin Game
//     uint256 public randomNumber;
//     uint256 public hybirdLevelCounter;
//     uint256 adminCounter;
//     uint8 private clientCount;

//     address[] private winnersArray;
//     // 0 =========>>>>>>>>> Owner Address
//     // 1 =========>>>>>>>>> community vault Address
//     address[] private Contracts = [
//         0xBE0c66A87e5450f02741E4320c290b774339cE1C,
//         0x1eF17faED13F042E103BE34caa546107d390093F
//     ];

//     // Log the event about a deposit being made by an address and its amount
//     event LogDepositMade(address indexed accountAddress, uint256 amount);
//     event initialized(uint256 counter, uint256 startAt);

//     struct GameMember {
//         bool chooes_side;
//         uint256 startAt;
//         uint256 day;
//         uint256 stage;
//         uint256 level;
//         uint256 score;
//         bool resumeStatus;
//         bool feeStatus;
//     }

//     struct Admin {
//         uint256 startAt;
//         uint256 day;
//         uint256 GameLevel;
//         bool hybirdLevelStatus;
//     }

//     // Nft Owner Hash

//     mapping(bytes32 => GameMember) public Player;
//     mapping(uint256 => Admin) public adminInitialized;
//     mapping(uint256 => uint256) public RandomNumber;
//     mapping(address => uint256) private balances;
//     mapping(address => uint256) private winnerbalances;
//     mapping(address => uint256) private ownerbalances;
//     mapping(address => uint256) private vaultbalances;
//     //Series One && Series Two Nft Holder Count's.(****Make Seperate Count if require)
//     mapping(address => uint256) public nftHoldersCount;

//     // mapping(address => uint256) public nftHoldersSeriesTwoCount;

//     /*
//      * @notice Admin initialize Game into Smart contract
//      */

//     function initialize(
//         uint256 _startAT,
//         bool _hybirdStatus,
//         uint256 _gameLevel
//     ) public onlyOwner {
//         adminCounter = _adminCounter.current();
//         Admin memory _admin = adminInitialized[adminCounter];
//         _admin.startAt = _startAT;
//         _admin.hybirdLevelStatus = _hybirdStatus;
//         _admin.GameLevel = _gameLevel;
//         if (_gameLevel == 2 && _hybirdStatus == true) {
//             randomNumber = 0;
//         }
//         _admin.day += 1;
//         adminInitialized[adminCounter] = _admin;
//         emit initialized(adminCounter, block.timestamp);
//     }

//     /*
//      * @dev Entery Fee for series one.
//      * @param _nftId
//      */
//     function enteryFee(uint256 _nftId) public {
//         bytes32 playerId = this.computeNextPlayerIdForHolder(
//             msg.sender,
//             _nftId,
//             1
//         );
//         //count's 1++;b
//         GameMember memory _member = Player[playerId];
//         uint256 currentVestingCount = nftHoldersCount[msg.sender];
//         nftHoldersCount[msg.sender] = currentVestingCount.add(1);
//         _member.feeStatus = true;
//         _member.resumeStatus = true;
//         _member.day += 1;
//         Player[playerId] = _member;
//     }

//     /**
//      * @dev Entery Fee for series Two.
//      */
//     function enteryFeeSeriesTwo(uint256 _nftId) public payable {
//         bytes32 playerId = this.computeNextPlayerIdForHolder(
//             msg.sender,
//             _nftId,
//             2
//         );
//         //count's 1++;b
//         GameMember memory _member = Player[playerId];
//         uint256 currentVestingCount = nftHoldersCount[msg.sender];
//         nftHoldersCount[msg.sender] = currentVestingCount.add(1);
//         _member.feeStatus = true;
//         _member.resumeStatus = true;
//         _member.day += 1;
//         Player[playerId] = _member;
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
//     ) public pure returns (bytes32) {
//         return keccak256(abi.encodePacked(holder, _nftId, _sersionIndex));
//     }

//     // generate a randomish  number between 0 and 10.
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

//     /*
//         0 --false-- Indicate left side
//         1 --true-- Indicate right side
//     */
//     function participateInGame(
//         bool _chooes_side,
//         bytes32 playerId,
//         uint256 _adminMappingCounter
//     ) public GameInitialized After24Hours(playerId) {
//         GameMember memory _member = Player[playerId];
//         // uint256 calTimer = block.timestamp - _member.startAt;
//         // // Jump after 24 hours.
//         // require(calTimer >= 50, "Jump after 1 mintues.");
//         Admin memory _admin = adminInitialized[_adminMappingCounter];
//         start_period = block.timestamp;

//         require(
//             _member.day >= 1 && _member.resumeStatus == true,
//             "You are Fail"
//         );

//         if (_admin.GameLevel == 1) {
//             require(STAGES >= _member.stage, "Reached maximum");
//             if (randomNumber <= 0) {
//                 randomNumber = random() * 1e9;
//                 _member.score = randomNumber;
//                 _member.chooes_side = _chooes_side;
//             }
//             _member.day += 1;

//             //
//             _member.level = 1;

//             // level update when check progress function run
//             _member.stage += 1;

//             _member.startAt = block.timestamp;
//             _member.resumeStatus = true;
//         } else if (_admin.GameLevel == 2 && _admin.hybirdLevelStatus == true) {
//             // require(LEVELSTAGES >= _member.stage, "Reached maximum");
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
//             }

//             // use this private variable to check this (STAGES + LEVELSTAGES) constant value reach or not if reach then
//             //use  start the hybird Level

//             // if (hybirdLevelCounter <= 0) {
//             // hybirdLevelCounter = random() * 1e9;
//             // }

//             _member.stage += 1;
//             _member.level = 2;
//             _member.day += 1;
//             _member.chooes_side = _chooes_side;
//         }

//         // use this private variable to check this (STAGES + LEVELSTAGES) constant value reach or not if reach then
//         //use  start the hybird Level
//         _level += 1;
//         Player[playerId] = _member;
//     }

//     //UpdateAdmin
//     function updateAdmin() internal {
//         Admin memory _admin = adminInitialized[adminCounter];
//         _admin.day += 1;
//         adminInitialized[adminCounter] = _admin;
//     }

//     function checkProgres(bytes32 playerId, uint256 _adminMappingCounter)
//         public
//         returns (string memory, uint256)
//     {
//         uint256 period_differance = block.timestamp - start_period;
//         // Admin memory _admin = adminInitialized[_adminMappingCounter];
//         if (period_differance > TURN_PERIOD) {
//             // if (_admin.GameLevel == 1) {
//             if (randomNumber > 50e9) {
//                 uint256 daysCounter = _daysCounter.current();
//                 _daysCounter.increment();
//                 RandomNumber[daysCounter] = randomNumber = 0;
//                 return ("Complete with safe :)", 0);
//             } else {
//                 // transferFrom(msg.sender,address(this),0);
//                 randomNumber = 0;
//                 GameMember memory _member = Player[playerId];
//                 _member.resumeStatus = false;
//                 _member.stage -= 1;
//                 Player[playerId] = _member;
//                 return ("Complete with unsafe :)", 0);
//             }
//             // } else if (
//             //     _admin.GameLevel == 2 && _admin.hybirdLevelStatus == true
//             // ) {
//             //     if (randomNumber > 50e9) {
//             //         uint256 daysCounter = _daysCounter.current();
//             //         _daysCounter.increment();
//             //         RandomNumber[daysCounter] = randomNumber = 0;
//             //         return ("Complete with safe :)", 0);
//             //     } else {
//             //         // transferFrom(msg.sender,address(this),0);
//             //         randomNumber = 0;
//             //         GameMember memory _member = Player[playerId];
//             //         _member.resumeStatus = false;
//             //         _member.stage -= 1;
//             //         Player[playerId] = _member;
//             //         return ("Complete with unsafe :)", 0);
//             //     }
//             // }
//             // on Admin record increment 1 day.
//             // updateAdmin();
//         } else {
//             return ("You are in progress.Please Wait !", 0);
//         }
//     }

//     // function buyBack(uint256 _amount) public {
//     //     require(
//     //         IERC20(token).balanceOf(msg.sender) == _amount,
//     //         "Insuffient amount."
//     //     );
//     //     IERC20(token).transfer(address(this), _amount);
//     //     GameMember memory _member = Player[msg.sender];
//     //     _member.status = true;
//     // }

//     //    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
//     //        baseTokenURI = _baseTokenURI;
//     //    }

//     // function withdraw() public onlyOwner {
//     //     require(IERC20(token).balanceOf(msg.sender) > 0, "Insuffient amount.");
//     //     IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(msg.sender));
//     // }

//     // function setToken(IERC20 _token) public onlyOwner {
//     //     token = _token;
//     // }

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

//     // @notice Just reads balance of the account requesting, so "constant"
//     // @return The balance of the user
//     function balance() public view returns (uint256) {
//         return balances[msg.sender];
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

//     /*
//      * @notice Deposit ether into Smart contract
//      * @dev Select Gaming Level's And only contract select Level (hybird or sample).
//      * @param type The type of game which one currently in working.
//      * @param status The type of game which one currently in working.
//      * @return The balance of the user after the deposit is made
//      */

//     function deposit() public payable returns (uint256) {
//         if (Fee == msg.value) balances[msg.sender] += msg.value;
//         emit LogDepositMade(msg.sender, msg.value);
//         return balances[msg.sender];
//     }

//     // @return The balance of the Simple Smart contract contract
//     function treasuryBalance() public view returns (uint256) {
//         return address(this).balance;
//     }

//     function withdraw(uint8 withdrawtype) public returns (bool) {
//         // Check enough balance available, otherwise just return false
//         if (withdrawtype == 0) {
//             //owner
//             require(Contracts[0] == msg.sender, "Only Owner use this");
//             _withdraw(ownerbalances[msg.sender]);
//             return true;
//         } else if (withdrawtype == 1) {
//             //vault
//             require(Contracts[1] == msg.sender, "Only vault use this");
//             _withdraw(ownerbalances[msg.sender]);
//             return true;
//         } else {
//             //owners
//             _withdraw(ownerbalances[msg.sender]);
//             return true;
//         }
//     }

//     /*
//      * @notice Calculate the numebr of days after initialize the game into Smart contract
//      * @dev if user enter into the advance stage mediun way after game start.
//      * @return They return buyback price curve price in eth
//      */

//     function calculateBuyBackIn() public returns (uint256) {
//         // adminCounter = _adminCounter.current();
//         // Admin memory _admin = adminInitialized[adminCounter];
//         //calculate the number of days 86400
//         // uint256 days_ = (block.timestamp.sub(_admin.startAt)).div(50);
//         uint256 days_ = this.dayDifferance();
//         // for (uint256 i = 0; i < buy_back.length; i++) {
//         if (days_ <= buy_back.length) {
//             return buy_back[days_ - 1];
//         } else {
//             uint256 lastIndex = buy_back.length - 1;
//             return buy_back[lastIndex];
//         }
//         // else if (buy_back.length >= i) {
//         //                 uint lastIndex = buy_back.length-1;
//         // return buy_back[lastIndex];
//         //         }
//         // }
//         // return 0;
//     }

//     /*
//      * @notice Calculate the numebr of days.
//      * @dev Read functon.
//      * @return They return number of days
//      */
//     function dayDifferance() public returns (uint256) {
//         adminCounter = _adminCounter.current();
//         Admin memory _admin = adminInitialized[adminCounter];
//         uint256 day_ = (block.timestamp - _admin.startAt) / 50;
//         //86400;
//         return day_;
//     }

//     /*
//      * @dev getCurrentTime function returns the current block.timestamp
//      */
//     function getCurrentTime() public view returns (uint256) {
//         return block.timestamp;
//     }

//     // Cross Chain Bridging
//     // Addd modifier to check player have  NFT

//     modifier After24Hours(bytes32 playerId) {
//         GameMember memory _member = Player[playerId];
//         uint256 calTimer = block.timestamp - _member.startAt;
//         // Jump after 24 hours.
//         require(calTimer >= 50, "Jump after 1 mintues.");
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
//         Admin memory _admin = adminInitialized[adminCounter];
//         require(
//             (_admin.startAt > 0 && block.timestamp >= _admin.startAt),
//             "Game start after intialized time."
//         );
//         _;
//     }
// }
