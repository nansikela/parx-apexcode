public class ProductPriceHandlerTEST {
	
	static testmethod void autopriceTestMethod(){
		//PROGRAM RECORDTYPE PRODUCT
		String RECORDTYPE_PROGRAM = '012200000004y0dAAA'; //Program
		
		//FAMILIY
		String PRODUCT_BACHELOR = 'Bachelor Programs';
		String PRODUCT_PREPARATORY = 'Preparatory Programs';
		String PRODUCT_MASTER = 'Master Programs';
		String PRODUCT_DIPLOMA = 'Diploma Programs';
		
		//PRICEBOOK ID
		String PRICEBOOK_BACHELOR = '01s200000001RCUAA2';
		String PRICEBOOK_MASTER = '01s200000001RsaAAE';
		String PRICEBOOK_DIPLOMA = '01s200000001RCPAA2';
		
		String MODULEID = '012200000004y0eAAA';
		String MANDATORY = 'Mandatory';
		String STAGE = 'Expressed an interest';
		String CURRENCY_USD = 'USD';
		String CURRENCY_EUR = 'EUR';
		String CURRENCY_CHF = 'CHF';
		
		//program
		String PROGRAMID = '012200000004y0dAAA';
		String PERIOD = '99';
		String LANGUAGE = 'E';
		String OFFER = 'd';
		String FAMILY = 'MHA569';
		String ACADEMIC = '2008-89';
		
		try{
			
			List<Product2> productList = new List<Product2>();
			
			Product2 programBach = new Product2(Name = 'prodxxparx1', RecordTypeId = PROGRAMID, Family = PRODUCT_BACHELOR, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = 'MHA56', Product_Language__c = LANGUAGE, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
			productList.add(programBach);
			
			Product2 programMast = new Product2(Name = 'prodxxparx2', RecordTypeId = PROGRAMID, Family = PRODUCT_MASTER, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = 'MHA88', Product_Language__c = LANGUAGE, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
			productList.add(programMast);
			
			Product2 programDip = new Product2(Name = 'prodxxparx3', RecordTypeId = PROGRAMID, Family = PRODUCT_DIPLOMA, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = 'MHA89', Product_Language__c = LANGUAGE, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
			productList.add(programDip);
			
			Product2 programPrep = new Product2(Name = 'prodxxparx4', RecordTypeId = PROGRAMID, Family = PRODUCT_PREPARATORY, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = 'MHA90', Product_Language__c = LANGUAGE, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
			productList.add(programPrep);
			
			try{
				insert productList;
			}catch(System.DMLException e){
				System.debug('**** Exception occured ' +e);
				System.assert(false);
			}
			
			//check that pricebookentry are created for each product
			//BACHELOR
			List<PricebookEntry> entryBachelorList = [Select p.UseStandardPrice, p.UnitPrice, p.Pricebook2Id, p.IsActive, p.CurrencyIsoCode From PricebookEntry p where p.Pricebook2Id = :PRICEBOOK_BACHELOR and p.Product2Id = :programBach.Id];
			System.assertEquals(entryBachelorList.size(), 3);
			for(PricebookEntry p: entryBachelorList){
				System.assertEquals(p.UnitPrice, 0);
				System.assertEquals(p.IsActive, true);
			}
			
			//PREPARATORY
			List<PricebookEntry> entryPrepList = [Select p.UseStandardPrice, p.UnitPrice, p.Pricebook2Id, p.IsActive, p.CurrencyIsoCode From PricebookEntry p where p.Pricebook2Id = :PRICEBOOK_BACHELOR and p.Product2Id = :programPrep.Id];
			System.assertEquals(entryPrepList.size(), 3);
			for(PricebookEntry p: entryPrepList){
				System.assertEquals(p.UnitPrice, 0);
				System.assertEquals(p.IsActive, true);
			}
			
			
			//MASTER
			List<PricebookEntry> entryMasterList = [Select p.UseStandardPrice, p.UnitPrice, p.Pricebook2Id, p.IsActive, p.CurrencyIsoCode From PricebookEntry p where p.Pricebook2Id = :PRICEBOOK_MASTER and p.Product2Id = :programMast.Id];
			System.assertEquals(entryMasterList.size(), 3);
			for(PricebookEntry p: entryMasterList){
				System.assertEquals(p.UnitPrice, 0);
				System.assertEquals(p.IsActive, true);
			}
			
			
			//DIPLOMA
			List<PricebookEntry> entryDiplomaList = [Select p.UseStandardPrice, p.UnitPrice, p.Pricebook2Id, p.IsActive, p.CurrencyIsoCode From PricebookEntry p where p.Pricebook2Id = :PRICEBOOK_DIPLOMA and p.Product2Id = :programDip.Id];
			System.assertEquals(entryDiplomaList.size(), 3);
			for(PricebookEntry p: entryDiplomaList){
				System.assertEquals(p.UnitPrice, 0);
				System.assertEquals(p.IsActive, true);
			}
			
		}catch(System.Exception e){
			System.debug('**** Exception: ' + e);	
		}	
	}
}