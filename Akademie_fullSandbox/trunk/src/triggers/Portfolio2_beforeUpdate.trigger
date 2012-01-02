trigger Portfolio2_beforeUpdate on Portfolio2__c (before update) {
//if status verabschiedet> no changes possible
    //if status Eckdaten verabschiedet six fields still can be edited ( p.Zielgruppe__c, p.Teilnehmerhinweis__c, p.Seminarbeschreibung__c, p.Methode__c, p.Intro__c, p.Inhalte__c )
    
    //the following user should edit portfolio even if it's locked>
	//  '00520000000lHZdAAM' Carsten Brede
	//	'00520000000lHIIAA2' Helga Borkert
    
    String STATUS_FINAL = 'Verabschiedet';
    String STATUS_SEMIFINAL = 'Eckdaten verabschiedet';
    
    //user that are allowed to edit
    Id userId = UserInfo.getUserId();
    Set<Id> userAllowedList = new Set<Id>{'00520000000lHZdAAM','00520000000lHIIAA2'};
    
    //only check if user is not in list
    if(!userAllowedList.contains(userId)){
	    for(Portfolio2__c p : Trigger.new){
	        if(Trigger.oldMap.containsKey(p.Id)){
	        	Portfolio2__c oldP = Trigger.oldMap.get(p.Id);
	        	
	            if(oldP.Status__c == STATUS_FINAL){
	            	System.debug('*** STATUS_FINAL');
	                p.addError('Wenn der Status eines Seminars im Portfolio auf "verabschiedet" steht, können Sie keine Änderungen mehr vornehmen. Bitte wenden Sie sich an die Portfolio-Verantwortliche im Marketing Helga Borkert.');
	            }else if(oldP.Status__c == STATUS_SEMIFINAL){
	            	if(p.Weiterf_hrende_Seminare__c != oldP.Weiterf_hrende_Seminare__c
	            	|| p.Untertitel__c != oldP.Untertitel__c
	            	|| p.Bereich__c != oldP.Bereich__c
	            	|| p.Status__c != oldP.Status__c
	            	|| p.Sonderpreisinfo__c != oldP.Sonderpreisinfo__c
	            	|| p.Sonderpreis__c != oldP.Sonderpreis__c
	            	|| p.Seminartitel__c != oldP.Seminartitel__c
	            	|| p.Seite__c != oldP.Seite__c
	            	|| p.hauptbereich__c != oldP.hauptbereich__C
	            	|| p.Web_Preis__c != oldP.Web_Preis__c
	            	|| p.Jahr__c != oldP.Jahr__c
	            	|| p.OwnerId != oldP.OwnerId
	            	|| p.Name != oldP.Name
	            	|| p.NEU__c != oldP.NEU__c
	            	|| p.Mehrere_Trainer__c != oldP.Mehrere_Trainer__c
	            	|| p.Max_Teilnehmer__c != oldP.Max_Teilnehmer__c
	            	|| p.Min_Teilnehmer__c != oldP.Min_Teilnehmer__c
	            	|| p.Leitung__c != oldP.Leitung__c
	            	|| p.Key_Note_Speaker__c != oldP.Key_Note_Speaker__c
	            	|| p.Hinweise_f_r_Marketing__c != oldP.Hinweise_f_r_Marketing__c
	            	|| p.Hinweis_bei_Preis__c != oldP.Hinweis_bei_Preis__c
	            	|| p.Englisch__c != oldP.Englisch__c
	            	|| p.Ende__c != oldP.Ende__c
	            	|| p.Dauer_in_Tagen__c != oldP.Dauer_in_Tagen__c
	            	|| p.Bestandteil_Curriculum_Diplom__c != oldP.Bestandteil_Curriculum_Diplom__c
	            	|| p.Beginn__c != oldP.Beginn__c
	            	|| p.Aufbauseminar__c != oldP.Aufbauseminar__c
	            	|| p.Termine_n_chstes_Jahr__c != oldP.Termine_n_chstes_Jahr__c 
	            	|| p.Akademiestudie__c != oldP.Akademiestudie__c
	            	|| p.Anordnung__c != oldP.Anordnung__c
	            	|| p.Bemerkungen_Terminplanung__c != oldP.Bemerkungen_Terminplanung__c
	            	|| p.Beschreibung__c != oldP.Beschreibung__c
	            	|| p.Buch_Logo_Foto__c != oldP.Buch_Logo_Foto__c
	            	|| p.Buchen_deaktivieren__c != oldP.Buchen_deaktivieren__c
	            	|| p.change_frequency__c != oldP.change_frequency__c
	            	|| p.Draft_fuer_Portfolio__c != oldP.Draft_fuer_Portfolio__c
	            	|| p.Englisches_Portfolio__c != oldP.Englisches_Portfolio__c
	            	|| p.Buchbar__c != oldP.Buchbar__c
	            	|| p.Inhouse_Seminar__c != oldP.Inhouse_Seminar__c
	            	|| p.Keywords__c != oldP.Keywords__c
	            	|| p.Live__c != oldP.Live__c
	            	|| p.Meta_Description__c != oldP.Meta_Description__c
	            	|| p.Meta_Keywords__c != oldP.Meta_Keywords__c
	            	|| p.PDF__c != oldP.PDF__c
	            	|| p.priority__c != oldP.priority__c
	            	|| p.Produktmanager__c != oldP.Produktmanager__c
	            	|| p.Reservierungsoption__c != oldP.Reservierungsoption__c
	            	|| p.Seite__c != oldP.Seite__c
	            	|| p.Termine_dieses_Jahr__c != oldP.Termine_dieses_Jahr__c
	            	|| p.URL__c != oldP.URL__c
	            	|| p.Ver_ffentlichung__c != oldP.Ver_ffentlichung__c
	            	){
	            		System.debug('*** STATUS_SEMIFINAL');
	            		p.addError('Wenn der Status eines Seminars im Portfolio auf "Eckdaten verabschiedet" steht, können Sie nur noch die Felder: Zertifikatsinhalte / Methode / Zielgruppe ändern. Bitte wenden Sie sich an die Portfolio-Verantwortliche im Marketing Helga Borkert.');
	            	}
	            }
	        }
	    }
    }
}