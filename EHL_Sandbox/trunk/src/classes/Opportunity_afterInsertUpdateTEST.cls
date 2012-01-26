public class Opportunity_afterInsertUpdateTEST {
	
	
	static testmethod void oppCreateContractTestmethod(){
		String BACHELOR_ID = '012200000004nPAAAY';
		
		String STAGE = 'Expressed an interest';
		
		String OPPORTUNITY_STAGE = 'Contract';
		String OPPORTUNITY_CONSULTINGLHC_ID = '0122000000052OhAAI';
		
		String LHC_CONTRACT_ID = '0122000000052OmAAI';
		
		String CONTRACT_STATUS = 'Delivery';
	
		try{
			
			Account a = new Account(Name = 'Test AG');
			
			try{
				insert a;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			List<Contact> contactList = new List<Contact>();
			Contact c = new Contact(AccountId = a.Id, Lastname = 'Muster', Firstname = 'Max');
			
			try{
				insert c;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			List<Opportunity> oppList = new List<Opportunity>();
			Opportunity oppBac = new Opportunity(Name = 'Opp Test 1', RecordTypeId = BACHELOR_ID, Contact_Student__c = c.Id, AccountId = a.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			oppList.add(oppBac);
			Opportunity oppLHC1 = new Opportunity(Name = 'Opp Test 2', RecordTypeId = OPPORTUNITY_CONSULTINGLHC_ID, Contact_Student__c = c.Id, AccountId = a.Id, StageName = OPPORTUNITY_STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			oppList.add(oppLHC1);
			Opportunity oppLHC2 = new Opportunity(Name = 'Opp Test 3', RecordTypeId = OPPORTUNITY_CONSULTINGLHC_ID, Contact_Student__c = c.Id, AccountId = a.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			oppList.add(oppLHC2);

			try{
				insert oppList;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			//check that for opp oppLHC1 a contract was created
			List<Contract> contractList = [Select c.Status, c.Contact_Student__c, c.AccountId From Contract c where Opportunity__c = :oppLHC1.Id];
			if(!contractList.isEmpty()){
				Contract con = contractList[0];
				System.assertEquals(con.Status, CONTRACT_STATUS);
				System.assertEquals(con.Contact_Student__c, c.Id);
				System.assertEquals(con.Status, CONTRACT_STATUS);
				System.assertEquals(con.AccountId, a.Id);
			}else{
				System.assert(false);	
			}
			
			//change status to "Contract", no contract should be added because recordtype = bachelor
			oppBac.StageName = OPPORTUNITY_STAGE;
			try{
				update oppBac;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			contractList = [Select c.Id From Contract c where Opportunity__c = :oppBac.Id];
			System.assert(contractList.isEmpty());
			
			//change status to "Contract", contract should be added because recordtype = LHC Consulting
			oppLHC2.StageName = OPPORTUNITY_STAGE;
			try{
				update oppLHC2;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			contractList = [Select c.Status, c.Contact_Student__c, c.AccountId From Contract c where Opportunity__c = :oppLHC2.Id];
			if(!contractList.isEmpty()){
				Contract con = contractList[0];
				System.assertEquals(con.Status, CONTRACT_STATUS);
				System.assertEquals(con.Contact_Student__c, c.Id);
				System.assertEquals(con.Status, CONTRACT_STATUS);
				System.assertEquals(con.AccountId, a.Id);
			}else{
				System.assert(false);	
			}
		}catch(System.Exception e){
			System.debug('**** Final Exception: ' + e);	
		}	
	}
}