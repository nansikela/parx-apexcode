trigger Lead_afterUpdate on Lead (after update) {
	//if lead is converted: attaches all profile & experience objects to the newly created contact
	
	try{
	    LeadConvertHandler leadHandler = new LeadConvertHandler();
		
		leadHandler.updateProfileANDExperienceDeleteOpp(Trigger.new, Trigger.oldMap);
	    
	 }catch(System.Exception e){
	     System.debug('**** Final Exception Lead after update Trigger' + e);
	}
	
}