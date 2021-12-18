const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('SantaWars');

  const gameContract = await gameContractFactory.deploy(
    ["Santa", "Gingerbread Man", "Snowman", "Grinch", "Devil", "Rudolph"],
    ["https://i.imgur.com/JktQSET.png",
      "https://i.imgur.com/BEtfRao.png",
      "https://i.imgur.com/i4G9h22.png",
      "https://i.imgur.com/xNgesuL.png",
      "https://i.imgur.com/0yEPWx8.png",
      "https://i.imgur.com/z6XcNvu.png"],
    [1300, 1200, 1250, 1200, 1000, 800],
    [18, 20, 18, 30, 24, 36],
    [24, 30, 20, 16, 10, 16],
  );

  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  // let txn;
  // txn = await gameContract.mintCharacterNFT(0);
  // await txn.wait();

  // txn = await gameContract.mintCharacterNFT(1);
  // await txn.wait();

  console.log("Done deploying and minting")
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();