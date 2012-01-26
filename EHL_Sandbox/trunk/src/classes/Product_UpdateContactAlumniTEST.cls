public class Product_UpdateContactAlumniTEST {

	
	static testMethod void productUpdateContactTEST(){
		String programOPP = '012200000004nPAAAY';
		
		Account a = new Account(Name = 'Test AG');
		insert a;
		
		Contact c1 = new Contact(LastName = 'Test', AccountId = a.Id);
		insert c1;
		
		Opportunity opp = new Opportunity(AccountId = a.Id, Name = 'TestOpp', RecordTypeId = programOPP, CloseDate = Date.newInstance(2008,12,31), StageName = 'Invite for interview');
		insert opp;
		
		OpportunityContactRole oppContact = new OpportunityContactRole(Role = 'Student', ContactId = c1.Id, OpportunityId = opp.Id);
		insert oppContact;
		
		
		Product2 prod1 = new Product2(Product_Line__c = 'WP', Module__c = '12', Offer_No__c = '2', Start_Date__c = Date.newInstance(2010,08,15), Alumni__c = true);
		insert prod1;
		
		//get standard pricebook
		Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
		
		PricebookEntry pricebookEntry = new PricebookEntry(UnitPrice = 15, Product2Id = prod1.Id, Pricebook2Id = stdPb.Id,isActive=true, UseStandardPrice =  false);
		insert pricebookEntry;
		
		
		OpportunityLineItem oppLine = new OpportunityLineItem(UnitPrice = 15, Quantity = 1, OpportunityId = opp.Id, PricebookEntryId = pricebookEntry.Id);	
		insert oppLine;
		
		
		System.debug('+++++++++ update product');
		prod1.Has_reached_End_Date__c = true;
		update prod1;
		
		
		Contact updatedContact = [Select c.Alumni__c, c.Contact_Categorie__c from Contact c where c.Id = :c1.Id];
	
		System.assertEquals(updatedContact.Contact_Categorie__c,'Alumni');
		
	}
}