// contracts/MateMuto.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/IUniswapV2Factory.sol";
import "./interface/IUniswapV2Pair.sol";
import "./interface/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MateMuto is ERC20,Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public uniswapV2Router;    
    
    address public uniswapV2Pair;
    
    address private _owner;
    address private _deadAddress;
    
    uint32 public transferTaxRate;
    
    uint256 public tokensPerEth = 0.001 ether;
    uint256 private accumulatedOperatorTokensAmount;

    bool private _inSwapAndLiquify;

    mapping(address => bool) public blacklist;    
    
    event BuyAmount(address buyer,uint256 amount);
    event LiquidityAdded(uint256 tokenAmount, uint256 ethAmount);
    event UniswapV2RouterUpdated(address sender, address router, address uinSwapPair);
    event SwapAndLiquify(uint256 halfLiquidityAmount, uint256 newBalance, uint256 otherhalf);

    constructor(address _dead) ERC20("MutoToken", "MT") {
        _deadAddress = _dead;
        _owner =  msg.sender;
    }
    receive() external payable {}

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }
 
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
        address(this),
        tokenAmount,
        0, // slippage is unavoidable
        0, // slippage is unavoidable
        _owner,
        block.timestamp
        );
        emit LiquidityAdded(tokenAmount, ethAmount);
    }

    function swapAndLiquify() private lockTheSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (contractTokenBalance >= accumulatedOperatorTokensAmount) {
            contractTokenBalance = contractTokenBalance.sub(accumulatedOperatorTokensAmount);
            if (contractTokenBalance > 0) {
                uint256 liquifyAmount = contractTokenBalance;
                uint256 half = liquifyAmount.div(2);
                uint256 otherHalf = liquifyAmount.sub(half);
                uint256 initialBalance = address(this).balance;
                swapTokensForEth(half);
                uint256 newBalance = address(this).balance.sub(initialBalance);
                addLiquidity(otherHalf, newBalance);
                emit SwapAndLiquify(half, newBalance, otherHalf);
            }
        }   
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }


    function buyTokens() public payable  {
        require(msg.value > 0, "You need to send some Eth to proceed");
        uint256 amountToBuy = (msg.value * 1e18) / tokensPerEth;
        _mint(msg.sender, (msg.value * 1e18) / tokensPerEth);
        emit BuyAmount(msg.sender,amountToBuy);
    }

    function sellTokens(uint256 tokenAmountToSell) public {
        require(tokenAmountToSell > 0,"Specify an amount of token greater than zero");
        require(balanceOf(msg.sender) >= tokenAmountToSell,"You have insufficient tokens");
        uint256 amountOfEthToTransfer = (tokenAmountToSell * tokensPerEth) / 1e18;
        uint256 ownerEthBalance = address(this).balance;
        require(ownerEthBalance >= amountOfEthToTransfer,"Vendor has insufficient funds");
        bool sent = transferFrom(msg.sender,_deadAddress,tokenAmountToSell);
        require(sent, "Failed to transfer tokens from user to vendor");
        payable(msg.sender).transfer(amountOfEthToTransfer);
        require(sent, "Failed to send Eth to the user");
    }

    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "No Eth present in Vendor");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to withdraw");
    }

    function treasuryBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function treasuryMinter(address _minter, uint256 _amount) public onlyOwner {
        _mint(_minter, _amount);
    }

    function addBlacklist(address _account) public onlyOwner {
        blacklist[_account] = true;
    }
    
    function updateRouter(address _router) public onlyOwner {
        require(uniswapV2Pair != address(0), "Token:Invalid pair");
        uniswapV2Router = IUniswapV2Router02(_router);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
        emit UniswapV2RouterUpdated(msg.sender, address(uniswapV2Router), uniswapV2Pair);
    }

    function setTransferTaxRate(uint32 _transferTaxRate) public onlyOwner {
        transferTaxRate = _transferTaxRate;
    }
}