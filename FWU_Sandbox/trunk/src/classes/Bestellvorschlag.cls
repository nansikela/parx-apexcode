global class Bestellvorschlag {
	
	public static list<Product2> Prod=new list<Product2>();
	public static list<Einkauf__c> Einkauf=new list<Einkauf__c>();
	public static map<String, map<String, map<Date, map<String, map<String, EinkaufBestellung__c>>>>> EinkaufBestellung =new map<String, map<String, map<Date, map<String, map<String, EinkaufBestellung__c>>>>>();
	public static list<EinkaufBestellung__c> EBtoInsert = new list<EinkaufBestellung__c>();
//	public static list<Produktionsstand__c> PS=new list<Produktionsstand__c>();
	 
	webservice static String init(list<String> ArtikelIds) {
		Prod = [Select id, BEME01__c, Gueltiger_Einkaufspreis__c, Kreditor__c, Liefertermin__c, BESB01__c, PDKZ01__c, Typ__c, AUSW01__c, PJKZ01__c, SWFA01__c, AZME01__c,
			 MEDA01__r.Name, Isactive, Bestandsmeldung__c, Name, IVKZ01__c  from Product2 where Id IN: ArtikelIds];
		system.debug('ARTIKEL IDS ' + ArtikelIds);
		
		String m = Einkauf_Bestellung();
		if(m != 'true') {
			return m;
		}
		
		m = match();
		if(m != 'true') {
			return m;
		}
	//	produktionsstand();
		insertupdate();
		return 'true';
	}
	
	private static String Einkauf_Bestellung() {
		EinkaufBestellung__c EB;
		String UngueltigerEP = '';
		String Beme = '';
		for(Product2 p:Prod) {
			if(p.Typ__c != 'Signatur' || p.MEDA01__r.Name == '55' || p.MEDA01__r.Name == '57' || p.IsActive != True || p.PDKZ01__c > 8 || p.PDKZ01__c < 2 || p.SWFA01__c == null || p.SWFA01__c == '' || p.AZME01__c == null)
				return system.Label.Bestellung_FehlerMeldung;
			if(p.Gueltiger_Einkaufspreis__c == -1)
				UngueltigerEP += p.Name + ', ';				
			if(p.BEME01__c == null)
				Beme += p.Name + ', ';
			
			EB = new EinkaufBestellung__c();
			EB.lieferant__c =  p.Kreditor__c;
			EB.Medienart__c = p.MEDA01__r.Name;
			EB.Liefertermin__c = p.Liefertermin__c;
			EB.Angebotskz__c = p.AUSW01__c;
			EB.Projektkz__c = p.PJKZ01__c;
			EB.Conga_Workflow_for_Activation__c = True;
		
			/*****start of: we split products between 5 categories: Account, Medienart, Liefertermin, Angebotskz, Projektkz ******/
			
			if(!EinkaufBestellung.containsKey(p.Kreditor__c)) {
				EinkaufBestellung.put(p.Kreditor__c, new map<String, map<Date, map<String, map<String, EinkaufBestellung__c>>>>{
							    p.MEDA01__r.Name /*Medienart*/ => new map<Date, map<String, map<String, EinkaufBestellung__c>>>{
							    p.Liefertermin__c /*Liefertermin*/ => new map<String, map<String, EinkaufBestellung__c>>{
							    p.AUSW01__c /*Angebotskz*/ => new map<String, EinkaufBestellung__c>{
							    p.PJKZ01__c /*Projektkz__c*/ => 
							    EB}}}});
				EBtoInsert.add(EB);
			}
			else if(!EinkaufBestellung.get(p.Kreditor__c).containsKey(p.MEDA01__r.Name)) {
				EinkaufBestellung.get(p.Kreditor__c).put(
							    p.MEDA01__r.Name /*Medienart*/ , new map<Date, map<String, map<String, EinkaufBestellung__c>>>{
							    p.Liefertermin__c /*Liefertermin*/ => new map<String, map<String, EinkaufBestellung__c>>{
							    p.AUSW01__c /*Angebotskz*/ => new map<String, EinkaufBestellung__c>{
							    p.PJKZ01__c /*Projektkz__c*/ => 
							    EB}}});
				EBtoInsert.add(EB);
			}
			else if(!EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).containsKey(p.Liefertermin__c)) {
				EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).put(
							    p.Liefertermin__c /*Liefertermin*/, new map<String, map<String, EinkaufBestellung__c>>{
							    p.AUSW01__c /*Angebotskz*/ => new map<String, EinkaufBestellung__c>{
							    p.PJKZ01__c /*Projektkz__c*/ => 
							    EB}});
				EBtoInsert.add(EB);
			}
			else if(!EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).get(p.Liefertermin__c).containsKey(p.AUSW01__c)) {
				EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).get(p.Liefertermin__c).put(
							    p.AUSW01__c /*Angebotskz*/, new map<String, EinkaufBestellung__c>{
							    p.PJKZ01__c /*Projektkz__c*/ => 
							    EB});
				EBtoInsert.add(EB);
			}
			else if(!EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).get(p.Liefertermin__c).get(p.AUSW01__c).containsKey(p.PJKZ01__c)){
				EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).get(p.Liefertermin__c).get(p.AUSW01__c).put(
							    p.PJKZ01__c, 
							    EB);
				EBtoInsert.add(EB);
			}
			/*****end of: we split products between 5 categories: Account, Medienart, Liefertermin, Angebotskz, Projektkz ******/
		}
		if(UngueltigerEP != '')
			return 'Ungültiger Einkaufspreis: ' + UngueltigerEP.substring(0, UngueltigerEP.length() - 2);
		if(Beme != '')
			return 'Bestellmenge null für: ' + Beme.substring(0, Beme.length() - 2);
		if(!EBtoInsert.isEmpty())
			insert EBtoInsert;
		return 'true';
	}
	
	private static String match() {

		Einkauf__c E ;
		for(Product2 p:Prod) {
			E = new Einkauf__c();
			E.Artikel__c = p.Id;   //Product
			E.BWSL22__c = '03';  //Bewegungsschlüssel
			E.MENG22__c = p.BEME01__c;  //Menge
			if(p.IVKZ01__c == '7')
				EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).get(p.Liefertermin__c).get(p.AUSW01__c).get(p.PJKZ01__c).Inventur_Kz_7__c = 1;
			if(EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).get(p.Liefertermin__c).get(p.AUSW01__c).get(p.PJKZ01__c).Menge__c == null)
				EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).get(p.Liefertermin__c).get(p.AUSW01__c).get(p.PJKZ01__c).Menge__c = 0;
			EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).get(p.Liefertermin__c).get(p.AUSW01__c).get(p.PJKZ01__c).Menge__c += p.BEME01__c;
			E.EKPR22__c = p.Gueltiger_Einkaufspreis__c; //Einkaufspreis (Gültiger Einkaufspreis)
			E.KPSL22__c = p.Kreditor__c;  //Lieferant (from account)
			E.LITE22__c = p.Liefertermin__c;  //Liefertermin /-tage
			
			E.Bestellung__c = EinkaufBestellung.get(p.Kreditor__c).get(p.MEDA01__r.Name).get(p.Liefertermin__c).get(p.AUSW01__c).get(p.PJKZ01__c).Id;
			Einkauf.add(E);
			if(p.BESB01__c == null ) 
				p.BESB01__c = 0;
				
			p.BESB01__c += p.BEME01__c;   //Bestell bestand
			p.BEME01__c = null;  //init
			p.Neuer_Einkaufspreis__c = null;   //init
			p.Neuer_Liefertermin__c = null;   //init
			p.Pruefung_Einkauf__c = false; //init 
		}
			
		return 'true';
	}
	
	/*public static void produktionsstand(){
		Produktionsstand__c pr;
		for(Product2 p:Prod) {
			if(p.PDKZ01__c < 4) {
				pr = new Produktionsstand__c();
				pr.Status__c = '03';
				pr.Datum__c = system.today();
				pr.Artikel__c = p.Id;
				PS.add(pr);
			}
		}
	}*/
	
	private static void insertupdate() {
		try {
			insert Einkauf;
		}
		catch(exception e) {
			Einkauf[0].addError(e.getMessage());
		}
		try {
			update Prod;
		}
		catch(exception e) {
			throw e;//Prod[0].addError(e.getMessage());
		}
		try {
			update EBtoInsert;
		}
		catch(exception e) {
			throw e;//EBtoInsert[0].addError(e.getMessage());
		}
	//	insert PS;
	}
}