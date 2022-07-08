#!/bin/bash

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
    echo "####-USAGE GUIDE-#####"
    echo ""
    echo -e "\033[32m[->]\033[0m Usage ${0}: ./test_emulator.sh [iid] [arch] [debug]"
    echo ""
    echo "[arch] = |mipsel|mipseb|armel|"
    echo "[debug] = |-d|--debug|debug| - Option Available ONLY in the IOT-AFL project (see Github), please don't use it in a normal FirmAE execution"
    exit 1
fi



set -e
set -u

if [ -e ./firmae.config ]; then
    source ./firmae.config
elif [ -e ../firmae.config ]; then
    source ../firmae.config
elif [ -e ../../firmae.config ]; then
    source ../../firmae.config
elif [ -e FirmAE/firmae.config ]; then
    source FirmAE/firmae.config
else
    echo "Error: Could not find 'firmae.config'!"
    exit 1
fi

IID=${1}
WORK_DIR=`get_scratch ${IID}`
ARCH=${2}

echo ""
echo -e "\033[33m[*]\033[0m Starting a test emulation with the new firmware configuration:"

if [ $# -eq 2 ]; then
    ${WORK_DIR}/run.sh 2>&1 >${WORK_DIR}/emulation.log &
else
    DEBUG=${3}
    if [ ${3} == "debug" ] || [ ${3} == "-d" ] || [ ${3} == "--debug" ]; then  
        ${WORK_DIR}/run.sh debug #2>&1 >${WORK_DIR}/emulation.log &
        exit 1
    else
        echo -e "\033[31m[-]\033[0m Error: You provide three arguments to test_emulation.sh but > ${3} < is not a debug key. Exiting.."
        exit 1
    fi
fi


sleep 10

echo ""

IPS=()
if (egrep -sq true ${WORK_DIR}/isDhcp); then
  IPS+=("127.0.0.1")
  echo true > ${WORK_DIR}/result_ping
else
  IP_NUM=`cat ${WORK_DIR}/ip_num`
  for (( IDX=0; IDX<${IP_NUM}; IDX++ ))
  do
    IPS+=(`cat ${WORK_DIR}/ip.${IDX}`)
  done
fi

echo -e "\033[33m[*]\033[0m Waiting web service... from ${IPS[@]}"
read IP PING_RESULT WEB_RESULT TIME_PING TIME_WEB < <(check_network "${IPS[@]}" false)

if (${PING_RESULT}); then
    echo true > ${WORK_DIR}/result_ping
    echo ${TIME_PING} > ${WORK_DIR}/time_ping
    echo ${IP} > ${WORK_DIR}/ip
fi
if (${WEB_RESULT}); then
    echo true > ${WORK_DIR}/result_web
    echo ${TIME_WEB} > ${WORK_DIR}/time_web
fi

kill $(ps aux | grep `get_qemu ${ARCH}` | awk '{print $2}') 2> /dev/null | true

sleep 2
