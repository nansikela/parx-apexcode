public class WebSeminarDetailNextSeminar {
    public String datum {get; set;}
    public String place {get; set;}
    public String placeLink {get; set;}
    public String trainer {get; set;}
    public String trainerLink {get; set;}
    public String cotrainer {get; set;}
    public String cotrainerLink {get; set;}
    public String bookingLinkText {get; set;}
    public String bookingLink {get; set;}
    public String seminarId {get; set;}
    public boolean istZusatztermin {get; set;}
    public boolean trainerAnzeigeWebsite {get;set;}
    public boolean cotrainerAnzeigeWebsite {get;set;}
    
    public List<WebSeminarDetailNextSeminar> getSeminarList() {
        List<WebSeminarDetailNextSeminar> result = new List<WebSeminarDetailNextSeminar>();
        String portfolio = WebURLEncoder.decodeParam('seminarCode');
        WebSeminarDetailNextSeminar item;
        List<Product2> products = [	Select 
        								
        								p.ist_Zusatztermin__c,
        								p.Co_Trainer__c, 
        								p.Ampel__c , 
        								p.Co_Trainer__r.Id, 
        								p.Co_Trainer__r.Name, 
        								p.Id, 
        								p.Portfolio__c, 
        								p.Portfolio__r.Name, 
        								p.Seminarbeginn__c, 
        								p.Seminarende__c, 
        								p.Trainer__c, 
        								p.Trainer__r.Id, 
        								p.Trainer__r.Name,
        								p.Trainer__r.Sprechende_URL__c,
        								p.Trainer__r.Anzeige_Auf_Website__c,
        								p.Co_Trainer__r.Sprechende_URL__c,
        								p.Co_Trainer__r.Anzeige_Auf_Website__c,
        								p.Veranstaltungsort__c, 
        								p.Veranstaltungsort2__c, 
        								p.Veranstaltungsort2__r.Id, 
        								p.Veranstaltungsort2__r.Name 
        							from Product2 p 
        							WHERE 
        								p.Portfolio__r.Name = : portfolio 
        							AND p.Anzeige_auf_Website__c = true 
        							AND p.Seminarbeginn__c >=today 
        							ORDER BY p.Seminarbeginn__c];
        
        
        //Generating URLs DetailPages
        String bookingURL 	= WebURLEncoder.getPageIdById('p-00015');
        String trainerURL 	= WebURLEncoder.getPageIdById('p-00016');
        String placeURL 	= WebURLEncoder.getPageIdById('p-00018');
        String noBookingURL	= WebURLEncoder.getPageIdById('p-00017');
        
        for(Product2 p:products){
            item 					= new WebSeminarDetailNextSeminar();
            item.datum 				= p.Seminarbeginn__c.format() +' - '+ p.Seminarende__c.format();
            item.place 				= p.Veranstaltungsort2__r.Name;
            item.placeLink 			= 'page?pageid='+placeURL+'&hotelId=' + p.Veranstaltungsort2__r.Id;
            item.trainer 			= p.trainer__r.name;
            item.trainerLink 		= p.Trainer__r.Sprechende_URL__c;
            item.cotrainer 			= p.co_trainer__r.name;
            item.cotrainerLink 		= p.Co_Trainer__r.Sprechende_URL__c;
            item.istZusatztermin	= p.ist_Zusatztermin__c;
            item.seminarId			= p.id;
            item.trainerAnzeigeWebsite	= p.Trainer__r.Anzeige_auf_website__c;
            item.cotrainerAnzeigeWebsite = p.Co_Trainer__r.Anzeige_auf_website__c;
            
            //Booking ok?
            if(p.Ampel__c != '<img src="/img/samples/light_red.gif" alt="status color" border="0"/>'){
                item.bookingLink 	= 'page?pageid='+bookingURL+'&seminarCode='+portfolio ;
                item.bookingLinkText = 'Buchen';
            }else{
                item.bookingLink = 'page?pageid='+noBookingURL+'&seminarCode='+portfolio ;
                item.bookingLinkText = 'ausgebucht';
            }
            
            result.add(item);
        }
        
        
        return result;
    }

}