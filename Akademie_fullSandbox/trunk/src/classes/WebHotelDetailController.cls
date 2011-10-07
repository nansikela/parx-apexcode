public class WebHotelDetailController {
  public static Hotel__c hotel {get;set;}
  
  public WebHotelDetailController(){
    if(hotel==null){
      String hotelid = WebURLEncoder.decodeParam('hotelId');
      hotel = [	Select 
      				h.account__c, 
      				h.account__r.BillingStreet, 
      				h.account__r.BillingPostalCode, 
      				h.account__r.Phone, 
      				h.account__r.Fax, 
      				h.account__r.BillingCity, 
      				h.Karte__c, 
      				h.Hotelbeschreibung__c, 
      				h.account__r.Website, 
      				h.account__r.Latitude__c,
      				h.account__r.Longitude__c,
      				h.Id, 
      				h.name, 
      				h.bildurl__c 
      			from Hotel__c h 
      			WHERE 
      				h.id =:hotelid 
      				AND 
      				h.Anzeige_auf_Website__c = true];
    }
  }

  public static Hotel__c getHotelInformation(){
    
    return hotel;
  }
  
  
  private static String getAccuntFromHotel(){
    String hotelid = WebURLEncoder.decodeParam('hotelId');
    Hotel__c result = [SELECT Account__c FROM Hotel__c h WHERE h.id = :hotelid];
    return result.Account__c;
  }

  
    public static List<Portfolio__c> getSeminarEvents(){
      
      System.Debug('xxx');
    String accountid = getAccuntFromHotel();
    List<Product2> products = new List<Product2>();
    String hotelid = WebURLEncoder.decodeParam('hotelId');
    List<Portfolio__c> result = new List<Portfolio__c>();
    products= [	Select 
    				p.Portfolio__r.register__c,
    				p.Portfolio__r.Englisch__c, 
    				p.Portfolio__r.Seminartitel__c, 
    				p.Portfolio__r.NEU__c, 
    				p.Portfolio__r.id, 
    				p.Portfolio__r.Name,
    				p.Portfolio__r.sprechende_URL__c
    			From Product2 p 
    			WHERE 
    				p.Seminarbeginn__c > today 
    				AND 
    				p.Veranstaltungsort2__c = :hotelid 
    				AND 
    				anzeige_auf_website__c = true 
    			ORDER BY p.Portfolio__r.name];
    Portfolio__c item;
    Portfolio__c oldItem;
    oldItem = new Portfolio__c();
    oldItem.name = '';
    
    
    for(Product2 p: products){
      if(p.Portfolio__r.name != null){
      item = p.Portfolio__r;
      if(oldItem.Name!=item.Name){
      	result.add(item);
      }
      oldItem = new Portfolio__c();
      oldItem = item;
      }
    }
    
    return result;
  }
  
}