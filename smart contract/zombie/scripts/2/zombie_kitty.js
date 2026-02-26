const ethers = require("ethers");
const hre = require("hardhat");

async function main() {
    const artifact = await hre.artifacts.readArtifact("ZombieFeeding2");
    const abi = artifact.abi;

    const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

    const zombieFactory = new ethers.Contract("0xd5a761C4B515d49d840d3977cD239e0D5A7cA521",
        abi,
        wallet
    );

    let zombieId = 1;
    let kittyId = 1;

    /**
    
        [1] tx 전송
        ↓
        mempool
        ↓ (기다림)
        validator가 블록에 포함
        ↓
        receipt 생성
        ↓
        tx.wait() resolve
     */
    const tx = await zombieFactory.feedOnKitty(zombieId, kittyId);
    console.log("tx hash: ", tx.hash)
    const receipt = await tx.wait();

}