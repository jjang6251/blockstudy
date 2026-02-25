// ethers: 이더리움과 상호작용(지갑, RPC, 컨트랙트 배포/호출)을 위한 라이브러리
const { ethers } = require("ethers");

// hre(Hardhat Runtime Environment): Hardhat의 런타임 객체.
// artifacts(컴파일 산출물) 읽기, 네트워크 설정, 플러그인 기능 등을 제공
const hre = require("hardhat");

async function main() {
  // ✅ 1) Hardhat artifacts에서 "MapleNFTS" 컨트랙트의 빌드 결과(JSON)를 읽어옴
  // - "MapleNFTS"는 Solidity 파일 내 `contract MapleNFTS { ... }`의 컨트랙트 이름
  // - artifacts 안에 abi, bytecode 등이 포함되어 있음
  const artifact = await hre.artifacts.readArtifact("MapleNFTS");

  // ✅ 2) ABI(Application Binary Interface)
  // - JS에서 컨트랙트의 함수/이벤트를 호출하기 위한 “인터페이스”
  // - 예: mint(), ownerOf(), setPrice() 같은 함수 시그니처 정보가 들어있음
  const abi = artifact.abi;

  // ✅ 3) Bytecode
  // - EVM에 배포될 실제 실행 코드(컴파일된 바이트코드)
  // - ContractFactory가 이 bytecode를 이용해서 컨트랙트를 배포함
  const bytecode = artifact.bytecode;

  // ✅ 4) JsonRpcProvider 생성
  // - SEPOLIA_RPC_URL: Sepolia 네트워크에 붙는 RPC 엔드포인트(Infura/Alchemy 등)
  // - 이 provider를 통해 체인에 읽기 요청(조회) 및 tx 전송을 수행할 수 있음
  const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL);

  // ✅ 5) Wallet 생성
  // - PRIVATE_KEY로 지갑을 만들고 provider에 연결
  // - 이 wallet이 트랜잭션에 서명하고 전송할 "서명자(signer)" 역할을 함
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  // ✅ 6) 배포자 주소 확인
  // - wallet.address는 private key에서 파생된 공개 주소
  // - 이 주소가 배포 비용(가스)을 지불함
  const deployer = wallet.address;
  console.log("deployer address", deployer);

  // ✅ 7) ContractFactory 생성
  // - (abi + bytecode + signer)를 묶어서 “배포 도구”를 만든 것
  // - deploy(...)를 호출하면 컨트랙트 생성 트랜잭션을 만들어서 네트워크에 보냄
  const factory = new ethers.ContractFactory(abi, bytecode, wallet);

  // ✅ 8) subscriptionID 준비
  // ChainLink VRF ID 값
  const subscriptionID = ethers.toBigInt("51072396844416215303992335196748623877629988781204266923410875530134572365360");

  // ✅ 9) 컨트랙트 배포
  // - deploy(subscriptionID)는 컨트랙트의 constructor 인자에 subscriptionID를 전달한다는 의미
  // - 생성된 트랜잭션이 네트워크에 전송되고, 채굴되면 컨트랙트가 만들어짐
  const subConsumer = await factory.deploy(subscriptionID);

  // ✅ 10) 배포된 컨트랙트 주소 출력
  // - ethers v6에서는 배포된 주소가 보통 `contract.target`에 있음
  console.log("deploying...", subConsumer.target);

  // 💡 참고(권장): 실제로 배포가 채굴될 때까지 기다리고 싶으면
  // await subConsumer.waitForDeployment();
  // console.log("deployed at:", await subConsumer.getAddress());
}

// main 실행 후 정상 종료/에러 처리
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });