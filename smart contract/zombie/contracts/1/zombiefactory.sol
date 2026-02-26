// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract ZombieFactory {
    //event 선언
    /**
        1) 한 줄 정의

        Event = 스마트컨트랙트가 "로그(Log)"를 블록체인에 남기는 기능

        즉,
        상태(state)를 저장하는 게 아니라
        "기록"을 남기는 것이다.
        --------------------------------------------------
        2) 왜 필요할까?

        스마트컨트랙트는 내부 상태만 저장하면
        외부(프론트엔드, 백엔드)가
        "무슨 일이 일어났는지" 알기 어렵다.

        3) 이벤트는 어디에 저장될까?

        이벤트는:
        - contract storage에 저장되지 않음
        - transaction receipt의 log 영역에 저장됨

        즉,
        EVM storage가 아니라
        블록의 로그 영역에 기록된다.

        4) indexed란?

        event Transfer(
            address indexed from,
            address indexed to,
            uint amount
        );

        indexed를 붙이면:

        - topic 영역에 저장됨
        - 검색이 가능해짐
        - 필터링에 사용 가능

        최대 3개까지 indexed 가능

        5) event vs 상태 변수 차이

        상태 변수:
        - 영구 저장
        - 다른 컨트랙트에서 읽기 가능
        - gas 매우 비쌈

        event:
        - 로그 기록용
        - 다른 컨트랙트에서는 직접 접근 불가
        - 외부에서 조회
        - gas 비교적 저렴
     */
    event NewZombie(uint zombieId, string name, uint dna);

    // uint data type을 가진 dnaDigits를 선언한다. 이 변수는 블록체인에 영구적으로 보관된다.
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    // Solidity는 구조체(struct)를 제공한다. 구조체를 사용하면 여러 속성을 가진 더 복잡한 데이터 유형을 만들 수 있다.
    struct Zombie {
        string name;
        uint dna;
    }
    /**
        솔리디티에는 고정 배열과 동적 배열, 두 가지 유형의 배열이 있다.
        구조체 배열도 가능하다.
        상태 변수는 블록체인에 영구적으로 저장된다. -> 구조체 배열을 동적으로 생성하는 것은 데이터베이스처럼 컨트랙트에 구조화된 데이터를 저장하는데 유용하다.

        배열을 선언하게 되면 Solidity가 자동으로 해당 배열에 대한 getter Public 메서드를 생성한다.
        Person[] public people;
     */
    Zombie[] public zombies;

    /**
        함수 인자명을 언더바로 시작해서 전역 변수와 구별하는 것이 관례다.(의무는 아니다)
        솔리디티 0.5.0 이후 버전에서는 모든 함수에 visibility(public, private, internal, external)를 명시해야 한다.

        [왜 string은 memory가 붙고, uint는 안 붙을까?]

        1) 타입 차이

        - uint → 값 타입 (Value Type)
        - string → 참조 타입 (Reference Type)

        값 타입:
        - 데이터 자체를 복사해서 사용
        - 저장 위치를 따로 지정하지 않아도 됨

        참조 타입:
        - 실제 데이터가 다른 공간에 저장됨
        - "어디에 저장할지" 반드시 명시해야 함
        → memory / storage / calldata


        2) EVM 데이터 저장 영역 3가지

        1. storage
        - 블록체인에 영구 저장
        - 가장 비쌈 (gas 많이 듦)
        - 상태 변수 위치

        2. memory
        - 함수 실행 중 임시 저장
        - 함수 끝나면 사라짐
        - storage보다 저렴

        3. calldata
        - 외부 함수 입력값 저장
        - 읽기 전용
        - 가장 저렴 (복사 없음)


        3) 왜 string에는 memory를 써야 하나?

        string은 내부적으로 동적 배열(bytes 배열) 구조임.

        즉,
        - 길이
        - 데이터

        이렇게 여러 슬롯을 사용함.

        그래서 컴파일러가
        "이걸 storage에 둘 건지? memory에 둘 건지?"
        명확히 알아야 함.

        따라서 반드시 이렇게 써야 함:

        function create(string memory _name, uint _dna) public {
            ...
        }

        반면,

        uint는 고정 32바이트 값 타입이므로
        위치 지정 필요 없음:

        function create(string memory _name, uint _dna) public {
            ...
        }


        4) gas 관점 정리

        external 함수라면:

        function foo(string calldata name) external {
            ...
        }

        - calldata는 복사하지 않음
        - memory는 복사 발생
        - storage는 가장 비쌈

        gas 비용 순서:
        calldata < memory << storage


        5) 한 줄 요약

        - uint는 값 타입이라 위치 지정 필요 없음
        - string은 참조 타입이라 반드시 memory/storage/calldata 명시해야 함
        - Solidity는 EVM 메모리 모델을 직접 다루는 언어다
      */

    /**
        컨트랙트 함수의 public 선언 -> 누구나 내 컨트랙트의 함수를 호출하고 코드를 실행할 수 있다는 의미이다.
        그래서 기본적으로는 함수는 private으로 선언한다. private 함수명도 앞에 언더바를 붙이는 것이 관례이다.
       */
    function _createZombie(string memory _name, uint _dna) internal {
        //array.push를 통해 배열 끝에 추가할 수 있다.
        zombies.push(Zombie(_name, _dna));
        uint id = zombies.length - 1;
        emit NewZombie(id, _name, _dna);
    }

    /**

        Solidity에서 함수는
        "블록체인 상태(state)를 읽거나/수정하는지"에 따라 구분됨.

        이걸 명확히 하기 위해
        view, pure 키워드를 사용한다.

        - view = 상태 읽기 전용
        - pure = 상태 완전 독립 계산
        - 둘 다 상태 변경은 절대 불가
     */
    function _generateRandomDna(
        string memory _str
    ) private view returns (uint) {
        //의사난수함수로 내장함수인 keccak256 사용. 이 함수는 bytes 타입 하나를 인자로 받는 함수이다.
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}
