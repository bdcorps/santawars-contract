const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('SantaWars');

  const gameContract = await gameContractFactory.deploy(
    ["Santa", "Grinch"],
    ["https://i.imgur.com/JktQSET.png",
      "https://i.imgur.com/xNgesuL.png"],
    [100, 200],
    [200, 50],
    [10, 24],
  );

  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();

  txn = await gameContract.mintCharacterNFT(1);
  await txn.wait();

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