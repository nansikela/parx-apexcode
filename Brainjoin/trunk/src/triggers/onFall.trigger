/*
* Dieser Trigger Setzt den Inhaber des Falls gleich dem Coach, 
* falls der Coach ausgefuellt wird. 
*/
/*
	die zweite Funktionalitaet ist wesentlich komplexer und kuemmert
	sich um die Pauschalen bzw. Coachings sollte die Fallkategorie 
	geaendert werden
*/
trigger onFall on Fall__c (before insert, before update, after insert, after update) {
	System.debug('Start des Triggers am Fall__c');
	
	map<Id, Fall__c> falltcupdate= new map<Id, Fall__c>();
	
	// Coach - Inhaber
	System.debug('Fuer den Fall bei Insert');
	if (trigger.isBefore) {
		if (Trigger.isInsert) {
			System.debug('Laeft alle Triggers durch');
			for (Integer i=0;i<Trigger.size;i++) {
				System.debug('Nur wenn neue Coach__c != null ist');
				if(Trigger.new[i].Coach__c != null) {
					Trigger.new[i].OwnerId=Trigger.new[i].Coach__c;
				} else if (Trigger.new[i].Teamleader__c!=null) {
					Trigger.new[i].OwnerId=Trigger.new[i].Teamleader__c;
				}
				// Datum Fallkategorie Aenderung darf nicht in der Zukunft liegen
				if (trigger.new[i].Datum_Fallkategorie_Aenderung__c>System.today()) 
					trigger.new[i].Datum_Fallkategorie_Aenderung__c.addError(System.label.DatumnichtinZukunft);
		    }
		}
		
		System.debug('Fuer den Fall bei Update');
		if (Trigger.isUpdate) {
			System.debug('Laeft alle Triggers durch');
	        for (Integer i=0;i<Trigger.size;i++) {
	        	System.debug('Nur wenn neue Coach__c != altem Coach__c');
	        	if(Trigger.new[i].Coach__c != null && Trigger.new[i].Coach__c != Trigger.old[i].Coach__c) {
	            	Trigger.new[i].OwnerId=Trigger.new[i].Coach__c;
	        	} else if (Trigger.new[i].Coach__c==null && Trigger.new[i].Teamleader__c!=Trigger.old[i].Teamleader__c) {
					Trigger.new[i].OwnerId=Trigger.new[i].Teamleader__c;
				}
				// Datum Fallkategorie Aenderung darf nicht in der Zukunft liegen
				if (trigger.new[i].Datum_Fallkategorie_Aenderung__c>System.today()) 
					trigger.new[i].Datum_Fallkategorie_Aenderung__c.addError(System.label.DatumnichtinZukunft);
	        }
	    }
	}
    
    // Fallkategorie - Pauschalen
    if (trigger.isAfter) {
    	list<Fall__c> fallinsert=new list<Fall__c>();
    	map<Id, Fall__c> fallupdatenew=new map<Id, Fall__c>();
    	map<Id, Fall__c> fallupdateold=new map<Id, Fall__c>();
    	
	    if (trigger.isInsert) {
	    	// Beim Anlegen eines Falls mit Pauschale legen wir fuer den aktuellen Monate
	    	// sofort eine passende Pauschale an
	    	for (Integer i=0;i<trigger.size;i++) {
	    		if (systemHelper.isPauschale(trigger.new[i].Fallkategorie__c))
	    			fallinsert.add(trigger.new[i]);
	    	}
	    	if (!fallinsert.isEmpty())
	    		FallTriggerhelper.FallInsert(fallinsert);
	    }
	    
	    if (trigger.isUpdate) {
	    	for (Integer i=0;i<trigger.size;i++) {
	    		// wenn wir bisher keine pauschale haben, dann interessiert uns nur der wechsel in eine Pauschale hinein
	    		// oder ein wechsel innerhalb von Pauschalen
	    		// oder ein wechsel aus einer Pauschalen in einen Aufwand
	    		// oder von einem Aufwand in den anderen
	    		// alternativ, auch wenn ein Datum eingegeben wurde und die Fallkategorie nicht gewechselt hat
	    		// CR NP: wir müssen bei identischer Pauschale zusätzlich einfach eine neue anlegen
	    		if (
	    			/*
	    			(
	    			(
	    			(
	    			!systemHelper.isPauschale(trigger.old[i].Fallkategorie__c) 
	    			&& systemHelper.isPauschale(trigger.new[i].Fallkategorie__c)
	    			) 
	    			||
	    			(
	    			systemHelper.isPauschale(trigger.old[i].Fallkategorie__c) 
	    			&& !systemHelper.isPauschale(trigger.new[i].Fallkategorie__c)
	    			)
	    			|| 
	    			(
	    			systemHelper.isPauschale(trigger.new[i].Fallkategorie__c) 
	    			&& systemHelper.isPauschale(trigger.old[i].Fallkategorie__c) 
	    			&& trigger.old[i].Fallkategorie__c!=trigger.new[i].Fallkategorie__c
	    			)
	    			)
	    			|| 
	    			(
	    			trigger.new[i].Datum_Fallkategorie_Aenderung__c<=System.today() 
	    			&&
	    			trigger.new[i].Datum_Fallkategorie_Aenderung__c!=null
	    			)
	    			|| trigger.new[i].Datum_Fallkategorie_Aenderung__c==null)
	    			*/
					(
	    			(
	    			(
	    			!systemHelper.isPauschale(trigger.old[i].Fallkategorie__c) 
	    			&& systemHelper.isPauschale(trigger.new[i].Fallkategorie__c)
	    			) 
	    			||
	    			(
	    			systemHelper.isPauschale(trigger.old[i].Fallkategorie__c) 
	    			&& !systemHelper.isPauschale(trigger.new[i].Fallkategorie__c)
	    			)
	    			|| 
	    			(
	    			systemHelper.isPauschale(trigger.new[i].Fallkategorie__c) 
	    			&& systemHelper.isPauschale(trigger.old[i].Fallkategorie__c) 
	    			&& trigger.old[i].Fallkategorie__c!=trigger.new[i].Fallkategorie__c
	    			)
	    			)
	    			&& 
	    			(
	    			trigger.new[i].Datum_Fallkategorie_Aenderung__c==System.today() 
	    			|| trigger.new[i].Datum_Fallkategorie_Aenderung__c==null)
	    			)
	    			||
					(
	    			trigger.new[i].Datum_Fallkategorie_Aenderung__c<System.today() && 
	    			trigger.new[i].Datum_Fallkategorie_Aenderung__c!=null 
	    			)
	    			
	    			) {
	    			if (!fallupdatenew.containsKey(trigger.new[i].Id)) fallupdatenew.put(trigger.new[i].Id, trigger.new[i]);
	    			if (!fallupdateold.containsKey(trigger.old[i].Id)) fallupdateold.put(trigger.old[i].Id, trigger.old[i]);
	    			System.debug('onFall Trigger: fallupdatenew size: ' + fallupdatenew.size());
	    		}
	    		// new since 20100208:
    			// if new fallkategorie is in setNachAufwandGKPK, the price for the timecards has changed
	    		if ((systemHelper.getSetNachAufwandGKPK().contains(trigger.new[i].Fallkategorie__c) 
		    		|| systemHelper.getSetNachAufwandGKPK().contains(trigger.old[i].Fallkategorie__c) 
		    		)) {
		    		falltcupdate.put(trigger.new[i].Id, trigger.new[i]);
		    	}
		    	
		    	// CR NP
		    	if (trigger.new[i].Datum_Fallkategorie_Aenderung__c!=null && trigger.new[i].Erneuerung_Pauschale__c) {
		    		if (!fallupdatenew.containsKey(trigger.new[i].Id)) fallupdatenew.put(trigger.new[i].Id, trigger.new[i]);
	    			if (!fallupdateold.containsKey(trigger.old[i].Id)) fallupdateold.put(trigger.old[i].Id, trigger.old[i]);
	    			System.debug('onFall Trigger: fallupdatenew size: ' + fallupdatenew.size());
		    	}
	    	}
	    	
	    	if (!fallupdatenew.isEmpty() && !FallTriggerHelper.getAlreadyRun()) {
	    		FallTriggerHelper.alreadyRun=true;
	    		FallTriggerHelper.updateTimecards(fallupdatenew, fallupdateold);
	    	}
	    }
    }
    
    // new since 20100208:
    // if new fallkategorie is in setNachAufwandGKPK, the price for the timecards has changed
    if (!falltcupdate.isEmpty() && FallTriggerHelper.alreadyRun) FallTriggerHelperUpdateTimecards.changeTimecardPrices(falltcupdate);
    
 	System.debug('Ende des Triggers am Fall__c');
}