# Docker DB Util Script

이 저장소는 Docker Compose 환경에서 MySQL 데이터 백업/복구를 도와주는 bash 유틸리티 스크립트를 제공합니다.

## 구성 파일

- db-util.sh: 메인 스크립트
- .db-util/config: 설정 파일 (DB_PATH 보관)
- .db-util/backups/: 백업 저장 디렉터리

## 설치/준비

- 실행 환경: Linux 또는 macOS의 bash 쉘

1. Docker와 Docker Compose를 설치합니다.
2. 설정 파일을 생성합니다.

```bash
mkdir -p ./.db-util
echo "DB_PATH=/path/to/mysql" > ./.db-util/config
```

## 사용 방법

```bash
./db-util.sh options
```

### 명령어

- backup [name]: MySQL 데이터를 ./.db-util/backups/[name]으로 백업합니다.
- restore [name]: ./.db-util/backups/[name]에서 복구합니다.
- reset: MySQL 데이터를 삭제하고 컨테이너를 재생성합니다.
- dockerup: 컨테이너를 빌드 후 실행합니다.
- dockerdown: 컨테이너를 중지하고 볼륨을 제거합니다.
- list: 사용 가능한 백업 목록을 출력합니다.
- setpath [path]: DB_PATH 값을 ./.db-util/config에 저장합니다.

## 참고 사항

- backup/restore의 두 번째 인자는 경로(`/`)를 허용하지 않습니다.
- config 파일이 없거나 DB_PATH가 비어 있으면 스크립트가 종료됩니다.
- 백업은 ./.db-util/backups 아래에 저장됩니다.

## 예시

```bash
./db-util.sh setpath /data/mysql
./db-util.sh backup my-backup
./db-util.sh list
./db-util.sh restore my-backup
```
