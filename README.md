# santawars-contract

`./hardhat.config.js`
```
require('@nomiclabs/hardhat-waffle');

module.exports = {
  solidity: '0.8.0',
  networks: {
    rinkeby: {
      url: 'ALCHEMY_API',
      accounts: ['PRIVATE_KEY'],
    },
  },
};
```
