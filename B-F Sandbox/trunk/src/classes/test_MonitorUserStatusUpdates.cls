@isTest
private class test_MonitorUserStatusUpdates {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
 
        Profile p = [select id from profile where name='Standard User'];         
        User user = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8', lastname='Testing',         
        languagelocalekey='en_US', profileid = p.id, localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='standarduser@b-f.com',        
        CurrentStatus='New status');                
        insert user;                        
        // Start the test        
        test.startTest();        
        // Execute as the user         
        system.runAs(user) {            
        	// Set the status message            
        	user.CurrentStatus = 'Just installed Chatter for iPad m.salesforce.com';            
        	try{                
        		// Try to update the status message                
        		update user;            
        	} catch(DmlException e){                
        		// Verify the results are as expected                
        		System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,e.getDmlType(0));                
        		System.assertEquals('Unwanted Status: Just installed Chatter for iPad m.salesforce.com',e.getDmlMessage(0));            
        	}        
        }        
        // Stop the test        
        test.stopTest();  
    }
}