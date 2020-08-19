package com.cron.batch.ctr;

import static org.quartz.JobBuilder.newJob;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.PostConstruct;

import org.quartz.CronScheduleBuilder;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

import com.cron.batch.RunApplication;
import com.cron.batch.job.TrReReqJob;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
public class BatchController {

    @Autowired
    private Scheduler scheduler;
    

    @PostConstruct
    public void start() {
		Logger logger = LoggerFactory.getLogger(BatchController.class);
    	
		String[] args = RunApplication.getParams();
		String cronCycle = args[1];
		
        JobDetail aggreReqJobDetail = buildJobDetail(TrReReqJob.class, "QuartzJob", "Quartz", new HashMap());
        try {
			scheduler.scheduleJob(aggreReqJobDetail, buildJobTrigger(cronCycle));
		} catch (SchedulerException e) {
			logger.error("start Function Fail :", e);
		}
    }

    public Trigger buildJobTrigger(String scheduleExp) {
        return TriggerBuilder.newTrigger()
                .withSchedule(CronScheduleBuilder.cronSchedule(scheduleExp)).build();
    }

    public JobDetail buildJobDetail(Class job, String name, String group, Map params) {
        JobDataMap jobDataMap = new JobDataMap();
        jobDataMap.putAll(params);

        return newJob(job).withIdentity(name, group)
                .usingJobData(jobDataMap)
                .build();
    }
}
