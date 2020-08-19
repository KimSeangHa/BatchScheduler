#!/bin/bash

#config 파일 존재 여부 및 CONF_DIR 변수 생성 확인
function confExistChk() {
	CONF_CHK_CNT=`find / -name 'batchSet.conf' 2>/dev/null | wc -l`
	if [ $CONF_CHK_CNT -eq 0 ]; then
		echo "batchSet.conf 파일을 찾을 수 없습니다." 
		exit
	fi
	
	CONF_CHK=`find / -name 'batchSet.conf' 2>/dev/null`
	echo "CONF_DIR : $CONF_CHK"
    
	CONF_YN=`cat $CONF_CHK | grep CONF_DIR= | wc -l`
	
	if [ $CONF_YN -eq 0 ]; then
        echo "CONF_DIR=$CONF_CHK" >> $CONF_CHK
    fi   
}

#자바 체크
function javaChk() {
	confDir=`find / -name 'batchSet.conf' 2>/dev/null`
	javaDirCnt=`cat $confDir | grep JAVA_DIR | wc -l`
	javaDir=`cat $confDir | grep JAVA_DIR | cut -d "=" -f2`
	
	if [ $javaDirCnt -eq 0 ]; then
		result=1
	else 
		result=0
		echo "JAVA_DIR : $javaDir"

	fi
	
	return "$result"	
}

#초기 세팅 및 로그폴더 설정
function init() {
	i_CHK=`find / -name 'batchSet.conf' 2>/dev/null`
	i_DIR=`echo $i_CHK | awk -F 'batchSet' '{printf $1}'`
  
	if [ ! -d $i_DIR"log" ]; then
		mkdir $DIR"log" 
	fi

	if [ ! -d $i_DIR"pid" ]; then
		mkdir $DIR"pid"
	fi
 
	if [ ! -d $i_DIR"compare" ]; then
		mkdir $DIR"compare"
		mkdir $DIR"compare/succ"
		mkdir $DIR"compare/fail"
	fi
}
 
#config 등록
function setConfig() {
	s_CHK=`find / -name 'batchSet.conf' 2>/dev/null`
	s_DIR=`echo $s_CHK | awk -F 'batchSet' '{printf $1}'`
	s_REGDIR=$s_DIR"log/confRegister.log"
	s_Date=`date +"%Y-%m-%d %H:%M:%S"`

	echo "$1=\"(|$2|$3|);\"" >> $s_CHK
	echo "[$s_Date]$1=\"(|$2|$3|);\"" >> $s_REGDIR 
}

echo "========================================================="
echo "               Batch Setting 메뉴얼"
echo ""
echo "입력받을 값(모두 영어로 입력할 것, 공백쓰지 말 것)       "
echo "1. CONF_DIR : batchSet.conf(배치세팅파일) 위치한 디렉토리"
echo " - example) CONF_DIR : /home/kim/script/"
echo "2. JAVA_DIR : JAVA1.8/bin 위치한 디렉토리(bin 폴더입력)"
echo " - example) JAVA_DIR : /usr/java/jdk1.8.0_241/bin        "
echo "3. SCHEDULER_NAME : 스케줄러명"
echo " - example) SCHEDULER_NAME : TEST_BATCH "
echo "4. SHELL_PATH : 실행할 위치와 파일"
echo " - example) SHELL_PATH : /home/kim/script/testBatch.sh"
echo "5. RUN_TIME : 실행시간(하루 중 실행해야할 시간)"
echo " - example) 14:00 "
echo " - example) 15:20 "
echo " - 10분단위로 작성할 것"
echo ""
echo "주의사항: " 
echo "  - 스케줄러명 중복으로 만들지 말것"
echo "  - 실행파일과 설정파일이 한 공간에 위치해야 함"
echo "  - batchSet.conf 파일 내 CONF_DIR 변수는 하나여야 함." 
echo ""
echo "========================================================="
echo "========================================================="
echo "                 Batch Setting Start"

confExistChk

javaChk
javaChkResult=$?

if [ $javaChkResult -eq 1 ]; then
	echo "JAVA_DIR : "
	read JAVA_DIR
	CONF_DIR=`find / -name 'batchSet.conf' 2>/dev/null`
	echo "JAVA_DIR=$JAVA_DIR" >> $CONF_DIR	
fi

echo "SCHEDULER_NAME : "
read SCHEDULER_NAME

echo "SHELL_PATH : "
read SHELL_PATH

echo "RUN_TIME : "
read RUN_TIME

echo ""
echo "설정중....."

init
setConfig $SCHEDULER_NAME $SHELL_PATH $RUN_TIME
echo "========================================================="





