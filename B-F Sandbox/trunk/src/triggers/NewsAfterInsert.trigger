trigger NewsAfterInsert on News__c (after insert) {
    FeedItem post = new FeedItem();
    String newsTitle;
    String newsGroup;
    String newsAbstract;
    String newsExternalURL;
    String sfURL;
    PageReference pageDetail = new PageReference('/apex/NewsContent');
    sfURL = pageDetail.getURL();
    
    for(News__c newsPost : trigger.new){ 
        newsTitle = newsPost.Name__c;
        newsGroup = newsPost.Group__c;
        newsExternalURL = newsPost.External_URL__c; //use this if not null instead of using newsPost.id

               
        //Get group id to post feed
        if(newsGroup.equals('Company')){
            post.ParentId = news_settings__c.getInstance().Company_News_Chatter__c;
        }else if(newsGroup.equals('Employee')) {
            post.ParentId = news_settings__c.getInstance().Employee_News_Chatter__c;
        }else if(newsGroup.equals('Brands')) {
            post.ParentId = news_settings__c.getInstance().Brand_News_Chatter__c;
        }else if(newsGroup.equals('Industry')) {
            post.ParentId = news_settings__c.getInstance().Industry_News_Chatter__c;            
        }else if(newsGroup.equals('Story of the Day')) {
            post.ParentId = news_settings__c.getInstance().Story_of_the_Day_Chatter__c;
        }else if(newsGroup.equals('Video of the Day')) {
            post.ParentId = news_settings__c.getInstance().Video_of_the_Day_Chatter__c;
        }else if(newsGroup.equals('Travel Alert')) {
            post.ParentId = news_settings__c.getInstance().Travel_Chatter__c;           
        } 

//insert RTF substring here    
        newsAbstract = '';
        if(newsPost.Body__c.length() > 0 && newsPost.Body__c.length() < 200){
            newsAbstract = removeHTML(newsPost.Body__c);//Returns raw html as we are using a rich text field .. removeHTML strips out the html
        }else {
            newsAbstract = removeHTML(newsPost.Body__c.substring(0, 200));//Returns raw html as we are using a rich text field .. removeHTML strips out the html
        }

        post.type = 'LinkPost';
        post.Body = newsAbstract + ' ...'; //'Enter post text here'
        //check if External_URL field is blank if so use newsPost.id else use External_URL value
        if(newsExternalURL!=null){
             post.LinkUrl = newsExternalURL;             
        }else{
            post.LinkUrl = sfURL + '?id='+ newsPost.id;  
        }
        post.Title = newsTitle;
    }
    try {
    	insert post;
    } catch (DMLException e) {
    	
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