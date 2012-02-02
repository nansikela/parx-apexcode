public class onVorhabenKosten {
	public static boolean inFutureContext = false;
	public static VorhabenBewegung__c VB;
	public static Boolean alreadyInUpdate= false;
	
	
	public static void init(list<VorhabenBewegung__c> VorhabenBewegung04) {
		list<VorhabenBewegung__c> VBlist2 = new list<VorhabenBewegung__c>();
		list<String> VorhabenIds = new list<String>();
		map<String, map<String, map<Date, map<String, VorhabenBewegung__c>>>> VorhabenBewegung03 = new map<String, map<String, map<Date, map<String, VorhabenBewegung__c>>>>();
		list<VorhabenBewegung__c> toClone = new list<VorhabenBewegung__c>();
			
		for(VorhabenBewegung__c VB04:VorhabenBewegung04) {
			VorhabenIds.add(VB04.VORHB9__c);
		}
		
		list<VorhabenBewegung__c> toWorkon = new list<VorhabenBewegung__c>([select id, VORHB9__c, BTRGB9__c, GKTOK9__c, VTDIB9__c, KSTAK9__c from VorhabenBewegung__c
													where VORHB9__c IN: VorhabenIds 
													  AND DORGB9__c = 03 ]);
		
		for(VorhabenBewegung__c temp:toWorkon) {
			//we just fill out the map
			if(!VorhabenBewegung03.containsKey(temp.VORHB9__c)) {
				VorhabenBewegung03.put(temp.VORHB9__c /*Vorhaben*/, new map<String, map<Date, map<String, VorhabenBewegung__c>>>{
							    temp.GKTOK9__c /*Lieferant*/ => new map<Date, map<String, VorhabenBewegung__c>>{
							    temp.VTDIB9__c /*Vertragsdatum*/ => new map<String, VorhabenBewegung__c> {
							    temp.KSTAK9__c /*Kostenart*/ =>							    
							    temp}}});
			}
			else if(!VorhabenBewegung03.get(temp.VORHB9__c).containsKey(temp.GKTOK9__c)) {
				VorhabenBewegung03.get(temp.VORHB9__c).put(temp.GKTOK9__c /*Lieferant*/, new map<Date, map<String, VorhabenBewegung__c>>{
							    temp.VTDIB9__c /*Vertragsdatum*/ => new map<String, VorhabenBewegung__c> {
							    temp.KSTAK9__c /*Kostenart*/ =>							    
							    temp}});
			}
			else if(!VorhabenBewegung03.get(temp.VORHB9__c).get(temp.GKTOK9__c).containsKey(temp.VTDIB9__c)) {
				VorhabenBewegung03.get(temp.VORHB9__c).get(temp.GKTOK9__c).put(temp.VTDIB9__c /*Vertragsdatum*/, new map<String, VorhabenBewegung__c> {
							    temp.KSTAK9__c /*Kostenart*/ =>							    
							    temp});
			}
			else if(!VorhabenBewegung03.get(temp.VORHB9__c).get(temp.GKTOK9__c).get(temp.VTDIB9__c).containsKey(temp.KSTAK9__c)) {
				VorhabenBewegung03.get(temp.VORHB9__c).get(temp.GKTOK9__c).get(temp.VTDIB9__c).put(
							    temp.KSTAK9__c /*Kostenart*/ ,							    
							    temp);
			}
		}
		
		for(VorhabenBewegung__c VB04:VorhabenBewegung04) {
			//we check for each if there is already a 03 which pass to the 04
			//if not, we create a clone of the 04 (insertNew03)
			//if yes, we just add the new "betrag"
			if(!VorhabenBewegung03.containsKey(VB04.VORHB9__c)) {
				VorhabenBewegung03.put(VB04.VORHB9__c /*Vorhaben*/, new map<String, map<Date, map<String, VorhabenBewegung__c>>>{
							    VB04.GKTOK9__c /*Lieferant*/ => new map<Date, map<String, VorhabenBewegung__c>>{
							    VB04.VTDIB9__c /*Vertragsdatum*/ => new map<String, VorhabenBewegung__c> {
							    VB04.KSTAK9__c /*Kostenart*/ =>							    
							    VB04}}});
				toClone.add(VB04);	
			} 
			else if(!VorhabenBewegung03.get(VB04.VORHB9__c).containsKey(VB04.GKTOK9__c)) {
				VorhabenBewegung03.get(VB04.VORHB9__c).put(VB04.GKTOK9__c /*Lieferant*/, new map<Date, map<String, VorhabenBewegung__c>>{
							    VB04.VTDIB9__c /*Vertragsdatum*/ => new map<String, VorhabenBewegung__c> {
							    VB04.KSTAK9__c /*Kostenart*/ =>							    
							    VB04}});
				toClone.add(VB04);
			}
			else if(!VorhabenBewegung03.get(VB04.VORHB9__c).get(VB04.GKTOK9__c).containsKey(VB04.VTDIB9__c)) {
				VorhabenBewegung03.get(VB04.VORHB9__c).get(VB04.GKTOK9__c).put(VB04.VTDIB9__c /*Vertragsdatum*/, new map<String, VorhabenBewegung__c> {
							    VB04.KSTAK9__c /*Kostenart*/ =>							    
							    VB04});
				toClone.add(VB04);
			}
			else if(!VorhabenBewegung03.get(VB04.VORHB9__c).get(VB04.GKTOK9__c).get(VB04.VTDIB9__c).containsKey(VB04.KSTAK9__c)) {
				VorhabenBewegung03.get(VB04.VORHB9__c).get(VB04.GKTOK9__c).get(VB04.VTDIB9__c).put(
							    VB04.KSTAK9__c /*Kostenart*/ ,							    
							    VB04);
				toClone.add(VB04);
			}
			else {
				VB = new VorhabenBewegung__c();
				VB = VorhabenBewegung03.get(VB04.VORHB9__c).get(VB04.GKTOK9__c).get(VB04.VTDIB9__c).get(VB04.KSTAK9__c);
				if(VB04.BTRGB9__c != null)
					VB.BTRGB9__c += VB04.BTRGB9__c;
				VBlist2.add(VB);
			}
				
		}
		
		if(!toClone.isEmpty()) {
			//we have to create the new 03 because they still does not exist.
			insertNew03(toClone);
		}

		if(!VBlist2.isEmpty())	
			update VBlist2;
	}
	
	private static void insertNew03(list<VorhabenBewegung__c> toClone) {
		list<VorhabenBewegung__c> VBlist = new list<VorhabenBewegung__c>();
		for(VorhabenBewegung__c new03:toClone) {
			 VB = new VorhabenBewegung__c();
			 VB = new03.clone(true,false);
			 VB.DORGB9__c = 03;
			 VB.BUDAB9__c = VB.VTDIB9__c; //Buchungsdatun = Vertragsdatum
			 
			 VBlist.add(VB);
		}
		if(!VBlist.isEmpty())
			insert VBlist;
	}
	
	public static void duplicate(list<VorhabenBewegung__c> todup) {
		list<VorhabenBewegung__c> toInsert = new list<VorhabenBewegung__c>();
		for (VorhabenBewegung__c item: todup) {
			VorhabenBewegung__c nVB=item.clone(false,true);
			nVB.DORGB9__c=02;
			nVB.VBKey__c=null;
			toInsert.add(nVB);
		}
		if (!toInsert.isEmpty())
			insert toInsert;
	}
	
	/*
		wir berechnen für jeden geänderten Eintrag die Zugehörige 03er Bewegung neu, oder legen neue an oder löschen, falls nötig alte 03er
		
		Dabei müssen wir berücksichtigen, dass sich innerhalb der Maps natürlich mehrere Änderungen an ein und der selben 03er Bewegung enthalten sein können
		
		Einfaches Konzept: Wir holen uns alle zu den angegebenen Kriterien bestehenden 03er Bewegungen und führen Schritt für Schritt die Änderungen daran durch
		Sollte eine 03 nicht existieren, wird sie entsprechend neu angelegt, sollte eine 03er Bewegung betragsmäßig schließlich bei 0 sein, wird sie gelöscht
		TODO letzten Teilsatz klären.
		
		Kriterien für die Identifizierung: Vorhaben, Lieferant, Vertragsdatum und Kostenart
	*/
	public static void onChange(map<Id, VorhabenBewegung__c> oldMap, map<Id, Vorhabenbewegung__c> newMap) {
		alreadyInUpdate=true;
		list<VorhabenBewegung__c> vhbtoupdate=new list<VorhabenBewegung__c>();
		list<VorhabenBewegung__c> vhbtodelete=new list<VorhabenBewegung__c>();
		list<VorhabenBewegung__c> vhbtoinsert=new list<VorhabenBewegung__c>();
		map<id, VorhabenBewegung__c> vorhb03=new map<id, VorhabenBewegung__c>();
		// getter bestehende 03er
		// Vorbereitung query
		set<id> vhids=new set<id>();
		set<Date> vtdt=new set<Date>();
		set<id> ksta=new set<id>();
		set<id> lieferanten=new set<Id>();
		map<Id, map<Id, map<Id, map<Date, VorhabenBewegung__c>>>> vbkeynewmap =new map<Id, map<Id, map<Id, map<Date, VorhabenBewegung__c>>>>();
		map<Id, map<Id, map<Id, map<Date, VorhabenBewegung__c>>>> vbkeyoldmap =new map<Id, map<Id, map<Id, map<Date, VorhabenBewegung__c>>>>();
		map<Id, map<Id, map<Id, map<Date, VorhabenBewegung__c>>>> vb03keymap =new map<Id, map<Id, map<Id, map<Date, VorhabenBewegung__c>>>>();
		for (VorhabenBewegung__c vorhb: newMap.values()) {
			if (!vhids.contains(vorhb.VORHB9__c )) vhids.add(vorhb.VORHB9__c);
			if (!vbkeynewmap.containsKey(vorhb.VORHB9__c)) 
				vbkeynewmap.put(vorhb.VORHB9__c, new map<Id, map<Id, map<Date, VorhabenBewegung__c>>>());
			if (vorhb.KSTAK9__c!=null && !ksta.contains(vorhb.KSTAK9__c)) ksta.add(vorhb.KSTAK9__c);
			if (!vbkeynewmap.get(vorhb.VORHB9__c).containsKey(vorhb.KSTAK9__c)) 
				vbkeynewmap.get(vorhb.VORHB9__c).put(vorhb.KSTAK9__c, new map<Id, map<Date, VorhabenBewegung__c>>());
			if (vorhb.GKTOK9__c!=null && !lieferanten.contains(vorhb.GKTOK9__c)) lieferanten.add(vorhb.GKTOK9__c);
			if (!vbkeynewmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).containsKey(vorhb.GKTOK9__c)) 
				vbkeynewmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).put(vorhb.GKTOK9__c, new map<Date, VorhabenBewegung__c>());
			if (vorhb.VTDIB9__c!=null && !vtdt.contains(vorhb.VTDIB9__c)) vtdt.add(vorhb.VTDIB9__c);
			if (!vbkeynewmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).containsKey(vorhb.VTDIB9__c))
				vbkeynewmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).put(vorhb.VTDIB9__c, vorhb);
		}
		for (VorhabenBewegung__c vorhb: oldMap.values()) {
			if (!vhids.contains(vorhb.VORHB9__c )) vhids.add(vorhb.VORHB9__c);
			if (!vbkeyoldmap.containsKey(vorhb.VORHB9__c)) 
				vbkeyoldmap.put(vorhb.VORHB9__c, new map<Id, map<Id, map<Date, VorhabenBewegung__c>>>());
			if (vorhb.KSTAK9__c!=null && !ksta.contains(vorhb.KSTAK9__c)) ksta.add(vorhb.KSTAK9__c);
			if (!vbkeyoldmap.get(vorhb.VORHB9__c).containsKey(vorhb.KSTAK9__c)) 
				vbkeyoldmap.get(vorhb.VORHB9__c).put(vorhb.KSTAK9__c, new map<Id, map<Date, VorhabenBewegung__c>>());
			if (vorhb.GKTOK9__c!=null && !lieferanten.contains(vorhb.GKTOK9__c)) lieferanten.add(vorhb.GKTOK9__c);
			if (!vbkeyoldmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).containsKey(vorhb.GKTOK9__c)) 
				vbkeyoldmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).put(vorhb.GKTOK9__c, new map<Date, VorhabenBewegung__c>());
			if (vorhb.VTDIB9__c!=null && !vtdt.contains(vorhb.VTDIB9__c)) vtdt.add(vorhb.VTDIB9__c);
			if (!vbkeyoldmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).containsKey(vorhb.VTDIB9__c))
				vbkeyoldmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).put(vorhb.VTDIB9__c, vorhb);
		}
		for (VorhabenBewegung__c vorhb:[SELECT Id
											, VORHB9__c
											, VTDIB9__c
											, KSTAK9__c
											, GKTOK9__c
											, BTRGB9__c 
											FROM VorhabenBewegung__c 
											WHERE DORGB9__c=3 
											AND 
											(VORHB9__c IN: vhids 
											OR VTDIB9__c IN: vtdt 
											OR KSTAK9__c IN: ksta 
											OR GKTOK9__c IN :lieferanten
											)
											]) {
			if (!vorhb03.containsKey(vorhb.id)) vorhb03.put(vorhb.id, vorhb);
			if (!vb03keymap.containsKey(vorhb.VORHB9__c)) 
				vb03keymap.put(vorhb.VORHB9__c, new map<Id, map<Id, map<Date, VorhabenBewegung__c>>>());
			if (!vb03keymap.get(vorhb.VORHB9__c).containsKey(vorhb.KSTAK9__c)) 
				vb03keymap.get(vorhb.VORHB9__c).put(vorhb.KSTAK9__c, new map<Id, map<Date, VorhabenBewegung__c>>());
			if (!vb03keymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).containsKey(vorhb.GKTOK9__c)) 
				vb03keymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).put(vorhb.GKTOK9__c, new map<Date, VorhabenBewegung__c>());
			if (!vb03keymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).containsKey(vorhb.VTDIB9__c))
				vb03keymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).put(vorhb.VTDIB9__c, vorhb);
		}
		for (VorhabenBewegung__c vorhb: vorhb03.values()) {
			// zunächst suchen wir die 03er, die dem alten Stand entsprechen, d. h. sie sind die Quelle für die nötigen Veränderungen
			if(vbkeyoldmap.containsKey(vorhb.VORHB9__c) 
					&& vbkeyoldmap.get(vorhb.VORHB9__c).containsKey(vorhb.KSTAK9__c) 
					&& vbkeyoldmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).containsKey(vorhb.GKTOK9__c)
					&& vbkeyoldmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).containsKey(vorhb.VTDIB9__c)
					) {
				System.debug('Matching 03 Bewegung: ' + vorhb.id);
				// now we have a matching between 03er und 04er Bewegungen (entweder über die alte oder die neue Map)
				// wir holen uns jetzt die 04er Bewegungen aus der alten und neuen Map und prüfen, was sich tatsächlich geändert hat.
				VorhabenBewegung__c vhb04old=vbkeyoldmap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).get(vorhb.VTDIB9__c);
				VorhabenBewegung__c vhb04new=newMap.get(vhb04old.id);
				// check for changes
				// case 1: nur der Betrag hat sich geändert, einfachster Fall!
				// case 2: der Lieferant hat sich geändert (sollten sich die anderen werte geändert haben, wird entsprechend der neuen agiert 
				// und beim alten Datensatz die alten Werte benutzt)
				// case 3: Kostenart hat sich geändert, Verfahren wie bei case 2
				// noch besser: es hat sich ja auf jedenfall etwas geändert, es ist nur die Frage, ob eine neue 03er Bewegung anzulegen ist
				// 1. Schritt: ändere die alte 03er Bewegung analog der Werte durch die 04er Bewegung
				if (vb03keymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).get(vorhb.VTDIB9__c).BTRGB9__c!=null && vhb04old.BTRGB9__c!=null) vb03keymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).get(vorhb.VTDIB9__c).BTRGB9__c-=vhb04old.BTRGB9__c;
				// 2. Schritt: finde die passende 03er Bewegung zur neuen 04er Bewegung (lege diese ggfls.) und führe die Änderung analog der neuen Werte durch
				if (vb03keymap.containsKey(vhb04new.VORHB9__c) 
					&& vb03keymap.get(vhb04new.VORHB9__c).containsKey(vhb04new.KSTAK9__c) 
					&& vb03keymap.get(vhb04new.VORHB9__c).get(vhb04new.KSTAK9__c).containsKey(vhb04new.GKTOK9__c)
					&& vb03keymap.get(vhb04new.VORHB9__c).get(vhb04new.KSTAK9__c).get(vhb04new.GKTOK9__c).containsKey(vhb04new.VTDIB9__c)
					) {
					System.debug('Bestehende 03 Bewegung wird geändert!');
					if (vb03keymap.get(vhb04new.VORHB9__c).get(vhb04new.KSTAK9__c).get(vhb04new.GKTOK9__c).get(vhb04new.VTDIB9__c).BTRGB9__c!=null && vhb04new.BTRGB9__c!=null) 
						vb03keymap.get(vhb04new.VORHB9__c).get(vhb04new.KSTAK9__c).get(vhb04new.GKTOK9__c).get(vhb04new.VTDIB9__c).BTRGB9__c+=vhb04new.BTRGB9__c;
					else
						vb03keymap.get(vhb04new.VORHB9__c).get(vhb04new.KSTAK9__c).get(vhb04new.GKTOK9__c).get(vhb04new.VTDIB9__c).BTRGB9__c=vhb04new.BTRGB9__c;
				} else { // neue 03er Bewegung
					System.debug('Neue 03er Bewegung wird angelegt und in die alte Map eingefügt!');
					VorhabenBewegung__c vhb03new = new VorhabenBewegung__c();
			 		vhb03new = vhb04new.clone(false,true);
			 		vhb03new.DORGB9__c = 03;
			 		vhb03new.BUDAB9__c = vhb03new.VTDIB9__c; //Buchungsdatun = Vertragsdatum
			 		vhb03new.VBKey__c=null;	
					if (!vb03keymap.containsKey(vhb03new.VORHB9__c)) 
						vb03keymap.put(vhb03new.VORHB9__c, new map<Id, map<Id, map<Date, VorhabenBewegung__c>>>());
					if (!vb03keymap.get(vhb03new.VORHB9__c).containsKey(vhb03new.KSTAK9__c)) 
						vb03keymap.get(vhb03new.VORHB9__c).put(vhb03new.KSTAK9__c, new map<Id, map<Date, VorhabenBewegung__c>>());
					if (!vb03keymap.get(vhb03new.VORHB9__c).get(vhb03new.KSTAK9__c).containsKey(vhb03new.GKTOK9__c)) 
						vb03keymap.get(vhb03new.VORHB9__c).get(vhb03new.KSTAK9__c).put(vhb03new.GKTOK9__c, new map<Date, VorhabenBewegung__c>());
					if (!vb03keymap.get(vhb03new.VORHB9__c).get(vhb03new.KSTAK9__c).get(vhb03new.GKTOK9__c).containsKey(vhb03new.VTDIB9__c))
						vb03keymap.get(vhb03new.VORHB9__c).get(vhb03new.KSTAK9__c).get(vhb03new.GKTOK9__c).put(vhb03new.VTDIB9__c, vhb03new);
				}
				
			}
		}
		// jetzt prüfen wir, welche Datensätze aktualisiert werden müssen und welche neu sind und welche gelöscht werden müssen
		for (Id vhid: vb03keymap.keySet()) {
			for (Id kstaid: vb03keymap.get(vhid).keySet()) {
				for (Id lieferantid: vb03keymap.get(vhid).get(kstaid).keySet()) {
					for (Date vtd: vb03keymap.get(vhid).get(kstaid).get(lieferantid).keySet()) {
						VorhabenBewegung__c vhb03=vb03keymap.get(vhid).get(kstaid).get(lieferantid).get(vtd);
						if (vhb03.id!=null && vhb03.BTRGB9__c==0) vhbtodelete.add(vb03keymap.get(vhid).get(kstaid).get(lieferantid).get(vtd));
						if (vhb03.id==null && vhb03.BTRGB9__c!=0) vhbtoinsert.add(vb03keymap.get(vhid).get(kstaid).get(lieferantid).get(vtd));
						if (vhb03.id!=null && vhb03.BTRGB9__c!=0) vhbtoupdate.add(vb03keymap.get(vhid).get(kstaid).get(lieferantid).get(vtd));
					}
				}
			}
		}
		System.debug('List sizes, insert: ' + vhbtoinsert.size() + ' / delete: ' + vhbtodelete.size() + ' / update: ' + vhbtoupdate.size());
		
		if (!vhbtoinsert.isEmpty()) insert vhbtoinsert;
		if (!vhbtodelete.isEmpty()) delete vhbtodelete;
		if (!vhbtoupdate.isEmpty()) update vhbtoupdate;
	}
	
	/*
		Da diese Bewegung gelöscht wurde, muss die zugehörige 03er angepasst bzw. gelöscht werden!
	*/
	public static void deleted(map<Id, VorhabenBewegung__c> delMap) {
		list<VorhabenBewegung__c> vhbtoupdate=new list<VorhabenBewegung__c>();
		list<VorhabenBewegung__c> vhbtodelete=new list<VorhabenBewegung__c>();
		// getter bestehende 03er
		// Vorbereitung query
		set<id> vhids=new set<id>();
		set<Date> vtdt=new set<Date>();
		set<id> ksta=new set<id>();
		set<id> lieferanten=new set<Id>();
		map<Id, map<Id, map<Id, map<Date, VorhabenBewegung__c>>>> vbkeymap =new map<Id, map<Id, map<Id, map<Date, VorhabenBewegung__c>>>>();
		for (VorhabenBewegung__c vorhb: delMap.values()) {
			if (!vhids.contains(vorhb.VORHB9__c )) vhids.add(vorhb.VORHB9__c);
			if (!vbkeymap.containsKey(vorhb.VORHB9__c)) vbkeymap.put(vorhb.VORHB9__c, new map<Id, map<Id, map<Date, VorhabenBewegung__c>>>());
			if (vorhb.KSTAK9__c!=null && !ksta.contains(vorhb.KSTAK9__c))
				ksta.add(vorhb.KSTAK9__c);
			if (!vbkeymap.get(vorhb.VORHB9__c).containsKey(vorhb.KSTAK9__c)) 
				vbkeymap.get(vorhb.VORHB9__c).put(vorhb.KSTAK9__c, new map<Id, map<Date, VorhabenBewegung__c>>());
			if (vorhb.GKTOK9__c!=null && !lieferanten.contains(vorhb.GKTOK9__c))
				lieferanten.add(vorhb.GKTOK9__c);
			if (!vbkeymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).containsKey(vorhb.GKTOK9__c)) 
				vbkeymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).put(vorhb.GKTOK9__c, new map<Date, VorhabenBewegung__c>());
			if (vorhb.VTDIB9__c!=null && !vtdt.contains(vorhb.VTDIB9__c)) vtdt.add(vorhb.VTDIB9__c);
			if (!vbkeymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).containsKey(vorhb.VTDIB9__c))
				vbkeymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).put(vorhb.VTDIB9__c, vorhb);
		}
		for (VorhabenBewegung__c vorhb:[SELECT Id
											, VORHB9__c
											, VTDIB9__c
											, KSTAK9__c
											, GKTOK9__c
											, BTRGB9__c 
											FROM VorhabenBewegung__c 
											WHERE DORGB9__c=3 
											AND 
											(VORHB9__c IN: vhids 
											OR VTDIB9__c IN: vtdt 
											OR KSTAK9__c IN: ksta 
											OR GKTOK9__c IN :lieferanten
											)
											]) {
			if(vbkeymap.containsKey(vorhb.VORHB9__c) 
					&& vbkeymap.get(vorhb.VORHB9__c).containsKey(vorhb.KSTAK9__c) 
					&& vbkeymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).containsKey(vorhb.GKTOK9__c)
					&& vbkeymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).containsKey(vorhb.VTDIB9__c)
					) {
				// now we have a matching between 03er und 04er Bewegungen
				VorhabenBewegung__c vhb04=vbkeymap.get(vorhb.VORHB9__c).get(vorhb.KSTAK9__c).get(vorhb.GKTOK9__c).get(vorhb.VTDIB9__c);
				if (vhb04.BTRGB9__c==vorhb.BTRGB9__c) vhbtodelete.add(vorhb);
				else {
					if (vorhb.BTRGB9__c!=null && vhb04.BTRGB9__c!=null) vorhb.BTRGB9__c-=vhb04.BTRGB9__c;
					vhbtoupdate.add(vorhb);
				}
			}
		}
		if (!vhbtodelete.isEmpty()) delete vhbtodelete;
		if (!vhbtoupdate.isEmpty()) update vhbtoupdate;
	}
	
}