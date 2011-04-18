public class DEwerbemittelController{
	
	public Boolean showfirstpage {get; set;}
	public Boolean showsecondpage {get; set;}
	public Boolean showthirdpage {get; set;}
	public String goHomeUrl { get; set; }
	public Boolean alert {get; set;}
	
	
	List<myterm> Terms = new List<myterm>();
	List<myterm> Terms2 = new List<myterm>();
	Account a = new Account();
	DEuserdataController ctrl = new DEuserdataController();
	Werbemittel_Bestellung__c bestellungTemp= new Werbemittel_Bestellung__c();
	DEretrieveAccountFromContact bestellung;
	String help_id = '' ; 
	List<Werbemittel_Bestellung__c>  Wbestellung;
  	  	
  	public DEwerbemittelController () {   //our constructor. show only the first page at the beginning
  		alert = false;
  		showfirstpage=true;
  		showsecondpage=false;
  		showthirdpage=false;
  		setbestellungTemp();
  		goHomeUrl=SystemSettings.goHome().getUrl();
  		Wbestellung = new List<Werbemittel_Bestellung__c>();
  		
  	}
  	
  	public PageReference firstPage() {   //will show the first page
  		showfirstpage=true;
  		showsecondpage=false;
  		Terms2.clear();

		return null;
	}
	
	public boolean Verify(myterm bla) {   // to remove useless 0. example : '010' -> '10'
		if (bla.quantity!='') {
			while(bla.quantity.substring(0,1)=='0'){
				if(bla.quantity == '0')
					break;
				bla.quantity = bla.quantity.substring(1);
			}	
		}
		if (bla.quantity!='' && bla.quantity != '0') {
			setTerms2(bla);
			return true;
		}
		else
			return false;
	
	}
	
	public PageReference secondPage() {   // will show the second page and add the orders in a list which have to be displayed
		//PageReference pageRef= new PageReference('/apex/Exception');
		//pageRef.setredirect(true);
		Boolean result = false;

			  	
			  	//myterm t2=new myterm();
		for (myterm t: Terms) {
			if(Verify(t))
				result = true;
		}
		if(result) {
			showfirstpage=false;
	  		showsecondpage=true;
	  		alert = false;
		}
		else
		{
		  	showfirstpage=true;
  			showsecondpage=false;
  			alert = true;
  			Terms2.clear();	
		}
		
		return null;
	}
	
      public DEuserdataController getctrl() {
       	return ctrl;
      }  
      
  	public void setbestellungTemp() {
  		if(ctrl!= null && ctrl.c != null) {
  			bestellung = new DEretrieveAccountFromContact(new list<String>{ctrl.c.AccountId});
  		  	bestellungTemp = bestellung.bestellung.get(0);	//anyway for the 0, it cannot be bigger cause this controller is already called by the page.	
  			if(bestellungTemp.Kontakt__c == null || bestellungTemp.Kontakt__c == '') {
  				if(ctrl.u.Firstname != '' && ctrl.u.Firstname != null)	
  				      bestellungTemp.Kontakt__c = ctrl.u.Firstname;
  				if(ctrl.u.Lastname != '' && ctrl.u.Lastname != null)	 
  				 	bestellungTemp.Kontakt__c += ' ' + ctrl.u.Lastname;
  			}
  		}
  		if(SystemSettings.contactid != '')
  			help_id = SystemSettings.contactid;
      }  
	
	public Werbemittel_Bestellung__c getbestellungTemp() {		
		return bestellungTemp;
	}
	
	public PageReference thirdPage() {   //for the 3. page
		showsecondpage=false;
  		showthirdpage=true;
  		
  		Werbemittel_Posten__c WPostenTemp = new Werbemittel_Posten__c();
  		List<Werbemittel_Posten__c> WPosten = new List<Werbemittel_Posten__c>();
  		
 		
 		
 		//system.debug('CONTACTID ID:' + SystemSettings.contactid);	
 		if (help_id!='')
 			bestellungTemp.besteller__c=help_id;
 	//	bestellungTemp.Portal__c = systemsettings.portal;
 		bestellungTemp.Status__c = 'Bestellt';
 		Wbestellung.add(bestellungTemp);

		insert Wbestellung;

  		for(myterm t:Terms2) {
  			WPostenTemp = new Werbemittel_Posten__c();
			WPostenTemp.Werbemittel__c = t.term.id;
  			WPostenTemp.Menge__c = decimal.valueOf(t.quantity);
  			WPostenTemp.Bestellung__c = bestellungTemp.Id;
  			WPosten.add(WPostenTemp);
  		}		
		
		insert WPosten;
		PageReference ref = ApexPages.currentPage();
		ref.getParameters().put('isDone', '');
		ref.setRedirect(true);
  		return ref;
	}
  	
  	public class myterm {   //our help class
  		public String quantity {get; set;}
  		public Werbemittel__c term {get; set;}
  		
  		public myterm() {
  			quantity='';
  			term=new Werbemittel__c();
  		}
  	}
  	
  	public void setTerms2(myterm T) {
       	Terms2.add(T);
      }  
      
  	public List<myterm> getTerms2() {
       	return Terms2;
      }  
      
      public List<myterm> getTerms() {    //we retrieve the datas from salesforce which have to be displayed in the webshop
      	//List<myterm> Terms = new List<myterm>();
		if (Terms.isEmpty()) {
	      	for (Werbemittel__c wm: [Select Id, Bild__c, Titel__c, Beschreibung__c, Artikelnummer__c, Verpackungseinheit__c, Name From Werbemittel__c where Aktiv__c = true and Portal__c =: systemsettings.portal order by Titel__c desc]) {
	        		myterm t=new myterm();
	        		t.term=wm;
	        		terms.add(t); 
	        	}
		}
       	return Terms;
      }  
}