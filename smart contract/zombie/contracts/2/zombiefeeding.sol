// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./zombiefactory.sol";

/**
    블록체인 상에서 우리가 소유하지 않은 컨트랙트와 우리 컨트랙트가 상호작용을 하려면 우선 인터페이스를 정의해야 한다.

    물론 상호작용하는 함수가 public이나 external로 선언되어 있어야 한다.
 */
interface KittyInterface {
    function getKitty(
        uint256 _id
    )
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

/**
    상속하는 contract는 상속되는 contract의 어떤 public 함수든지 접근이 가능하다.
 */
contract ZombieFeeding is ZombieFactory {
    /**
        크립토 키티 contract와 상호작용을 하기 위해서 크립토 키티 주소를 이용하여 정의한 인터페이스를 사용한다.
     */
    //크립토 키티 주소
    address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    KittyInterface kittyContract = KittyInterface(ckAddress);

    /**
        솔리디티에는 변수를 저장할 수 있는 공간으로 storage와 memory 두 가지가 있다.

        Storage -> 블록체인 상에 영구적으로 저장되는 변수
        Memory -> 임시적으로 저장되는 변수
     */
    function feedAndMultiply(
        uint _zombieID,
        uint _targetDna,
        string memory _species
    ) public {
        require(zombieToOwner[_zombieID] == msg.sender);
        Zombie storage myZombie = zombies[_zombieID];

        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        if (
            keccak256(abi.encodePacked(_species)) ==
            keccak256(abi.encodePacked("kitty"))
        ) {
            newDna = newDna - (newDna % 100) + 99;
        }
        _createZombie("NoName", newDna);
    }

    /**
        function multipleReturns() internal returns(uint a, uint b, uint c) {
            return(1,2,3);
        }
        function processMultipleReturns() external {
            uint a;
            uint b;
            uint c;
            // 다음과 같이 다수 값을 할당한다:
            (a, b, c) = multipleReturns();
        }

        // 혹은 단 하나의 값에만 관심이 있을 경우: 
        function getLastReturnValue() external {
            uint c;
            // 다른 필드는 빈칸으로 놓기만 하면 된다: 
            (,,c) = multipleReturns();
        }
     */

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
