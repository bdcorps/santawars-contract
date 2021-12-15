const main = async () => {
  const [owner, random] = await hre.ethers.getSigners();
  console.log(owner.address, random.address)
  const gameContractFactory = await hre.ethers.getContractFactory('SantaWars');
  const gameContract = await gameContractFactory.deploy(
    ["Santa", "Gingerbread Man", "Snowman", "Grinch", "Devil", "Rudolph"],
    ["https://i.imgur.com/JktQSET.png",
      "https://i.imgur.com/BEtfRao.png",
      "https://i.imgur.com/i4G9h22.png",
      "https://i.imgur.com/xNgesuL.png",
      "https://i.imgur.com/0yEPWx8.png",
      "https://i.imgur.com/z6XcNvu.png"],
    [130, 120, 125, 120, 100, 80],
    [18, 20, 18, 30, 24, 36],
    [24, 30, 20, 16, 10, 16],
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();

  txn = await gameContract.attack(owner.address);
  await txn.wait();

  txn = await gameContract.heal(owner.address);
  await txn.wait();

  // Get the value of the NFT's URI.
  // let returnedTokenUri = await gameContract.tokenURI(1);
  // console.log("Token URI:", returnedTokenUri);

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