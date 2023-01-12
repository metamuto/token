// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const { ethers, upgrades } = require('hardhat')
// const hre = require('hardhat')


async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    /*const squidGame = await hre.ethers.getContractFactory("squidGame");
    const _squidGame = await squidGame.deploy("0xD7d3c8BA71D781dba927cC98c32412BfA4766c73","0x296Db2C8F2c97FE53d7e60C8Cd0cA1aba4ac3730");
    await _squidGame.deployed();
    console.log(`squid Game deployed to: ${_squidGame.address}`);
    await hre.run("verify:verify", {
        address: _squidGame.address,
        constructorArguments: [
          "0xD7d3c8BA71D781dba927cC98c32412BfA4766c73","0x296Db2C8F2c97FE53d7e60C8Cd0cA1aba4ac3730"
        ],
    });*/

    // console.log('-- Exchange TOKEN CONTRACT --');
    // const Exchange = await ethers.getContractFactory("Exchange");
    // const _exchange = await upgrades.deployProxy(Exchange);
    // await _exchange.deployed();
    // let _exchangeImplementation = await upgrades.erc1967.getImplementationAddress(_exchange.address);
    // let _exchangeProxyAdmin = await upgrades.erc1967.getAdminAddress(_exchange.address);
    // console.log('ALORA TOKEN CONTRACT: ',_exchange.address);
    // console.log('IMPLEMENTATION: ',_exchangeImplementation)
    // console.log('PROXY ADMIN: ',_exchangeProxyAdmin)

    

    // const MutoToken = await hre.ethers.getContractFactory("MutoToken");
    // const _MutoToken = await MutoToken.deploy("0x37f4a13f3Af9a8397d09c0Dc3ca508dB6181e492");
    // await _MutoToken.deployed();
    // console.log(`squid Game deployed to: ${_MutoToken.address}`);
    // await hre.run("verify:verify", {
    //     address: _MutoToken.address,
    //     constructorArguments: [
    //         "0x37f4a13f3Af9a8397d09c0Dc3ca508dB6181e492"
    //     ],
    // });
    // D:\Solidity_Office\Projects\squadGame\
    // BridgesOfFateTestV2.sol
    // contracts\BridgesOfFateTestV2.sol
    // D:\Solidity_Office\Projects\squadGame\contracts\BridgesOfFateV3.sol 
    //contracts/BridgesOfFateTestV4.sol:BridgesOfFateTestV4
    // D:\Solidity_Office\Projects\squadGame\contracts\BridgesOfFateTestV5.sol
    // D:\Solidity_Office\Projects\squadGame\contracts\BridgesOfFateTestV6.sol
    // D:\Solidity-Office\Projects\squadGame\contracts\BridgesOfFateTestoptmizeV7.sol
    // D:\Solidity-Office\Projects\squadGame\contracts\BridgesOfFateTestV6.sol
    //Smaple
    const squidGameTest = await hre.ethers.getContractFactory("contracts/BridgesOfFateTestoptmizeV7.sol:BridgesOfFate");
    const _squidGameTest = await squidGameTest.deploy("0xbB7b5004e80E28Cb384EC44612a621A6a74f92b9");
    await _squidGameTest.deployed();
    console.log(`squid Game deployed to: ${_squidGameTest.address}`);
    await hre.run("verify:verify", {
        address: _squidGameTest.address,
        constructorArguments: [
            "0xbB7b5004e80E28Cb384EC44612a621A6a74f92b9"
        ],
    });

    //Hybrid
    // const squidGameTest_hybrid = await hre.ethers.getContractFactory("contracts/BridgesOfFateHybridTestV2.sol:BridgesOfFate");
    // const _squidGameTest_hybrid = await squidGameTest_hybrid.deploy("0xbB7b5004e80E28Cb384EC44612a621A6a74f92b9");
    // await _squidGameTest_hybrid.deployed();
    // console.log(`squid Game deployed to: ${_squidGameTest_hybrid.address}`);
    // await hre.run("verify:verify", {
    //     address: _squidGameTest_hybrid.address,
    //     constructorArguments: [
    //         "0xbB7b5004e80E28Cb384EC44612a621A6a74f92b9"
    //     ],
    // });
    // const squidGameTest = await hre.ethers.getContractFactory("contracts/token.sol:GLDToken");
    // const _squidGameTest = await squidGameTest.deploy();
    // await _squidGameTest.deployed();
    // console.log(`squid Game deployed to: ${_squidGameTest.address}`);
    // await hre.run("verify:verify", {
    //     address: _squidGameTest.address,
    //     constructorArguments: [
    //     ],
    // });

    
    
    // contracts/1155.sol:GameItems
    // const squidGameTest = await hre.ethers.getContractFactory("contracts/1155.sol:MyNFT");
    // const _squidGameTest = await squidGameTest.deploy();
    // await _squidGameTest.deployed();
    // console.log(`squid Game deployed to: ${_squidGameTest.address}`);
    // await hre.run("verify:verify", {
    //     address: _squidGameTest.address,
    //     constructorArguments: [],
    // });

    // const squidGameTest = await hre.ethers.getContractFactory("BridgesOfFateTest");
    // const _squidGameTest = await squidGameTest.deploy("0xbB7b5004e80E28Cb384EC44612a621A6a74f92b9");
    // await _squidGameTest.deployed();
    // console.log(`squid Game deployed to: ${_squidGameTest.address}`);
    // await hre.run("verify:verify", {
    //     address: _squidGameTest.address,
    //     constructorArguments: [
    //         "0xbB7b5004e80E28Cb384EC44612a621A6a74f92b9"
    //     ],
    // });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
