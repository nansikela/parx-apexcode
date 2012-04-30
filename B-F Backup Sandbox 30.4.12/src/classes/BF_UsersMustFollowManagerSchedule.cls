/*************************************************************
*Name : BF_UsersMustFollowManagerSchedule
*Created By : Akash (Appirio Off)
*Created Date : 1st july,2011
*Purpose : Schedules BF_UsersMustFollowManagerJob class 
****************************************************************/
global class BF_UsersMustFollowManagerSchedule implements Schedulable {

// class that allows us to schedule execution of the BF_UsersMustFollowManagerJob batch job.

  global void execute(SchedulableContext sc) {
    Database.executeBatch(new BF_UsersMustFollowManagerJob(null));
  }
  
  @isTest
  public static void testBF_UsersMustFollowManagerSchedule() {
    BF_UsersMustFollowManagerSchedule s = new BF_UsersMustFollowManagerSchedule();
    s.execute(null);
  }

}