#!/bin/bash

#config 위치찾기
function getConfDir() {
        CONF_CHK_CNT=`find / -name 'batchSet.conf' 2>/dev/null | wc -l`
        if [ $CONF_CHK_CNT -eq 0 ]; then
                echo "batchSet.conf 파일을 찾을 수 없습니다."
                exit
        fi

        CONF_CHK=`find / -name 'batchSet.conf' 2>/dev/null`
        CONF_YN=`cat $CONF_CHK | grep CONF_DIR= | wc -l`

        if [ $CONF_YN -eq 0 ]; then
        echo "batchSet.sh 을 먼저 실행하여 설정을 해주세요."
    fi
        echo $CONF_CHK | awk -F 'batchSet' '{printf $1}'
}

runFileDir=$(getConfDir)
runFileName="BatchScheduler-0.0.1-SNAPSHOT.jar"
runLogFile=$runFileDir"log/jartail.log"
pidFile=$runFileDir"pid/"$runFileName".pid"
log_Date=`date +"%Y-%m-%d %H:%M:%S"`

#프로세스 실행 중인지 확인
#1개이상 실행 중일 경우 수동 종료
function procCheck() {
	procCnt=`ps -ef | grep $runFileName | grep -v grep | wc -l`
 	procPid=`ps -ef | grep $runFileName | grep -v grep | awk '{print $2}'`
	
	if [ $procCnt -eq 0 ]; then 
		echo "$runFileName 프로세스가 실행중이지 않습니다."
		exit
	elif [ $procCnt -eq 1 ]; then
		stopProc $procPid
	else 
		echo "프로세스가 1개 이상 실행중입니다. 확인 후 수동으로 중지하시기 바랍니다."
                echo "PID 확인 방법"
                echo "ps -ef | grep $runFileName | grep -v grep | awk '{print $2}'"
                echo "kill -9 PID"
                exit

	fi
}


#프로세스 종료
function stopProc() {
	getPid=$1
	
	stopProcess=`kill -9 $getPid`
	stopResult=$?

	if [ $stopResult -eq 0 ]; then
		echo "PROCESS KILL SUCCESS | PROCESS NAME: $runFileName | PID: $getPid"
		echo "[$log_Date][stopBatch.sh] PROCESS KILL SUCCESS | PROCESS NAME: $runFileName | PID: $getPid" >> $runLogFile
	else 
		echo "PROCESS KILL FAIL | PROCESS NAME: $runFileName | PID: $getPid"
	fi	
}

procCheck
