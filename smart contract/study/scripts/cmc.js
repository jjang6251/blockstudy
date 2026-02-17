const axios = require('axios');
const dotenv = require('dotenv');
dotenv.config();
const{ ethers } = require('hardhat');

let response = null;
new Promise(async (resolve, reject) => {
    try {
        response = await axios.get('//코인마켓 api', {
            headers: {
                'X-CMC_PRO_API_KEY': process.env.CMC_API_KEY,
            },
        });
    } catch(ex) {
        response = null;

        console.log(ex);
        reject(ex);
    }
    if(response) {
        const json = response.data;
        console.log(json);

        const bitcoin = json.data.BTC.find(coin => coin.name === "Bitcoin");

        if (bitcoin && bitcoin.quote && bitcoin.quote.USD) {
            console.log("Bitcoin USD data: ");
            console.log(JSON.stringify(bitcoin.quote.usd, null, 2));
            const realPrice = bitcoin.quote.USD.price;
            console.log("real price: ", realPrice);

            const provider = new ethers.JsonRpcApiProvider(process.env.SEPOLIA_RPC_URL);
            const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
            const artifact = await hre.artifact.readArtifact("FastcampusOracle");
            const abi = artifact.abi;
            const bytecode = artifact.bytecode;
            const oracle = new ethers.Contract("0x~~", abi, wallet);
            const ethersPrice = ethers.parseEther(realPrice.toString());
            const tx = await oracle.setPrice(ethersPrice);
            const reciept = await tx.wait();
            console.log(receipt);
            const price = await oracle.getPrice();
            console.log("price:", price);
            resolve(bitcoin.quote.USD);
        } else {
            console.log("Bitcoin data not found in response");
            console.log("Available BTC symbols:", json.data.BTC.map(coin => coin.name));
            reject(new Error("Bitcoin data not found"));
        }
    }
})

