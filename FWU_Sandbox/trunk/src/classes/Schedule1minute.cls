global class Schedule1minute implements Schedulable {

	global void execute(SchedulableContext SC)  {	                
        //The line of code below would contain the required business logic      
		abort(SC.getTriggerId());
		CongaSchedule.init();

		
        	//system.debug(SC);
		String hour = String.valueOf(Datetime.now().hour());
		String min = String.valueOf(Datetime.now().minute() + 1);
		String ss = String.valueOf(Datetime.now().second()); 
		
		if(Datetime.now().minute() + 1 > 59) { 
			min='0';
			hour = String.valueOf(Datetime.now().hour()+1);
		}
    
		if(Datetime.now().hour() + 1 > 23) {
			hour = '0';
		}
    
		String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
   
		Schedule1minute s = new Schedule1minute();
		System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);

	} 
  
	private static void abort(String Id){ 
		try{
			System.abortjob(Id);
		}
		catch(exception e) {//could happen if the job is does not exist in the table.
		}
 	}   
}