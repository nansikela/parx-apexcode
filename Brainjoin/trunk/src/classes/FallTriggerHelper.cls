public class FallTriggerHelper {

	/*
		allgemeine Methoden
	*/
	
	public static Boolean alreadyRun=false;
	
	public static Boolean getAlreadyRun() {
		return alreadyRun;
	}
	
	private static Boolean tcUpdateAlreadyRun=false;
	
	//public static Boolean getTcUpdateAlreadyRun() {
	//	return tcUpdateAlreadyRun;
	//}

	/*
		Fall insert Methoden
	*/
	public static void FallInsert(list<Fall__c> fallinsert) {
		list<Timecard__c> newtcs = new list<Timecard__c>();
		if (!fallinsert.isEmpty()) {
			for (Fall__c f: fallinsert) {
				newtcs.add(createTimecard(f));
			}
			if (!newtcs.isEmpty()) {
				try {
					insert newtcs;
				} catch (System.DmlException e) {
					for (Fall__c f: fallinsert) {
						systemHelper.sendApexWarnEmail('Fehler beim Anlegen von Pauschalen Timecards des Falls ' + f.id + ': ' + e.getMessage());
						f.addError(System.label.ErrorInsertTimecard + ' ' + f.id + ' Meldung: ' + e.getMessage());
					}
				}
			}
		}
	}
	
	private static Timecard__c createTimecard(Fall__c fall) {
		Date startdate = System.today();
		// CR NP
		// Date enddate = System.today().toStartOfMonth()+Date.daysInMonth(startdate.year(), startdate.month())-1;
		Datetime startdatetime = Datetime.newInstance(startdate.year(),startdate.month(),startdate.day(),0,0,0);
		// CR NP
		// Datetime enddatetime = Datetime.newInstance(enddate.year(),enddate.month(),enddate.day(),23,59,59);
		Timecard__c tc = new Timecard__c();
		if (fall.Fallkategorie__c!=null)
			tc.Aktivitaet__c = fall.Fallkategorie__c;
		if (fall.id!=null)
			tc.Fall__c = fall.Id; 
		tc.verrechenbar__c = true;
		if (fall.Coach__c!=null)
			tc.Coach__c = fall.Coach__c;
		if (fall.CurrencyIsoCode!=null)
			tc.CurrencyIsoCode = fall.CurrencyIsoCode;
		tc.von__c                = startdatetime;
		// CR NP
		//tc.bis__c                = enddatetime;
		//tc.createdByTrigger__c 	= true;
		tc.berechnet__c          = false; // das setzt spaeter die Rechnung 
		return tc;
	}
	
	
	/*
		Fall update Methoden
	*/
	// CR NP
	// Erneuerung:
	// Falls das Erneuerungsflag gesetzt wird, wir einfach nur eine passende neue Pauschale mit dem betreffenden Termin angelegt. 
	// Es findet keine weitere Validierung des Termins bzgl. bestehender Pauschalen statt!
	// Rückwirkende Änderung:
	// Falls eine noch nicht abgerechnete Pauschale vor oder nach dem angegebenen Termin (max. 6 Monate davor) exisitert, 
	// wird sie mit den neuen Daten angepasst
	// Weitere noch nicht abgerechnete Pauschalen vor dem Termin werden nicht angepasst
	// Verrechenbarkeit wird wie gehabt geprüft
	
	
	// Strategie:
	// holen wir alle Timecards mit von > MINIMUM(ausgewaehltes datum), die Pauschalen sind oder verrechenbar sind.
	// nun muessen wir je fall und wechsel der fallkategorie verschiedene pruefungen durchfuhren
	// Szenarien:
	// IN JEDEM FALL: Fehlermeldung, sollten durch das gewaehlte Datum bereits berechnete TC betroffen sein
	// 		dann wechsel nicht gestatten! 
	// 1) Nach Aufwand -> Pauschal
	//	Anteilige Anlage der Pauschale ab dem gewuenschten Datum und Ruecksetzen des Verrechenbar Flags fuer
	//	bisher angelegte Coachings (bzw. div. andere Aktivitaeten)
	// 2) Pauschal -> nach Aufwand
	//	kuerzung des Pauschalen Zeitraumes, bzw. notfalls Loeschung von nicht mehr benoetigten Pauschalen
	//	evtl. erfasste Coachings (usw.) auf verrechenbar setzen
	// 3) Pauschale -> Pauschale
	//	kuerzung/loeschung der alten Pauschale, Anlage der neuen Pauschale, evtl erfasste Coachings auf nicht
	//	verrechenbar
	//
	// zum Schluss, leeren aller ausgewaehlten daten
	private static Datetime minimumSelectedDate=System.now();
	private static Boolean hasException=false;
	private static map<Id, Fall__c> falltoupdate = new map<Id, Fall__c>();
	private static map<Id, map<Id, Timecard__c>> tcpauschal = new map<id, map<Id, Timecard__c>>();
	private static map<Id, map<Id, Timecard__c>> tcpauschalall = new map<id, map<Id, Timecard__c>>();
	private static map<Id, map<Id, Timecard__c>> tcverrechenbar = new map<id, map<Id, Timecard__c>>();
	private static map<Id, map<Id, Timecard__c>> tcnichtverrechenbar = new map<id, map<Id, Timecard__c>>();
	private static map<Id, map<Id, Timecard__c>> tcvl = new map<id, map<Id, Timecard__c>>();
	private static list<Timecard__c> timecardstoinsert = new list<Timecard__c>();
	private static list<Timecard__c> timecardstoupdate = new list<Timecard__c>();
	private static list<Timecard__c> timecardstodelete = new list<Timecard__c>();
	
	public static void updateTimecards(map<Id, Fall__c> fallnew, map<Id, Fall__c> fallold) {
		System.debug('updateTimecards: Faelle to update ' + fallnew.size());
		// holen wir die Faelle fuer ein Update
		fillFalltoupdate(fallnew.keySet());
		// untere Grenze fuer das Datum der Timecards (ueber alle Faelle)
		setMinimumSelectedDate(fallnew);
		// so, dann holen wir uns die TC und sortieren sie nach unseren aufgaben
		getTimecards(fallnew.keySet(),fallnew);
		System.debug('updateTimecards: tcpauschal: ' + tcpauschal.size() + ', tcnichtverrechenbar: ' + tcnichtverrechenbar.size() + ', tcnichtverrechenbar: ' + tcnichtverrechenbar.size() + ', tcvl: ' + tcvl.size());
		
		// nun gehts ans eingemachte
		// wir muessen nun sicherstellen, dass TC vom Trigger erstellt nicht parallel nebeneinander
		// ex. 
		// die beste Strategie scheint zu sein, zu naechst auf das Vorhandensein einer TC zu
		// prüfen, bei der das Datum im Intervall liegt. Ex. diese, wird ihr Intervall gekürzt.
		// sollte im akt. Monat noch eine TC existieren, wird die Aktvitaet geaendert und das Intervall
		// angepasst.
		// gibt es noch weiter zukuenfitge TC werden deren Aktivitaeten angepasst.
		// ex. noch keine TC, so werden alle erforderlichen TC ab der letzten neu angelegt.
		// der Zeitstempel darf nicht in der Zukunft liegen
		System.debug('updateTimecards: Fehler? ' + hasException);
		if (!hasException) recalculateTimecards(fallnew, fallold);
		System.debug('updateTimecards: timecardstoinsert: ' + timecardstoinsert.size() + ', timecardstoupdate: ' +timecardstoupdate.size() + ', timecardstodelete: ' + timecardstodelete.size());
		
		// kuemmern wir uns um die faelschlicherweise verrechenbaren bzw. nicht verrechenbaren
		System.debug('updateTimecards: Fehler? ' + hasException);
		if (!hasException) invertTCverrechenbar();
		System.debug('updateTimecards: timecardstoinsert: ' + timecardstoinsert.size() + ', timecardstoupdate: ' +timecardstoupdate.size() + ', timecardstodelete: ' + timecardstodelete.size());
		
		System.debug('updateTimecards: Fehler? ' + hasException);
		if (!hasException) upsertdelTimecards(fallnew);
		
		// finally
		System.debug('updateTimecards: Fehler? ' + hasException);
		System.debug('updateTimecards: falltoupdate: ' + falltoupdate.size());
		if (!hasException) updateFaelle();
	}
	
	// Helferlein
	private static void recalculateTimecards(map<Id, Fall__c> fallnew, map<Id, Fall__c> fallold) {
		
		for (Fall__c f: fallnew.values()) {
			if ((f.Erneuerung_Pauschale__c==null || !f.Erneuerung_Pauschale__c) && tcpauschalall.containsKey(f.id)) timecardstodelete.addAll(tcpauschalall.get(f.id).values());
			if (systemHelper.isPauschale(f.Fallkategorie__c) && f.Datum_Fallkategorie_Aenderung__c!=null) {
				Date dt=f.Datum_Fallkategorie_Aenderung__c;
				createTimecard(Datetime.newInstance(dt.year(),dt.month(),dt.day(),0,0,0),f);
			}
 		}
 		// Löschen aller bisherigen pauschalen
		delete timecardstodelete;
		timecardstodelete.clear();
	}
	/*
	// nicht löschen, wird vielleicht noch mal gebraucht!
	private static void recalculateTimecardsOld(map<Id, Fall__c> fallnew, map<Id, Fall__c> fallold) {
		list<Id> shortenIds = new list<id>();
		for (Id fid: fallnew.keySet()) {
			shortenIds.clear();
			Date nextdate=fallnew.get(fid).Datum_Fallkategorie_Aenderung__c;
			if (nextdate==null) nextdate=System.today();
			Datetime nextdatetime=Datetime.newInstance(nextdate.year(),nextdate.month(),nextdate.day(),0,0,0);
			Date enddate=nextdate-1;
			Datetime newenddatetime=Datetime.newInstance(enddate.year(),enddate.month(),enddate.day(),23,59,59);
			Boolean fehlendePauschalen=true;
			if (tcpauschal.containsKey(fid)) {
			// es gibt bereits pauschalen zum fall
				// wir suchen die TC, die den neuen Gegebenheiten angepasst werden muss
				for (Timecard__c tc: tcpauschal.get(fid).values()) {
					System.debug('recalculateTimecardsPauschale: Fall: ' + fid + ', nextdatetime: ' + nextdatetime + ', tc.von__c: ' + tc.von__c + ', tc.bis__c: ' + tc.bis__c);
					// wenn wir insgesamt einen treffer haben, fehlen keine Pauschalen
					if (tc.von__c<nextdatetime && tc.bis__c>=nextdatetime && tc.Aktivitaet__c!=fallnew.get(fid).Fallkategorie__c) {
						// das ist sie, sie muss sich auch in der Aktivitaet von der neuen Fallkategorie unterscheiden
						// eine Pauschale mit der selben Aktivitaet zu kuerzen ist nicht sinnvoll!
						tc.bis__c=newenddatetime;
						tc.verrechenbar__c=verrechenbarIfHasExistingCoaching(tc, fid);
						timecardstoupdate.add(tc);
						shortenIds.add(tc.id);
					} else if (tc.von__c<nextdatetime && tc.bis__c>=nextdatetime && tc.Aktivitaet__c==fallnew.get(fid).Fallkategorie__c)  {
						// diese ist eine Pauschale mit der selben Aktivitaet!
						// nextdatetime muss auf enddate dieser TC gesetzt werden, da wir die TC ja nicht veraendern
						Date otherenddate=Date.newInstance(tc.bis__c.year(),tc.bis__c.month(),tc.bis__c.day());
						nextdate=otherenddate+1;
						nextdatetime=Datetime.newInstance(nextdate.year(),nextdate.month(),nextdate.day(),0,0,0);
						shortenIds.add(tc.id);
						// noch pruefen, ob die Pauschale mittlerweile verrechenbar ist
						if (verrechenbarIfHasExistingCoaching(tc, fid)!=tc.verrechenbar__c) {
							tc.verrechenbar__c=verrechenbarIfHasExistingCoaching(tc, fid);
							timecardstoupdate.add(tc);
						}
					}
				}
				if (!shortenIds.isEmpty()) {
					fehlendePauschalen=false;
					for (Id tcid : shortenIds) {
						tcpauschal.get(fid).remove(tcid);
						tcpauschalall.get(fid).remove(tcid);
					}
				}
				// die restlichen Pauschalen muessen geloescht werden
				selectdeleteTimecards(tcpauschal.get(fid).values());
				
			// so, nun haben wir einen sauberen stand fuer diesen Fall
			// es gibt noch keine pauschalen zum fall
			// dann legen wir eben alle nötigen bis in den aktuellen Monat hinein an
			}
			
			// wir muessen noch herausfinden, ob es Pauschalen in der Vergangenheit gibt, die noch anzulegen sind
			// das ist sicher nur notwendig, wenn die alte Fallkategorie eine Pauschale war
			// wir gehen davon aus, dass es mindestens eine pauschale geben muss, die beim anlegen
			// des Falls oder beim letzten Fallkategoriewechsel erzeugt wurde
			// AUSNAHME: Abklärung Pauschal
			if (fehlendePauschalen && systemHelper.isPauschale(fallold.get(fid).Fallkategorie__c) && !systemHelper.isAbklaerungPauschal(fallold.get(fid).Fallkategorie__c)) {
				// nun muessen wir herausfinden, welche Pauschalen fehlen und all diese anlegen
				// Pauschalen musssen nur bis nextdate-1 angelegt werden!
				// konzept: wir gehen monatsweise zurueck und legen pauschalen mit der alten Fallkategorie an
				// bis wir eine passende Pauschale finden
				Boolean erzeugePauschale=true;
				Datetime fallcreationdatetime=creationdatetime(fallold.get(fid).CreatedDate);
				if (fallold.get(fid).CreatedDate_OnlyForTest__c!=null)
					fallcreationdatetime=creationdatetime(fallold.get(fid).CreatedDate_OnlyForTest__c);
				Date enddateOfMissingTC=nextdate-1;
				Date startdateOfMissingTC=nextdate.toStartOfMonth();
				Datetime enddatetimeOfMissingTC=Datetime.newInstance(enddateOfMissingTC.year(),enddateOfMissingTC.month(),enddateOfMissingTC.day(),23,59,59);
				Datetime startdatetimeOfMissingTC=Datetime.newInstance(startdateOfMissingTC.year(),startdateOfMissingTC.month(),startdateOfMissingTC.day(),0,0,0);
				//createTimecard(startdatetimeOfMissingTC,enddatetimeOfMissingTC,fallold.get(fid));
				while (erzeugePauschale) {
					if (tcpauschalall.containsKey(fid)) { 
					// eine suche nach fehlenden TC ist nur sinnvoll wenn es ueberhaupt welche gibt
						for (Timecard__c tc: tcpauschalall.get(fid).values()) {
							if (tc.von__c>=startdatetimeOfMissingTC && tc.bis__c<=enddatetimeOfMissingTC && tc.Aktivitaet__c==fallold.get(fid).Fallkategorie__c)
								erzeugePauschale=false;
						}
					}
					if (erzeugePauschale && startdatetimeOfMissingTC>=fallcreationdatetime)
						if (startdatetimeOfMissingTC<enddatetimeOfMissingTC) createTimecard(startdatetimeOfMissingTC,enddatetimeOfMissingTC,fallold.get(fid));
					enddateOfMissingTC=startdateOfMissingTC-1;
					startdateOfMissingTC=enddateOfMissingTC.toStartOfMonth();
					enddatetimeOfMissingTC=Datetime.newInstance(enddateOfMissingTC.year(),enddateOfMissingTC.month(),enddateOfMissingTC.day(),23,59,59);
					startdatetimeOfMissingTC=Datetime.newInstance(startdateOfMissingTC.year(),startdateOfMissingTC.month(),startdateOfMissingTC.day(),0,0,0);
					// abbruchbedingung, sollte es doch keine Pauschale in der Vergangenheit geben
					if (erzeugePauschale && startdatetimeOfMissingTC<fallcreationdatetime) {
						if (fallcreationdatetime<enddatetimeOfMissingTC) createTimecard(fallcreationdatetime,enddatetimeOfMissingTC,fallold.get(fid));
						erzeugePauschale=false;
					}
				}
			}
			
			// die neue Fallkategorie ist eine Pauschale?
			// dann legen wir Pauschalen der Zukunft an
			System.debug('recalculateTimecards: nextdate: ' + nextdate + ' isPauschale: ' + systemHelper.isPauschale(fallnew.get(fid).Fallkategorie__c) + ' Fallkategorie: ' + fallnew.get(fid).Fallkategorie__c );
			if (systemHelper.isPauschale(fallnew.get(fid).Fallkategorie__c)) {
				while (nextdate<=System.today()) {
					System.debug('recalculateTimecards: nextdate: ' + nextdate );
					nextdate=createTimecard(nextdate,fallnew.get(fid));
				}
			}
			
		}
	}
	
	
	private static void selectdeleteTimecards(list<Timecard__c> tcs) {
		timecardstodelete=tcs;
		// diese tcs muessen auch aus der gesamtliste raus
		for (Timecard__c tc: tcs) {
			tcpauschalall.get(tc.Fall__c).remove(tc.id);
		}
	}
	
	private static Datetime creationdatetime(Datetime dt) {
		return Datetime.newInstance(dt.year(),dt.month(),dt.day(),0,0,0);
	}	
	
	private static Date createTimecard(Date startdate,Fall__c f) {
		Date enddate=System.today();
		Datetime startdatetime=Datetime.newInstance(startdate.year(),startdate.month(),startdate.day(),0,0,0);
		enddate=startdate.toStartOfMonth()+ Date.daysInMonth(startdate.year(),startdate.month())-1;
		if (systemHelper.getMapAbklaerungPauschal().containsKey(f.Fallkategorie__c)) {
			Date zwdate=startdate.addMonths(2);
			enddate=zwdate.toStartOfMonth()+ Date.daysInMonth(zwdate.year(),zwdate.month())-1;
		}
		Datetime enddatetime=Datetime.newInstance(enddate.year(),enddate.month(),enddate.day(),23,59,59);
		Timecard__c tc=createTimecard(f);
		tc.von__c=startdatetime;
		tc.bis__c=enddatetime;
		tc.verrechenbar__c=verrechenbarIfHasExistingCoaching(tc, f.id);
		timecardstoinsert.add(tc);
		return enddate+1;
	}

	private static void createTimecard(Datetime startdatetime, Datetime enddatetime ,Fall__c f) {
		Timecard__c tc=createTimecard(f);
		tc.von__c=startdatetime;
		tc.bis__c=enddatetime;
		tc.verrechenbar__c=verrechenbarIfHasExistingCoaching(tc, f.id);
		timecardstoinsert.add(tc);
	}
	*/
	private static void createTimecard(Datetime startdatetime, Fall__c f) {
		Timecard__c tc=createTimecard(f);
		tc.von__c=startdatetime;
		//tc.bis__c=enddatetime;
		//tc.verrechenbar__c=verrechenbarIfHasExistingCoaching(tc, f.id);
		tc.verrechenbar__c=true;
		timecardstoinsert.add(tc);
	}
	
	private static void upsertdelTimecards(map<Id, Fall__c> fallnew) {
		if (!timecardstoinsert.isEmpty()) {
			try {
				list<Timecard__c> toins = new list<Timecard__c>();
				for (Timecard__c tc: timecardstoinsert) {
					if (tc.id==null) toins.add(tc);
				}
				insert toins;
			} catch (System.DmlException e) {
				for (Fall__c f: fallnew.values()) {
					systemHelper.sendApexWarnEmail('Fehler beim Anlegen von Pauschalen Timecards des Falls ' + f.id + ': ' + e.getMessage());
					f.addError(System.label.ErrorInsertTimecard + ' ' + f.id + ' Meldung: ' + e.getMessage());
				}
				hasException=true;
			}
		}
		if (!timecardstoupdate.isEmpty()) {
			try {
				map<Id, Timecard__c> dedup = new map<Id, Timecard__c>();
				for (Timecard__c tc: timecardstoupdate) {
					if (!dedup.containsKey(tc.id)) dedup.put(tc.id,tc);
				}
				update dedup.values();
			} catch (System.DmlException e) {
				for (Fall__c f: fallnew.values()) {
					systemHelper.sendApexWarnEmail('Fehler beim Aktualisieren von Pauschalen Timecards des Falls ' + f.id + ': ' + e.getMessage());
					f.addError(System.label.ErrorUpdateTimecard + ' ' + f.id + ' Meldung: ' + e.getMessage());
				}
				hasException=true;
			}
		}
		if (!timecardstodelete.isEmpty()) {
			try {
				map<Id, Timecard__c> dedup = new map<Id, Timecard__c>();
				for (Timecard__c tc: timecardstodelete) {
					if (!dedup.containsKey(tc.id) && !tc.isDeleted) dedup.put(tc.id,tc);
				}
				delete dedup.values();
			} catch (System.DmlException e) {
				if (!e.getMessage().contains('ENTITY_IS_DELETED')) {
					for (Fall__c f: fallnew.values()) {
						systemHelper.sendApexWarnEmail('Fehler beim Löschen von Pauschalen Timecards des Falls ' + f.id + ': ' + e.getMessage());
						f.addError(System.label.ErrorDeleteTimecard + ' ' + f.id + ' Meldung: ' + e.getMessage());
					}
					hasException=true;
				}
			}
		}
	}
	
	
	private static void invertTCverrechenbar() {
		if (!tcverrechenbar.isEmpty()) {
			for (Id fid: tcverrechenbar.keySet()) {
				if (!tcverrechenbar.get(fid).isEmpty())
					for (Id tcid: tcverrechenbar.get(fid).keySet()) {
						Timecard__c tc=tcverrechenbar.get(fid).get(tcid);
						tc.verrechenbar__c=false;
						timecardstoupdate.add(tc);
					}
			}
		}
		if (!tcnichtverrechenbar.isEmpty()) {
			for (Id fid: tcnichtverrechenbar.keySet()) {
				if (!tcnichtverrechenbar.get(fid).isEmpty())
					for (Id tcid: tcnichtverrechenbar.get(fid).keySet()) {
						Timecard__c tc=tcnichtverrechenbar.get(fid).get(tcid);
						tc.verrechenbar__c=true;
						timecardstoupdate.add(tc);
					}
			}
		}
	}
	
	private static Date getMinimumDate(Date a, Date b) {
		if (a<b)
			return a;
		else
			return b;
	}
	
	private static Datetime getMaximumDatetime(Datetime a, Datetime b) {
		if (a>b)
			return a;
		else
			return b;
	}
	
	private static void setMinimumSelectedDate(map<Id, Fall__c> faelle) {
		Date minimum=System.today();
		for (Fall__c f: faelle.values()) {
			Datetime fallcreationdatetime=f.CreatedDate;
			if (f.CreatedDate_OnlyForTest__c!=null)
				fallcreationdatetime=f.CreatedDate_OnlyForTest__c;
			Datetime maxDateOfCreationOrLastInvoice=fallcreationdatetime;
			if (f.Letzte_Rechnung__c!=null) 
				maxDateOfCreationOrLastInvoice=getMaximumDatetime(fallcreationdatetime,f.Letzte_Rechnung__c);
			minimum=Date.newInstance(maxDateOfCreationOrLastInvoice.year(), maxDateOfCreationOrLastInvoice.month(), maxDateOfCreationOrLastInvoice.day()); 
			if (f.Datum_Fallkategorie_Aenderung__c!=null) {
				minimum=getMinimumDate(minimum,f.Datum_Fallkategorie_Aenderung__c);
				Fall__c fu=new Fall__c();
				if (falltoupdate.containsKey(f.id)) {
					fu=falltoupdate.get(f.id);
					falltoupdate.remove(f.id);
				} else
					fu=f;
				fu.Datum_Fallkategorie_Aenderung__c=null;
				fu.Erneuerung_Pauschale__c=false;
				falltoupdate.put(fu.id, fu);
			}
		}
		minimumSelectedDate=datetime.newInstance(minimum.year(),minimum.month(),minimum.day(),0,0,0);
		// CR NP wir brauchen jetzt das exakte Datum!
		//minimumSelectedDate=minimumSelectedDate.addDays(-1);
	}
	
	private static void fillFalltoupdate(Set<Id> fallids) {
		if (!fallids.isEmpty())
			for (Fall__c f: [SELECT Id, Datum_Fallkategorie_Aenderung__c, Betrag_Pauschale__c, Erneuerung_Pauschale__c FROM Fall__c WHERE Datum_Fallkategorie_Aenderung__c<>null AND Id IN: fallids]) {
				if (!falltoupdate.containsKey(f.id)) falltoupdate.put(f.id, f);
			}
	}
	
	private static void updateFaelle() {
		alreadyRun=true;
		if (!falltoupdate.isEmpty()) {
			try {
				update falltoupdate.values();
			} catch (System.DmlException e) {
				systemHelper.sendApexWarnEmail('Leeren der Fallkategorie Zeitstempel fehlgeschlagen: ' + e.getMessage());
			}
		}
	}
	
	private static void getTimecards(Set<Id> fallids, map<Id, Fall__c> fallnew) {
		if (!fallids.isEmpty()) {
			// wegen Abklärung Pauschal müssen wir bis in den vorherigen Monat schauen
			Date searchDate=Date.newInstance(minimumSelectedDate.year(),minimumSelectedDate.month(),minimumSelectedDate.day());
			//searchDate=searchDate.toStartOfMonth()-1;
			//searchDate=searchDate.toStartOfMonth();
			Datetime searchDatetime=datetime.newInstance(searchDate.year(),searchDate.month(),searchDate.day(),0,0,0);
			map<Id, Id> ok=new map<Id, Id>();
			system.debug('getTimecards: searchDate: ' + searchDatetime);
			
			for (Timecard__c tc: [SELECT Id, Aktivitaet__c, Fall__c, berechnet__c, verrechenbar__c, von__c, bis__c
					, createdByTrigger__c 
					, IsDeleted
					FROM Timecard__c WHERE von__c>=:searchDatetime AND Fall__c IN: fallids]) {
				// die tc muss im fraglichen Intervall des Falls liegen sonst ist die tc irrelevant
				Date selectedDate=fallnew.get(tc.Fall__c).Datum_Fallkategorie_Aenderung__c;
				if (selectedDate==null) selectedDate=System.today();
				Datetime selectedDatetime=datetime.newInstance(selectedDate.year(),selectedDate.month(),selectedDate.day(),0,0,0);
				// ... und darf nicht schon eine berechnete TC haben (ok)
				// CR NP
				// Bedingung noch prüfen
				if (systemHelper.isCoachingActivity(tc.Aktivitaet__c) && tc.von__c>=selectedDatetime && !ok.containsKey(tc.Fall__c)) {
					// pruefung, ob auch keine berechneten tc im intervall des speziellen falls ist
					if (tc.berechnet__c) {
						fallnew.get(tc.Fall__c).addError(System.label.ErrorEsGibtBerechneteTC);
						if (!ok.containsKey(tc.Fall__c)) ok.put(tc.Fall__c,tc.Fall__c);
						hasException=true;
					}
					// wir arbeiten weiter, wenn es wirklich sinnvoll ist
					if (!ok.containsKey(tc.Fall__c)) {
						system.debug('getTimecards: tc.Aktivitaet__c: ' + tc.Aktivitaet__c);
						// pauschalen, nur die, die wir auch angelegt haben
						if (systemHelper.isPauschale(tc.Aktivitaet__c)) {
							if (!tcpauschal.containsKey(tc.Fall__c)) tcpauschal.put(tc.Fall__c, new map<Id, Timecard__c>());
							if (!tcpauschal.get(tc.Fall__c).containsKey(tc.id)) tcpauschal.get(tc.Fall__c).put(tc.id, tc);
						}
						// verrechenbare Coachings
						// interessieren nur, wenn wir eine Pauschale Fallkategorie haben
						//System.debug('Aktivitaet: ' + tc.Aktivitaet__c + ', isCoaching: ' + systemHelper.isCoachingActivity(tc.Aktivitaet__c) + ', Verrechenbar: ' + tc.verrechenbar__c + ', Fallpauschale: ' + systemHelper.isPauschale(fallnew.get(tc.Fall__c).Fallkategorie__c));
						if (systemHelper.isCoachingActivity(tc.Aktivitaet__c) && tc.verrechenbar__c && systemHelper.isPauschale(fallnew.get(tc.Fall__c).Fallkategorie__c)) {
							if (!tcverrechenbar.containsKey(tc.Fall__c)) tcverrechenbar.put(tc.Fall__c, new map<Id, Timecard__c>());
							if (!tcverrechenbar.get(tc.Fall__c).containsKey(tc.id)) tcverrechenbar.get(tc.Fall__c).put(tc.id, tc);
						}
						// nicht verrechenbare Coachings
						// interessieren nur, wenn wir keine Pauschale Fallkategorie haben
						if (systemHelper.isCoachingActivity(tc.Aktivitaet__c) && !tc.verrechenbar__c && !systemHelper.isPauschale(fallnew.get(tc.Fall__c).Fallkategorie__c)) {
							if (!tcnichtverrechenbar.containsKey(tc.Fall__c)) tcnichtverrechenbar.put(tc.Fall__c, new map<Id, Timecard__c>());
							if (!tcnichtverrechenbar.get(tc.Fall__c).containsKey(tc.id)) tcnichtverrechenbar.get(tc.Fall__c).put(tc.id, tc);
						}
					}
				}
				// alle verrechenbare Leistungen
				if (systemHelper.isCoachingActivity(tc.Aktivitaet__c)) {
					if (!tcvl.containsKey(tc.Fall__c)) tcvl.put(tc.Fall__c, new map<Id, Timecard__c>());
					if (!tcvl.get(tc.Fall__c).containsKey(tc.id)) tcvl.get(tc.Fall__c).put(tc.id, tc);
				}
				// alle pauschalen
				if (systemHelper.isPauschale(tc.Aktivitaet__c)) {
					if (!tcpauschalall.containsKey(tc.Fall__c)) tcpauschalall.put(tc.Fall__c, new map<Id, Timecard__c>());
					if (!tcpauschalall.get(tc.Fall__c).containsKey(tc.id)) tcpauschalall.get(tc.Fall__c).put(tc.id, tc);
				}
			}
		}
	}
	
	
	private static Boolean verrechenbarIfHasExistingCoaching(Timecard__c tc, Id fallid) {
		if (tc.berechnet__c) return true;
		System.debug('verrechenbarIfHasExistingCoachingPauschale: Pauschale ' + tc.Aktivitaet__c + ', von: ' + tc.von__c + ', bis: ' + tc.bis__c);
		if (tcvl.containsKey(fallid)) {
			if (!tcvl.get(fallid).isEmpty()) {
				for (Timecard__c vl: tcvl.get(fallid).values()) {
					System.debug('verrechenbarIfHasExistingCoachingPauschale: VL ' + vl.Aktivitaet__c + ', von: ' + vl.von__c + ', bis: ' + vl.bis__c);
					if (vl.von__c>=tc.von__c) 
						return true;
				}
			}
		}
		return false;
	}
	
	
}