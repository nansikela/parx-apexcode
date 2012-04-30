trigger ChatterPostCompanyNewsAfterInsertUpdate on News__c (after insert) {

FeedItem post = new FeedItem();
    String newsTitle;
    String newsGroup;
    String newsAbstract;
    String newsExternalURL;
    String sfURL;
    PageReference pageDetail = new PageReference('https://cs3.salesforce.com/apex/NewsContent');
    sfURL = pageDetail.getURL();
    
    for(News__c newsPost : trigger.new){ 
        newsTitle = newsPost.Name;
        newsGroup = newsPost.Group__c;
        newsExternalURL = newsPost.External_URL__c; //use this if not null instead of using newsPost.id 
         //Get group id to post feed
        if(newsGroup.equals('Company')){
            //post to group 'Test'
//            post.ParentId = '0F9Q00000004D0d'; // id  ....This can be hardcoded or can be evaluated on a formula field and then pulled in here..
            //post to group 'Test Group'
            post.ParentId = '0F9Q00000004D2e';
        }else if(newsGroup.equals('Employee')) {
            post.ParentId = '';
        }else if(newsGroup.equals('On The Move')) {
            post.ParentId = ''; 
        }else if(newsGroup.equals('Discounts')) {
            post.ParentId = '';
        }else if(newsGroup.equals('Services')) {
            post.ParentId = '';
        }

//insert RTF substring here
//String Content = newsPost.Body__c.substring(0, 200);       
        newsAbstract = '';
        if(newsPost.Body__c.length() < 200 && newsPost.Body__c!=null){
            newsAbstract = removeHTML(newsPost.Body__c);//Returns raw html as we are using a rich text field .. removeHTML strips out the html
        }else {
            newsAbstract = removeHTML(newsPost.Body__c).substring(0, 200);//Returns raw html as we are using a rich text field .. removeHTML strips out the html
        }

/*
        if(newsPost.Content__c.length()< 200){
            newsAbstract = newsPost.Content__c;//Get Content
        }else {
            newsAbstract = newsPost.Content__c.substring(0, 200);//Get abstract
        }
*/
        post.type = 'LinkPost';
        post.Body = newsAbstract + ' ...'; //'Enter post text here'
        //check if External_URL field is blank if so use newsPost.id else use External_URL value
        if(newsExternalURL!=null){
             post.LinkUrl = newsExternalURL;
        }else{
//            post.LinkUrl = '/'+ newsPost.id;
//            post.LinkUrl = '/apex/NewsContent?id='+ newsPost.id;
            post.LinkUrl = sfURL + '?id='+ newsPost.id;  
        }
        post.Title = newsTitle;
    }
    insert post;

    public String removeHTML(String htmlString){ 
        String noHTMLString = htmlString.replaceAll('\\<.*?\\>', ''); 
        noHTMLString = noHTMLString.replaceAll('\r', '<br/>'); 
        noHTMLString = noHTMLString.replaceAll('\n', ' ');
        noHTMLString = noHTMLString.replaceAll('\'', '&#39;');
        noHTMLString = noHTMLString.replaceAll('\"', '&quot;');
        return noHTMLString;
    }



/*
//Adding a Text post
FeedItem post = new FeedItem();
post.ParentId = '0F9Q00000004D0d'; // Test group id..
post.Body = newsAbstract; //'Enter post text here';
insert post;

//Adding a Link post
FeedItem post = new FeedItem();
post.ParentId = oId; // group id..
post.Body = 'Enter post text here';
post.LinkUrl = 'http://www.someurl.com';
insert post;

//Adding a Content post
FeedItem post = new FeedItem();
post.ParentId = oId; // group id..
post.Body = 'Enter post text here';
post.ContentData = base64EncodedFileData;
post.ContentFileName = 'sample.pdf';
insert post;
*/
}