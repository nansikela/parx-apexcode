trigger afterUpdatePostChangeRequestToChatter on Change_Set__c (after update) {
	String postBody;
	String postTitle;
	List<FeedItem> posts = New List<FeedItem>();
	List<bme_settings__c> bmeSettings = bme_settings__c.getAll().values();	
    RecordType releaseRtype = [Select Id From RecordType where Sobjecttype = 'change_set__c' and name = 'Release' limit 1];
    
    for(Change_Set__c cr : trigger.new){ 
    	Change_Set__c oldCR = trigger.oldMap.get(cr.ID);
    	if (oldCR.Deployed__c == false && cr.Deployed__c == true && cr.RecordTypeId == releaseRtype.id) {	
	    	FeedItem post = new FeedItem();
	    	
	        if(cr.Release_Notes__c.length() > 0 && cr.Release_Notes__c.length() < 950){
	            postBody = 'SalesForce Change Deployed: \r\n' +removeHTML(cr.Release_Notes__c);
	        }else {
	            postBody = 'SalesForce Change Deployed: \r\n' +removeHTML(cr.Release_Notes__c.substring(0, 950));
	        }

	        if(cr.Summary__c.length() > 0 && cr.Summary__c.length() < 255){
	            postTitle = removeHTML(cr.Summary__c);
	        }else {
	            postTitle = removeHTML(cr.Summary__c.substring(0, 255));
	        }

	        post.ParentId = bmeSettings[0].BF_IT_Chatter_Group__c;       
	        post.type = 'LinkPost';
	        post.Body = postBody;
	        post.LinkUrl = '/' + cr.id;  
	        post.Title = postTitle;
	        
			if (post.ParentID != null) {
        		posts.add(post);
			}
    	}
    }
    
    if (posts.size() > 0) {
   		insert posts;
    }

    public String removeHTML(String htmlString){ 
        String noHTMLString = htmlString.replaceAll('\\<.*?\\>', ''); 
        noHTMLString = noHTMLString.replaceAll('<br/>', '\r'); 
        noHTMLString = noHTMLString.replaceAll('\n', ' ');
        noHTMLString = noHTMLString.replaceAll('&amp;', '&');        
        noHTMLString = noHTMLString.replaceAll('&#39;', '\'');
        noHTMLString = noHTMLString.replaceAll('&quot;', '\"');
        return noHTMLString;
    }
}