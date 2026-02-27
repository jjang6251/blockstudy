// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./ownable3.sol";

contract ZombieFactory3 is Ownable3 {
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    /**
        uint8, uint16, uint32, 등등 기본적으로 이런 하위 타입들을 쓰는 것은 가스비 절약에 아무런 이득이 없다.
        왜냐하면 Solidity에서는 uint의 크기에 상관없이 256비트의 저장 공간을 미리 잡아놓기 때문이다.

        하지만 예외가 있는데, 바로 구조체(struct) 안에서다.
        구조체 안에 여러 개의 uint를 만든다면, 가능한 더 작은 크기의 uint를 써야한다.
        Solidity에서는 그 변수들을 더 적은 공간을 차지하도록 압축할 것이다.

        또한 동일한 데이터 타입은 하나로 묶어놓는 것이 좋다. 구조체에서 서로 옆에 있도록 선언하면 Solidity에서 사용하는
        저장 공간을 최소화한다.

        {
            uint c;
            uint32 a;
            uint32 b;
        }

        {
            uint32 a;
            uint c;
            uint32 b;
        }

        위 구조체가 아래 구조체보다 가스를 덜 소모한다.
     */
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }

    Zombie[] public zombies;

    mapping(uint => address) public zombieToOwner;
    mapping(address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) internal {
        zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime)));
        uint id = zombies.length - 1;

        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(
        string memory _str
    ) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
