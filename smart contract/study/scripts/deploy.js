const {ethers} = require("ethers");
const hre = require("hardhat");

async function main() {
    const artifact = await hre.artifacts.readArtifact("Fastcampus");
    const abi = artifact.abi;
    const bytecode = artifact.bytecode;

    const provider = new ethers.JsonRpcProvider(process.env.MONAD_RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
    const balance = await provider.getBalance(wallet.address);
    const deployer = wallet.address;

    console.log("deploying...", deployer)

    const factory = new ethers.ContractFactory(abi, bytecode, wallet);
    const fastcampus = await factory.deploy(deployer);
    console.log("deploying...", fastcampus.target);
}

main().then(() => process.exit(0).catch(error => {
    console.error(error);
    process.exit(1);
}))