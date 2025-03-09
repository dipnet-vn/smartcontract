# NFTGram-Contracts Deployment Guideline
DipNet Smart Contracts Repo

## Install Packages
Run the following command:
```
yarn
```
or
```
npm i
```

## Configure the .env file
Update the `.env` file based on the `.env.example` file provided below:
```
# VERIFY_API_KEY
ETHERSCAN_API_KEY=
BSCSCAN_API_KEY=
POLYGONSCAN_API_KEY=
SCROLLSCAN_API_KEY=

# MAINNET_RPC_ENDPOINT
ETHEREUM_RPC_PROVIDER_URL=
BSC_RPC_PROVIDER_URL=
POLYGON_RPC_PROVIDER_URL=
SCROLL_RPC_PROVIDER_URL=

# TESTNET_RPC_ENDPOINT
ETHEREUM_SEPOLIA_RPC_PROVIDER_URL=
BSC_TESTNET_RPC_PROVIDER_URL=
SCROLL_SEPOLIA_RPC_PROVIDER_URL=

# ACCOUNT_DEPLOY_PRIVATE_KEY
ETHEREUM_DEPLOYER_PRIVATE_KEY=
BSC_DEPLOYER_PRIVATE_KEY=
POLYGON_DEPLOYER_PRIVATE_KEY=
SCROLL_DEPLOYER_PRIVATE_KEY=
ETHEREUM_SEPOLIA_DEPLOYER_PRIVATE_KEY=
BSC_TESTNET_DEPLOYER_PRIVATE_KEY=
SCROLL_SEPOLIA_DEPLOYER_PRIVATE_KEY=
```

## Compile and deploy contracts

### Compile contract

Run the following command:
```
yarn compile
```
or
```
npm run compile
```

### Deploy contract

After deployment, the contract addresses will be recorded in the file `ignition/deployments/<network>/deployed_addresses.json`.

Run the following command:

**Forking**

***We recommend that you first try deploying the system onto mainnet forks.***

| Network | Command |
|---------|---------|
| Ethereum | `yarn deploy:fork-ethereum`<br> or <br>`npm run deploy:fork-ethereum`|
| BSC | `yarn deploy:fork-bsc`<br> or <br>`npm run deploy:fork-bsc`|
| Polygon | `yarn deploy:fork-polygon`<br> or <br>`npm run deploy:fork-polygon`|
| Scroll | `yarn deploy:fork-scroll`<br> or <br>`npm run deploy:fork-scroll`|

**Mainnet**

| Network | Command |
|---------|---------|
| Ethereum | `yarn deploy:mainnet:ethereum`<br> or <br>`npm run deploy:mainnet:ethereum`|
| BSC | `yarn deploy:mainnet:bsc`<br> or <br>`npm run deploy:mainnet:bsc`|
| Polygon | `yarn deploy:mainnet:polygon`<br> or <br>`npm run deploy:mainnet:polygon`|
| Scroll | `yarn deploy:mainnet:scroll`<br> or <br>`npm run deploy:mainnet:scroll`|

**Testnet**

| Network | Command |
|---------|---------|
| Ethereum Sepolia | `yarn deploy:testnet:ethereumSepolia`<br> or <br>`npm run deploy:testnet:ethereumSepolia`|
| BSC Testnet | `yarn deploy:testnet:bscTestnet`<br> or <br>`npm run deploy:testnet:bscTestnet`|
| Scroll Sepolia | `yarn deploy:testnet:scrollSepolia`<br> or <br>`npm run deploy:testnet:scrollSepolia`|

### Verify contract

Run the following command:

**Mainnet**

| Network | Command |
|---------|---------|
| Ethereum | `yarn verify:mainnet:ethereum`<br> or <br>`npm run verify:mainnet:ethereum`|
| BSC | `yarn verify:mainnet:bsc`<br> or <br>`npm run verify:mainnet:bsc`|
| Polygon | `yarn verify:mainnet:polygon`<br> or <br>`npm run verify:mainnet:polygon`|
| Scroll | `yarn verify:mainnet:scroll`<br> or <br>`npm run verify:mainnet:scroll`|

**Testnet**

| Network | Command |
|---------|---------|
| Ethereum Sepolia | `yarn verify:testnet:ethereumSepolia`<br> or <br>`npm run verify:testnet:ethereumSepolia`|
| BSC Testnet | `yarn verify:testnet:bscTestnet`<br> or <br>`npm run verify:testnet:bscTestnet`|
| Scroll Sepolia | `yarn verify:testnet:scrollSepolia`<br> or <br>`npm run verify:testnet:scrollSepolia`|

Copyright (C) 2024 EZCON Inc. All Rights Reserved.
