public class SeminarhotelViewController {
    private static String pageid;
    private Account account;
    //private WebHotelHelper hotelHelper;
    
    public List<Product2> products {get;set;}
    
    public SeminarhotelViewController()
    {
    }
    
    public SeminarhotelViewController (ApexPages.StandardController stdController)
    { /*
        try
        {
             //this.hotelHelper = new WebHotelHelper();
        
            account = (Account) stdController.getRecord();

            products = [Select p.Id, p.Portfolio__r.Id, p.Name, p.Seminarcode__c From Product2 p where Seminarort__c = :account.Id];
        }
        catch(System.Exception e)
        {
            System.debug('** Exception : ' + e.getMessage());
            ApexPages.addMessages(e);   
        } */
    }
    
    public List<hotel__c> getHotels()
    {
       return [Select h.id, h.Name, h.Karte__c, h.Account__r.BillingCity, h.Account__r.Sprechende_URL__c From Hotel__c h WHERE Anzeige_auf_Website__c = true ORDER BY h.Account__r.BillingCity];
    }
    
    public static String getHotelURL(){
      if(pageid==null)
      pageid = WebURLEncoder.getPageIdById('p-00018');
      
      
      return '?pageid='+pageid+'&hotelId=';
    }
    
}