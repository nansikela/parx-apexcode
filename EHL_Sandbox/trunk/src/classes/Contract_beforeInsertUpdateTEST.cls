public class Contract_beforeInsertUpdateTEST {
	
	static testmethod void contractStudentTestmethod(){
		String BACHELOR_ID = '012200000004nPAAAY';
		String FUNDRAISING_ID = '012200000004nOzAAI';
		
		String INTERNSHIP_CONTRACT_RECORDTYPE = '012200000004uOmAAI';
		String STATUS = 'Posted';
		
		String STAGE = 'Expressed an interest';
		try{
			
			Account a1 = new Account(Name = 'Test AG 1');
			
			try{
				insert a1;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			List<Contact> contactList = new List<Contact>();
			Contact c1 = new Contact(AccountId = a1.Id, Lastname = 'MUSTER1', Firstname = 'Max1');
			contactList.add(c1);
			Contact c2 = new Contact(AccountId = a1.Id, Lastname = 'MUSTER2', Firstname = 'Max2');
			contactList.add(c2);
			Contact c3 = new Contact(AccountId = a1.Id, Lastname = 'MUSTER3', Firstname = 'Max3');
			contactList.add(c3);
		
			try{
				insert contactList;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			
			Opportunity o1 = new Opportunity(Name = 'Opp Test 1', RecordTypeId = BACHELOR_ID, Contact_Student__c = c2.Id, AccountId = a1.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			Opportunity o2 = new Opportunity(Name = 'Opp Test 2', RecordTypeId = BACHELOR_ID, Contact_Student__c = c1.Id, AccountId = a1.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30));
			
			try{
				insert o1;
				insert o2;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			//create new contract
			Contract con1 = new Contract(Opportunity__c = o1.Id, RecordTypeId = INTERNSHIP_CONTRACT_RECORDTYPE, AccountId = a1.Id, Status = STATUS);
			try{
				insert con1;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			
			//check that contract has c2 as student
			List<Contract> conList = [Select c.Contact_Student__c From Contract c where c.Id = :con1.Id];               
            if(!conList.isEmpty()){
                System.assertEquals(conList[0].Contact_Student__c, c2.Id);
            }else{
                System.assert(false);
            }
            
            
            //update contract with new opportunity
            con1.Opportunity__c = o2.Id;
            try{
				update con1;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			//check that contract student has changed to c1
			conList = [Select c.Contact_Student__c From Contract c where c.Id = :con1.Id];    
			System.debug('***** C1 '+ c1.Id + ', c2 ' + c2.Id + ', student ' + conList[0].Contact_Student__c);          
            if(!conList.isEmpty()){
                System.assertEquals(conList[0].Contact_Student__c, c1.Id);
            }else{
                System.assert(false);
            }
        }catch(System.Exception e){
			System.debug('**** Final Exception: ' + e);	
		}	
	}
}