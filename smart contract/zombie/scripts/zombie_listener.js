require("dotenv").config();
const { ethers } = require("ethers");
const hre = require("hardhat");

async function main() {
    const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);

    const artifact = await hre.artifacts.readArtifact("ZombieFactory");
    const abi = artifact.abi;


    /**
        [결론]
        ✔ 읽기 / 이벤트 감지 → provider만 있으면 됨  
        ✔ 트랜잭션 보내기(상태 변경) → wallet(= signer) 필요
     */
    const zombieFactory = new ethers.Contract(
        "0x20935a9c801db6E57AAa5C187697e6b020E15077",
        abi,
        provider // 👈 리스너는 wallet 말고 provider만 써도 됨
    );

    console.log("👂 Listening for NewZombie events...");

    zombieFactory.on("NewZombie", (zombieId, name, dna, event) => {
        console.log("🧟 좀비 생성됨!");
        console.log("zombieId:", zombieId.toString());
        console.log("name:", name);
        console.log("dna:", dna.toString());
        console.log("blockNumber:", event.log.blockNumber);
    });
}

main().catch(console.error);