/*******************************************************************************************************
 Name: CPACanadaServiceAllScheduler

 Dependencies: CPACanadaServiceController, CPACanadaServiceDeltaBatch, 
 CPACanadaServiceAllScheduler, CPACanadaServiceDeltaScheduler, CPACanadaServiceControllerTest

 Description: Scheduler class for get All CPACAnada Files
 
 Class is created for call API to get CPA Canada report file urls and update in Salesforce.
  
 Instructions:  
 
    RUN CODE FROM CONSOLE
    CPACanadaServiceAllScheduler.scheduleMe('CPACanada Sync All Files');
  
    
 *******************************************************************************************************
 Revision History:
 
     2/19/2019 - Created new class
     
 ******************************************************************************************************/
 
 
global class CPACanadaServiceAllScheduler implements Schedulable{
 
   public static String sched = '0 0 6 ? * SUN'; //Every Sunday 6 AM
  
   global static String scheduleMe(String jobNameStr) {
        CPACanadaServiceAllScheduler SC = new CPACanadaServiceAllScheduler(); 
        return System.schedule(jobNameStr, sched, SC);
    }

    global void execute(SchedulableContext sc) {
        CPACanadaServiceController.getAllCPACanadaFiles(); 
    }
}