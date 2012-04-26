/*************************************************************
*Name : BF_UsersMustFollowManagerTrigger
*Created By : Akash (Appirio Off)
*Created Date : 1st july,2011
*Purpose : trigger to force users to follow their managers on user insert/update
           Check if the manager has been changed or updated.
****************************************************************/

trigger BF_UsersMustFollowManagerTrigger on User (after insert, after update) {
	Profile termProfile = [select id from profile where name='Terminations'];
		  
	List<Id> lstUpdatedUsers = new List<Id>(); 
	for(User user :Trigger.New) {
		User oldUser = Trigger.oldMap.get(user.ID);		
	  	if(isManagerUpdated(user,oldUser)) {
		    lstUpdatedUsers.add(user.Id);
	  	}
	  
		//If the user was moved to the Terminations profile, 
		//send an email to the Terminations Public Group  	  
	    if (user.ProfileID != oldUser.ProfileID && user.ProfileId == termProfile.id){
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				String[] toAddresses = getMailAddresses(); 
			
				mail.setToAddresses(toAddresses);		
				mail.setSenderDisplayName('BF Salesforce Support');	
				mail.setSubject('Terminated User : ' + user.FirstName + ' ' + user.LastName);	
				mail.setUseSignature(false);	
				mail.setHtmlBody('<b> ' + user.FirstName + ' ' + user.LastName +' </b> has been terminated.  Someone needs to de-activete.<p>To view: <a href=https://bf.my.salesforce.com/'+user.Id+'>click here.</a>'
				+'<p/>Old Profile:' + user.Profile.Name);
				Messaging.sendEmail(new Messaging.Email[] { mail });		    	
	    }	  
	}
	  
	if(lstUpdatedUsers.size() > 0 ) { 
	  BF_UsersMustFollowManager.followManager(lstUpdatedUsers); 
	}

	//-----------
	//Returns the email addresses from the terminations public group
	//---------------
	private List<String> getMailAddresses(){
		List<String> mailList = new List<String>();
		List<String> mailAddresses = new List<String>(); 
	  
		Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name = 'Terminations'];
		for (GroupMember gm : g.groupMembers) {
			mailList.add(gm.userOrGroupId);
	  	}
	  	User[] usr = [SELECT email FROM user WHERE id IN :mailList];
	  	for(User u : usr) {
	  		mailAddresses.add(u.email);
	  	} 
	
	  	return mailAddresses;
	}
  
	//-----------------------------------------//
	// Returns true if the manager of the user is changed in case of update
	// and in case of insert if manager is not  blank 
	//-----------------------------------------//
	private Boolean IsManagerUpdated(User user,User oldUser) {
    	if(Trigger.isInsert) {
      		return (user.ManagerId != null);
    	}
    
    	if(!oldUser.isActive && user.IsActive && user.ManagerId != null)
	      	return true;
     
	    if(oldUser.ManagerId != user.ManagerId && user.ManagerID != null) {
      		return true;
    	}
    	return false;
  	} 
}