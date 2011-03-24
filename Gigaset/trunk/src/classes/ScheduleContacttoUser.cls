global class ScheduleContacttoUser implements Schedulable {
	global void execute(SchedulableContext SC)  {      
    	      abort(SC.getTriggerId());     
		//The few lines of code below would contain the required business logic
		if(FNA_BulkCon.init4Schedule()) {  //for google map partner localisierung
			ContacttoUser.init();    //for AD: to create user from contacts or automatically create user from cases
			ContactRemove.init();    //for AD: to deactivate user
			ContactRemove.removeit();  //mainly for AD: to remove contact- if user is activated or not (do everything automatically)
			ContacttoUser.changeEmail();  //for everybody: if the email is changed in the Contact, we have to change this email in the user.
		} 
		// End of the business logic
		    
		
		
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
		
		         
		ScheduleContacttoUser s = new ScheduleContacttoUser();
		System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
	} 
	
	private static void abort(String Id){ 
		try{
			System.abortjob(Id);
		}
		catch(exception e) {
		}
 	}     
}