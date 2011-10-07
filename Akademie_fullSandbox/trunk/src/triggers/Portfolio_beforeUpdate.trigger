trigger Portfolio_beforeUpdate on Portfolio__c (before update) {
    //if status verabschiedet> no changes possible
    //if status Eckdaten verabschiedet six fields still can be edited ( p.Zielgruppe__c, p.Teilnehmerhinweis__c, p.Seminarbeschreibung__c, p.Methode__c, p.Intro__c, p.Inhalte__c )
    
    //the following user should edit portfolio even if it's locked>
    //	'00520000000mpjeAAA' Stefanie Schmider
	//  '00520000000lHZdAAM' Carsten Brede
	//	'00520000000lHIIAA2' Helga Borkert
    
    String STATUS_FINAL = 'Verabschiedet';
    String STATUS_SEMIFINAL = 'Eckdaten verabschiedet';
    
    //user that are allowed to edit
    Id userId = UserInfo.getUserId();
    Set<Id> userAllowedList = new Set<Id>{'00520000000mpjeAAA','00520000000lHZdAAM','00520000000lHIIAA2'};
    
    //only check if user is not in list
    if(!userAllowedList.contains(userId)){
	    for(Portfolio__c p : Trigger.new){
	        if(Trigger.oldMap.containsKey(p.Id)){
	        	Portfolio__c oldP = Trigger.oldMap.get(p.Id);
	            if(oldP.Status__c == STATUS_FINAL){
	            	System.debug('*** STATUS_FINAL');
	                p.addError('Wenn der Status eines Seminars im Portfolio auf "verabschiedet" steht, können Sie keine Änderungen mehr vornehmen. Bitte wenden Sie sich an die Portfolio-Verantwortliche im Marketing Stefanie Schmider');
	            }else if(oldP.Status__c == STATUS_SEMIFINAL){
	            	System.debug('*** Semifinal, pm' + p.PM__c + ', pmold'+ oldP.PM__c);
	            	if(p.regName__c != oldP.regName__c 
	            	|| p.lfd_Mr__c != oldP.lfd_Mr__c  
	            	|| p.Weiterf_hrende_Seminare__c != oldP.Weiterf_hrende_Seminare__c
	            	|| p.Untertitel__c != oldP.Untertitel__c
	            	|| p.Unterregister__c != oldP.Unterregister__c
	            	|| p.Status__c != oldP.Status__c
	            	|| p.Sonderpreisinfo__c != oldP.Sonderpreisinfo__c
	            	|| p.Sonderpreis__c != oldP.Sonderpreis__c
	            	|| p.Seminartitel__c != oldP.Seminartitel__c
	            	|| p.Seminarname__c != oldP.Seminarname__c
	            	|| p.Seite__c != oldP.Seite__c
	            	|| p.Register__c != oldP.Register__c
	            	|| p.Preis__c != oldP.Preis__c
	            	|| p.Portfolio_Jahr__c != oldP.Portfolio_Jahr__c
	            	|| p.PM__c != oldP.PM__c
	            	|| p.OwnerId != oldP.OwnerId
	            	|| p.Name != oldP.Name
	            	|| p.NEU__c != oldP.NEU__c
	            	|| p.Mehrere_Trainer__c != oldP.Mehrere_Trainer__c
	            	|| p.Max_Teilnehmer__c != oldP.Max_Teilnehmer__c
	            	|| p.MG_Online__c != oldP.MG_Online__c
	            	|| p.Leitung__c != oldP.Leitung__c
	            	|| p.Key_Note_Speaker__c != oldP.Key_Note_Speaker__c
	            	|| p.Kennung__c != oldP.Kennung__c
	            	|| p.Hinweise_f_r_Marketing__c != oldP.Hinweise_f_r_Marketing__c
	            	|| p.Hinweis_bei_Preis__c != oldP.Hinweis_bei_Preis__c
	            	|| p.Englisches_Seminar__c != oldP.Englisches_Seminar__c
	            	|| p.Ende__c != oldP.Ende__c
	            	|| p.Dauer_in_Tagen__c != oldP.Dauer_in_Tagen__c
	            	|| p.Buch_oder_Logo_oder_Foto__c != oldP.Buch_oder_Logo_oder_Foto__c
	            	|| p.Bestandteil_Curriculum_Diplom__c != oldP.Bestandteil_Curriculum_Diplom__c
	            	|| p.Beginn__c != oldP.Beginn__c
	            	|| p.Ausgabenummer__c != oldP.Ausgabenummer__c 
	            	|| p.Aufbauseminar__c != oldP.Aufbauseminar__c
	            	|| p.Anzahl_Termine_2010__c != oldP.Anzahl_Termine_2010__c
	            	|| p.Anzahl_Termine_2009__c != oldP.Anzahl_Termine_2009__c 
	            	|| p.Akademiestudie__c != oldP.Akademiestudie__c){
	            		System.debug('*** STATUS_SEMIFINAL');
	            		p.addError('Wenn der Status eines Seminars im Portfolio auf "Eckdaten verabschiedet" steht, können Sie nur noch die Felder: Intro / Inhalte / Seminarbeschreibung / Methode / Zielgruppe /Teilnehmerhinweis ändern. Bitte wenden Sie sich an die Portfolio-Verantwortliche im Marketing Stefanie Schmider.');
	            	}
	            }
	        }
	    }
    }
}