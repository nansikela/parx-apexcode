public with sharing class retrieveAccountFromContact {
	
	public list<Werbemittel_Bestellung__c> bestellung { get; set; }
		
	public retrieveAccountFromContact(String temp, list<String> c) {
		bestellung = new list<Werbemittel_Bestellung__c>();
		if(c == null) {
			c = new list<String>();
			c.add(temp);
		}	
		getCurrentAccount(c);
	}
	
	private void getCurrentAccount(list<String> c) {
  		list<Account> a2 = [Select ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, 
  		ShippingCity, Kontakt_Lieferanschrift__c, Firmenname_Lieferanschrift__c, BillingStreet, Name,
  		BillingState, BillingPostalCode, BillingCountry, BillingCity From Account where Id IN :c];
		
		Werbemittel_Bestellung__c bestellungTemp;
		for(Account a:a2) {
			bestellungTemp = new Werbemittel_Bestellung__c();
	  	 	if(a.ShippingStreet == null || a.ShippingStreet == '') {
		  		bestellungTemp.Strasse__c = a.BillingStreet;
		  		bestellungTemp.Postleitzahl__c = a.BillingPostalCode;
		  		bestellungTemp.Stadt__c = a.BillingCity;
				bestellungTemp.Land__c = a.BillingCountry;
		  		bestellungTemp.Firmenname__c = a.Name;
	  		}
	  		else {
	  			bestellungTemp.Strasse__c = a.ShippingStreet;
		  		bestellungTemp.Postleitzahl__c = a.ShippingPostalCode;
		  		bestellungTemp.Stadt__c = a.ShippingCity;
		  		bestellungTemp.Land__c = a.ShippingCountry;
		  		if(a.Firmenname_Lieferanschrift__c == '' || a.Firmenname_Lieferanschrift__c == null)
		  			bestellungTemp.Firmenname__c = a.Name;
		  		else		
		  			bestellungTemp.Firmenname__c = a.Firmenname_Lieferanschrift__c;
		  		bestellungTemp.Kontakt__c = a.Kontakt_Lieferanschrift__c;
	  		}
	  		bestellung.add(bestellungTemp);
		}
	}
}