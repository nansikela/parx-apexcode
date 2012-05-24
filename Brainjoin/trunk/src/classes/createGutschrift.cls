global class createGutschrift {

   	public static String DatensatzTyp               = '';
	public static String DATENSATZ_TYP_GUTSCHRIFT   = 'Gutschrift';

	public static void setDatensatzTyp(String rtname) {
		DatensatzTyp = [select id, Name from RecordType where IsActive=true and SobjectType='Debitoren_Rechnung__c' and Name=:rtname].id;
	}

	webservice static String createGutschrift(Id rechnungId){
     	
        System.debug('PARX createGutschrift START');
        String result = 'false';
        setDatensatzTyp(DATENSATZ_TYP_GUTSCHRIFT);

        List<Posten__c> gutschriftPosten = new List<Posten__c>();
        // Alle Posten mit der RechnungsId holen
        // Order__c
        List<Posten__c> rechnungPosten = new List<Posten__c>();
        try {
        	rechnungPosten = [select Rechnung__c, Order__c, 
        								Bezeichnung__c, MWST__c, 
        								Falldokumentation__c, Betrag__c, 
        								Anzahl__c, Einheit__c, GS_RE_von__c
                                              from Posten__c where Rechnung__c =: rechnungId];
        } catch (System.QueryException e) {
        	// could happen that there are no posten
        	System.debug('Perhaps no posten for rechnung: ' + e.getMessage());
        }
        
        // Rechnung mit der Eingegebenen rechnungsId holen
        Debitoren_Rechnung__c rechnung = new Debitoren_Rechnung__c();
        try {
        	rechnung = [select Id, Name, Fall__c, CurrencyIsoCode, Betrag_Gutschrift__c, Rechnungsempfaenger__c, Klient__c, Referenz_Nr__c,
        										GS_RE_Lastname__c, GS_RE_Firstname__c, Status__c, Periode__c, Kurs__c
        										, Rechnungsempf_nger_Kontakt__c 
        										from Debitoren_Rechnung__c where Id =: rechnungId limit 1];
        } catch (System.QueryException e) {
        	// it could happen that there is no rechnung anymore (may be deleted)
        	System.debug('Perhaps no more invoice: ' + e.getMessage());
        }
        
        list<Id> listToogleBerechnet = new list<Id>();
        
        // Neue Gutschrift erstellen
        Debitoren_Rechnung__c gutschrift    = new Debitoren_Rechnung__c();
        Id fallId;
        if (rechnung.id!=null) {
        	gutschrift.RecordTypeId = DatensatzTyp;
	      gutschrift.Fall__c = rechnung.Fall__c;
	      gutschrift.Rechnung__c = rechnung.Id;
	      gutschrift.Rechnungsempfaenger__c = rechnung.Rechnungsempfaenger__c;
	      gutschrift.Rechnungsempf_nger_Kontakt__c = rechnung.Rechnungsempf_nger_Kontakt__c;
	      gutschrift.CurrencyIsoCode = rechnung.CurrencyIsoCode;
	      gutschrift.Referenz_Nr__c = rechnung.Referenz_Nr__c;
	      gutschrift.GS_Rechnungsnummer__c = rechnung.Name;
	      gutschrift.Kurs__c = rechnung.Kurs__c;
	      gutschrift.Periode__c = rechnung.Periode__c;
	      fallId = rechnung.Fall__c;
        }
        
        try {
            insert gutschrift;
        } catch (System.DmlException e) {
            System.debug('Fehler bei Erstellen einer Gutschrift Klasse[createGutschrift]/Methode[createGutschrift] ' + e.getMessage());
        }
        
        //Double bufferSummaryBetragBrutto = 0; 
        // Posten fuer die Gutschrift erstellen
        for(Posten__c p: rechnungPosten) {
            //bufferSummaryBetragBrutto = bufferSummaryBetragBrutto + p.Betrag__c; 
            Posten__c posten                = new Posten__c();
            posten.Falldokumentation__c     = p.Falldokumentation__c;
            posten.Betrag__c                = p.Betrag__c;
            posten.MWST__c                  = p.MWST__c;
            posten.Einheit__c               = p.Einheit__c;
            posten.Anzahl__c                = p.Anzahl__c;
            posten.Bezeichnung__c           = p.Bezeichnung__c;
            posten.Rechnung__c              = gutschrift.Id;
            posten.Order__c                 = p.Order__c;
            posten.GS_RE_von__c             = p.GS_RE_von__c;
            posten.GS_RE_Lastname__c        = rechnung.GS_RE_Lastname__c;
            posten.GS_RE_Firstname__c       = rechnung.GS_RE_Firstname__c;
            gutschriftPosten.add(posten);     
            listToogleBerechnet.add(p.Falldokumentation__c);  
        }
        
        if (gutschrift.id!=null) {
        	if(!gutschriftPosten.isEmpty()) {
	            result = gutschrift.Id;
	            try {
	                insert gutschriftPosten;
	            } catch (System.DmlException e) {
	            	result='false';
	                System.debug('Fehler bei Erstellen der Posten Klasse[createGutschrift]/Methode[createGutschrift] ' + e.getMessage());
	            } 
	        }
	        // wir aktualisieren die Rechnung und setzen ihren Status auf 'storinert'
	        if (result==gutschrift.Id) {
	        	rechnung.Status__c='storniert';
	        	try {
	        		update rechnung;
	        	} catch (System.Dmlexception e) {
	        		System.debug('Fehler bei Aktualisierung der Rechung mit neuem Status storniert! ' + e.getMessage());
	        		throw e;
	        	}
	        }
        
        
	        /*  wenn eine Gutschrift erstellt worden ist, dann müssen die jeweiligen Timecards auf dem Fall
	        	 (die gleichzeitig die Posten der Rechnung sind) auf berechnet=false gesetzt werden 
	        */
	        // ist fachlich bloedsinn, sobald eine Rechnung dazu existiert, bleiben die Timecards berechnet
	        // ist nur sinnvoll, falls eine Rechnung gelöscht wird, oder auf storniert gesetzt wird
	        /*
	        if(!listToogleBerechnet.isEmpty()){
	        	Fall__c oFall = new Fall__c();
	        	try {
	        		if (fallid!=null)
	        			oFall = [select Id, letzte_Rechnung__c from Fall__c where Id =:fallId];
	        	} catch (System.Queryexception e) {
	        		// may be we have no fallid or no suitable fall
	        		System.debug('Perhaps no suitable fall: ' + e.getMessage());
	        	}
	        	list<Timecard__c> listTimecardToToggle = new list<Timecard__c>();
	        	try {
	        		if (!listToogleBerechnet.isEmpty())
	        			listTimecardToToggle = [select berechnet__c, Berechenbar__c 
	        						from Timecard__c where Id in: listToogleBerechnet];
	        	} catch (System.Queryexception e) {
	        		System.debug('Perhaps there are no timecards to toggle: ' + e.getMessage());
	        	}
	        	for(Integer i=0; i<listTimecardToToggle.size(); i++){
	        			listTimecardToToggle.get(i).berechnet__c = false;
	        	}
	        	// reset date of letzte Rechnung
	        	oFall.letzte_Rechnung__c = null;
	        	try {
	            	update listTimecardToToggle;
	            	update oFall;
	        	} catch (System.DmlException e) {
	            	System.debug('Fehler bei Erstellen einer Gutschrift Klasse[createGutschrift]/Methode[createGutschrift] ' + e.getMessage());
	        		throw e;
	        	} 
	        }
	        */
        }
        

        System.debug('PARX createGutschrift END');
        return result; 
    }

}