// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract ZombieFactory {
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    /**
        ** 주소는 특정 유저(혹은 스마트컨트랙트)가 소유한다 **

        매핑은 기본적으로 키-값(key-value) 저장소로, 데이터를 저장하고 검색하는데 사용된다.
        mapping (key => value) ~~;
     */
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) private {
        //array.push를 통해 배열 끝에 추가할 수 있다.
        zombies.push(Zombie(_name, _dna));
        uint id = zombies.length - 1;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(
        string memory _str
    ) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
