require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.20" }, // For OpenZeppelin and other dependencies
      { version: "0.8.0" },  // For your contracts, if absolutely necessary
    ],
  },
  networks: {
    hardhat: { chainId: 1337 },
    // sepolia: { ... },
  },
};
