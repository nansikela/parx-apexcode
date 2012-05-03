@isTest
private class Test_BME {

    static testMethod void myUnitTest() {
		List<Change_Set__C> changeRequests = new List<Change_Set__c>();
    	RecordType releaseRtype = [Select Id From RecordType where Sobjecttype = 'change_set__c' and name = 'Release' limit 1];

        Change_Set__c cr1 = new Change_Set__c(
        	RecordTypeID=releaseRtype.id,
        	Summary__c='test summary',
        	Deployed__c=false,
        	Tested_In_QA__c = true,        	
        	Release_Notes__c='test release notes'); 
   	
    	String longSummary = padRight('test summary',260);
    	String longReleaseNotes = padRight('test release notes',955); 
    	system.debug(longSummary.length());   	
    	system.debug(longReleaseNotes.length());
        Change_Set__c crLong = new Change_Set__c(
        	RecordTypeID=releaseRtype.id,        
        	Summary__c= longSummary,
        	Deployed__c=false,
        	Tested_In_QA__c = true,
        	Release_Notes__c= longReleaseNotes);

        changeRequests.add(cr1);
		changeRequests.add(crLong);        
		insert changeRequests;	 	    	
   	
		//Change Deployed to true so the trigger fires    	
    	cr1.Deployed__c=true;
    	crLong.Deployed__c=true;    

		changeRequests.clear();
    	changeRequests.add(cr1);   	
		changeRequests.add(crLong);	 
		update changeRequests;   		
    }
	
	public static String padRight(String s, Integer len) {
		for (Integer i=0;i<len;i++) {
			s = s+' ';
		}
		system.debug(s);
		return s;
	}   
	 
}