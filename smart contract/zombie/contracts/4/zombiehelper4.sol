// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./zombiefeeding4.sol";

contract ZombieHelper4 is ZombieFeeding4 {
    // levelUpFee를 받기 위한 0.001 ether 정의
    uint levelUpFee = 0.001 ether;

    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    /**
        사용자가 컨트랙트에 이더를 보내게 되면, 해당 컨트랙트의 이더리움 계좌에 이더가 저장되고 거기에 갇히게 된다.
        -> 컨트랙트 주인이 이더를 인출하는 함수를 만들지 않는다면.

        따라서 아래 withdraw 함수와 같이 컨트랙트 주인만이 계좌로 출금할 수 있도록 한다.
     */
    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    function changeName(
        uint _zombieId,
        string calldata _newName
    ) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }

    // state modifier 중 하나인 payable을 사용하여 사용자로부터 levelUpFee를 받는다.
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level++;
    }

    function changeDna(
        uint _zombieId,
        uint _newDna
    ) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        zombies[_zombieId].dna = _newDna;
    }

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
