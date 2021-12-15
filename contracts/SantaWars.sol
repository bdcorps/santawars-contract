pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract SantaWars is ERC721 {

  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint attackDamage;
    uint healingPower;
  }

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint public deadlineTime;
  CharacterAttributes[] defaultCharacters;

  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  mapping(address => uint256) public nftHolders;
  uint public totalNFTHolders;

  address[] allPlayers;
  mapping(address => bool) userExists;

  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    uint[] memory characterHealingPwr
  )
    ERC721("Christmasers", "CRMS")
  {
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i],
        healingPower: characterHealingPwr[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
    
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }

    deadlineTime = 1640455200;

    _tokenIds.increment();
  }

// _characterIndex -> which character you want to mint
  function mintCharacterNFT(uint _characterIndex) external {

  require (
    !userExists[msg.sender],
    "Error: You already own an NFT"
  );

    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);

    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage,
      healingPower: defaultCharacters[_characterIndex].healingPower
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
    nftHolders[msg.sender] = newItemId;
    allPlayers.push(msg.sender);
    userExists[msg.sender] = true;

    _tokenIds.increment();

    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
  CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

  string memory strHp = Strings.toString(charAttributes.hp);
  string memory strMaxHp = Strings.toString(charAttributes.maxHp);
  string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);
  string memory strHealingPower = Strings.toString(charAttributes.healingPower);

  string memory json = Base64.encode(
    bytes(
      string(
        abi.encodePacked(
          '{"name": "',
          charAttributes.name,
          ' -- NFT #: ',
          Strings.toString(_tokenId),
          '", "description": "This is an NFT that lets people play in the game SantaWars game", "image": "',
          charAttributes.imageURI,
          '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ', strAttackDamage,'}, { "trait_type": "Healing Power", "value": ', strHealingPower,'} ]}'
        )
      )
    )
  );

  string memory output = string(
    abi.encodePacked("data:application/json;base64,", json)
  );
  
  return output;
}

function attack(address targetAddress) public {
  uint time = block.timestamp;
  require (
    time < deadlineTime,
    "Error: contract was only valid until Dec 25, 2021."
  );

  uint256 nftTokenIdOfTarget = nftHolders[targetAddress];
  CharacterAttributes storage target = nftHolderAttributes[nftTokenIdOfTarget];

  uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
  CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

  console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
  console.log("Target %s has %s HP and %s AD", target.name, target.hp, target.attackDamage);
  
  require (
    player.hp > 0,
    "Error: character must have HP to attack target."
  );

  require (
    target.hp > 0,
    "Error: target must have HP to be attacked."
  );
  
  if (target.hp < player.attackDamage) {
    target.hp = 0;
  } else {
    target.hp = target.hp - player.attackDamage;
  }

  console.log("Player attacked target. New target hp: %s", target.hp);
  emit AttackComplete(target.hp, player.hp);
}

function heal(address targetAddress) public {
  uint time = block.timestamp;
  require (
    time < deadlineTime,
    "Error: contract was only valid until Dec 25, 2021."
  );

  uint256 nftTokenIdOfTarget = nftHolders[targetAddress];
  CharacterAttributes storage target = nftHolderAttributes[nftTokenIdOfTarget];

  uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
  CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];

  console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s Heal Power", player.name, player.hp, player.healingPower);
  console.log("Target %s has %s HP", target.name, target.hp, target.healingPower);
  
  require (
    player.hp > 0,
    "Error: character must have more than 0 HP to heal target."
  );

  require (
    target.hp > 0 ,
    "Error: target must be alive to be healed"
  );
  
  if ((target.maxHp - target.hp) < player.healingPower) {
    target.hp = target.maxHp;
  } else {
    target.hp = target.hp + player.healingPower;
  }

  console.log("Player attacked target. New target hp: %s", target.hp);
  emit HealComplete(target.hp, player.hp);
}

function getNFTOnUser(address targetAddress) public view returns (CharacterAttributes memory) {
  uint256 userNftTokenId = nftHolders[targetAddress];
  if (userNftTokenId > 0) {
    return nftHolderAttributes[userNftTokenId];
  }
  else {
    CharacterAttributes memory emptyStruct;
    return emptyStruct;
   }
}

function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
  return defaultCharacters;
}

function getAllPlayers() public view returns (address[] memory) {
  return allPlayers;
}

event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
event AttackComplete(uint newTargetHp, uint newPlayerHp);
event HealComplete(uint newTargetHp, uint newPlayerHp);
}