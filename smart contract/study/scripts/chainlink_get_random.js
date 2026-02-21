const { ethers } = require("ethers");
const hre = require("hardhat");

async function main() {
    const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

    const artifact = await hre.artifacts.readArtifact("MapleNFTS");
    const abi = artifact.abi;
    const bytecode = artifact.bytecode;

    const contract = new ethers.Contract("0x8Ff4668FD1A89E669c31eac0698f38a7526833aD", abi, wallet);

    // Check if the caller is the owner
    try {
        const owner = await contract.owner();
        console.log("Contract owner", owner);
        console.log("Your address", wallet.address);

        if (owner.toLowerCase() !== wallet.address.toLowerCase()) {
            throw new Error("You are not the owner of the contract. Only the owner can request random words.");
        }
    } catch (error) {
        console.error("Error checking ownership:", error);
        process.exit(1);
    }

    let requestId;
    console.log("Setting up event listeners...");

    //Listen for all relavent events
    contract.on("RequestSent", (reqId, numWords) => {
        requestId = reqId;
        console.log(`\nRequest Sent!`);
        console.log(`Request ID: ${reqId}`);
        console.log(`Number of random words: ${numWords}`);
    });

    contract.on("RequestFulfilled", (reqId, randomWords) => {
        console.log(`\nRequest Fulfilled!`);
        console.log(`Request ID: ${reqId}`);
        console.log(`Random Words: ${randomWords}`);
    });

    contract.on("NFTMinted", (to, tokenId, stats) => {
        console.log(`\nNFT Minted Successfully!`);
        console.log(`Token ID: ${tokenId}`);
        console.log(`Minted to: ${to}`);
        console.log("Stats: ");
        console.log(`- STR: ${stats.STR}`);
        console.log(`- DEX: ${stats.DEX}`);
        console.log(`- INT: ${stats.INT}`);
        console.log(`- LUK: ${stats.LUK}`);
        process.exit(0);
    });

    console.log("chainId:", (await provider.getNetwork()).chainId);

    const code = await provider.getCode(contract.target);
    console.log("code length:", code.length); // "0x"면 2

    // ABI에 함수가 진짜 있는지 확인
    console.log("has requestRandomWords?:", !!contract.interface.getFunction("requestRandomWords"));

    // calldata가 실제로 만들어지는지 확인 (핵심)
    const populated = await contract.requestRandomWords.populateTransaction(false);
    console.log("populated data:", populated.data);

    console.log("subId on contract:", (await contract.s_subscriptionId()).toString());

    console.log("\nRequesting random words...");
    try {
        const tx = await contract.requestRandomWords(false, {
            gasLimit: 900000
        });

        console.log("Transaction hash:", tx.hash);
        console.log("Waiting for transaction confirmation...");

        await tx.wait();
        console.log("\nInitial transaction confirmed!");
        console.log("Waiting for Chainlink VRF to respond (this may take 1-3 minutes)...");

        const checkStatus = async () => {
            if (!requestId) return;
            try {
                const [fulfilled, randomWords] = await contract.getRequestStatus(requestId);
                console.log("\nRequest Status: ");
                console.log(`Fulfilled: ${fulfilled}`);
                if (fulfilled) {
                    console.log(`Random Words: ${randomWords}`);
                }
            } catch (error) {
                console.log("Error checking status: ", error.message);
            }
        };

        // Check status every 30 seconds
        const intervalId = setInterval(checkStatus, 30000);

        // Also check immediately
        await checkStatus();

        console.log("\nChecking status every 30 seconds. Press Ctrl+C to exit.");

        // Keep the script running
        process.stdin.resume();
    } catch (error) {
        console.error("Error details:", error);
        process.exit(1);
    }
}

main().catch(error => {
    console.error(error);
    process.exit(1);
});