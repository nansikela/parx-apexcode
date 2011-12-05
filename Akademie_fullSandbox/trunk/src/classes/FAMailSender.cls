public class FAMailSender {
	
	
	private static String getFooter()
	{
		String text = '';
		text+= 'Mit freundlichen Grüssen\n';
		text+= 'Ihre Vossloh Akademie';
		return text;
	}
	
	
	
	
	//Send Vossloh registration eMail
	public static void sendRegistrationMail(User user)
	{
		Messaging.SingleEmailMessage registrationMail = FAHelper.getNewMailFromAkademie(user.email);
		List<String>emailListe = new List<String>();
		eMailListe.add(user.eMail);
		registrationMail.setToAddresses(eMailListe);
        registrationMail.setSubject('Anmeldung Vossloh Firmenakademie');
        String registrationMailBody = '';
        
        if(user.anrede__c =='Herr')
        {
        	registrationMailBody+='Sehr geehrter Herr '+user.Lastname+',\n';
        }else if(user.anrede__c == 'Frau')
        {
        	registrationMailBody+='Sehr geehrte Frau '+user.Lastname+',\n';
        }
        registrationMailBody+='\n';
        registrationMailBody+='vielen Dank für Ihre Registrierung im Weiterbildungsportal der Vossloh AG. Wir freuen uns, dass Sie sich für das Schulungsangebot der Vossloh Akademie interessieren und hoffe, Sie bei Ihrer persönlichen Entwicklung jederzeit bestmöglich unterstützen zu können.\n\n';
        registrationMailBody+= 'Bitte bestätigen Sie Ihre Registrierung im Webportal der Vossloh Akademie mit diesem Link:\n\n';
        registrationMailBody+= 'http://www.vossloh.die-akademie.de/FaRegisterConfirm?id='+user.id+'\n\n';
        registrationMailBody+='Im Webportal der Vossloh Akademie haben Sie nicht nur die Möglichkeit, sich über das aktuelle Seminarangebot zu informieren, Sie können sich auch nach Rücksprache mit Ihrem Vorgesetzten direkt und komfortabel zu einem Seminar anmelden. Hier finden Sie auch einen Überblick über unsere Services und Antworten auf häufig gestellte Fragen rund um die Vossloh Akademie. Zum Beispiel zur Stornierung eines Seminars, die Sie ebenfalls im Portal vornehmen können. Bitte beachten Sie, dass dabei gegebenenfalls Stornokosten anfallen können.\n\n';
		registrationMailBody+= 'Sollten Sie darüber hinaus noch Fragen oder Anregungen zur Akademie haben, stehe ich Ihnen jederzeit zur Verfügung.\n\n';
		registrationMailBody+= getFooter();
		registrationMail.setPlainTextBody(registrationMailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { registrationMail });
	}
	
	
	
	
	//EMails bei Seminarbestellung
	/*WORKAROUND OK*/
	public static void sendWarenkorbBestaetigung()
	{
		System.debug('*****sendWarenkorbBestaetigung:Start');
		//eMail to Teilnehmer
		Messaging.SingleEmailMessage bestellbestaetigungTeilnehmer = FAHelper.getNewMailFromAkademie(FAHelper.getCurrentPerson().eMail__c);
		String bestellbestaetigungBody = '';
		
		
		if(FAHelper.getCurrentPerson().anrede__c =='Herr')
        {
        	bestellbestaetigungBody+='Sehr geehrter Herr '+FAHelper.getCurrentPerson().name+',\n';
        }else if(FAHelper.getCurrentPerson().anrede__c == 'Frau')
        {
        	bestellbestaetigungBody+='Sehr geehrte Frau '+FAHelper.getCurrentPerson().name+',\n';
        }
        bestellbestaetigungBody+='\n\n';
        //BESTÄTIGUNGSPORZESS MIT VORGESEZTER
        if(FAHelper.getCurrentPerson().Genehmigungsverfahren_ausgeschlossen__c == null || FAHelper.getCurrentPerson().Genehmigungsverfahren_ausgeschlossen__c == false)
        {
        	bestellbestaetigungBody+='vielen Dank für Ihr Interesse am unten aufgeführten Seminar. Damit haben Sie Ihre Seminarbuchung in die Wege geleitet. Ihr Vorgesetzter wurde soeben per Email über Ihre Anfrage informiert, die er per Link bestätigen muss. Nach dieser Zustimmung durch Ihren Vorgesetzten erhalten Sie eine verbindliche Anmeldebestätigung.\n\n';
        	bestellbestaetigungBody+='Geht Ihnen diese Anmeldebestätigung nicht innerhalb der nächsten Tage zu, bitten wir Sie, sich direkt mit Ihrem Vorgesetzten in Verbindung zu setzen und den Anmeldestatus zu klären.\n\n';
        }else // WENN NICHT TEIL DES APPROVAL PROZESS
        {
        	bestellbestaetigungBody+='vielen Dank für Ihr Interesse an dem Angebot der Vossloh Akademie. In Kürze erhalten Sie Ihre verbindliche Anmeldebestätigung zum unten aufgeführten Seminar.\n\n';
        }
        for(FASeminar seminar: Warenkorb.getInstance().getWarenkorbElement())
        {
        	bestellbestaetigungBody+='Termin: '+seminar.Datum+', '+seminar.ort+'\n';
        	bestellbestaetigungBody+= 'Titel: ' +seminar.titel+'\n';
        	bestellbestaetigungBody+= 'Preis: '+seminar.preis+' EUR\n\n';
        	if(seminar.isHotelReservierung)
    		{
    			bestellbestaetigungBody+= 'Hotel: '+seminar.hotelName+' \n';
    			bestellbestaetigungBody+= 'Anreise: '+seminar.anreise+' \n';
    			bestellbestaetigungBody+= 'Anreise: '+seminar.abreise+' \n';
    			if(seminar.ezReservierung)
    			{
    				bestellbestaetigungBody+= 'EZ '+seminar.ezPreis+' p. N. \n';
    			}
    			if(seminar.dzReservierung)
    			{
    				bestellbestaetigungBody+= 'DZ '+seminar.dzPreis+' p. N. \n';
    			}
    		}
        }
        
        bestellbestaetigungBody+= '\n\n'+getFooter();
        
        bestellbestaetigungTeilnehmer.setSubject('Ihre Bestellung Vossloh Akademie');
        
		bestellbestaetigungTeilnehmer.setPlainTextBody(bestellbestaetigungBody);
		
		
		//eMail to Vorgesetzter
		if(FAHelper.getCurrentPerson().Genehmigungsverfahren_ausgeschlossen__c == null || FAHelper.getCurrentPerson().Genehmigungsverfahren_ausgeschlossen__c == false)
		{
			Messaging.SingleEmailMessage bestellbestaetigungVorgesetzter = FAHelper.getNewMailFromAkademie(FAHelper.getCurrentPerson().eMail_Adresse_Vorgesetzter__c);
			String bestellbestaetigungBodyVorgesetzter ='';
			
			bestellbestaetigungBodyVorgesetzter += 'Guten Tag,\n\n';
			if(FAHelper.getCurrentPerson().anrede__c =='Herr')
	        {
	        	bestellbestaetigungBodyVorgesetzter+='Ihr Mitarbeiter Herr '+FAHelper.getCurrentPerson().name+'';
	        }else if(FAHelper.getCurrentPerson().anrede__c == 'Frau')
	        {
	        	bestellbestaetigungBodyVorgesetzter+='Ihre Mitarbeiterin Frau '+FAHelper.getCurrentPerson().name+'';
	        }
	        bestellbestaetigungBodyVorgesetzter+= ' hat sich zum unten aufgeführten Seminar der Vossloh Akademie angemeldet.';
	        
	        bestellbestaetigungBodyVorgesetzter+='\n\n';
	        for(FASeminar seminar: Warenkorb.getInstance().getWarenkorbElement())
	        {
	        	bestellbestaetigungBodyVorgesetzter+='Termin: '+seminar.Datum+', '+seminar.ort+'\n';
	        	bestellbestaetigungBodyVorgesetzter+= 'Titel: ' +seminar.titel+'\n';
	        	bestellbestaetigungBodyVorgesetzter+= 'Preis: '+seminar.preis+' EUR\n\n';
	        	if(seminar.isHotelReservierung)
	    		{
	    			bestellbestaetigungBodyVorgesetzter+= 'Hotel: '+seminar.hotelName+' \n';
	    			bestellbestaetigungBodyVorgesetzter+= 'Anreise: '+seminar.anreise+' \n';
	    			bestellbestaetigungBodyVorgesetzter+= 'Anreise: '+seminar.abreise+' \n';
	    			if(seminar.ezReservierung)
	    			{
	    				bestellbestaetigungBodyVorgesetzter+= 'EZ '+seminar.ezPreis+' p. N. \n';
	    			}
	    			if(seminar.dzReservierung)
	    			{
	    				bestellbestaetigungBodyVorgesetzter+= 'DZ '+seminar.dzPreis+' p. N. \n';
	    			}
	    		}
	        }
	        bestellbestaetigungBodyVorgesetzter+= 'Bitte klicken Sie auf den nachfolgenden Link, um das Seminar zu bestätigen oder abzulehnen:\n';
			bestellbestaetigungBodyVorgesetzter+= 'http://www.vossloh.die-akademie.de/FAApproval?token='+Warenkorb.getInstance().warenkorb.id;
	        bestellbestaetigungBodyVorgesetzter+= '\n\n\n';
	        bestellbestaetigungBodyVorgesetzter+= 'Wir empfehlen Ihnen, im Anschluss das Gespräch mit Ihrem Mitarbeiter zu suchen, um Ihre Entscheidungsfindung transparent zu gestalten und die Akzeptanz dafür zu erhöhen.\n\n';
	        bestellbestaetigungBodyVorgesetzter+= 'Bitte beachten Sie, dass Sie Ihre Entscheidung über diesen Link rückwirkend nicht ändern können. Wenden Sie sich in diesem Fall direkt an rvochezer@die-akademie.de';
	        bestellbestaetigungBodyVorgesetzter+= '\n\n';
	        bestellbestaetigungBodyVorgesetzter+= 'Wir danken für Ihre Unterstützung.\n\n';
	        bestellbestaetigungBodyVorgesetzter+= getFooter();
	        
	        bestellbestaetigungVorgesetzter.setSubject('Bestellung Ihres Mitarbeiters in der Vossloh Akademie');
			bestellbestaetigungVorgesetzter.setPlainTextBody(bestellbestaetigungBodyVorgesetzter);
			
			
			System.debug('****EMailVersand TEILNEHMER:'+bestellbestaetigungTeilnehmer);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { bestellbestaetigungTeilnehmer, bestellbestaetigungVorgesetzter });
		}
		else
		{
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { bestellbestaetigungTeilnehmer });
		}
		
		
	}
	/*WORKAROUND OK*/
	public static void sendApprovalFromVorgesetzter(List<FASeminar>seminarList, Warenkorb__c warenkorb)
	{
		
		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
		
		for(FASeminar seminar: seminarList)
		{
			Messaging.SingleEmailMessage approvaleMail = FAHelper.getNewMailFromAkademie(warenkorb.person__r.eMail__c);
			String approvaleMailBody = '';
			
			if(warenkorb.person__r.anrede__c =='Herr')
	        {
	        	approvaleMailBody+='Sehr geehrter Herr '+warenkorb.person__r.name+',\n\n';
	        }else if(warenkorb.person__r.anrede__c == 'Frau')
	        {
	        	approvaleMailBody+='Sehr geehrte Frau '+warenkorb.person__r.name+',\n\n';
	        }
			approvaleMailBody+='Sie haben sich im Weiterbildungsportal der Vossloh AG zum folgenden Seminar angemeldet.\n';
			approvaleMailBody+='Termin: '+seminar.Datum+', '+seminar.ort+'\n';
    		approvaleMailBody+= 'Titel: ' +seminar.titel+'\n';
    		approvaleMailBody+= 'Preis: '+seminar.preis+' \n';
    		if(seminar.isHotelReservierung)
    		{
    			approvaleMailBody+= 'Hotel: '+seminar.hotelName+' \n';
    			approvaleMailBody+= 'Anreise: '+seminar.anreise+' \n';
    			approvaleMailBody+= 'Anreise: '+seminar.abreise+' \n';
    			if(seminar.ezReservierung)
    			{
    				approvaleMailBody+= 'EZ '+seminar.ezPreis+' p. N. \n';
    			}
    			if(seminar.dzReservierung)
    			{
    				approvaleMailBody+= 'DZ '+seminar.dzPreis+' p. N. \n';
    			}
    		}
    		approvaleMailBody+= '\n\n';
			if(seminar.statusCode == 300)
			{
        		approvaleMailBody+= 'Ihr Vorgesetzter hat dieser Anmeldung zugestimmt und damit Ihre Teilnahme bestätigt.\n Sie erhalten rechtzeitig vor Seminarbeginn noch eine Einladung mit weiteren Informationen, wie z.B. Seminarzeiten und Anreise. Für weitere Fragen zum Seminar stehen wir Ihnen auch vorab gerne zur Verfügung.\n\n';
				approvaleMail.setSubject('Approval-Bestätigung - Vossloh Akademie');
			}
			else
			{
				approvaleMailBody+= 'Ihr Vorgesetzter hat die an ihn weitergeleitete Anmeldung leider nicht bestätigt und damit Ihre Teilnahme am Seminar abgelehnt. Bitte klären Sie die Gründe dafür sofern nicht schon geschehen mit ihm persönlich. Wenn Sie dabei Unterstützung wünschen, wenden Sie sich jederzeit an Ihre zuständige Personalabteilung oder den Konzernbetriebsratvorsitzenden.\n\n';
				approvaleMail.setSubject('Ablehnung Ihrer Seminarbestellung - Vossloh Akademie');
			}
			
			approvaleMailBody+= getFooter();
			
			
			approvaleMail.setPlainTextBody(approvaleMailBody);
			
			messages.add(approvaleMail);
			
		}
		System.debug('*********MAILS:'+messages);
        Messaging.sendEmail(messages);
        
	}
	 public static void sendStorno()
  {
    
  }
	public static void sendStorno(Warenkorb_Element__c w)
	{
		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
		
		//EMail an Teilnehmer
		Messaging.SingleEmailMessage approvaleMail = FAHelper.getNewMailFromAkademie(FAHelper.getCurrentPerson().eMail__c);
		String approvaleMailBody = '';
		
		
		if(FAHelper.getCurrentPerson().anrede__c =='Herr')
        {
        	approvaleMailBody+='Sehr geehrter Herr '+FAHelper.getCurrentPerson().name+',\n\n';
        }else if(FAHelper.getCurrentPerson().anrede__c == 'Frau')
        {
        	approvaleMailBody+='Sehr geehrte Frau '+FAHelper.getCurrentPerson().name+',\n\n';
        }
		approvaleMailBody+='Sie haben im Weiterbildungsportal der Vossloh AG das folgende, von Ihnen bereits gebuchte Seminar storniert.\n';
		approvaleMailBody+='Termin: '+w.SeminarBeginn__c.format()+' - '+w.Seminarende__c.format()+'\n';
		approvaleMailBody+= 'Titel: ' +w.portfolio__r.Seminartitel__c+'\n';
		if(w.Portfolio__r.Inhouse_Seminar__c != null && w.Portfolio__r.Inhouse_Seminar__c)
		{
			approvaleMailBody+= 'Preis: '+w.portfolio__r.web_Preis__c+'EUR \n';
		}
		approvaleMailBody+= 'Grund: ' +w.stornogrund__c+'';
		if(w.Anderer_Stornogrund__c!= null)
		{
			approvaleMailBody+= ' ' +w.Anderer_Stornogrund__c+'\n';
		}
		
		approvaleMailBody+= '\n\n';
		
		if(w.Portfolio__r.Inhouse_Seminar__c == null || w.Portfolio__r.Inhouse_Seminar__c == false)
		{
			if(w.SeminarBeginn__c>=Date.today().addDays(4*7))
			{
				approvaleMailBody+= 'Da die Stornierung mehr als 4 Wochen vor Seminarbeginn erfolgt ist, fällt nur eine Bearbeitungsgebühr von 125,00€ an. Wir hoffen, Sie bei einem der kommenden Seminare als Teilnehmer begrüßen zu dürfen.\n\n';
			}
			else 
			{
				approvaleMailBody+= 'Da die Stornierung innerhalb einer Frist von 4 Wochen vor Seminarbeginn erfolgt ist, werden Ihnen 100% der Seminarkosten in Rechnung gestellt. Das entsprich einer Summer von '+w.portfolio__r.web_Preis__c+' € Wir hoffen, Sie bei einem der kommenden Seminare als Teilnehmer begrüßen zu dürfen.\n\n';
			}
		}
		else
		{
			if(w.SeminarBeginn__c>=Date.today().addDays(2*7))
			{
				approvaleMailBody+= 'Da die Stornierung mehr als 2 Wochen vor Seminarbeginn erfolgt ist, fallen keine Stornokosten an. Wir hoffen, Sie bei einem der kommenden Seminare als Teilnehmer begrüßen zu dürfen.\n\n';
			}
			else 
			{
				approvaleMailBody+= 'Da die Stornierung innerhalb einer Frist von 2 Wochen vor Seminarbeginn erfolgt ist, werden Ihnen die tatsächlichen Seminarkosten anteilig in Rechnung gestellt. Wir hoffen, Sie bei einem der kommenden Seminare als Teilnehmer begrüßen zu dürfen.\n\n';
			}
		}
		approvaleMail.setSubject('Stornierung Ihrer Seminarbestellung - Vossloh Akademie');
		approvaleMailBody+= getFooter();
		approvaleMail.setPlainTextBody(approvaleMailBody);
		messages.add(approvaleMail);
		
		
		//EMail an Vorgesetzen
		Messaging.SingleEmailMessage approvaleMailVorgesetzter = FAHelper.getNewMailFromAkademie(FAHelper.getCurrentPerson().eMail_Adresse_Vorgesetzter__c);
		approvaleMailBody = '';
		
		
		approvaleMailBody += 'Guten Tag,\n\n';
		if(FAHelper.getCurrentPerson().anrede__c =='Herr')
        {
        	approvaleMailBody+='Ihr Mitarbeiter Herr '+FAHelper.getCurrentPerson().name+' ';
        }else if(FAHelper.getCurrentPerson().anrede__c == 'Frau')
        {
        	approvaleMailBody+='Ihre Mitarbeiterin Frau '+FAHelper.getCurrentPerson().name+' ';
        }
		approvaleMailBody+='hat das folgende, von Ihm gebuchte und durch Sie bereits bestätigte Seminar storniert.\n\n';
		approvaleMailBody+='Termin: '+w.SeminarBeginn__c.format()+' - '+w.Seminarende__c.format()+'\n';
		approvaleMailBody+= 'Titel: ' +w.portfolio__r.Seminartitel__c+'\n';
		
		if(w.Portfolio__r.Inhouse_Seminar__c != null && w.Portfolio__r.Inhouse_Seminar__c)
		{
			approvaleMailBody+= 'Preis: '+w.portfolio__r.web_Preis__c+'EUR \n';
		}
		approvaleMailBody+= 'Grund: ' +w.stornogrund__c+'';
		if(w.Anderer_Stornogrund__c!= null)
		{
			approvaleMailBody+= ' ' +w.Anderer_Stornogrund__c+'\n';
		}
		
		approvaleMailBody+= '\n\n';
		
		if(w.Portfolio__r.Inhouse_Seminar__c == null || w.Portfolio__r.Inhouse_Seminar__c == false)
		{
			if(w.SeminarBeginn__c>=Date.today().addDays(4*7))
			{
				approvaleMailBody+= 'Da die Stornierung mehr als 4 Wochen vor Seminarbeginn erfolgt ist, fällt nur eine Bearbeitungsgebühr von 125,00€ an. \n\n';
			}
			else 
			{
				approvaleMailBody+= 'Da die Stornierung innerhalb einer Frist von 4 Wochen vor Seminarbeginn erfolgt ist, werden 100% der Seminarkosten in Rechnung gestellt. Das entsprich einer Summer von '+w.portfolio__r.web_Preis__c+' €\n\n';
			}
		}
		else
		{
			if(w.SeminarBeginn__c>=Date.today().addDays(2*7))
			{
				approvaleMailBody+= 'Da die Stornierung mehr als 2 Wochen vor Seminarbeginn erfolgt ist, fallen keine Stornokosten an.\n\n';
			}
			else 
			{
				approvaleMailBody+= 'Da die Stornierung innerhalb einer Frist von 2 Wochen vor Seminarbeginn erfolgt ist, werden die tatsächlichen Seminarkosten anteilig in Rechnung gestellt.\n\n';
			}
		}
		approvaleMailVorgesetzter.setSubject('Stornierung Ihrer Seminarbestellung - Vossloh Akademie');
		approvaleMailBody+= getFooter();
		approvaleMailVorgesetzter.setPlainTextBody(approvaleMailBody);
		messages.add(approvaleMailVorgesetzter);
		Messaging.sendEmail(messages);
		
	}
	
	
	static testMethod void testMain() {
		Warenkorb_Element__c w = [SELECT Id, warenkorb__r.person__r.Benutzer__c,warenkorb__r.person__r.Benutzer__r.id FROM Warenkorb_Element__c WHERE warenkorb__r.person__r.Benutzer__c != null LIMIT 1];
		Warenkorb__c warenkorb = [SELECT Id, person__r.eMail__c FROM Warenkorb__c WHERE Id=:w.Warenkorb__c];
		User u = [SELECT Id, Anrede__c, Email, LastName, Firstname FROM USER WHERE ID=:w.warenkorb__r.person__r.Benutzer__c];
		System.runAs(u){
			w = [SELECT Id, warenkorb__r.person__r.Benutzer__c,warenkorb__r.person__r.Benutzer__r.id, SeminarBeginn__c, Seminarende__c, 
				Portfolio__r.Inhouse_Seminar__c, Anderer_Stornogrund__c,
				portfolio__r.Seminartitel__c, portfolio__r.web_Preis__c,
				stornogrund__c
				FROM Warenkorb_Element__c WHERE warenkorb__r.person__r.Benutzer__c != null LIMIT 1];
			warenkorb = [SELECT Id, person__r.eMail__c, person__r.anrede__c, person__r.name FROM Warenkorb__c WHERE Id=:w.Warenkorb__c];
			FASeminar fas=new FASeminar();
			list<FASeminar> faslist = new list<FASeminar>();
			faslist.add(fas);
			sendRegistrationMail(u);
			sendWarenkorbBestaetigung();
			sendApprovalFromVorgesetzter(faslist,warenkorb);
			sendStorno();
			sendStorno(w);
		}
	}
}