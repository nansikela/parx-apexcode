public class FARegisterController 
{
	public Person__c person {get; set;}
	public List<SelectOption> nachgeordneteFirmaOptions {get; set;}
	public String password {get; set;}
	
	public FARegisterController()
	{
		password = 'Computer123';
		person = new Person__c();
		person.Firma__c = 'a0g20000000Hy2s';
		
		
		nachgeordneteFirmaOptions = new List<SelectOption>();
		nachgeordneteFirmaOptions.add(new SelectOption('', '– ' + Label.none + ' –'));
		for(Firma__c f :[SELECT ID, Name FROM Firma__c WHERE (Dachfirma__c = : person.Firma__c OR ID = :person.Firma__c) AND Live__c = true ORDER BY name])
		{
			nachgeordneteFirmaOptions.add(new SelectOption(String.valueOf(f.id), f.name));
		}
	}
	
	public PageReference save()
	{
		
		
		return new PageReference('/');
	}
	
	public PageReference toStep2()
	{
		
		List<Firma__c> accountList = [SELECT Account__c, eMail_Endung__c, eMail_Endung2__c FROM Firma__c WHERE ID = :person.Nachgeordnete_Firma__c];
		String accountId;
		String eMailEndung;
		String eMailEndung2;
		if(accountList.size()>0)
		{
			accountId = accountList.get(0).Account__c;
			eMailEndung = accountList.get(0).eMail_Endung__c;
			eMailEndung2 = accountList.get(0).eMail_Endung2__c;
		}
		System.debug('person:'+person);
		if(!(person.email__c.endsWith(eMailEndung) || (eMailEndung2!= null && person.email__c.endsWith(eMailEndung2))))
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.akademie_booking_please_correct_email);
	        ApexPages.addMessage(msg);
			return null;
		}
		
		
		
		List<Contact> contactList = [SELECT ID From Contact WHERE eMail = :person.Email__c AND AccountId = :accountId];
		Contact contact;
		if(contactList.isEmpty())
		{
			contact = new Contact();
		}else{
			contact = contactList.get(0);
		}
		contact.salutation = person.Anrede__c;
		contact.Title = person.Titel__c;
		contact.AccountId = accountId;
		contact.LastName = person.Name;
		contact.FirstName = person.Vorname__c;
		contact.Email = person.Email__c;
		contact.Department = person.Abteilung__c;
		contact.Phone = person.Telefon__c;
		
		upsert contact;
		person.Kontakt__c = contact.id;
		person.RecordTypeId = '01220000000Q2Ve';
		
		insert person;
		
		return new PageReference('https://die-akademie.secure.force.com/firmenakademie/FARegisterStep2?token='+contact.id);
	}
	
	
	
	
	
	
	static testMethod void testRegistration() {
			FARegisterController controller = new FARegisterController();
			controller.person.Anrede__c = 'Herr';
			controller.person.Name = 'Deckert';
			controller.person.Vorname__c = 'Christian';
			controller.person.eMail__c = 'c.deckert@efowifhowerlfkjwlefrgujhfaskl.de';
			controller.person.Nachgeordnete_Firma__c = 'a0g20000000Hy2s';
			
			controller.toStep2();
			
	}
}