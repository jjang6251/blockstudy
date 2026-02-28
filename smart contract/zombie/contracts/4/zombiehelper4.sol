// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./zombiefeeding4.sol";

contract ZombieHelper4 is ZombieFeeding4 {
    /**
        // 사용자의 나이를 저장하기 위한 매핑
        mapping (uint => uint) public age;

        // 사용자가 특정 나이 이상인지 확인하는 제어자
        modifier olderThan(uint _age, uint _userId) {
            require (age[_userId] >= _age);
            _;
        }

        // 차를 운전하기 위햐서는 16살 이상이어야 한다.
        // `olderThan` 제어자를 인수와 함께 호출하려면 이렇게 하면 된다.
        function driveCar(uint _userId) public olderThan(16, _userId) {
            // 필요한 함수 내용들
        }
     */
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    function changeName(
        uint _zombieId,
        string calldata _newName
    ) external aboveLevel(2, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].name = _newName;
    }

    function changeDna(
        uint _zombieId,
        uint _newDna
    ) external aboveLevel(20, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }

    /**
        만약 view함수가 동일 컨트랙트에 있는, view 함수가 아닌 다른 함수에서 내부적으로 호출될 경우, 여전히 가스를 소모한다.
        -> 다른 함수가 이더리움에 트랜잭션을 생성하고, 이는 모든 개별 노드에서 검증되어야 하기 때문이다.
        
        So, view 함수는 컨트랙트 내부가 아닌 외부에서 호출되었을 경우에만 무료이다.
     */
    function getZombiesByOwner(
        address _owner
    ) external view returns (uint[] memory) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}
