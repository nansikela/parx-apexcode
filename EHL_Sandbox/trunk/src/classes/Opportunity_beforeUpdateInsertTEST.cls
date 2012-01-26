public class Opportunity_beforeUpdateInsertTEST {
	
	static testmethod void oppContactAccountTestmethod(){
		String BACHELOR_ID = '012200000004nPAAAY';
		String MASTER_ID = '0122000000052fsAAA';
		String DIPLOMA_ID = '0122000000057DyAAI';
		String EXECUTIVE_EDUCATION_ID = '0122000000059stAAA'; //LIVE
		//String EXECUTIVE_EDUCATION_ID = '012S00000000EqWIAU'; //SANDBOX
		
		String FUNDRAISING_ID = '012200000004nOzAAI';
		String STAGE = 'Expressed an interest';
		try{
			
			Account a1 = new Account(Name = 'Test AG 1');
			Account a2 = new Account(Name = 'Test AG 2');
			
			try{
				insert a1;
				insert a2;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			List<Contact> contactList = new List<Contact>();
			Contact c1 = new Contact(AccountId = a1.Id, Lastname = 'Muster1', Firstname = 'Max1');
			contactList.add(c1);
			Contact c11 = new Contact(AccountId = a1.Id, Lastname = 'Muster11', Firstname = 'Max11');
			contactList.add(c11);
			Contact c2 = new Contact(AccountId = a2.Id, Lastname = 'Muster2', Firstname = 'Max2');
			contactList.add(c2);
		
			try{
				insert contactList;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			List<Opportunity> oppList = new List<Opportunity>();
			Opportunity oppBac = new Opportunity(Name = 'Opp Test', RecordTypeId = BACHELOR_ID, Contact_Student__c = c2.Id, AccountId = a1.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			oppList.add(oppBac);
			Opportunity oppMas = new Opportunity(Name = 'Opp Test', RecordTypeId = MASTER_ID, Contact_Student__c = c2.Id, AccountId = a1.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			oppList.add(oppMas);
			Opportunity oppDip = new Opportunity(Name = 'Opp Test', RecordTypeId = DIPLOMA_ID, Contact_Student__c = c2.Id, AccountId = a1.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			oppList.add(oppDip);
			Opportunity oppEE = new Opportunity(Name = 'Opp Test', RecordTypeId = EXECUTIVE_EDUCATION_ID, Contact_Student__c = c2.Id, AccountId = a1.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			oppList.add(oppEE);
			try{
				insert oppList;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			//check that opportunity has account from contact c2 attached and name is set
			List<Opportunity> renamedOppList = [Select o.AccountId, Name From Opportunity o where o.Id in :oppList];               
            if(!renamedOppList.isEmpty()){
            	for(Opportunity opp : renamedOppList){
	                System.assertEquals(opp.AccountId, a2.Id);
	                System.assertEquals(opp.Name, 'Max2 Muster2: -');
            	}
            }else{
                System.assert(false);
            }
            
            //update opp, check that account and name has changed
            oppBac.Contact_Student__c = c1.Id;
            try{
				update oppBac;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			renamedOppList = [Select o.Name, o.AccountId From Opportunity o where o.Id = :oppBac.Id];               
            if(!renamedOppList.isEmpty()){
                System.assertEquals(renamedOppList[0].AccountId, a1.Id);
                System.assertEquals(renamedOppList[0].Name, 'Max1 Muster1: -');
            }else{
                System.assert(false);
            }
            
            
            //test that if not bachelor, than nothing happens
            Opportunity oppFund = new Opportunity(Name = 'Opp Test', RecordTypeId = FUNDRAISING_ID, Contact_Student__c = c2.Id, AccountId = a1.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			try{
				insert oppFund;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
		
			renamedOppList = [Select o.Name, o.AccountId, o.Contact_Student__c From Opportunity o where o.Id = :oppFund.Id];               
            if(!renamedOppList.isEmpty()){
                System.assertEquals(renamedOppList[0].AccountId, a1.Id);
                System.assertEquals(renamedOppList[0].Contact_Student__c, c2.Id);
                System.assertEquals(renamedOppList[0].Name, 'Opp Test');
            }else{
                System.assert(false);
            }
		}catch(System.Exception e){
			System.debug('**** Final Exception: ' + e);	
		}	
	}
}