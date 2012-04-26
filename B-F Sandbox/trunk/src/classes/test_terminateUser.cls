@isTest
private class test_terminateUser {

    static testMethod void myUnitTest() {
	Profile initialProfile = [select id from profile where name='Standard User'];        
    Profile termProfile = [select id from profile where name='Terminations'];
   
	//Creating a Test User
	User termUser = new User(alias='tuser',email='myTermTest@b-f.com', 
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = initialProfile.id,
            timezonesidkey='America/Los_Angeles', username='myTermTest@b-f.com@b-f.com');
	insert termUser;     
	termuser.profileID = termProfile.id;

    update termUser;
    }
}