pragma solidity ^"0.4.24";

// Director Contract
// -----------------------------------
// 감독관을 등록, 삭제하고 감독관에 해당되는 컨텐츠 제공자를 관리한다.
// 퍼포먼스를 위해 감독관에 해당되는 컨텐츠 제공자를 별도로 이곳에서 관리한다.

contract Director {
    // Contract Owner
    address public owner;

    // 감독관 상태 구조체
    struct DirectorAttr {
        address addr;               // 감독관 주소
        string host;                // 감독관 호스트 주소 (address:port)
        string extdata;             // 감동관의 추가 정보 (Json String 형태로 저장됨)
        bool activated;             // 활성화 여부
    }

    // 감독관 Mapping 변수
    mapping(address => DirectorAttr) directorMapping;

    // 감독관 목록 변수
    address[] public directors;

    // 생성자
    constructor() payable public {
        // Contract Owner 지정
        owner = msg.sender;
    }

    // Contract Owner 식별
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // 감독관 식별
    modifier onlyDirector {
        // 감독관 Mapping 변수에 할당되어 있으며 activated가 true인 경우
        require(directorMapping[msg.sender].activated);
        _;
    }

    // 감독관 추가시 발생되는 이벤트 선언
    event evt_addDirector(address _address);

    // 감독관 수정시 발생되는 이벤트 선언
    event evt_updateDirector(address _address);

    // 감독관 삭제시 발생되는 이벤트 선언
    event evt_removeDirector(address _address);

    // 감독관 추가 (Owner만 호출 가능)
    function addDirector(address _address, string _host, string _extdata) payable public onlyOwner {
        DirectorAttr storage attr = directorMapping[_address];

        // 중복 방지
        if(!attr.activated) {
            attr.addr = _address;
            attr.host = _host;
            attr.extdata = _extdata;
            attr.activated = true;

            directors.push(_address);

            emit evt_addDirector(_address);
        }
    }

    // 감독관 변경 (Owner만 호출 가능)
    function updateDirector(address _address, string _host, string _extdata) payable public onlyOwner {
        DirectorAttr storage attr = directorMapping[_address];

        // 기존 감독관인 경우
        if(attr.activated) {
            attr.host = _host;
            attr.extdata = _extdata;

            emit evt_updateDirector(_address);
        }
    }

    // 감독관 제거 (Owner만 호출 가능)
    function removeDirector(address _address) payable public onlyOwner {
        // Mapping되어 있는지 확인
        require(directorMapping[_address].activated);

        delete directorMapping[_address];

        for(uint32 i = 0; i<directors.length; i++) {
            if(_address == directors[i]) {
                // 맨 마지막 자료와 Swap한 이후 배열의 크기 조정
                if(directors.length > 1) {
                    directors[i] = directors[directors.length - 1];
                    directors.length = directors.length - 1;
                }
                else {
                    directors.length = 0;
                }

                break;
            }
        }

        emit evt_removeDirector(_address);
    }

    // 주소로 감독관 정보 얻기
    function getDirector(address _address) view public returns (address, string, string, bool) {
        return (directorMapping[_address].addr, directorMapping[_address].host, directorMapping[_address].extdata, directorMapping[_address].activated);
    }

    // 순번으로 감독관 정보 얻기
    function fromIndex(uint32 n) view public returns (address, string, string, bool) {
        require(n < directors.length);

        return getDirector(directors[n]);
    }

    // 감독관수 확인
    function getDirectorCount() view public returns (uint32) {
        return (uint32) (directors.length);
    }
}
