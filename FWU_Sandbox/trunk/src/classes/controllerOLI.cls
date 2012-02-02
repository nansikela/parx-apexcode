public class controllerOLI {

  	public Opportunity opp = new Opportunity();
  	public list<OpportunityLineItem> OLIlist = new list<OpportunityLineItem>();
  	public static String A_S = '';
  	public static String L_N = '';
  	public static String RAB = '';
  	public static String Amount = '';
  	public List<myterm> Terms = new List<myterm>();
  	public static list<PricebookEntry> prod = new list<PricebookEntry>();
  	public static list<ArtikelLizenz__c> ArtikelLizenz = new list<ArtikelLizenz__c>();
  	public static map<String, String> PBE = new map<String, String>();
	public static map<String, String> LizenzM = new map<String, String>();
	public static list<String> Artikel = new list<String>();
 	public static list<String> LizenzL = new list<String>();
		
	public Boolean showfirstpage {get; set;}
	public Boolean showsecondpage {get; set;}	
	public Boolean displayKopienRabatt {get; set;}
		
  	public class myterm {   //our help class
  		public String Anzahl_Schulen {get; set;}
  		public String Anzahl_SchulenError {get; set;}
  		public String ArtikelId {get; set;} 
  		public String displayInput {get; set;}
  		public String displayOutput {get; set;}
  		public String Id {get; set;} 
  		public boolean Kopien_Rabatt {get; set;}		
  		public String Lizenznummer {get; set;}
  		public String Lizenzpreis {get; set;}
  		public String Name {get; set;}
  		public String NameError {get; set;}
  		public String Quantity {get; set;}
  		public String QuantityError {get; set;}
  		public String Rabatt {get; set;}
  		public String RabattError {get; set;}
  		public String UnitPrice {get; set;}
  		public String UnitPriceError {get; set;}
  		public String Titel {get; set;}
  		
  		public myterm() {
  			//Name='';
  			Anzahl_Schulen = A_S;
  			Rabatt = RAB;
  			displayInput = 'true';			
  			displayOutput = 'false';
  			Lizenznummer = L_N;
  			Quantity='1';
  		}	
  	}
  	
	public controllerOLI(ApexPages.StandardController stdController) {
		myTerm m;
		this.opp = (Opportunity)stdController.getRecord();
		String oId = this.opp.Id;
		showfirstpage = true;
		showsecondpage = false;
		
		opp = [select Id, Lizenznummer__c, Anzahl_Schulen__c, VKPG2A__c, Rabatt__c from Opportunity where Id =: oId limit 1 ];
		if(opp.VKPG2A__c != 'O2')
			A_S = String.valueof(opp.Anzahl_Schulen__c);
		L_N = String.valueOf(opp.Lizenznummer__c);
		RAB = String.valueOf(opp.Rabatt__c);
		if(opp.VKPG2A__c == 'O2' || opp.VKPG2A__c == 'KO' || opp.VKPG2A__c == 'AK')
			displayKopienRabatt = false;
		else
			displayKopienRabatt = true;
			
		if(A_S == '0')
			A_S = '';
		if(L_N == '0')
			L_N = '';
		for(Integer i = 0 ; i < 10 ; i++) {
			m = new myTerm();
		//	m.Anzahl_Schulen = A_S;
			Terms.add(m);
		}
		DisplayAmount();
		
	}
	
	public PageReference updateLine(){
		myTerm m;
		//opp = [select Id, Lizenznummer__c, Anzahl_Schulen__c from Opportunity where Id =: oId limit 1 ];
		if(opp.VKPG2A__c != 'O2')
			A_S = String.valueof(opp.Anzahl_Schulen__c);
		L_N = String.valueof(opp.Lizenznummer__c);
		RAB = String.valueOf(opp.Rabatt__c);
		
		if(A_S == '0')
			A_S = '';
		if(L_N == '0')
			L_N = '';
		for(Integer i = 0 ; i < 10 ; i++) {
			m = new myTerm();
			Terms.add(m);
		}	

		return null;
	}
	
	public PageReference checkLine() {
		feedList();
		for(myTerm t:Terms) {
			verifyNumber(t);
		}
		
		return null;
	}
	public PageReference initCheck()
      { 
            if(opp.Lizenznummer__c == null || opp.Lizenznummer__c == ''){
      		showfirstpage = false;
			showsecondpage = true;
        	}
            return null;
      }
      
	public PageReference saveContinue() {
	//	boolean valid = True;
	system.debug('terms lizenzpreis qw ' + terms[0].Lizenzpreis); 
		feedList();
		list <myterm> Terms_temp = new list <myterm>();
		list <myterm> Terms_to_Save = new list <myterm>();
		integer i = 0;
		for(myterm t:Terms) {
			if(!verifyNumber(t)) {
	//			valid = false;
				Terms_temp.add(t);
			//	Terms.remove(i);			
			}
			else {
				Terms_to_Save.add(t);
			}
		//	i++;
			
		}
		
		if(!Terms_to_Save.isEmpty()) {
			Terms = new list<myterm>();
			Terms.addAll(Terms_to_Save);
			String s = Save();
		}
		
		list<String> oliIds = new list<String>();
		for(OpportunityLineItem oli:OLIlist){
			oliIds.add(oli.Id);
		}	
		OLIlist = new list <OpportunityLineItem>([select id, titel__c, Anzahl_Schulen__c, Quantity, UnitPrice, PricebookEntry.Name, Lizenznummer__c, Discount, Kopien_Rabatt__c, AL_Preis__c, Product2Id__c from OpportunityLineItem where Id IN: oliIds ]);
		
		myTerm m;
		
		Terms = new list <myterm>();
		if(!Terms_temp.isEmpty())
			Terms.addAll(Terms_temp);
		
		for(OpportunityLineItem oli:OLIlist){
			m = new myTerm();
			if(opp.VKPG2A__c == 'KO')
  				m.Anzahl_Schulen = String.valueOf(oli.Anzahl_Schulen__c);
  			m.ArtikelId = oli.Product2Id__c;
			m.Id = oli.Id;
			m.Rabatt = String.valueOf(oli.Discount);
			m.Kopien_Rabatt = oli.Kopien_Rabatt__c;
			m.Lizenznummer = oli.Lizenznummer__c;
  		    m.Name = oli.PricebookEntry.Name;
  			m.Quantity = String.valueOf(oli.Quantity);
  			m.Titel = oli.Titel__c;
  			m.UnitPrice = String.valueOf(oli.UnitPrice);
  			m.Lizenzpreis = String.valueOf(oli.AL_Preis__c);
  			system.debug('lizenz preis ... ' + m.Lizenzpreis); 			
  			m.displayInput = 'false';
  			m.displayOutput = 'true';	
			Terms.add(m);
		}
		
		for(i = 0 ; i < 10 ; i++) {
			m = new myTerm();
			Terms.add(m);
		}
		DisplayAmount();
		return null;
	}
	
	public PageReference saveIt() {
		boolean valid = True;
		feedList();
		for(myterm t:Terms) {
			if(!verifyNumber(t))
				valid = false;
		}
		if(valid) {
			String s = Save();
			if(s!=null) {
				PageReference backtoopp = new PageReference(s);
				backtoopp.setRedirect(true);
				return backtoopp;
			}
			else
				return null;
		}
		else
			return null;
	}
	
	public PageReference cancel() {
		PageReference cancel = new PageReference('/' + opp.id);
		cancel.setRedirect(true);
		return cancel;
	}
		
	private void feedList(){

	 	opp = [select id, Lizenznummer__c, Anzahl_Schulen__c, Rabatt__c,  VKPG2A__c from Opportunity where Id =: opp.Id];
		for(myTerm t:Terms) {
			Artikel.add(t.Name);
			LizenzL.add(t.Name + t.Lizenznummer);		
		}	
		
		prod = [Select Id, Product2.Name From PricebookEntry where Pricebook2.Name = 'Standard Price Book' AND product2.Name IN: Artikel];
		ArtikelLizenz = [select id, Name from ArtikelLizenz__c where ArtikelLizenz__c.Name IN: LizenzL AND SPK015__c = False];
		
		for(PricebookEntry p:prod){
			PBE.put(p.Product2.Name, p.Id);
		}
		for(ArtikelLizenz__c AL:ArtikelLizenz){
			LizenzM.put(AL.Name, AL.Id);
		}
	//	system.debug('Lizenz.. ' + Lizenz);
	}
	
	public PageReference Del() {
		String oliId = ApexPages.currentPage().getParameters().get('oliId');
		OpportunityLineItem oli = new OpportunityLineItem();
		oli= [select id, KreisListe__c from OpportunityLineItem where Id =: oliId];
		Database.delete(oliId);
		if(oli.KreisListe__c != null)
			Database.delete(oli.KreisListe__c);
		Integer i = 0;
		for(myterm t:Terms) {
			if(t.Id == oliId)
				break;
			i++;
		}
		Terms.remove(i);
		DisplayAmount();
		return null;
	}
	
	private void DisplayAmount() {
		Opportunity o = new Opportunity();
		o = [select id, Amount from Opportunity where Id =: opp.Id];
		if(o.Amount == null)
			o.Amount = 0;
		Amount = 'Gesamtpreis: ' +o.Amount + ' €';
		
	}
	
	private String Save() {
		OpportunityLineItem OLI;
		if(opp.VKPG2A__c != 'O2')	
			A_S = String.valueof(opp.Anzahl_Schulen__c);
		RAB = String.valueOf(opp.Rabatt__c);
		L_N = String.valueof(opp.Lizenznummer__c);
		list<String> oliIdsAlreadySaved = new list<String>();
		for(myTerm t:Terms) {
			oliIdsAlreadySaved.add(t.Id);
		}		
		map<Id, OpportunityLineItem> OLISaved = new map<Id, OpportunityLineItem>([select id, SCHL2D__c, Quantity, Anzahl_Schulen__c, UnitPrice, Discount, Kopien_Rabatt__c, AL_Preis__c from OpportunityLineItem where Id IN: oliIdsAlreadySaved]);
		system.debug('Oli debug ' + OLIlist.size());
		system.debug('Oli debug ' + OLIlist);
		OLIlist = new list<OpportunityLineItem>();
		
		for(myTerm t:Terms) {
			//if line is empty, we do not add it.	
			if(  !( (t.Name == '' || t.Name == null) && (t.Quantity == '' || t.Quantity == null || t.Quantity =='1')
				&& (t.Anzahl_Schulen == '' || t.Anzahl_Schulen == null || t.Anzahl_Schulen == A_S || t.Lizenznummer == null|| t.Lizenznummer == '' || t.Lizenznummer == L_N))) {
				system.debug('debug name ' + t.Name + ' ' + t.Id);
				if(t.Id == null) {
					OLI = new OpportunityLineItem();
					if(t.Anzahl_Schulen != null && t.Anzahl_Schulen != '')
						OLI.Anzahl_Schulen__c=Decimal.valueOf(t.Anzahl_Schulen);
					if(t.Rabatt != null && t.Rabatt != '')
						OLI.Discount = Decimal.valueOf(t.Rabatt);
					OLI.OpportunityId = opp.Id;
					OLI.PricebookEntryId=PBE.get(t.Name);
					if(t.Quantity != null && t.Quantity != '')
						OLI.Quantity=Decimal.valueOf(t.Quantity);
					OLI.SCHL2D__c=LizenzM.get(t.Name + t.Lizenznummer);
					
					if(t.Kopien_Rabatt != null && t.Kopien_Rabatt == true)
						OLI.UnitPrice = 0;
					else {	
						if(t.UnitPrice != null && t.UnitPrice != '') {
							OLI.UnitPrice = Decimal.valueOf(t.UnitPrice);
							OLI.skip_Workflow__c = true;
						}
						else 
							OLI.UnitPrice = 0;
					}
					if(t.Kopien_Rabatt != null)
						OLI.Kopien_Rabatt__c = t.Kopien_Rabatt;
					OLIlist.add(OLI);
				}
				else {
					if(t.Anzahl_Schulen != null && t.Anzahl_Schulen != '')
						OLISaved.get(t.Id).Anzahl_Schulen__c=Decimal.valueOf(t.Anzahl_Schulen);
					if(t.Rabatt != null && t.Rabatt != '')
						OLISaved.get(t.Id).Discount = Decimal.valueOf(t.Rabatt);
					
					if(t.Quantity != null && t.Quantity != '')
						OLISaved.get(t.Id).Quantity=Decimal.valueOf(t.Quantity);
					OLISaved.get(t.Id).SCHL2D__c=LizenzM.get(t.Name + t.Lizenznummer);
					
					if(t.Kopien_Rabatt != null && t.Kopien_Rabatt != OLISaved.get(t.Id).Kopien_Rabatt__c)
						OLISaved.get(t.Id).UnitPrice = 0;
					else {	
						if(t.UnitPrice != null && t.UnitPrice != '') {
							OLISaved.get(t.Id).UnitPrice = Decimal.valueOf(t.UnitPrice);
							OLISaved.get(t.Id).skip_Workflow__c = true;
						}
						else							
							OLISaved.get(t.Id).UnitPrice = 0;					
					}
					if(t.Kopien_Rabatt != null)
						OLISaved.get(t.Id).Kopien_Rabatt__c = t.Kopien_Rabatt;
					
					OLIlist.add(OLISaved.get(t.Id));
				}
				
			}
		}
		if(!OLIlist.isEmpty()) {
			try{
				upsert OLIlist;
			}
			catch(exception e){
				return null;
			}
		}
			
		return '/' + opp.id;
	}
	
	private Boolean verifyNumber(myterm t) {
		Boolean verified = True;
		// if the line is empty, we do not check it.
		if(opp.VKPG2A__c != 'O2')	
			A_S = String.valueof(opp.Anzahl_Schulen__c);
		RAB = String.valueOf(opp.Rabatt__c);
		L_N = String.valueOf(opp.Lizenznummer__c);
					
		if(  !( (t.Name == '' || t.Name == null) && (t.Quantity == '' || t.Quantity == null || t.Quantity =='1') 
			&& (t.Anzahl_Schulen == '' || t.Anzahl_Schulen == null || t.Anzahl_Schulen == A_S || t.Lizenznummer == null|| t.Lizenznummer == '' || t.Lizenznummer == L_N))) {
				
			if(!LizenzM.containsKey(t.Name + t.Lizenznummer) ) {
				t.NameError = system.Label.Wrongvalue;
				verified = false;
			} 
			else {
				t.NameError = '';
			}
			if(!PBE.containsKey(t.Name) ) {
				t.NameError = system.Label.Wrongvalue ;//+ Prod.size() + ' ' + Artikel ;
				verified = false;
			}

			if(!Pattern.matches( '[0-9]*[\\.]?[0-9]+', t.Quantity )) {
				t.QuantityError = system.Label.Wrongvalue;
				verified = false;
			}
			else {
				t.QuantityError = '';
			}
			
			if(t.Rabatt != null && !Pattern.matches( '[0-9]*[\\.]?[0-9]+', t.Rabatt ) && t.Rabatt != '') {
				t.RabattError = system.Label.Wrongvalue;
				verified = false;
			}
			else {
				t.RabattError = '';
			}
			
			if( t.UnitPrice != null && !Pattern.matches( '[0-9]*[\\.]?[0-9]+', t.UnitPrice ) && t.Id != null ) {
				t.UnitPriceError = system.Label.Wrongvalue;
				verified = false;
			}
			else {
				t.UnitPriceError = '';
			}
			
			if(t.Anzahl_Schulen != null && t.Anzahl_Schulen != '' && (!Pattern.matches( '[0-9]*[\\.]?[0-9]+', t.Anzahl_Schulen ) || opp.VKPG2A__c == 'O2')) {
				t.Anzahl_SchulenError = system.Label.Wrongvalue;
				verified = false;
			}
			else {
				t.Anzahl_SchulenError = '';
			}			
		}
		else {
			t.NameError = '';
			t.UnitPriceError = '';
			t.RabattError = '';
			t.QuantityError = '';
			t.Anzahl_SchulenError = '';
		}
		return verified;
	}
	
	public String getAmount() {return Amount;  } 
	public List<myterm> getTerms() {return Terms;}  

}