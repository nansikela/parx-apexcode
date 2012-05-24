public class TimecardTriggerHelper {
	/*
	private static Datetime minimumDate=System.now();
	private static Datetime maximumDate=System.now();
	private static Boolean hasException=false;
	private static list<Id> fallids=new list<Id>();
	private static list<Timecard__c> tcPauschalen = new list<Timecard__c>();
	private static list<Timecard__c> timecardstoupdate = new list<Timecard__c>();
	private static map<Id, map<Id, Timecard__c>> tcinputmap = new map<Id, map<Id, Timecard__c>>();

	private static Boolean vIsAlreadyRun=false;
	private static Boolean nvIsAlreadyRun=false;

	public static Boolean getVIsAlreadyRun() {
		return vIsAlreadyRun;
	}

	public static Boolean getNvIsAlreadyRun() {
		return nvIsAlreadyRun;
	}
	
	public static void updateLeistung(list<Timecard__c> tcs) {
		init();
		// wir holen uns alle Pauschelen die im Zeitraum der Leistungen liegen
		// damit finden wir das weitest moegliche suchintervall
		setMinMax(tcs);
		System.debug('updateLeistung: Intervall von ' + minimumDate + ' bis ' + maximumDate);
		// die betreffenden Fall Ids
		getFallIds(tcs);
		
		// wir brauchen die Pauschalen zu den Faellen und zum Zeitraum
 		getPauschalenTimecards();
		getInputTimecards(tcs);
		system.debug('tcinputmap size: ' + tcinputmap.size());
		
		// pruefen wir erneut auf verrechenbarkeit
		recalculatePauschalenTimecards();
		
		//vIsAlreadyRun=true;
		updateTimecards();
	}
	
	public static void  updatePauschaleAfterDelete(list<Timecard__c> tcs) {
		init();
		// wir holen uns alle Pauschelen die im Zeitraum der Leistungen liegen
		// und pruefen, ob es noch weitere TCs in deren Zeitraum gibt
		// damit finden wir das weitest moegliche suchintervall
		setMinMax(tcs);
		
		// die betreffenden Fall Ids
		getFallIds(tcs);
		
		// wir brauchen die Pauschalen zu den Faellen und zum Zeitraum
 		getPauschalenTimecards();               
 		// nun dehnen wir unser suchintervall anhand der Pauschalen aus
 		setMinMax(tcPauschalen);
 		System.debug('updatePauschaleAfterDelete: Intervall von ' + minimumDate + ' bis ' + maximumDate);
 		// im gegensatz zu updateLeistung brauchen wir hier alle _anderen_ VL, als die input TC
		getInputTimecardsDelete(tcs);
		system.debug('tcinputmap size: ' + tcinputmap.size());
		
		// pruefen wir erneut auf verrechenbarkeit
		recalculatePauschalenTimecardsDelete();
		
		//nvIsAlreadyRun=true;
		updateTimecards();		
	}
	
	// helpers
	private static void init() {
		tcinputmap.clear();
		hasException=false;
		minimumDate=System.now();
		maximumDate=System.now();
		fallids.clear();
		tcPauschalen.clear();
		timecardstoupdate.clear();
	}
	
	private static void setMinMax(list<Timecard__c> tcs) {
		for (Timecard__c tc: tcs) {
			minimumDate=getMinimumDatetime(tc.von__c, minimumDate);
			maximumDate=getMaximumDatetime(tc.von__c, maximumDate);
			if (tc.bis__c!=null) maximumDate=getMaximumDatetime(tc.bis__c, maximumDate);
		} 
	}
	
	private static Datetime getMinimumDatetime(Datetime a, Datetime b) {
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
	
	private static void getFallids(list<Timecard__c> tcs) {
		for (Timecard__c tc: tcs) {
			fallids.add(tc.Fall__c);
		}
	}
	
	private static void getPauschalenTimecards() {
		if (!fallids.isEmpty()) {
	 		try {
		 		for (Timecard__c tc: [SELECT Id, Fall__c, Aktivitaet__c, von__c, bis__c, verrechenbar__c, berechnet__c
		 								FROM Timecard__c WHERE 
		 									Fall__c IN: fallids 
		 									AND Aktivitaet__c IN: systemHelper.getMapPauschal().values()
		 									AND bis__c>=:minimumDate
		 									AND von__c<=:maximumDate
		 									]) {
		 			tcPauschalen.add(tc);
		 		}
	 		} catch (System.Queryexception e) {
	 			System.debug('TimecardTriggerHelper.getTimecards, no Pauschal - Timecards found! ' + e.getMessage());
	 		}
	 		System.debug(tcPauschalen.size() + ' Pauschalen gefunden!');
		}
	}
	
	private static void recalculatePauschalenTimecards() {
		// iterieren wir durch die Pauschalen
		Boolean oldvalue=false;
		for (Timecard__c tcp: tcPauschalen) {
			oldvalue=tcp.verrechenbar__c;
			if (tcinputmap.containsKey(tcp.Fall__c)) {
				// so weit so gut, wir haben wohl Timecards dazu gefunden
				// da wir mit den min/max Zeiten gearbeitet haben, muessen wir noch pruefen,
				// ob es wirklich Timecards in dem fraglichen zeitraum sind
				for (Timecard__c tcv: tcinputmap.get(tcp.Fall__c).values()) {
					System.debug('moegliche Timecard tcv fuer pauschale gefunden: ' + tcv.Aktivitaet__c + ', von: ' + tcv.von__c);
					System.debug('Pauschale von: ' + tcp.von__c + ', bis: ' + tcp.bis__c);
					if (tcv.von__c>=tcp.von__c && tcv.von__c<=tcp.bis__c) {
						// verrechenbare Leistung innerhalb des zeitraums gefunden!
						System.debug('verrechenbare Leistung innerhalb des zeitraums gefunden!');
						tcp.verrechenbar__c=true;
					}
				}
			}
			if (tcp.verrechenbar__c!=oldvalue)
				timecardstoupdate.add(tcp);
		}
	}
	
	private static void recalculatePauschalenTimecardsDelete() {
		// iterieren wir durch die Pauschalen
		Boolean oldvalue=false;
		for (Timecard__c tcp: tcPauschalen) {
			oldvalue=tcp.verrechenbar__c;
			// grundsaetzlich gehen wir davon aus, dass wir auf false setzen muessten
			// wenn wir doch eine TC finden, wir es wieder auf true gesetzt
			if (! (systemHelper.isAbklaerungPauschal(tcp.Aktivitaet__c) && (tcp.berechnet__c || tcp.verrechenbar__c))) tcp.verrechenbar__c=false;
			if (tcinputmap.containsKey(tcp.Fall__c)) {
				// so weit so gut, wir haben wohl Timecards dazu gefunden
				// da wir mit den min/max Zeiten gearbeitet haben, muessen wir noch pruefen,
				// ob es wirklich Timecards in dem fraglichen zeitraum sind
				for (Timecard__c tcv: tcinputmap.get(tcp.Fall__c).values()) {
					System.debug('moegliche Timecard tcv fuer pauschale gefunden: ' + tcv.Aktivitaet__c + ', von: ' + tcv.von__c);
					System.debug('Pauschale von: ' + tcp.von__c + ', bis: ' + tcp.bis__c);
					if (tcv.von__c>=tcp.von__c && tcv.von__c<=tcp.bis__c) {
						// verrechenbare Leistung innerhalb des zeitraums gefunden!
						System.debug('verrechenbare Leistung innerhalb des zeitraums gefunden!');
						tcp.verrechenbar__c=true;
					}
				}
			}
			if (tcp.verrechenbar__c!=oldvalue)
				timecardstoupdate.add(tcp);
		}
	}
	
	private static void updateTimecards() {
		if (!timecardstoupdate.isEmpty()) {
			system.debug(timecardstoupdate.size() + ' zu aktualisierende TC');
			try {
				update timecardstoupdate;
			} catch (System.DmlException e) {
				systemHelper.sendApexWarnEmail('Fehler beim Aktualisieren/Erstellen von Timecards: ' + e.getMessage());
				system.debug('Fehler beim Aktualisieren/Erstellen von Timecards: ' + e.getMessage());
				hasException=true;
			}
		}
	}
	
	private static void getInputTimecards(list<Timecard__c> tcs) {
		for (Timecard__c tc: tcs) {
			if (!tcinputmap.containsKey(tc.Fall__c)) tcinputmap.put(tc.Fall__c, new map<Id, Timecard__c>());
			if (!tcinputmap.get(tc.Fall__c).containsKey(tc.Id)) tcinputmap.get(tc.Fall__c).put(tc.id,tc);
		}
	}
	
	private static void getInputTimecardsDelete(list<Timecard__c> tcs) {
		map<Id, Timecard__c> inputmap = new map<Id, Timecard__c>();
		for (Timecard__c tc: tcs) {
			if (!inputmap.containsKey(tc.Id)) inputmap.put(tc.id,tc);
		}
		// nun holen wir uns alle VL innerhalb des suchintervalls zu allen faellen, lassen aber die
		// input TC weg
		for (Timecard__c tc: [SELECT Id, Aktivitaet__c, von__c, bis__c, verrechenbar__c, Fall__c FROM Timecard__c 
								WHERE Aktivitaet__c IN :systemHelper.getMapCoachingActivity().values()
								AND Fall__c IN :fallids
								AND von__c>= :minimumDate
								AND von__c<= :maximumDate
								]) {
			// wir fuegen die VL nur in die Map, wenn sie nicht in der urspruenglichen liste ist,
			// in der urspruenglichen (inputmap) sind die geloeschten TC
			if (!inputmap.containsKey(tc.id)) {
				if (!tcinputmap.containsKey(tc.Fall__c)) tcinputmap.put(tc.Fall__c, new map<Id, Timecard__c>());
				if (!tcinputmap.get(tc.Fall__c).containsKey(tc.Id)) tcinputmap.get(tc.Fall__c).put(tc.id,tc);
				System.debug('Fall: ' + tc.Fall__c + ', size of map: ' + tcinputmap.get(tc.Fall__c).size());
			}
		}
		
	}
	*/
}