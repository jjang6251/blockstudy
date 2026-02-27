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
    function setKittyContractAddress(address _address) external {
        kittyContract = KittyInterface(_address);
    }

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
