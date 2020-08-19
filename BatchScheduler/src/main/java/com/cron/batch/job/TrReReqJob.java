package com.cron.batch.job;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.quartz.InterruptableJob;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.UnableToInterruptJobException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.stereotype.Component;

import com.cron.batch.RunApplication;

import lombok.extern.slf4j.Slf4j;


@Component
@Slf4j
public class TrReReqJob extends QuartzJobBean implements InterruptableJob {
	@Override
	public void interrupt() throws UnableToInterruptJobException {
		
	}

	@Override
	protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
		Logger logger = LoggerFactory.getLogger(TrReReqJob.class);
		
		String[] args = RunApplication.getParams();
		String commandLine = args[0];
		
		SimpleDateFormat format1 = new SimpleDateFormat ( "yyyy-MM-dd HH:mm:ss");
		Date time = new Date();
		String currentTime = format1.format(time);
		
	      try {
	    	logger.info("RunTime: "+currentTime+" | RunShell: "+commandLine+" | Result: Success");
	    	shellCmd(commandLine);
		} catch (Exception e) {
			logger.error("RunTime: "+currentTime+" | RunShell: "+commandLine+" | Result: Error");
			logger.error("Batch Run Fail :", e);
		}
	}

	public static void shellCmd(String command) throws Exception {
		Logger logger = LoggerFactory.getLogger(TrReReqJob.class);
		
		Runtime runtime = Runtime.getRuntime();
          Process process = runtime.exec(command);
		  InputStream is = process.getInputStream();
		  InputStreamReader isr = new InputStreamReader(is);
		  BufferedReader br = new BufferedReader(isr);
		  String line;
		  while((line = br.readLine()) != null) {
              logger.info(line);   
		  }
	}
}


