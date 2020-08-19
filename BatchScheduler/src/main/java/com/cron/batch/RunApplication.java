package com.cron.batch;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class RunApplication {
    private static String[] ParamList;
    
    public static String[] getParams() {
        return ParamList;
    }
    
	public static void main(String[] args) {
		String[] Params = new String[2];
		Logger logger = LoggerFactory.getLogger(RunApplication.class);
		
		//Default Setting : 10분마다 batchAdmin.sh(기본제공) 실행
		String ShellDir = args[0];
		Params[0] = "sh " + ShellDir + "batchAdmin.sh";
		
		if (args.length == 1 ) {
			Params[1] = "0 0/10 * * * ?";	
			
		} else if (args.length == 2 ) {
			Params[1] = args[1].replace(",", " ");
			
		} else {
			logger.info("사용법: startBatch.sh $PortNumber 또는 startBatch.sh $ProtNumber $cronCycle");
			return;
		}
		
		ParamList = Params;
		SpringApplication.run(RunApplication.class, Params);
		
	
	}
}
