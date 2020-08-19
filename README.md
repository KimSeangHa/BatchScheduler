*설명
-------------
   
###### Batch Scheduler란 crontab과 유사한 스케줄링 기능을 할 수 있도록 개발한 프로그램이며, jar, shell, config 파일들로 구성되어있습니다.   
###### 사용자가 실행해야 할 스크립트 경로와 시간을 입력하여, 해당 시간에 실행시켜주는 프로그램입니다.   
###### 입력한 스크립트의 실행 주기는 1일 1회로 고정적으로 사용할 수 있으며, 실패 시 재처리 기능을 포함하고 있습니다.   
      
.   
.   
.   
   
*개발환경
-------------
   
###### OS : Windows10 Pro   
###### Vmware : CentOS Linux release 7.7.1908 (AltArch)   
###### java-version : 13.0.2   
###### springframwork-version : 5.2.3.RELEASE    
###### springBoot : 2.2.4 RELEASE   
###### quartz  : 2.3.2   
###### Gradle : 6.0.1   
      
.   
.   
.   
   
<img src="https://user-images.githubusercontent.com/59985995/90592502-adbe9280-e220-11ea-8451-1e6ad732f22f.png" width="90%">   
   
###### .   
###### .   
###### .   
   
*구성
-------------
   
###### BatchScheduler-0.0.1-SNAPSHOT.jar : Spring Batch + Quartz 조합 / batchAdmin.sh 주기적으로 실행   
###### startBatch.sh : BatchScheduler-0.0.1-SNAPSHOT.jar 실행하는 스크립트   
###### stopBatch.sh : BatchScheduler-0.0.1-SNAPSHOT.jar 종료하는 스크립트   
###### batchAdmin.sh : batchSet.conf 를 참조하여 일정 시간에 Shell Script을 실행 및 종료 스크립트   
###### batchSet.sh : batchSet.conf 에 정보 등록 및 초기 세팅   
###### batchSet.conf : 스케줄러명과 실행해야할 스크립트와 시간 등 설정 관리   
      
   
.   
.   
.   
      
*주요기능 설명:  
-------------
   
###### 1) BatchScheduler-0.0.1-SNAPSHOT.jar      
######   ■  params[0] = "sh ./batchAdmin.sh"   
######   ■  params[1] = "0 0/10 * * * ?" (default)   
######   ■  CronCycle 쉼표 → 공백 치환   
######   ■  고정 쉘 파일 / default 10분 주기 파라미터 전달   
.   
.   
.   
      

###### 2) TrReReqJob.java   
######   ■  Job 생성   
######       – batchAdmin.sh 실행   
######       – Shell 커멘드라인 입력   
######       – Log 출력   
      
.   
.   
.   
   
###### 3) BatchController.java   
######   ■  Trigger 생성   
######   ■  JobDetail 생성   
######       –  trReqJob.class → 생성된 Job 으로 구성   
######       –  cronCycle → Triiger 주기 설정   
######       –  빌드   
      
.   
.   
.   

###### 4) batchAdmin.sh   
###### function getConfDir() : batchSet.conf 위치 찾는 함수   
###### function getBatchCont() : batchSet.conf 설정내용과 스케줄러명 가져오는 함수   
###### function compareTime() : batchSet.conf 의 설정된 시간과 현재 시간 비교 함수   
###### function reProce() : Shell Script 실행 실패건 체크 및 재처리 함수   
###### function adminShell() : batchSet.conf 의 설정된 Shell Script 실행 및 종료   
###### function regSpace() : 공백 → 쉼표, 쉼표 → 공백 치환 함수   
###### function volumeAdmin() : 읽어오는 로그파일들 용량 관리 함수   

.   
.   
.   


###### 5) batchSet.sh   
###### - Batch Setting 메뉴얼 출력 및 설정 값 입력   
.   
.   
.   

###### function confExistChk() : batchSet.conf 파일 존재 여부 및 변수 생성 확인   
###### function init() : 초기 세팅 및 모니터링 로그 폴더 생성   
###### function javaChk() : JAVA 디렉토리 확인 및 설정   
###### function setConfig() : 입력받은 값 저장   
.   
.   
.   
   
   
