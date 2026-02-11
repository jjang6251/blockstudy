const {ethers} = require("ethers");
const hre = require("hardhat");

async function main() {
    const provider = new ethers.JsonRpcProvider(process.env.MONAD_RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

    const artifact = await hre.artifacts.readArtifact("Fastcampus");
    const abi = artifact.abi;
    const bytecode = artifact.bytecode;

    const fastcampus = new ethers.Contract("0x~~~~~", abi, wallet);
    const mint = await fastcampus.mint("0x~~~");
    const receipt = await mint.wait();
    console.log(receipt);
    console.log("minted");
}
main().then(() => process.exit(0).catch(error => {
    console.error(error);
    process.exit(1);
}))