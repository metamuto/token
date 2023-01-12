const { ethers, upgrades } = require('hardhat')
// const hre = require('hardhat')


async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
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


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
