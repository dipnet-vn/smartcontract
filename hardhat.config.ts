import "dotenv/config";
import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ignition-ethers";

// VERIFY_API_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY as string;
const BSCSCAN_API_KEY = process.env.BSCSCAN_API_KEY as string;
const POLYGONSCAN_API_KEY = process.env.POLYGONSCAN_API_KEY as string;
const SCROLLSCAN_API_KEY = process.env.SCROLLSCAN_API_KEY as string;

// MAINNET_RPC_ENDPOINT
const ETHEREUM_RPC_PROVIDER_URL = process.env.ETHEREUM_RPC_PROVIDER_URL as string;
const BSC_RPC_PROVIDER_URL = process.env.BSC_RPC_PROVIDER_URL as string;
const POLYGON_RPC_PROVIDER_URL = process.env.POLYGON_RPC_PROVIDER_URL as string;
const SCROLL_RPC_PROVIDER_URL = process.env.SCROLL_RPC_PROVIDER_URL as string;

// TESTNET_RPC_ENDPOINT
const ETHEREUM_SEPOLIA_RPC_PROVIDER_URL = process.env.ETHEREUM_SEPOLIA_RPC_PROVIDER_URL as string;
const BSC_TESTNET_RPC_PROVIDER_URL = process.env.BSC_TESTNET_RPC_PROVIDER_URL as string;
const SCROLL_SEPOLIA_RPC_PROVIDER_URL = process.env.SCROLL_SEPOLIA_RPC_PROVIDER_URL as string;

// ACCOUNT_DEPLOY_PRIVATE_KEY
const ETHEREUM_DEPLOYER_PRIVATE_KEY = process.env.ETHEREUM_DEPLOYER_PRIVATE_KEY as string;
const BSC_DEPLOYER_PRIVATE_KEY = process.env.BSC_DEPLOYER_PRIVATE_KEY as string;
const POLYGON_DEPLOYER_PRIVATE_KEY = process.env.POLYGON_DEPLOYER_PRIVATE_KEY as string;
const SCROLL_DEPLOYER_PRIVATE_KEY = process.env.SCROLL_DEPLOYER_PRIVATE_KEY as string;
const ETHEREUM_SEPOLIA_DEPLOYER_PRIVATE_KEY = process.env.ETHEREUM_SEPOLIA_DEPLOYER_PRIVATE_KEY as string;
const BSC_TESTNET_DEPLOYER_PRIVATE_KEY = process.env.BSC_TESTNET_DEPLOYER_PRIVATE_KEY as string;
const SCROLL_SEPOLIA_DEPLOYER_PRIVATE_KEY = process.env.SCROLL_SEPOLIA_DEPLOYER_PRIVATE_KEY as string;

const FORK_NETWORK = process.env.FORK_NETWORK;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    }
  },
  ignition: {
    requiredConfirmations: 1
  },
  etherscan: {
    apiKey: {
      etherum: ETHERSCAN_API_KEY,
      bsc: BSCSCAN_API_KEY,
      bscTestnet: BSCSCAN_API_KEY,
      polygon: POLYGONSCAN_API_KEY,
      sepolia: ETHERSCAN_API_KEY,
      scroll: SCROLLSCAN_API_KEY,
      scrollSepolia: SCROLLSCAN_API_KEY
    },
    customChains: [
      {
        network: 'scroll',
        chainId: 534352,
        urls: {
          apiURL: 'https://api.scrollscan.com/api',
          browserURL: 'https://scrollscan.com/',
        },
      },
      {
        network: 'scrollSepolia',
        chainId: 534351,
        urls: {
          apiURL: 'https://api-sepolia.scrollscan.com/api',
          browserURL: 'https://sepolia.scrollscan.com/',
        },
      },
    ]
  },
  networks: {
    hardhat: {
      forking: {
        url: FORK_NETWORK === "ethereum" ? ETHEREUM_RPC_PROVIDER_URL
             : FORK_NETWORK === "bsc" ? BSC_RPC_PROVIDER_URL
             : FORK_NETWORK === "polygon" ? POLYGON_RPC_PROVIDER_URL
             : FORK_NETWORK === "scroll" ? SCROLL_RPC_PROVIDER_URL : "",
      },
      chainId: 1337
    },
    etherum: {
      url: ETHEREUM_RPC_PROVIDER_URL,
      accounts: ETHEREUM_DEPLOYER_PRIVATE_KEY !== "" ? [`0x${ETHEREUM_DEPLOYER_PRIVATE_KEY}`] : []
    },
    bsc: {
      url: BSC_RPC_PROVIDER_URL,
      accounts: BSC_DEPLOYER_PRIVATE_KEY !== "" ? [`0x${BSC_DEPLOYER_PRIVATE_KEY}`] : []
    },
    bscTestnet: {
      url: BSC_TESTNET_RPC_PROVIDER_URL,
      accounts: BSC_TESTNET_DEPLOYER_PRIVATE_KEY !== "" ? [`0x${BSC_TESTNET_DEPLOYER_PRIVATE_KEY}`] : []
    },
    polygon: {
      url: POLYGON_RPC_PROVIDER_URL,
      accounts: POLYGON_DEPLOYER_PRIVATE_KEY !== "" ? [`0x${POLYGON_DEPLOYER_PRIVATE_KEY}`] : []
    },
    scroll: {
      url: SCROLL_RPC_PROVIDER_URL,
      accounts: SCROLL_DEPLOYER_PRIVATE_KEY !== "" ? [`0x${SCROLL_DEPLOYER_PRIVATE_KEY}`] : []
    },
    ethereumSepolia: {
      url: ETHEREUM_SEPOLIA_RPC_PROVIDER_URL,
      accounts: ETHEREUM_SEPOLIA_DEPLOYER_PRIVATE_KEY !== "" ? [`0x${ETHEREUM_SEPOLIA_DEPLOYER_PRIVATE_KEY}`] : []
    },
    scrollSepolia: {
      url: SCROLL_SEPOLIA_RPC_PROVIDER_URL,
      accounts: SCROLL_SEPOLIA_DEPLOYER_PRIVATE_KEY !== "" ? [`0x${SCROLL_SEPOLIA_DEPLOYER_PRIVATE_KEY}`] : [],
      ignition: {
        maxFeePerGasLimit: 50_000_000_000n, // 50 gwei
        maxPriorityFeePerGas: 2_000_000_000n, // 2 gwei,
      },
    }
  }
};

export default config;
