global class createRechnung {
	// CR NP
	
	/*
BJ Rechnungserstellung:
Step 1 (Fallsäuberung):
- lege fehlende Pauschalen an, falls Fallkategorie Pauschale und letzte Pauschale nicht im letzten Monat 
(dabei muss gelten Aktivität der letzten Pauschale==Fallkategorie)
--- Abklärung Pauschalen werden nicht fortgeführt
- Pauschalen sind verrechenbar, falls Coaching TC im Pauschalen Intervall existieren. 
- Diese Coaching TC sind dann nicht verrechenbar
- existiert keine Pauschale parallel zu einer Coaching TC, ist diese verrechenbar

- schließlich mache update auf allen verrechenbaren TC, damit der Umsatz auch wirklich stimmt 
(nicht mehr nötig, da die TCs bei Rechnungserstellung vor Einfügen der Posten noch aktualisiert werden.)

Step 2 (Rechnungserzeugung):
- lege Rechnung mit Falldaten an
- lege für alle verrechenbaren TC Posten in der Rechnung an, verknüpfe sie mit den TC
- markiere alle TC als berechnet
- fülle letzte_Rechnung im Fall
- verknüpfe TC mit Rechnung
	*/

	public static Fall__c fall;
	private static Debitoren_Rechnung__c rechnung;
	private static list<Posten__c> posten=new list<Posten__c>();
	private static list<Timecard__c> timecardsforrechnung = new list<Timecard__c>();
	private static map<Id, Timecard__c> tcmap=new map<Id, Timecard__c>();
	private static Id rtype=[SELECT ID FROM RecordType WHERE Name='Rechnung' AND SobjectType='Debitoren_Rechnung__c' limit 1].Id;
	private static list<Timecard__c> tclist = new list<Timecard__c>();
	private static String specialActivity01	= 'Erstgespräch';
	private static list<String> specialActivities = new list<String>();
	
	/*
	* Ueberprueft ob bestimmte Bedingungen vorhanden sind und erstellt fuer den
	* Fall einer bzw. keine Rechnung.
	* 
	* @return String
	*/
	webservice static String createRechnung(Id fallId) {
		String retval='false';
		clear();
		// we only run if an invoice does not exist in current month
		// TODO
		// && (fall.letzte_Rechnung__c!=null && fall.letzte_Rechnung__c.year()==System.now().year() && fall.letzte_Rechnung__c.month()!=System.now().month())
		if (getFall(fallId)) {
			// CR NP
			//if (cleanupFall()) {
				retval=createRechnung();
				if (retval=='' && !posten.isEmpty()) retval='Rechnung konnte nicht erstellt werden!';
				else if (retval=='' && posten.isEmpty()) retval='Keine Posten für eine Rechnung gefunden, Rechnung wurde nicht erstellt!';	
			//} else {
			//	retval='Fehler bei Korrektur der Timecards!';
			//}
		} else {
			retval='Fall konnte nicht gefunden werden!';
		}
		// we write all errors to the database
		systemHelper.insertErrors();
		System.debug('PARX createRechung retval: ' + retval);
		return retval;
	}
	
	private static void clear() {
		fall=null;
		rechnung=null;
		posten=new list<Posten__c>();
		timecardsforrechnung = new list<Timecard__c>();
		tcmap=new map<Id, Timecard__c>();
	}
	
	private static void fillSpecialActivities() {
    	specialActivities.add(specialActivity01);
    }
	
	private static Boolean getFall(Id fallId) {
		if (fallid!=null) {
			try {
				fall=[SELECT Id
					, Name
					, Coach__c
					, letzte_Rechnung__c
					, CreatedDate
					, CurrencyIsoCode
					, Rechnungsempfaenger__c
					, Klient__c
					, Fallkategorie__c
					, CreatedDate_OnlyForTest__c
                    , Rechnungsempf_nger_Kontakt__c 
					FROM Fall__c WHERE Id=:fallId];
			} catch (System.QueryException e) {
				systemHelper.sendApexWarnEmail(e.getMessage());
				systemHelper.logError(e.getMessage(), 'getFall', '', fallId);
			}
		}
		if (fall.id!=null) return true;
		else return false;
	}
	
	/* CR NR
	private static Boolean cleanupFall() {
		Boolean success=false;
		if (createMissingPauschalen())
			if (recalculateVerrechenbarkeit()) success=true;
		return success;
	}
	
	private static Boolean createMissingPauschalen() {
		Boolean success=true;
		if (Fall!=null && systemHelper.isPauschale(Fall.Fallkategorie__c) && !systemHelper.isAbklaerungPauschal(Fall.Fallkategorie__c)) {
			DateTime maxdate=Datetime.newInstance(findMaxDate().year(),findMaxDate().month(),1,0,0,0).addHours(-3);
			map<Id, Timecard__c> pauschalen = new map<Id, Timecard__c>();
			list<Timecard__c> neuepauschalen = new list<Timecard__c>();
			try {
				for (Timecard__c tc: [SELECT Id
							, berechnet__c
							, verrechenbar__c
							, Berechenbar__c
							, von__c
							, bis__c
							, Fall__c
							, Aktivitaet__c
							, Debitoren_Rechnung__c 
							FROM Timecard__c 
							WHERE Fall__c =: fall.Id 
							AND Aktivitaet__c=:fall.Fallkategorie__c
							AND von__c>=:maxdate
							ORDER BY von__c asc
							]) {
					if (!pauschalen.containsKey(tc.id)) pauschalen.put(tc.id,tc);
				}
			} catch (System.Queryexception e) {
				systemHelper.sendApexWarnEmail(e.getMessage());
				systemHelper.logError(e.getMessage(), 'createMissingPauschalen', 'select pauschalen', fall.Id);
			}
			if (systemHelper.isDebug) systemHelper.logError('PARX pauschalen.size: ' + pauschalen.size());
			// now we need to know at which date we have to start our new pauschalen
			DateTime startdate=System.now();
			if (pauschalen.isEmpty()) {
				// pauschalen have to be created ab maxdate
				startdate=maxdate.addHours(3);
				if (systemHelper.isDebug) systemHelper.logError('PARX create Rechnung: keine Pauschalen gefunden start ab: ' + maxdate);
			} else {
				// find recent pauschale and its end date,
				// pauschalen have to have an end date! (bis__c!=null)
				startdate=pauschalen.values().get(0).bis__c!=null?pauschalen.values().get(0).bis__c:pauschalen.values().get(0).von__c;
				for (Timecard__c tc: pauschalen.values()) {
					if (tc.bis__c!=null && tc.bis__c>startdate)
						startdate=tc.bis__c;
				}
				// startdate should now be the latest bis__c date
				// this should be 23:59:59 (or in GMT 21:59:59)
				// for the new startdate we need 00:00 the next day (or 22:00 the same day in GMT)
				startdate=startdate.addSeconds(1);
			}
			if (systemHelper.isDebug) systemHelper.logError('PARX startdate fuer neue pauschalen: ' + startdate);
			// we create pauschalen for all missing months 
			while (startdate.year()<System.now().year() || (startdate.year()==System.now().year() && startdate.month()<System.now().month())) {
				neuepauschalen.add(createTimecard(startdate));
				Date sdate=Date.newInstance(startdate.year(),startdate.month(),1).addMonths(1);
				startdate=DateTime.newInstance(sdate.year(),sdate.month(),1,0,0,0);
			}
			if (!neuepauschalen.isEmpty()) {
				try {
					insert neuepauschalen;
				} catch (System.Dmlexception e) {
					systemHelper.sendApexWarnEmail(e.getMessage());
					systemHelper.logError(e.getMessage(), 'createMissingPauschalen', 'insert neuepauschalen', fall.Id);
					success=false;
				}
			}
		}
		return success;
	}
	
	private static Timecard__c createTimecard(DateTime startdate) {
		DateTime enddate=DateTime.newInstance(startdate.addDays(32).year(),startdate.addDays(32).month(),1,0,0,0).addSeconds(-1);
		if (systemHelper.isDebug) systemHelper.logError('PARX enddate fuer neue pauschalen: ' + enddate);
		Timecard__c tc = new Timecard__c();
		if (fall.Fallkategorie__c!=null)
			tc.Aktivitaet__c = fall.Fallkategorie__c;
		if (fall.id!=null)
			tc.Fall__c = fall.Id; 
		tc.verrechenbar__c = false; // will be recalculated later
		if (fall.Coach__c!=null)
			tc.Coach__c = fall.Coach__c;
		if (fall.CurrencyIsoCode!=null)
			tc.CurrencyIsoCode=fall.CurrencyIsoCode;
		tc.von__c=startdate;
		tc.bis__c=enddate;
		tc.createdByTrigger__c=true;
		tc.berechnet__c=false; // das setzt spaeter die Rechnung 
		return tc;
	}

	private static DateTime findMaxDate() {
		DateTime retdate=DateTime.newInstance(System.now().addMonths(-1).year(),System.now().addMonths(-1).month(),1);
		if (fall!=null) {
			if (fall.letzte_Rechnung__c!=null) return fall.letzte_Rechnung__c;
			if (fall.CreatedDate_OnlyForTest__c!=null) return fall.CreatedDate_OnlyForTest__c;
			else return fall.CreatedDate;
		} else
		return retdate;
	}
	
	private static Boolean recalculateVerrechenbarkeit() {
		Boolean success=true;
		if (Fall!=null && systemHelper.isPauschale(Fall.Fallkategorie__c)) {
			DateTime maxdate=findMaxDate();
			map<Id, Timecard__c> tcpauschalen = new map<Id, Timecard__c>();
			map<Id, Timecard__c> tcverrechenbar = new map<Id, Timecard__c>();
			list<Timecard__c> timecardstoupdate = new list<Timecard__c>();
			try {
				for (Timecard__c tc: [SELECT Id
							, berechnet__c
							, verrechenbar__c
							, Berechenbar__c
							, von__c
							, bis__c
							, Fall__c
							, Aktivitaet__c
							, Debitoren_Rechnung__c 
							FROM Timecard__c 
							WHERE Fall__c =: fall.Id 
							AND von__c>=:Datetime.newInstance(maxdate.addHours(3).year(),maxdate.addHours(3).month(),1)
							AND berechnet__c=false
							AND (
								Aktivitaet__c IN :systemHelper.getMapPauschal().values()
								OR Aktivitaet__c IN :systemHelper.getMapCoachingActivity().values()
							)
							ORDER BY von__c asc
							]) {
					if (!tcpauschalen.containsKey(tc.id) && systemHelper.isPauschale(tc.Aktivitaet__c)) tcpauschalen.put(tc.id,tc);
					if (!tcverrechenbar.containsKey(tc.id) && systemHelper.isCoachingActivity(tc.Aktivitaet__c)) tcverrechenbar.put(tc.id,tc);
				}
			} catch (System.Queryexception e) {
				systemHelper.sendApexWarnEmail(e.getMessage());
				systemHelper.logError(e.getMessage(), 'recalculateVerrechenbarkeit', 'select timecards', fall.Id);
			}
			// in tcpauschalen and tcverrechenbar we have now all the relevant tc whilest the fall is in pauschal
			// we go through them in two ways:
			// 1) go through all pauschalen and prove their verrechenbar flag
			// 2) go through all verrechbare tc and prove their verrechenbar flag
			
			// step 1
			for (Timecard__c tc: tcpauschalen.values()) {
				Boolean verrechenbar=false;
				for (Timecard__c c: tcverrechenbar.values()) {
					// pauschalen intervall enthält mind. eine verrechenbare leistung
					if (c.von__c>=tc.von__c && c.von__c<=tc.bis__c) verrechenbar=true;
				}
				if (tc.verrechenbar__c!=verrechenbar) {
					tc.verrechenbar__c=verrechenbar;
					timecardstoupdate.add(tc);
				}
			}
			
			// step 2
			for (Timecard__c tc: tcverrechenbar.values()) {
				Boolean verrechenbar=true;
				for (Timecard__c p: tcpauschalen.values()) {
					// verrechenbare leistung liegt innerhalb einer pauschalen!
					if (tc.von__c>=p.von__c && tc.von__c<=p.bis__c) verrechenbar=false;
				}
				if (tc.verrechenbar__c!=verrechenbar) {
					tc.verrechenbar__c=verrechenbar;
					timecardstoupdate.add(tc);
				}
			}
			
			// last step - the update itself
			if (!timecardstoupdate.isEmpty()) {
				try {
					update timecardstoupdate;
				} catch (System.Dmlexception e) {
					systemHelper.sendApexWarnEmail(e.getMessage());
					systemHelper.logError(e.getMessage(), 'recalculateVerrechenbarkeit', 'update timecardstoupdate', fall.Id);
					success=false;
				}
			}
		}
		return success;
	}
	*/
	
	private static String createRechnung() {
		String reid='';
		fillupRechnung();
		fillSpecialActivities();
		getTimecardsForRechnung();
		updateFall();
		createPosten();		
		insertRechnung();
		if (rechnung.id!=null) return rechnung.id;
		else
		return reid;
	}
	
	private static void updateFall() {
		if (fall!=null) fall.letzte_Rechnung__c=System.now();
	}
	
	private static void updateTimecardsForRechnung() {
		if (!posten.isEmpty() && rechnung.id!=null) {
			for (Posten__c p: posten) {
				if (p.Falldokumentation__c!=null && tcmap.containsKey(p.Falldokumentation__c)) {
					Timecard__c tc=tcmap.get(p.Falldokumentation__c);
					tc.Debitoren_Rechnung__c=rechnung.id;
					tc.berechnet__c=true;
					timecardsForRechnung.add(tc);
				}
			}
		}
	}
	
	private static void fillupRechnung() {
		rechnung=new Debitoren_Rechnung__c();
		rechnung.Fall__c=fall.Id;
            rechnung.RecordTypeId=rtype;
            rechnung.Rechnungsempfaenger__c=fall.Rechnungsempfaenger__c;
            rechnung.Rechnungsempf_nger_Kontakt__c=fall.Rechnungsempf_nger_Kontakt__c;
            rechnung.CurrencyIsoCode=fall.CurrencyIsoCode;
	}
	
	private static void getTimecardsForRechnung() {
		
		try {
			for (Timecard__c tc: [SELECT Id
							, berechnet__c
							, verrechenbar__c
							, Berechenbar__c
							, von__c
							, Fall__c
							, Aktivitaet__c
							, Debitoren_Rechnung__c
							, Fall__r.Fallkategorie__c 
							FROM Timecard__c 
							WHERE Fall__c =: fall.Id 
							AND (verrechenbar__c=true OR 
							(Aktivitaet__c IN :specialActivities AND Fall__r.Fallkategorie__c like '%Aufwand%'))
							AND berechnet__c=false 
							ORDER BY von__c desc
							]) {
				// these should be the needed timecards
				if (!tcmap.containsKey(tc.id)
					// CR NP Pauschalen müssen immer sofort in Rechnung gestellt werden können! 
					//&& tc.von__c<DateTime.newInstance(System.now().year(), System.now().month(), 1)
					) tcmap.put(tc.id, tc);
			}
			if (!tcmap.isEmpty()) {
				tclist=[SELECT Id
							, berechnet__c
							, verrechenbar__c
							, Berechenbar__c
							, von__c
							, Fall__c
							, Aktivitaet__c
							, Debitoren_Rechnung__c 
							FROM Timecard__c 
							WHERE Id IN :tcmap.keySet()
							ORDER BY von__c, von__c desc
							];
				
			}
		} catch (System.QueryException e) {
			systemHelper.sendApexWarnEmail(e.getMessage());
			systemHelper.logError(e.getMessage(), 'getTimecardsForRechnung', 'select timecards', fall.Id);
		}                                	
	}
	
	private static void createPosten() {
		if (!tclist.isEmpty()) {
			Integer order=0;
			for (Timecard__c t: tclist) {
				Posten__c p=new Posten__c();
				p.Falldokumentation__c        = t.Id;
            		//p.Rechnung__c                 = rechnung.Id; // will happen later
            		p.Order__c                    = order;
            		p.CurrencyIsoCode             = fall.CurrencyIsoCode;
            		p.GS_RE_von__c                = t.von__c;
            		posten.add(p);
            		order++;		
			}
			System.debug('PARX Posten size: ' + posten.size());
		}
	}
	
	private static void updatePostenWithRechnungId() {
		if (!posten.isEmpty()) {
			for (Integer i=0;i<posten.size();i++) {
				if (posten.get(i).Rechnung__c==null) posten.get(i).Rechnung__c=rechnung.id;
			}
		}
	}
	
	private static Id insertRechnung() {
		if (rechnung!=null && rechnung.id==null && !posten.isEmpty()) {
			Boolean hasError=false;
			Savepoint sp = database.setSavepoint();
			try {
				insert rechnung;
			} catch (System.Dmlexception e) {
				systemHelper.sendApexWarnEmail(e.getMessage());
				systemHelper.logError(e.getMessage(), 'insertRechnung', 'insert rechnung', fall.Id);
				hasError=true;
			}
			if (rechnung.id!=null) {
				// update timecards with rechnungsid
				updateTimecardsForRechnung();
				updatePostenWithRechnungId();
				try {
					upsert posten;
				} catch (System.Dmlexception e) {
					systemHelper.sendApexWarnEmail(e.getMessage());
					systemHelper.logError(e.getMessage(), 'insertRechnung', 'insert posten', rechnung.Id);
					hasError=true;
				}
				try {
					update timecardsforrechnung;
				} catch (System.Dmlexception e) {
					systemHelper.sendApexWarnEmail(e.getMessage());
					systemHelper.logError(e.getMessage(), 'insertRechnung', 'update timecardsforrechnung', rechnung.Id);
					hasError=true;
				}
				try {
					FallTriggerHelper.alreadyRun=true;
					update fall;
					FallTriggerHelper.alreadyRun=false;
				} catch (System.Dmlexception e) {
					systemHelper.sendApexWarnEmail(e.getMessage());
					systemHelper.logError(e.getMessage(), 'insertRechnung', 'update fall', rechnung.Id);
					hasError=true;
				}
			}
			// do a rollback if any error has occured
			if (hasError) database.rollback(sp);
		}
		return rechnung.id;
	}
	             
}