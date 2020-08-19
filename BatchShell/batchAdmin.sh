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
        echo "CONF_DIR=$CONF_CHK" >> $CONF_CHK
        echo $CONF_CHK | awk -F 'batchSet' '{printf $1}'
    fi
        echo $CONF_CHK | awk -F 'batchSet' '{printf $1}'
}

CONF_DIR=$(getConfDir)
#CONF_DIR="/home/kim/script/"
CONF_PATH=$CONF_DIR"batchSet.conf"
cat $CONF_PATH  | grep ";" |  cut -f 1 -d "=" > $CONF_DIR"batchList.conf"
batchList=$CONF_DIR"batchList.conf"

#Batch 설정내용 가져오기
function getBatchCont() {
	index=$1"="
	ShellDir=`cat $CONF_PATH | grep $index | cut -d "|" -f2` 
	RunTime=`cat $CONF_PATH | grep $index | cut -d "|" -f3`
 
	adminShell $1 $index $ShellDir $RunTime
	volumeAdmin
}

#시간 비교 함수
function compareTime() {
	#result=1, PASS
	#result=2, PROCESS START
	Name=$1
	Time=$2

	baseCurrent=`date +"%Y%m%d%H%M%S"`
	baseDate=`date +"%Y%m%d"`
	baseTime=`date +"%H%M"`
	baseTime_trans=${baseTime:0:2}
	baseMin_trans=${baseTime:2:1}

	targetTime=`echo $2 | sed "s/://"`
	targetTime_trans=${targetTime:0:2}
	targetMin_trans=${targetTime:2:1}
 
	#처음시작 시 예외처리
	if [ ! -e $CONF_DIR"compare/succ/comp_"$Name".log" ]; then 
		#실패건 체크
		reProc $Name
		reProcResult=$?
 
		if [ $reProcResult -eq 0 ]; then
			echo "reProcName: $Name | reProcResult: SUCC" 
			result=0
			return "$result"
		fi

		if [ $baseTime_trans -eq $targetTime_trans ]; then
			if [ $baseMin_trans -eq $targetMin_trans ]; then
				result=0
			else 
				result=1
			fi
		else
			result=1
		fi
	return "$result"
	fi

	targetCurrent=`cat $CONF_DIR"compare/succ/comp_"$Name".log" | tail -1 | cut -d "|" -f1`
	targetDate=${targetCurrent:0:8}
 
	#당일 실행 체크 
	if [ $baseDate -eq $targetDate ]; then
		result=1
		return "$result"
	fi
 
	#실패건 체크
	reProc $Name
	reProcResult=$?
 
	if [ $reProcResult -eq 0 ]; then
		echo "reProcName: $Name | reProcResult: SUCC" 
		result=0
		return "$result"
	fi 

	#현재시간과 사용자가 입력한 시간 비교
	if [ $baseTime_trans -eq $targetTime_trans ]; then
		if [ $baseMin_trans -eq $targetMin_trans ]; then
			result=0
		else
			result=1
		fi
	else
		result=1
	fi

	return "$result"
}

#실패건 체크 및 재처리
function reProc() {
	#result=1, PASS
	#result=0, ReProc
	Name=$1
 
	if [ -e $CONF_DIR"compare/fail/comp_"$Name".log" ]; then
		baseDate=`date +"%Y%m%d"`
		targetCurrent=`cat $CONF_DIR"compare/fail/comp_"$Name".log" | tail -1 | cut -d "|" -f1`
		targetDate=${targetCurrent:0:8}
     
	    #당일 체크
		if [ $baseDate -eq $targetDate ]; then
			result=0
		else 
			result=1
		fi
	else
		result=1
	fi
 
	return "$result" 
}

