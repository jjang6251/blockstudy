const axios = require('axios');
const dotenv = require('dotenv');
dotenv.config();
const { ethers } = require('ethers');
const hre = require("hardhat");

let response = null;
new Promise(async (resolve, reject) => {
    try {
        response = await axios.get('https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest?symbol=BTC', {
            headers: {
                'X-CMC_PRO_API_KEY': process.env.CMC_API_KEY,
            },
        });
    } catch (ex) {
        response = null;

        console.log(ex);
        reject(ex);
    }
    if (response) {
        const json = response.data;

        const bitcoin = json.data.BTC.find(coin => coin.name === "Bitcoin");
        console.log(bitcoin);

        if (bitcoin && bitcoin.quote && bitcoin.quote.USD) {
            // console.log("Bitcoin USD data: ");
            // console.log(JSON.stringify(bitcoin.quote.USD, null, 2));
            const realPrice = bitcoin.quote.USD.price;
            console.log("real price: ", realPrice);

            const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);
            const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
            const artifact = await hre.artifacts.readArtifact("FastcampusOracle");
            const abi = artifact.abi;
            const bytecode = artifact.bytecode;
            const oracle = new ethers.Contract("0x5052cf432062daf5f37D98bda62D7d96ed425b85", abi, wallet);
            const ethersPrice = ethers.parseEther(realPrice.toString());
            const owner = await oracle.owner();
            const signerAddress = await wallet.getAddress();

            console.log("컨트랙트 Owner:", owner);
            console.log("현재 실행 지갑:", signerAddress);

            if (owner.toLowerCase() !== signerAddress.toLowerCase()) {
                console.error("에러: 현재 지갑은 권한이 없습니다!");
            }
            const tx = await oracle.setPrice(ethersPrice);
            const reciept = await tx.wait();
            console.log(reciept);
            const price = await oracle.getPrice();
            console.log("oracle get price:", price);
            resolve(bitcoin.quote.USD);
        } else {
            console.log("Bitcoin data not found in response");
            console.log("Available BTC symbols:", json.data.BTC.map(coin => coin.name));
            reject(new Error("Bitcoin data not found"));
        }
    }
})

