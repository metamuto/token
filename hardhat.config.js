require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");
require('hardhat-contract-sizer');
// require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-solhint");
// require("hardhat-watcher");

module.exports = {
    defaultNetwork: "avalancheTest",
    networks: {
        hardhat: {},
            // rinkeby:{
        //   url: "https://rinkeby.infura.io/v3/4913daa7178a4c77823ddea002c39d00",
        //   accounts: ['a4f96c04ed56df73a0f1b36bcdac8b479f75d08459817435e3b2b95c8d49724c']
        // },
        // rinkeby:{
        //   url: "https://rinkeby.infura.io/v3/4913daa7178a4c77823ddea002c39d00",
        //   accounts: ['f0ce3fbe22b7641885b078618f65a7c6a4bf07652990c8f664222a437765aafc']
        // },
        // testnet: {
        //   url: "https://data-seed-prebsc-1-s1.binance.org:8545",
        //   accounts: ['21ece61053289747b70f0c236f8a76bcd13caf0e25be005502d78bc8290e70d6'],
        // },

        // testnet: {
        //   url: "https://data-seed-prebsc-1-s1.binance.org:8545",
        //   accounts: ['a4f96c04ed56df73a0f1b36bcdac8b479f75d08459817435e3b2b95c8d49724c'],   //cLIent account id
        // },
        avalancheTest: {
            url: "https://api.avax-test.network/ext/bc/C/rpc",
            accounts: ['a4f96c04ed56df73a0f1b36bcdac8b479f75d08459817435e3b2b95c8d49724c']
        },
        // goerli: {
        //     url: "https://goerli.infura.io/v3/",
        //     accounts: ['a4f96c04ed56df73a0f1b36bcdac8b479f75d08459817435e3b2b95c8d49724c']
        // },
        
    },
    watcher: {
        compilation: {
            tasks: ["compile"],
            files: ["./contracts"],
            verbose: true,
        },
        ci: {
            tasks: ["clean", { command: "compile", params: { quiet: true } }, {
                command: "test",
                params: { noCompile: true, testFiles: ["testfile.ts"] }
            }],
        }
    },
    etherscan: {
        // apiKey: "VTJJ86VD6ZKVE3WQBMRE1CGP7HUM4Z8KRC"             //testnet BANance
        // apiKey: "XIBRQWVBQ9965HWXU135TCB1HI6CRDJNWW"                //Rinby
        apiKey: "P69KHY349RFJFUX7NEAYQ6WREVR7VU5KMB"                //alvanche
        // apiKey: "XSG9HXA6DG22CITFJKEA87E73PA12WDP7S"                //goerli 
        
    },
    solidity: {
        compilers: [
            {
                version: "0.4.18"
            },
            {
                version: "0.7.5"
            },
            {
                version: "0.8.0"
            },
            {
                version: "0.6.2"
            },
            {
                version: "0.6.12"
            },
            {
                version: "0.8.2"
            },
            {
                version: "0.6.6"
            },
            {
                version: "0.5.16"
            }, {
                version: "0.8.13"
            }
        ],
        settings: {
            optimizer: {
                enabled: true,
                runs: 800
            }
        }
    },
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts"
    },
    gasReporter: {
        currency: 'CHF',
        gasPrice: 21
      }
}