public with sharing class cloneWerbemittelBestellung {
	
	public static Werbemittel_Bestellung__c WB = new Werbemittel_Bestellung__c();
	public static Boolean hasError { get; set; }
	public static String oldId;
	
	public cloneWerbemittelBestellung(ApexPages.StandardController controller) {
		Werbemittel_Bestellung__c WB_temp = new Werbemittel_Bestellung__c();
		//String oppid=getParam('Id');
		WB_temp = (Werbemittel_Bestellung__c)controller.getSubject();
		oldId = WB_temp.Id;
		//WB = WB_temp;
		WB_temp = [select id, Besteller__c, Firmenname__c, Kontakt__c, Strasse__c, Postleitzahl__c, Stadt__c, Land__c, Posten__c, PortalHidden__c, IsPro__c from Werbemittel_Bestellung__c where Id = :WB_temp.Id limit 1];
	//	WB.Besteller__c = WB_temp.Besteller__c;
	//	WB.Firmenname__c = WB_temp.Firmenname__c;
	//	WB.Kontakt__c = WB_temp.Kontakt__c;
	//	WB.Strasse__c = WB_temp.Strasse__c;
	//	WB.Postleitzahl__c = WB_temp.Postleitzahl__c;
	//	WB.Stadt__c = WB_temp.Stadt__c;
	//	WB.Land__c = WB_temp.Land__c;
	//	WB.Posten__c = WB_temp.Posten__c;

	}  

//	private String getParam(String name) {
//   		return ApexPages.currentPage().getParameters().get(name);  
//  	}
  	
  	public PageReference redirect() {
    		// creating new OppLineItem
    		//createWerbemittelBestellung();
    		insert WB;
    		createPosten();
    		if (!ApexPages.hasMessages() && WB.id!=null) {
      		// successful -> go to the new record
      		String url='/' + WB.id + '/e?retURL=%2F' + WB.id;
      		PageReference editoli = new PageReference(url);
      		editoli.setRedirect(true);
      		return editoli;
    		} else {
      		// show error
     		//	hasError=true;  
      		return null;
    		}
      } 
      
      public static void createPosten() {
    		//ApexPages.Message createWerbemittelBestellungError = new ApexPages.Message(ApexPages.Severity.FATAL, System.label.createOpportunityLineItemError);
    		list <Werbemittel_Posten__c> WP_toInsert = new list <Werbemittel_Posten__c>();
		Werbemittel_Posten__c WP_help;
		
		list<Werbemittel_Posten__c> WP = new list<Werbemittel_Posten__c>([Select Id, Menge__c, Werbemittel__c, Bestellung__c
				From Werbemittel_Posten__c where Bestellung__c = :oldId]);
				
		system.debug('oldid= ' + oldId + ' ' + WP.size());		
		for(Werbemittel_Posten__c temp: WP) {
			WP_help = new Werbemittel_Posten__c();
			WP_help.Menge__c = temp.Menge__c;
			WP_help.Bestellung__c = WB.Id;
			WP_help.Werbemittel__c = temp.Werbemittel__c;
			WP_toInsert.add(WP_help);
		}
		insert WP_toInsert;
	}
		
 	public PageReference back() {
      	PageReference backtoopp = new PageReference('/' + WB.id);
      	backtoopp.setRedirect(true);
      return backtoopp;
      }
}