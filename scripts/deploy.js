const { ethers, upgrades } = require('hardhat')
// const hre = require('hardhat')


async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    //Smaple
    // const squidGameTest = await hre.ethers.getContractFactory("contracts/BridgesOfFateTestoptmizeV7.sol:BridgesOfFate");
    // const _squidGameTest = await squidGameTest.deploy("0xbB7b5004e80E28Cb384EC44612a621A6a74f92b9");
    // await _squidGameTest.deployed();
    // console.log(`squid Game deployed to: ${_squidGameTest.address}`);
    // await hre.run("verify:verify", {
    //     address: _squidGameTest.address,
    //     constructorArguments: [
    //         "0xbB7b5004e80E28Cb384EC44612a621A6a74f92b9"
    //     ],
    // });

        // console.log('-- Exchange TOKEN CONTRACT --');
    const Exchange = await ethers.getContractFactory("Exchange");
    const _exchange = await upgrades.deployProxy(Exchange);
    await _exchange.deployed();
    let _exchangeImplementation = await upgrades.erc1967.getImplementationAddress(_exchange.address);
    let _exchangeProxyAdmin = await upgrades.erc1967.getAdminAddress(_exchange.address);
    console.log('ALORA TOKEN CONTRACT: ',_exchange.address);
    console.log('IMPLEMENTATION: ',_exchangeImplementation)
    console.log('PROXY ADMIN: ',_exchangeProxyAdmin)

    

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



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
