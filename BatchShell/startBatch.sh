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
	exit
    fi
        echo $CONF_CHK | awk -F 'batchSet' '{printf $1}'
}

#JAVA 디렉토리 체크
function javaChk() {
	flag=$1
	
	confDir=`find / -name 'batchSet.conf' 2>/dev/null`        
	javaDirCnt=`cat $confDir | grep JAVA_DIR | wc -l`
        javaDir=`cat $confDir | grep JAVA_DIR | cut -d "=" -f2`

	if [ $flag -eq 0 ]; then
		if [ $javaDirCnt -eq 0 ]; then
			result=1
		else
			result=0
		fi

		return "$result"
	else 
		echo "$javaDir"
	fi	
}

runFileDir=$(getConfDir)
runFileName="BatchScheduler-0.0.1-SNAPSHOT.jar"
runLogFile=$runFileDir"log/jartail.log"
pidFile=$runFileDir"pid/"$runFileName".pid"
log_Date=`date +"%Y-%m-%d %H:%M:%S"`

#프로세스 중복 실행 체크 함수
function procCheck() {
	procChk=`ps -ef | grep $runFileName | grep -v gre | wc -l`
	
	if [ $procChk -eq 0 ]; then
		result=0		
	else
		result=1
	fi
	
	return "$result"
}


#프로세스 시작
function startProc() {
	javaChk 0
	javaChkResult=$?

	if [ $javaChkResult -eq 0 ]; then 
		getJavaDir=$(javaChk 1)
		cd $getJavaDir
	
		procCheck
		procCheckResult=$?
	
		if [ $procCheckResult -eq 0 ]; then
			paramCnt=$1
	
			if [ $paramCnt -eq 1 ]; then
				startProcCmd=`nohup $getJavaDir/java -Dserver.port=$2 -jar $runFileDir$runFileName $runFileDir >> $runLogFile & echo $! > $pidFile`
			else 
				cronCycle=$3
				startProcCmd=`nohup $getJavaDir/java -Dserver.port=$2 -jar $runFileDir$runFileName $runFileDir $cronCycle >> $runLogFile & echo $! > $pidFile`
			fi
	
			procStartChk=`ps -ef | grep "$runFileName" | grep -v grep | wc -l`
		
			if [ $procStartChk -eq 0 ]; then
				echo "$runFileName Run Fail: 다시 실행해주세요."
				exit
			else 
				echo "$runFileName Run Success"
				echo "[$log_Date][startBatch.sh] $runFileName START SUCCESS | PROCESS NAME: $runFileName" >> $runLogFile
			fi
		else
			echo "$runFileName 프로세스가 이미 실행중입니다."
			exit
		fi
	else 
		echo "batchSet.sh 을 먼저 실행하여 JAVA 디렉토리를 설정  해주세요."
		exit
	fi
}

#파라미터 체크 
paramCnt=$#
if [ $paramCnt -eq 0 ]; then
	echo "PortNumber는 필수값 입니다."
	echo "사용법: sh startBatch.sh portNumber cronCycle"
	echo "example) sh startBatch.sh 9001"
	echo "example) sh startBatch.sh 9001 0,*,*,*,*,?"
	exit
elif [ $paramCnt -eq 1 ]; then
	echo "PortNumber: $1"
	startProc 1 $1
elif [ $paramCnt -eq 2 ]; then 
	echo "PortNumber: $1"
	echo "cronCycle: $2"
	startProc 2 $1 $2
else 
	echo "사용방법을 다시 확인해주세요."
        echo "사용법: sh startBatch.sh portNumber cronCycle"
        echo "example) sh startBatch.sh 9001"
        echo "example) sh startBatch.sh 9001 0,*,*,*,*,?"
        exit
fi

