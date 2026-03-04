// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./zombieattack4.sol";
import "./erc721.sol";

/**
    solidity는 다중 상속을 지원한다.
    
    ZombieOwnership이 ERC721(인터페이스)을 상속하고 있는데, balanceOf, ownerOf 등과 같은 필수 함수들을 아직 구현하지
    않았기 때문에 contract 앞에 abstract가 붙어야 한다.
    -> 구현을 나중에 추가할 예정이라면 abstrct로 표시하는 게 맞고, 해당 함수들을 모두 구현하면 abstract를 제거하면 된다.
 */
abstract contract ZombieOwnership is ZombieAttack4, ERC721 {

    mapping(uint => address) zombieApprovals;

    function balanceOf(
        address _owner
    ) public view override returns (uint256 _balance) {
        return ownerZombieCount[_owner];
    }

    function ownerOf(
        uint256 _tokenId
    ) public view override returns (address _owner) {
        return zombieToOwner[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        ownerZombieCount[_to]++;
        ownerZombieCount[_from]--;
        zombieToOwner[_tokenId] = _to;
        /**
            ERC721 스펙에는 Transfer 이벤트가 포함되어 있다. 따라서 _transfer 함수 마지막 부분에는 이벤트를 
            emit 해줘야 한다.
         */
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(
        address _to,
        uint256 _tokenId
    ) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _to;

        /**
            Approval은 _owner가 _to에게 _tokenId의 판매 권한을 부여하는 것이다.
         */
        emit Approval(msg.sender, _to, _tokenId);
    }
}
