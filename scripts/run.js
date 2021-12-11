const main = async () => {
  const [owner, random] = await hre.ethers.getSigners();
  console.log(owner.address, random.address)
  const gameContractFactory = await hre.ethers.getContractFactory('SantaWars');
  const gameContract = await gameContractFactory.deploy(
    ["Santa", "Grinch"],
    ["https://i.imgur.com/pKd5Sdk.png",
      "https://i.imgur.com/xVu4vFL.png"],
    [100, 200],
    [200, 50],
    [10, 24],
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