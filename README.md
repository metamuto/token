# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```


# SeriesOne
https://testnet.snowtrace.io/address/0xd7d3c8ba71d781dba927cc98c32412bfa4766c73#readContract
# SeriesTwo
https://testnet.snowtrace.io/address/0x296db2c8f2c97fe53d7e60c8cd0ca1aba4ac3730#code

## Change Variable Status before mainnet deployment.
# TURN_PERIOD
Change the turn period 50 to 86400 mean 24 hour set in the contract.
# STAGES = 5
Change the Stages 5 to 13


# Important Instruction
- random() make internal function at the end
- transferBalance(uint256 _amount) make internal function at the end
