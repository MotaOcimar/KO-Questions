# KO-Questions

A Q&A platform on top of Blockchain.

## Building and Deploying

We recommend you to use [Remix IDE](https://remix.ethereum.org/) to build and deploy your contract.
We also recommend you to use [MetaMask](https://metamask.io/) to manage your accounts.

To do so, just copy the source code from the [`main.sol`](src/main.sol) file and paste it into contracts folder of the Remix IDE.
Compile the `main.sol` file on *Solidity compiler* tab.
Then deploy the contract, go to *Deploy & run transactions* tab, select the correct environment and account and click on *deploy* button.

> ⚠️ Be careful selecting the correct environment and account. You will need to pay for the gas fee.\
> If you don't want to use real money, you can use [ganache](https://trufflesuite.com/ganache/) to run the test network.\
> You can also use Ropsten test network with [test Ether faucet](https://faucet.ropsten.be/).

### Frontend
To view the application, you will first need to copy your deployed contract address into the value of `address` at `contract.json` file.
Then, you can run the application by serving the `/` (root) folder.
> Some changes on `src/main.sol` file will also require to copy the contract abi into the value of `abi` at `contract.json` file.
