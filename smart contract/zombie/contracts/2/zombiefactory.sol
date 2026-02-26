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

    function _createZombie(string memory _name, uint _dna) internal {
        zombies.push(Zombie(_name, _dna));
        uint id = zombies.length - 1;

        /**
            솔리디티에는 모든 함수에서 이용 가능한 특정 전역 변수들이 있다. 그 중의 하나가 현재 함수를 호출한 사람 (혹은 스마트 컨트랙트)의 주소를 가리키는 msg.sender이다.

            ** 솔리디티에서 함수 실행은 항상 외부 호출자가 시작한다. 컨트랙트는 누군가가 컨트랙트의 함수를 호출할 때까지 블록체인 상에서 아무것도 안하고 있을 것이다. **
         */
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
        /**
            require를 활용하게 되면 특정 조건이 참이 아닐 때 함수가 에러 메시지를 발생하고 실행을 멈추게 된다.
         */
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}