require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/127e91b3eaa940d1a9e070cef5cae0b3", //Infura url with projectId
      accounts: ["ea401740910d7b3d12930fb9065e0f5fbae47948acefa3b6310e51720dda6306"] // add the account that will deploy the contract (private key)
     },
     bsc_testnet: {
      url: 'https://data-seed-prebsc-2-s3.binance.org:8545/',
      accounts: ["440331baae95b9bd06329558f61c05cf28f64b50c76e3ba5ae6c0f6179b1db52"] // add the account that will deploy the contract (private key)
     }
   },
   etherscan: {
    apiKey: "UVYT7D7UPKUZH8XFHB1D76TA1E6KGAJCM7" // eth
    //apiKey: "P3A263376TPJHKQ5IXUD4VHUNFQKDJB4G5" // bsc
  },
};
