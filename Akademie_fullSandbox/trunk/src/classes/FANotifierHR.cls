global class FANotifierHR implements Schedulable{
	global void execute(SchedulableContext SC) 
	{
		
		notify();
	
	}
	
	
	public static void notify()
	{
		Map<Id, FirmaNewWarenkorbElement> existingWarenkorbElementMap = new Map<Id, FirmaNewWarenkorbElement>();
		
		List<Warenkorb_Element__c> warenkorbElementsForUpdate = new List<Warenkorb_Element__c>();
		for(Warenkorb_Element__c w: [Select w.Warenkorb__r.Person__c, w.ort__c, w.Warenkorb__r.Person__r.name, w.Warenkorb__r.Person__r.vorname__c, w.Warenkorb__r.Person__r.Nachgeordnete_Firma__c, w.Warenkorb__c, w.Status_Text__c, w.Seminarende__c, w.Seminarbeginn__c, w.Portfolio__r.Web_Preis__c, w.Portfolio__r.Seminartitel__c, w.Portfolio__c, w.LastModifiedDate, w.Information_an_HR__c, w.Hotelreservierung__c, w.Einzelzimmer__c, w.EZ_Preis__c, w.Doppelzimmer__c, w.DZ_Preis__c, w.CreatedDate, w.Anreise__c, w.Abreise__c From Warenkorb_Element__c w WHERE Status_Code__c >100 AND (Information_an_HR__c = null OR (w.LastModifiedDate>:Date.today().addDays(-5))) LIMIT 1000])
		{
			//IF Warenkorb Element is valid
			if(w.Warenkorb__c!= null && w.Warenkorb__r.Person__c!= null && w.Warenkorb__r.Person__r.Nachgeordnete_Firma__c!= null && (w.Information_an_HR__c == null || w.LastModifiedDate>w.Information_an_HR__c))
			{
				//IF Element is new
				if(!existingWarenkorbElementMap.containsKey(w.Warenkorb__r.Person__r.Nachgeordnete_Firma__c))
				{
					existingWarenkorbElementMap.put(w.Warenkorb__r.Person__r.Nachgeordnete_Firma__c, new FirmaNewWarenkorbElement());
					
				}
				existingWarenkorbElementMap.get(w.Warenkorb__r.Person__r.Nachgeordnete_Firma__c).add(w);
				w.Information_an_HR__c = Datetime.now().addMinutes(2);
				warenkorbElementsForUpdate.add(w);
			}
		}
		//eMail Messages
		Messaging.MassEmailMessage masseMails = new Messaging.MassEmailMessage();
		
		
		
		
		//Get HR People
		Map<Id, Person__c> personaler = new Map<Id, Person__c>();
		List<Messaging.SingleEmailMessage > eMailList = new List<Messaging.SingleEmailMessage >();
		
		for(Person__c p : [SELECT ID, eMail__c, Personaler_Firma__c FROM Person__c WHERE Personaler_Firma__c != null])
		{
			if(existingWarenkorbElementMap.size()> 0 && (existingWarenkorbElementMap.containsKey(p.Personaler_Firma__c) || p.Personaler_Firma__c =='a0g20000000Hy2s')) // Vossloh HauptFirma
			{
				String plainMessage = 'Guten Tag\n';
				plainMessage+= 'Es wurden folgende Statusänderungen festgestellt:\n';
				
				if(p.Personaler_Firma__c =='a0g20000000Hy2s') // Vossloh HauptFirma
				{
					
					//Add All Messages for head personaler
					for(FirmaNewWarenkorbElement warenkorbnewElement : existingWarenkorbElementMap.values())
					{
						plainMessage+= warenkorbnewElement.getMessage();
					}
				}
				else
				{
					plainMessage+=existingWarenkorbElementMap.get(p.Personaler_Firma__c).getMessage();
				}
				plainMessage+='Für weitere Informationen melden Sie sich unter www.vossloh.die-akademie.de an und rufen Sie www.vossloh.die-akademie.de/report auf.';
				Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
				mail.setSubject('Neue Bestellungen - Status Änderungen auf Ihrer Weiterbildungsplattform');
				mail.setReplyTo('rvochezer@die-akademie.de');
				mail.setPlainTextBody(plainMessage);
				mail.setToAddresses(new String[] {p.eMail__c});
				eMailList.add(mail);
			}
		}
		
		if(eMailList.size()>0)
		{
			Messaging.sendEmail(eMailList);
		}
		
		
		
		//update warenkorbElements in eMails
		if(warenkorbElementsForUpdate.size()>0)
		{
			update warenkorbElementsForUpdate;
		}
	}
	
	
	
	
	
	
	
	class FirmaNewWarenkorbElement
	{
		String firmaId {get; set;}
		List<String> messageList {get; set;}
		
		FirmaNewWarenkorbElement()
		{
			messageList = new List<String>();
		}
		public void add(String message)
		{
			messageList.add(message);
		}
		public void add (Warenkorb_Element__c w)
		{
			String message = '';
			message+= w.portfolio__r.seminarTitel__c+'\n';
			if(w.seminarbeginn__c!= null && w.seminarende__c!= null)
			{
				message+= w.seminarbeginn__c.format()+' - '+w.seminarende__c.format()+', '+w.ort__c+'\n';
			}
			message+= 'Teilnehmer: '+w.Warenkorb__r.Person__r.name+' '+w.Warenkorb__r.Person__r.Vorname__c+'\n';
			message+= w.portfolio__r.web_Preis__c+'\n';
			//Hotelreservierung
			if(w.Hotelreservierung__c!= null && w.Hotelreservierung__c)
			{
				if(w.anreise__c!= null && w.abreise__c != null)
				{
					message+= 'Es wurde ein Hotelzimmer reserviert: '+w.anreise__c.format()+' - '+w.abreise__c.format();
				}
				
				if(w.Einzelzimmer__c!= null && w.Einzelzimmer__c)
				{
					message+= ' EZ PREIS: '+w.EZ_Preis__c;
				}
				if(w.Doppelzimmer__c!= null && w.Doppelzimmer__c)
				{
					message+= ' DZ PREIS:'+w.DZ_Preis__c;
				}
				message+= '\n';
			}
			
			message+= 'Status: '+w.status_Text__c;
			
			add(message);
		}
		public String getMessage()
		{
			String fullMessage = '';
			for(String message : messageList)
			{
				fullMessage+= message+'\n\n';
			}
			
			return fullMessage;
		}
	}
	
	static testMethod void myUnitTest() {
		notify();
	}
}