#Shell Script 실행 및 종료
function adminShell() {
	Name=$1
	ShellDir_before=$3 
	RunTime=$4
	log_Date=`date +"%Y-%m-%d %H:%M:%S"`
	comp_Date=`date +"%Y%m%d%H%M%S"`
 
	compareTime $Name $RunTime
	compareResult=$?
 
	ShellDir=$(regSpace 2 $ShellDir_before)

	if [ $compareResult -eq 0 ]; then
		ShellDir_Chk=`echo $ShellDir_before | cut -d "," -f1`
		
		if [ ! -e $ShellDir_Chk ] ; then
			DirChkResult=1
			DirChkResultContent="$ShellDir_Chk 파일이 존재하지 않습니다."
		else 
			DirChkResult=0
		fi
		
		if [ $DirChkResult -eq 1 ]; then 
			echo "$comp_Date|$Name|$ShellDir|FAIL" >> $CONF_DIR"compare/fail/comp_"$Name.log
			echo "[$log_Date] SchedulerName: $Name | Shell: $ShellDir | Result: FAIL | ErrorCode: $DirChkResultContent" >> $CONF_DIR"log/"$Name".log"
			echo "[$log_Date][batchAdmin.sh] SchedulerName: $Name | Shell: $ShellDir | Result: FAIL | ErrorCode: $DirChkResultContent"
		else 
			Startshell=`nohup sh $ShellDir nohup.out 2>&1 & echo $! > $CONF_DIR"pid/"$Name".pid" &`
			StartResult=$?
		
			if [ $StartResult -eq 0 ]; then
				echo "$comp_Date|$Name|$ShellDir|SUCC" >> $CONF_DIR"compare/succ/comp_"$Name".log"
				echo "[$log_Date] SchedulerName: $Name | Shell: $ShellDir | Result: SUCC" >> $CONF_DIR"log/"$Name".log"
				echo "[$log_Date][batchAdmin.sh] SchedulerName: $Name | Shell: $ShellDir | Result: SUCC"
			else
				echo "$comp_Date|$Name|$ShellDir|FAIL" >> $CONF_DIR"compare/fail/comp_"$Name.log  
				echo "[$log_Date] SchedulerName: $Name | Shell: $ShellDir | Result: FAIL | ErrorCode: $StartResult" >> $CONF_DIR"log/"$Name".log"
				echo "[$log_Date][batchAdmin.sh] SchedulerName: $Name | Shell: $ShellDir | Result: FAIL | ErrorCode: $DirChkResultContent"
			fi

			PID_NUM=`cat $CONF_DIR"pid/"$Name".pid"`
			searchProc=`ps -ef | grep $PID_NUM | grep "$ShellDir" | grep -v grep | wc -l`

			if [ $searchProc -gt 0 ]; then
				kill -9 $PID_NUM
				echo "[$log_Date][batchAdmin.sh] Process Kill Success : $PID_NUM"
			fi
		fi
	else 
		echo "[$log_Date][batchAdmin.sh] SchedulerName : $Name - PASS"
	fi
}

#공백 쉼표, 쉼표 공백 치환 함수
function regSpace() {
	#type=1, 공백 -> 쉼표
	#type=2, 쉼표 -> 공백

	type=$1
	beforeData=$2
   
	if [ $type -eq 1 ]; then
		afterData=`echo $beforeData | tr ' ' ','`
	else 
		afterData=`echo $beforeData | tr ',' ' '`
	fi
	echo "${afterData}"   
}

#읽어오는 파일 용량 체크
function volumeAdmin() {
	if [ -e $CONF_DIR"compare/succ/comp_"$Name".log" ]; then 
		volumeChk=`cat $CONF_DIR"compare/succ/comp_"$Name".log" | wc -l`
		log_Date=`date +"%Y-%m-%d %H:%M:%S"` 
		v_DIR=$CONF_DIR"compare/succ/comp_"$Name".log"

		if [ $volumeChk -ge 1000 ]; then
			sed -i '1,100d' $CONF_DIR"compare/succ/comp_"$Name".log"
			echo "[$log_Date] $v_DIR: LOG FILE 100 LINE REMOVE SUCC" >> $CONF_DIR"log/"$Name".log"
		fi
	fi 
}

while read line
do 
 #echo $line
	getBatchCont $line
done < $batchList

rm -rf batchList.conf


