global class Schedule1minute implements Schedulable {
  
  global void execute(SchedulableContext SC)  {                  
        //The line of code below would contain the required business logic      
  //  CongaSchedule.init();
    abort(SC.getTriggerId());
    
    list<Document__c> Docs = new list<Document__c>([select id from Document__c where PDF2Produce__c = true]);
    list<FeedItem> FeedItems = new list<FeedItem>();
    for(Document__c doc:Docs) {
        doc.PDF2Produce__c = false;
        PageReference pdf = new PageReference('http://rothkopf-developer-edition.na14.force.com/PDFGenerator?id=' + doc.Id);
        Blob body;
        body = pdf.getContent();
        FeedItem post = new FeedItem(ContentData =body, ContentFileName  = 'Content.pdf', ParentId = doc.Id);
        FeedItems.add(post);
    }
    
    if(!FeedItems.isEmpty()) {
        update docs;
        insert FeedItems;
        
     }
        
    String hour = String.valueOf(Datetime.now().hour());
    String min = String.valueOf(Datetime.now().minute() + 1);
    String ss = String.valueOf(Datetime.now().second()); 
    
    if(Datetime.now().minute() + 1 > 59) {
      min='0'; 
      hour = String.valueOf(Datetime.now().hour()+1);
    }
    
    if(Datetime.now().hour() + 1 > 23) {
      hour = '0'; 
    }
    
    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
    
    Schedule1minute s = new Schedule1minute();
    System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
  } 
      
    //  @future(callout=true)
  private static void abort(String Id){ 
    try{
      System.abortjob(Id);
    }
    catch(exception e) {
    }
   } 
}