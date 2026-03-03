// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./zombiehelper4.sol";

contract ZombieAttack4 is ZombieHelper4 {
    uint randNonce = 0;
    uint attackVictoryProbability = 70;

    /**
        실제 이더리움에서 난수를 안전하게 만들기 위해서는 외부의 난수 함수에 접근할 수 있도록 해주는 오라클(oracle)을 사용한다.
     */
    function randMod(uint _modulus) internal returns (uint) {
        randNonce++;
        return
            uint(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }

    function attack(
        uint _zombieId,
        uint _targetId
    ) external onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        uint rand = randMod(100);

        if (rand <= attackVictoryProbability) {
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount++;
            enemyZombie.winCount++;
        }
        _triggerCooldown(myZombie);
    }
}
