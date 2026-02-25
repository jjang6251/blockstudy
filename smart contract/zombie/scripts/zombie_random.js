const { ethers } = require("ethers");
const hre = require("hardhat");

async function main() {
    const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);


    const artifact = await hre.artifacts.readArtifact("ZombieFactory");
    const abi = artifact.abi;

    const zombieFactory = new ethers.Contract(
        "0x20935a9c801db6E57AAa5C187697e6b020E15077", // 배포된 ZombieFactory 컨트랙트 주소
        abi,
        wallet
    );

    //트랜잭션 실행
    const zombie_name = "SungWon";
    console.log(`좀비의 이름은 ${zombie_name}입니다.`);

    const tx = await zombieFactory.createRandomZombie(zombie_name);
    console.log("tx hash: ", tx.hash);

    const receipt = await tx.wait();
    console.log("mined in block:", receipt.blockNumber);
    console.log("receipt.status:", receipt.status); // ✅ 1이면 성공, 0이면 revert
    console.log("receipt.logs.length:", receipt.logs.length);


    // // 이벤트 파싱
    // const iface = new ethers.Interface(abi);

    // const event = receipt.logs
    //     .map((log) => {
    //         try {
    //             return iface.parseLog(log);
    //         } catch {
    //             return null;
    //         }
    //     })
    //     .find((e) => e && e.name === "NewZombie");

    // if (!event) {
    //     console.log("❌ NewZombie event not found");
    //     return;
    // }

    // const zombieId = event.args[0];
    // const name = event.args[1];
    // const dna = event.args[2];

    // console.log("✅ NewZombie event:", {
    //     zombieId: zombieId.toString(),
    //     name: name,
    //     dna: dna.toString(),
    // });

    // // public 배열 getter로 방금 만든 좀비 조회
    // // zombies(uint) -> (string name, uint dna)
    // const z = await zombieFactory.zombies(zombieId);
    // console.log("🔎 zombies[zombieId] =", {
    //     name: z[0],
    //     dna: z[1].toString(),
    // });

}

main().catch((err) => {
    console.error(err);
    process.exitCode = 1;
});