#!/bin/bash


mkdir -p ./.db-util  &> /dev/null
mkdir -p ./.db-util/backups &> /dev/null
if [[ ! -f "./.db-util/config" ]]; then
        echo "DB_PATH=\"\"" > ./.db-util/config
        echo "DOCKER_COMPOSE_PATH=\"\"" >> ./.db-util/config
fi


# config 파일 확인


if [[ ( "$1" != "setpath" && "$1" != "options" && "$1" != "setdockerpath" ) && ! -f "./.db-util/config" ]]; then  
    echo "no config file!"
    echo "use [./db-util.sh options] for help!"
    exit 1

fi


## 환경 변수 가져오기
source ./.db-util/config

if [[ ("$1" != "setpath" && "$1" != "options" && "$1" != "setdockerpath" )  && ( -z "$DB_PATH" || -z "$DOCKER_COMPOSE_PATH") ]]; then
        echo "DB_PATH or DOCKER_COMPOSE_PATH variable is empty!"
        echo "use [./db-util.sh options] for help!"
    exit 1

fi


# 옵션이 없으면
if [[ -z "$1" ]]; then
        echo "인자를 입력해주세요!"
        exit 1

elif [[ "$1" == "backup" ]]; then   #백업하기

        if [[ "$2" == *"/"* ]]; then
                echo "there should be no path in the backup name"
                exit 1
        fi

        # 백업저장 폴더 이름 확인하기
        if [[ -z "$2" ]]; then
                echo "백업 파일의 이름을 지정해주세요!"
                exit 1
        fi

        if [[ -d "./.db-util/backups/$2" ]]; then
                echo "백업 이미 파일이 존재합니다!"
                exit 1

        fi


        if [[ -d "$DB_PATH" ]]; then   #백업할 파일이 있으면
                sudo cp -r "$DB_PATH" "./.db-util/backups/$2" &> /dev/null


                #백업 실패
                if [[ ! -d "./.db-util/backups/$2" ]]; then
                        echo "backup failed.. exiting"
                        exit 1
                fi


                echo "done backup!"
                exit 0

        else
                echo "mysql directory missing!"   #백업할 파일이 없으면
                exit 1
        fi


elif [[ "$1" == "restore" ]]; then   #복구하기

        if [[ "$2" == *"/"* ]]; then
                echo "there should be no path in the backup name"
                exit 1
        fi

        #복구 파일 이름 확인하기
        if [[ -z "$2" ]]; then
                echo "복구 파일의 이름을 명시해주세요!"
                exit 1
        fi


        if [[ -d "./.db-util/backups/$2" ]]; then   #복구 파일이 있으면

                if [[ ! -f "$DOCKER_COMPOSE_PATH" ]]; then    #도커 파일이 없으면
                        echo "docker compose file missing! exiting"
                        exit 1
                fi

                echo "turning off containers..."
                sudo docker compose -f "$DOCKER_COMPOSE_PATH" down -v &> /dev/null   #컨테이너 끄기

                echo "restoring..."

                sudo rm -rf "$DB_PATH" &> /dev/null
                if [[ -d "$DB_PATH" ]]; then   #지우기 실패하면
                        echo "restore failed.. exiting"
                        exit 1

                fi


                sudo cp -r "./.db-util/backups/$2" "$DB_PATH" &> /dev/null

                if [[ ! -d "$DB_PATH" ]]; then
                        echo "restore failed... exiting"
                        exit 1

                fi

                echo "turning on containers..."
                sudo docker compose -f "$DOCKER_COMPOSE_PATH" up -d --build &> /dev/null
                echo "done restore!"
                exit 0

        else
                echo "backup file missing!"
                echo "please backup first!"

                exit 1

        fi


elif [[ "$1" == "reset" ]]; then
        read -p "are you sure to reset? y/n: " args

        if [[ ! -f "$DOCKER_COMPOSE_PATH" ]]; then
                echo "docker compose file missing!"
                exit 1

        fi

        if [[ "$args" == "y" || "$args" == "Y" ]]; then
                echo "turning off containers..."
                sudo docker compose -f "$DOCKER_COMPOSE_PATH" down -v &> /dev/null
                echo "erasing files.."
                sudo rm -rf "$DB_PATH" &> /dev/null
                echo "starting containers..."
                sudo docker compose -f "$DOCKER_COMPOSE_PATH" up -d --build

                echo "done!"
                exit 0



        else
                echo "cancelled!"
                exit 1

        fi

elif [[ "$1" == "dockerup" ]]; then
        sudo docker compose -f "$DOCKER_COMPOSE_PATH" up -d --build
        exit 0

elif [[ "$1" == "dockerdown" ]]; then
        sudo docker compose -f "$DOCKER_COMPOSE_PATH" down -v
        exit 0

elif [[ "$1" == "list" ]]; then
        ls ./.db-util/backups
        exit 0

elif [[ "$1" == "setpath" ]]; then
        if [[ -z "$2" ]]; then
                echo "path is required"
                exit 1
        fi

        if [[ -f "./.db-util/config" ]]; then
                source ./.db-util/config
        fi

        echo "DB_PATH=\"$2\"" > ./.db-util/config
        echo "DOCKER_COMPOSE_PATH=\"$DOCKER_COMPOSE_PATH\"" >> ./.db-util/config
    echo "done!"
    exit 0

elif [[ "$1" == "setdockerpath" ]]; then
        if [[ -z "$2" ]]; then
                echo "path is required"
                exit 1
        fi

        if [[ -f "./.db-util/config" ]]; then
                source ./.db-util/config
        fi

        echo "DB_PATH=\"$DB_PATH\"" > ./.db-util/config
        echo "DOCKER_COMPOSE_PATH=\"$2\"" >> ./.db-util/config
    echo "done!"
    exit 0


elif [[ "$1" == "options" ]]; then
        echo "backup [name] - backup mysql container data with specified name"
        echo "restore [name] - restore mysql container data with specified name"
        echo "reset - reset mysql container data"
        echo "dockerup - start containers of docker compose file"
        echo "dockerdown - remove containes of docker compose file"
        echo "list - list all available backup files"
        echo "setpath [path]- set path for backup, relative and absolute path supported!"
        echo "setdockerpath [path]- set path for docker compose file, relative and absolute path supported!"

else

        echo "please enter an valid argument!"
        echo "use [./db-util.sh options] for help!"
        exit 1
fi