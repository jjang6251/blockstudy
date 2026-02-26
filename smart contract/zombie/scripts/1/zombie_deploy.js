const { ethers } = require("ethers");
const hre = require("hardhat");

async function main() {
    const artifact = await hre.artifacts.readArtifact("ZombieFactory");
    const abi = artifact.abi;
    const bytecode = artifact.bytecode;

    const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    const deployer = wallet.address;

    console.log("deployer adress...", deployer);

    const factory = new ethers.ContractFactory(abi, bytecode, wallet);
    const zombie = await factory.deploy();
    
    console.log("deploying...", zombie.target);
}

main().then(() => process.exit(0).catch(error => {
    console.error(error);
    process.exit(1);
}))