@isTest
private class Test_beforeInsertMonitorEntityFeeds {

    static testMethod void myUnitTest() {
        Profile p = [select id from profile where name='Standard User'];         
        User user = new User(alias = 'standt', email='standarduser@testorg.com', emailencodingkey='UTF-8', lastname='Testing',         
        languagelocalekey='en_US', profileid = p.id, localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='standarduser@b-f.com',        
        CurrentStatus='New status');                
        insert user;                               

        FeedItem post = new FeedItem();
        post.ParentID = user.Id;
        post.Body = 'Just installed Chatter Desktop';
        post.LinkUrl = 'http://www.salesforce.com/';

        FeedItem post2 = new FeedItem();
        post2.ParentID = user.Id;
        post2.Body = 'Just installed Chatter Desktop';
        post2.Type = 'TextPost';
        
        FeedItem post3 = new FeedItem();
        post3.ParentID = user.Id;
        post3.Body = 'Chatter Desktop wurde gerade installiert';
        post3.LinkUrl = 'http://www.salesforce.com/';      
        
        FeedItem post4 = new FeedItem();
        post4.ParentID = user.Id;
        post4.Body = 'Just started using Mobile Dashboards for iPad!';
        post4.LinkUrl = 'http://www.salesforce.com/'; 
                
        test.startTest();                
        system.runAs(user) {                  
            try{
            	insert post;
            	insert post2;
            	insert post3;
            	insert post4;
            } catch(DmlException e){                                
                System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION,e.getDmlType(0));                
                System.assertEquals('Unwanted FeedItem',e.getDmlMessage(0));            
            }        
        }              
        test.stopTest();  
    }
}