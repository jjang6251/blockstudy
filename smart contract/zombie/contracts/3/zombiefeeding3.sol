// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./zombiefactory3.sol";

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

contract ZombieFeeding3 is ZombieFactory3 {
    // 해당 컨트랙트에 대한 버그 발생시 해당 주소를 바꿀 수 있도록 함.
    // address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    // KittyInterface kittyContract = KittyInterface(ckAddress);

    KittyInterface kittyContract;
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    /**
        ** 구조체를 인수로 전달하기 **
        private 또는 internal 함수에 인수로서 구조체의 storage 포인터를 전달할 수 있다.
        함수들 간에 구조체를 주고 받을 때 유용하다.
     */

    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= block.timestamp);
    }

    function feedAndMultiply(
        uint _zombieID,
        uint _targetDna,
        string memory _species
    ) internal {
        require(zombieToOwner[_zombieID] == msg.sender);
        Zombie storage myZombie = zombies[_zombieID];
        require(_isReady(myZombie));

        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        if (
            keccak256(abi.encodePacked(_species)) ==
            keccak256(abi.encodePacked("kitty"))
        ) {
            newDna = newDna - (newDna % 100) + 99;
        }
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    function multipleReturns() internal pure returns(uint a, uint b, uint c) {
        return(1,2,3);
    }

    function processMultipleReturns() external pure {
        uint a;
        uint b;
        uint c;
        // 다음과 같이 다수 값을 할당한다:
        (a, b, c) = multipleReturns();
    }

    // 혹은 단 하나의 값에만 관심이 있을 경우: 
    function getLastReturnValue() external pure {
        uint c;
        // 다른 필드는 빈칸으로 놓기만 하면 된다: 
        (,,c) = multipleReturns();
    }

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
