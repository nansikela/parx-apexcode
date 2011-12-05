public class FARegisterConfirmController 
{
	public Person__c currentPerson {get;set;}
	
	public FARegisterConfirmController()
	{
		List<User> userList = [SELECT ID, ContactId FROM User WHERE ID = : WebURLEncoder.decodeParam('id')];
		if(userList.size()>0)
		{
			User currentUser = userList.get(0);
			List<Person__c> personen = [SELECT ID, eMail_Adresse_Vorgesetzter__c, Genehmigungsverfahren_ausgeschlossen__c, benutzer__c FROM Person__c WHERE Kontakt__c = : currentUser.ContactId];
			if(personen.size()>0)
			{
				currentPerson = personen.get(0);
			}
		}
	}
	
	public PageReference save()
	{
		
		currentPerson.benutzer__c = WebURLEncoder.decodeParam('id');
		if(currentPerson.Genehmigungsverfahren_ausgeschlossen__c!= null && currentPerson.Genehmigungsverfahren_ausgeschlossen__c)
		{
			currentPerson.Genehmigungsverfahren_ausgeschlossen__c = false;
		}
		else
		{
			currentPerson.Genehmigungsverfahren_ausgeschlossen__c = true;
		}
		
		if(!currentPerson.Genehmigungsverfahren_ausgeschlossen__c && currentPerson.eMail_Adresse_Vorgesetzter__c == null)
		{
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.akademie_booking_please_enter_email_of_supervisor);
        	ApexPages.addMessage(msg);
            return null;
		}
		
		update currentPerson;
		return new PageReference('/FARegisterConfirm2');
	}
	
}