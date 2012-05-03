global class BF_UpdateNextLevelManagerNamesSchedule implements Schedulable
{ 
 global void execute(SchedulableContext ctx)
 {
    //call a future method so we can do callouts within a schedule    
    BF_UpdateNextLevelManagerNames.callUpdateManagerNames();
 }
 @isTest
   public static void testBF_UsersMustFollowManagerSchedule() {
     BF_UpdateNextLevelManagerNamesSchedule s = new BF_UpdateNextLevelManagerNamesSchedule();
     s.execute(null);
 }
}