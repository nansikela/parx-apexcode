public with sharing class INFW_TestHelper {

	public User createUser(){	
		User u1 = new User();
        u1.LastName = 'Welders';
        u1.FirstName = 'Info';
        Profile []p = [select id from Profile where Name = 'Standard User' LIMIT 1];        
        u1.ProfileID = p[0].id; 
        u1.Username = 'info@welders.com';
        u1.Email = 'info@welders.com';
        u1.Alias = 'infw';
        u1.CommunityNickname = 'infw98213';
        u1.TimeZoneSidKey='America/New_York';
        u1.LocaleSidKey='en_US';
        u1.EmailEncodingKey='UTF-8';
        u1.LanguageLocaleKey='en_US';  
        return u1;
	}	
}