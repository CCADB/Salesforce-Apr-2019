/*******************************************************************************************************
 Name: CPACanadaServiceDeltaScheduler

 Dependencies: CPACanadaServiceController, CPACanadaServiceDeltaBatch, 
 CPACanadaServiceAllScheduler, CPACanadaServiceDeltaScheduler, CPACanadaServiceControllerTest

 Description: Scheduler class for get Delta CPACAnada Files
 
 Class is created for call API to get CPA Canada report file urls and update in Salesforce.
  
 Instructions:  
 
    RUN CODE FROM CONSOLE
    //It calls batch for delta, if count doesn't match then auto runs job and sync all files.
    CPACanadaServiceDeltaScheduler.scheduleMe('CPACanada Sync Delta Files');
  
    
 *******************************************************************************************************
 Revision History:
 
     2/19/2019 - Created new class
     
 ******************************************************************************************************/
 
global class CPACanadaServiceDeltaScheduler implements Schedulable{
 
   public static String sched1 = '0 0 1 ? * *'; //Everyday 1 AM
   public static String sched2 = '0 0 13 ? * *'; //Everyday 1 PM
  
   global static String scheduleMe(String jobNameStr) {
        CPACanadaServiceDeltaScheduler SC = new CPACanadaServiceDeltaScheduler(); 
        System.schedule(jobNameStr + ' 1 AM', sched1, SC);
        return System.schedule(jobNameStr + ' 1 PM', sched2, SC);
    }

    global void execute(SchedulableContext sc) {
        //CPACanadaServiceController.getDeltaCPACanadaFiles(); 
        CPACanadaServiceDeltaBatch batch = new CPACanadaServiceDeltaBatch();
        Database.executebatch(batch, 1);
    }
}