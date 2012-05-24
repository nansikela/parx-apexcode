trigger onTimecard on Timecard__c (after delete, after insert, after undelete, after update) {
	list<Timecard__c> tcs_v = new list<Timecard__c>();
	list<Timecard__c> tcs_nv = new list<Timecard__c>();

	// Validierungsregel
	// CR NP
	// manuelle Pauschalen sind nun ausdrücklich erlaubt!
	//if (trigger.isAfter && ! trigger.isDelete) {
	//	for (Integer i=0;i<trigger.size;i++) {
	//		if (!trigger.new[i].createdByTrigger__c && systemHelper.isPauschale(trigger.new[i].Aktivitaet__c)) trigger.new[i].addError(System.label.KeineManuellePauschale);
	//	}
	//}

	// verrechenbarkeit von Pauschalen
	if (trigger.isAfter) {
		for (Integer i=0;i<trigger.size;i++) {
			if (trigger.isUpdate || trigger.isInsert || trigger.isUndelete) {
				// eine verrechenbare Leistung
				if (systemHelper.isCoachingActivity(trigger.new[i].Aktivitaet__c)) {
					tcs_v.add(trigger.new[i]);
				}
			}
			if (trigger.isDelete) {
				// eine verrechenbare Leistung wird geloescht
				if (systemHelper.isCoachingActivity(trigger.old[i].Aktivitaet__c)) {
					tcs_nv.add(trigger.old[i]);
				}
				if (trigger.old[i].berechnet__c) trigger.old[i].addError(System.label.ErrorEsGibtBerechneteTC);
			}
		}
	}

	// eine verrechenbare Leistung wurde erzeugt/geaendert
	// wir pruefen, ob es im gleichen Zeitraum eine noch nicht verrechenbare Pauschale gibt, die dann
	// auf verrechenbar gestellt wird
	// HINWEIS:
	// Wird eine verrechenbare Leistung in einem Intervall "Nach Aufwand" erstellt, wird nicht 
	// automatisch geprueft, ob diese dann auch verrechenbar ist.
	// diese Funktionalitaet ist Aufgabe der Rechnungserstellung 
	// CR NP
	// eine Prüfung auf Verrechenbarkeit kann nicht mehr erfolgen
	//if (!tcs_v.isEmpty() && !TimecardTriggerHelper.getVIsAlreadyRun())
	//	TimecardTriggerHelper.updateLeistung(tcs_v);
	
	// eine verrechenbare Leistung wurde geloescht
	// wir pruefen, ob es im gleichen zeitraum eine verrechenbare Pauschale gibt und keine weiteren
	// verrechenbaren Leistungen vorhanden sind
	// dann wird die Pauschale auf nicht verrechenbar gesetzt
	// CR NP
	// eine Prüfung auf Verrechenbarkeit kann nicht mehr erfolgen
	//if (!tcs_nv.isEmpty() && !TimecardTriggerHelper.getNvIsAlreadyRun())
	//	TimecardTriggerHelper.updatePauschaleAfterDelete(tcs_nv);

}