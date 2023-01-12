const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

//   const DefiSwapRouter02 = await hre.ethers.getContractFactory("DefiSwapRouter02");
//   const _defiSwapRouter02 = await DefiSwapRouter02.deploy("0x0B53855C3da5f100f85E14E72b73734735061f33","0x4F96C34ad9ef99F7D6d30D699281F68Ed146085E");
//   await _defiSwapRouter02.deployed();

//   console.log("DefiSwapRouter02 Call  Address:", _defiSwapRouter02.address);
//   await hre.run("verify:verify", {
//     address: _defiSwapRouter02.address,
//     constructorArguments: [
//       "0x0B53855C3da5f100f85E14E72b73734735061f33",
//       "0x4F96C34ad9ef99F7D6d30D699281F68Ed146085E"
//     ],
//   });
   https://testnet.snowtrace.io/address/0xD2ebFE4aeB9257B4DbdB9E8966CB44089CeF6cEa#code



    

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
