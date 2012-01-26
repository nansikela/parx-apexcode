public class OpportunityLineItem_afterInsertTEST {
	
	
	static testmethod void oppLineItemRenameTestMethod(){
		String OPP_BACHELOR_ID = '012200000004nPAAAY';
		String MASTER_ID = '0122000000052fsAAA';
		String DIPLOMA_ID = '0122000000057DyAAI';
		String EXECUTIVE_EDUCATION_ID = '0122000000059stAAA'; //LIVE
		//String EXECUTIVE_EDUCATION_ID = '012S00000000EqWIAU'; //SANDBOX
	
		String FUNDRAISING_ID = '012200000004nOzAAI';
		
		String MODULEID = '012200000004y0eAAA';
		String MANDATORY = 'Mandatory';
		String STAGE = 'Expressed an interest';
		String CURRENCY_USD = 'USD';
		String CURRENCY_EUR = 'EUR';
		String CURRENCY_CHF = 'CHF';
		
		//program
		String PROGRAMID = '012200000004y0dAAA';
		String PERIOD = '1';
		String LINE = 'MHA';
		String LANGUAGE = 'E';
		String LANGUAGE2 = 'F';
		String OFFER = 'a';
		String FAMILY = 'MHA';
		String ACADEMIC = '2008-2009';
		String PRODUCT_TYPE = 'Master Programs';
		
		try{
			List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
			
			Pricebook2 pricebook = [Select p.Id from Pricebook2 p where IsStandard = true limit 1];
				
			
			Account a = new Account(Name = 'Test AG ');
			insert a;
			
			Contact c = new Contact(AccountId = a.Id, Lastname = 'MUSTER', Firstname = 'Max');
	        insert c;  
			
			List<Opportunity> oppList = new List<Opportunity>();
			
			Opportunity oFund = new Opportunity(Contact_Student__c = c.Id, Name = 'Opp Test', RecordTypeId = FUNDRAISING_ID, AccountId = a.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30), Pricebook2Id = pricebook.Id, CurrencyIsoCode = CURRENCY_USD);
			insert oFund;
			
			Opportunity obac = new Opportunity(Contact_Student__c = c.Id, Name = 'Opp Test', RecordTypeId = OPP_BACHELOR_ID, AccountId = a.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30), Pricebook2Id = pricebook.Id, CurrencyIsoCode = CURRENCY_USD);
			oppList.add(obac);
			
			Opportunity omas = new Opportunity(Contact_Student__c = c.Id, Name = 'Opp Test', RecordTypeId = MASTER_ID, AccountId = a.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30), Pricebook2Id = pricebook.Id, CurrencyIsoCode = CURRENCY_USD);
			oppList.add(omas);
			
			Opportunity odip = new Opportunity(Contact_Student__c = c.Id, Name = 'Opp Test', RecordTypeId = DIPLOMA_ID, AccountId = a.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30), Pricebook2Id = pricebook.Id, CurrencyIsoCode = CURRENCY_USD);
			oppList.add(odip);
			
			Opportunity oee = new Opportunity(Contact_Student__c = c.Id, Name = 'Opp Test', RecordTypeId = EXECUTIVE_EDUCATION_ID, AccountId = a.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30), Pricebook2Id = pricebook.Id, CurrencyIsoCode = CURRENCY_USD);
			oppList.add(oee);
			
			insert oppList;
			
			//check that opp has not renamed --> is fundraising
			Opportunity oret = [Select o.Name from Opportunity o where o.Id = :oFund.Id];
			System.assertEquals(oret.Name, 'Opp Test');
			
			//check that opp has renamed
			String bacName = '';
			String masName = '';
			String dipName = '';
			String eeName = '';
			List<Opportunity> oppRenamedList = [Select o.Name, o.RecordTypeId from Opportunity o where o.Id in :oppList];
			for(Opportunity oppNew : oppRenamedList){
				
				System.assertNotEquals(oppNew.Name, 'Opp Test');
				if(oppNew.RecordTypeId == OPP_BACHELOR_ID){
					bacName = oppNew.Name;
				}else if(oppNew.RecordTypeId == MASTER_ID){
					masName = oppNew.Name;
				}else if(oppNew.RecordTypeId == DIPLOMA_ID){
					dipName = oppNew.Name;
				}else{
					eeName = oppNew.Name;
				}
			}

			List<Product2> productList = [Select p.Id from Product2 p where p.Product_Line__c = :LINE and Product_Period__c = :PERIOD and Product_Language__c = :LANGUAGE and Academic_Period__c = :ACADEMIC and Offer_ID__c = :OFFER and RecordTypeId = :PROGRAMID];
			Product2 program;
			if(!productList.isEmpty()){
				program = productList[0];
			}else{
				program = new Product2(Name = 'override', RecordTypeId = PROGRAMID, Family = PRODUCT_TYPE, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = LINE, Product_Language__c = LANGUAGE, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
		
			
				try{
					insert program;
				}catch(System.DMLException e){
					System.debug('**** Exception occured ' +e);
					System.assert(false);
				}
				
			}
			
			Product2 module1 = new Product2(Name = 'Module 1', RecordTypeId = MODULEID, Mandatory_Elective__c = MANDATORY, Product_Relation__c = program.Id);
			insert module1;
			
			Product2 module2 = new Product2(Name = 'Module 1', RecordTypeId = MODULEID, Mandatory_Elective__c = MANDATORY, Product_Relation__c = program.Id);
			insert module2;
			
			PricebookEntry entryProgram;
			List<PricebookEntry> productEntryList = [Select p.Id from PricebookEntry p where p.Product2Id = :program.Id and p.Pricebook2Id = :pricebook.Id and p.CurrencyIsoCode = :CURRENCY_USD];
			if(!productEntryList.isEmpty()){
				entryProgram = productEntryList[0];
			}else{
				entryProgram = new PricebookEntry(UnitPrice  = 100, Product2Id = program.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_USD);
				try{
					insert entryProgram;
				}catch(System.DMLException e){
					System.debug('**** Exception occured ' +e);
					System.assert(false);
				}
			}
			
			PricebookEntry entryModule1 = new PricebookEntry(UnitPrice  = 50, Product2Id = module1.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_USD);
			pricebookEntryList.add(entryModule1);
		
			
			PricebookEntry entryModule2 = new PricebookEntry(UnitPrice  = 50, Product2Id = module2.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_USD);
			pricebookEntryList.add(entryModule2);
			
			//should be ignored, not in USD -->CHF
			PricebookEntry entryModuleCHF = new PricebookEntry(UnitPrice  = 75, Product2Id = module2.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_CHF);
			pricebookEntryList.add(entryModuleCHF);
		
			//should be ignored, not USD --> EUR
			PricebookEntry entryModuleEUR = new PricebookEntry(UnitPrice  = 25, Product2Id = module2.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_EUR);
			pricebookEntryList.add(entryModuleEUR);
			
			insert pricebookEntryList;
			
			//add new opplineitem to master
			OpportunityLineItem oppLineItem1 = new OpportunityLineItem(TotalPrice = 100, Quantity = 1, PricebookEntryId = entryProgram.Id, OpportunityId = oFund.Id);
			try{
				insert oppLineItem1;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			//add new opplineitem to bachelor, diploma, master and ee
			List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
			
			OpportunityLineItem oppLineItemBac = new OpportunityLineItem(TotalPrice = 100, Quantity = 1, PricebookEntryId = entryProgram.Id, OpportunityId = obac.Id);
			oppLineItemList.add(oppLineItemBac);
			
			OpportunityLineItem oppLineItemMas = new OpportunityLineItem(TotalPrice = 100, Quantity = 1, PricebookEntryId = entryProgram.Id, OpportunityId = omas.Id);
			oppLineItemList.add(oppLineItemMas);
			
			OpportunityLineItem oppLineItemDip = new OpportunityLineItem(TotalPrice = 100, Quantity = 1, PricebookEntryId = entryProgram.Id, OpportunityId = odip.Id);
			oppLineItemList.add(oppLineItemDip);
			
			OpportunityLineItem oppLineItemEE = new OpportunityLineItem(TotalPrice = 100, Quantity = 1, PricebookEntryId = entryProgram.Id, OpportunityId = oee.Id);
			oppLineItemList.add(oppLineItemEE);
			
			try{
				insert oppLineItemList;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			//check that opp has renamed
			oppRenamedList = [Select o.Name, o.RecordTypeId, o.Product_Name_for_Contract__c from Opportunity o where o.Id in :oppList];
			for(Opportunity oppRenamed : oppRenamedList){
				if(oppRenamed.RecordTypeId == OPP_BACHELOR_ID){
					System.assertNotEquals(bacName, oppRenamed.Name);
				}else if(oppRenamed.RecordTypeId == MASTER_ID){
					System.assertNotEquals(masName, oppRenamed.Name);
				}else if(oppRenamed.RecordTypeId == DIPLOMA_ID){
					System.assertNotEquals(dipName, oppRenamed.Name);
				}else{
					System.assertNotEquals(eeName, oppRenamed.Name);
				}
				//check that prodcut name for contract is filled out
				System.assertNotEquals(oppRenamed.Product_Name_for_Contract__c, null);
			}
			
		}catch(System.Exception e){
			System.debug('**** Exception: ' + e);	
		}	
	}
	
	
	static testmethod void oppLineItemAttachProgramTestMethod(){
		String OPP_BACHELOR_ID = '012200000004nPAAAY';
		String MASTER_ID = '0122000000052fsAAA';
		String DIPLOMA_ID = '0122000000057DyAAI';
		String EXECUTIVE_EDUCATION_ID = '0122000000059stAAA'; //LIVE
		//String EXECUTIVE_EDUCATION_ID = '012S00000000EqWIAU'; //SANDBOX
	
		String FUNDRAISING_ID = '012200000004nOzAAI';
		
		String MODULEID = '012200000004y0eAAA';
		String MANDATORY = 'Mandatory';
		String STAGE = 'Expressed an interest';
		String CURRENCY_USD = 'USD';
		String CURRENCY_EUR = 'EUR';
		String CURRENCY_CHF = 'CHF';
		
		//program
		String PROGRAMID = '012200000004y0dAAA';
		String PERIOD = '1';
		String LINE = 'MHA';
		String LANGUAGE = 'E';
		String LANGUAGE2 = 'F';
		String OFFER = 'a';
		String FAMILY = 'MHA';
		String ACADEMIC = '2008-2009';
		String PRODUCT_TYPE = 'Master Programs';
		
		try{
			List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
			
			Pricebook2 pricebook = [Select p.Id from Pricebook2 p where IsStandard = true limit 1];
				
			
			Account a = new Account(Name = 'Test AG ');
			insert a;
			
			Contact c = new Contact(AccountId = a.Id, Lastname = 'MUSTER', Firstname = 'Max');
	        insert c;  
			
			List<Opportunity> oppList = new List<Opportunity>();
			
			Opportunity oFund = new Opportunity(Contact_Student__c = c.Id, Name = 'Opp Test', RecordTypeId = FUNDRAISING_ID, AccountId = a.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30), Pricebook2Id = pricebook.Id, CurrencyIsoCode = CURRENCY_USD);
			insert oFund;
			
			Opportunity obac = new Opportunity(Contact_Student__c = c.Id, Name = 'Opp Test', RecordTypeId = OPP_BACHELOR_ID, AccountId = a.Id, StageName = STAGE, CloseDate = Date.newInstance(2010, 1, 30), Pricebook2Id = pricebook.Id, CurrencyIsoCode = CURRENCY_USD);
			oppList.add(obac);
			
			insert oppList;
			
			

			List<Product2> productList = [Select p.Id from Product2 p where p.Product_Line__c = :LINE and Product_Period__c = :PERIOD and Product_Language__c = :LANGUAGE and Academic_Period__c = :ACADEMIC and Offer_ID__c = :OFFER and RecordTypeId = :PROGRAMID];
			Product2 program;
			if(!productList.isEmpty()){
				program = productList[0];
			}else{
				program = new Product2(Name = 'override', RecordTypeId = PROGRAMID, Family = PRODUCT_TYPE, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = LINE, Product_Language__c = LANGUAGE, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
		
			
				try{
					insert program;
				}catch(System.DMLException e){
					System.debug('**** Exception occured ' +e);
					System.assert(false);
				}
				
			}
			
			Product2 module1 = new Product2(Name = 'Module 1', RecordTypeId = MODULEID, Mandatory_Elective__c = MANDATORY, Product_Relation__c = program.Id);
			insert module1;
			
			Product2 module2 = new Product2(Name = 'Module 1', RecordTypeId = MODULEID, Mandatory_Elective__c = MANDATORY, Product_Relation__c = program.Id);
			insert module2;
			
			PricebookEntry entryProgram;
			List<PricebookEntry> productEntryList = [Select p.Id from PricebookEntry p where p.Product2Id = :program.Id and p.Pricebook2Id = :pricebook.Id and p.CurrencyIsoCode = :CURRENCY_USD];
			if(!productEntryList.isEmpty()){
				entryProgram = productEntryList[0];
			}else{
				entryProgram = new PricebookEntry(UnitPrice  = 100, Product2Id = program.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_USD);
				try{
					insert entryProgram;
				}catch(System.DMLException e){
					System.debug('**** Exception occured ' +e);
					System.assert(false);
				}
			}
			
			PricebookEntry entryModule1 = new PricebookEntry(UnitPrice  = 50, Product2Id = module1.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_USD);
			pricebookEntryList.add(entryModule1);
		
			
			PricebookEntry entryModule2 = new PricebookEntry(UnitPrice  = 50, Product2Id = module2.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_USD);
			pricebookEntryList.add(entryModule2);
			
			//should be ignored, not in USD -->CHF
			PricebookEntry entryModuleCHF = new PricebookEntry(UnitPrice  = 75, Product2Id = module2.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_CHF);
			pricebookEntryList.add(entryModuleCHF);
		
			//should be ignored, not USD --> EUR
			PricebookEntry entryModuleEUR = new PricebookEntry(UnitPrice  = 25, Product2Id = module2.Id, Pricebook2Id = pricebook.Id, UseStandardPrice = false, IsActive = true, CurrencyIsoCode = CURRENCY_EUR);
			pricebookEntryList.add(entryModuleEUR);
			
			insert pricebookEntryList;
			
			//add new opplineitem to oFund --> module 1
			OpportunityLineItem oppLineItem1 = new OpportunityLineItem(TotalPrice = 100, Quantity = 1, PricebookEntryId = entryModule1.Id, OpportunityId = oFund.Id);
			try{
				insert oppLineItem1;
			}catch(System.DMLException e){
				System.debug('**** Exception: ' + e);
				System.assert(false);
			}
			
			//check that corresponding program is also attached
			List<OpportunityLineItem> olList = [Select o.Id, o.PricebookEntryId from OpportunityLineItem o where o.OpportunityId = :oFund.Id];
			
			System.assertEquals(olList.size(), 2);
			System.assert((olList[0].PricebookEntryId == entryModule1.Id) || (olList[0].PricebookEntryId == entryProgram.Id)); 
			System.assert((olList[1].PricebookEntryId == entryModule1.Id) || (olList[1].PricebookEntryId == entryProgram.Id));	 	
			
			
		
		}catch(System.Exception e){
			System.debug('**** Exception: ' + e);	
		}	
	}
}