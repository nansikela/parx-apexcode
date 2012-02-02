trigger onVorhabenBewegung on VorhabenBewegung__c (before insert, before delete, after update) {
	if(!onVorhabenKosten.inFutureContext && trigger.isInsert) {
		onVorhabenKosten.inFutureContext = True;
		list<VorhabenBewegung__c> toSend = new list<VorhabenBewegung__c>();
		list<VorhabenBewegung__c> toDuplicate = new list<VorhabenBewegung__c>();
		for(VorhabenBewegung__c trig:trigger.new) {
			if(trig.DORGB9__c == 04 && !trig.wasInterfaced__c)
				toSend.add(trig);
			if (trig.DORGB9__c == 01 && trig.Duplizieren_f_r_02__c)
				toDuplicate.add(trig);
		}
		if(!toSend.isEmpty())
			onVorhabenKosten.init(toSend);
		if (!toDuplicate.isEmpty()) onVorhabenKosten.duplicate(toDuplicate);
	}
	
	if(!onVorhabenKosten.inFutureContext && !onVorhabenKosten.alreadyInUpdate && trigger.isUpdate) {
		map<Id, VorhabenBewegung__c> oldMap = new map<Id, VorhabenBewegung__c>();
		map<Id, VorhabenBewegung__c> newMap = new map<Id, VorhabenBewegung__c>();
		list<VorhabenBewegung__c> toDuplicate = new list<VorhabenBewegung__c>(); 
		for (VorhabenBewegung__c trig:trigger.new) { 
			if(trig.DORGB9__c == 04 && !trig.wasInterfaced__c && 
				(trig.BTRGB9__c!=trigger.oldMap.get(trig.Id).BTRGB9__c ||
				trig.VTDIB9__c!=trigger.oldMap.get(trig.Id).VTDIB9__c ||
				trig.GKTOK9__c!=trigger.oldMap.get(trig.Id).GKTOK9__c ||
				trig.KSTAK9__c!=trigger.oldMap.get(trig.Id).KSTAK9__c
				)) {
				if (!newMap.containsKey(trig.id)) newMap.put(trig.id, trig);
				if (!oldMap.containsKey(trig.id)) oldMap.put(trig.id, trigger.oldMap.get(trig.id));
			}
			if (trig.DORGB9__c == 01 && trig.Duplizieren_f_r_02__c && !trigger.oldMap.get(trig.id).Duplizieren_f_r_02__c)
				toDuplicate.add(trig);
		}
		if (!toDuplicate.isEmpty()) onVorhabenKosten.duplicate(toDuplicate);
		if (!newMap.isEmpty()) {
			onVorhabenKosten.alreadyInUpdate=true;
			onVorhabenKosten.onChange(oldMap, newMap);
		}
	}

	if(trigger.isDelete) {
		map<Id, VorhabenBewegung__c> vbdeleted=new map<Id, VorhabenBewegung__c>();
		for(VorhabenBewegung__c VB:trigger.old) {
			if(VB.wasInterfaced__c && (VB.DORGB9__c == 04 && VB.BTRGB9__c != null) || VB.DORGB9__c == 05 || VB.DORGB9__c == 06 || VB.DORGB9__c == 07 || VB.DORGB9__c == 08) {
				VB.addError('Bewegung kommt aus der Buchhaltung und darf nicht gelöscht werden.');
			} else if (!VB.wasInterfaced__c &&(VB.DORGB9__c == 04))
				if (!vbdeleted.containsKey(VB.id)) vbdeleted.put(VB.Id, VB);
				
		}
		if (!vbdeleted.isEmpty()) onVorhabenKosten.deleted(vbdeleted);
	}
}