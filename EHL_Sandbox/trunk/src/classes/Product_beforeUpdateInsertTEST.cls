public class Product_beforeUpdateInsertTEST {
	static testMethod void productNameTestMethod(){
		
		Integer i = 0;
		String PERIOD = '1';
		String LINE = 'MHA';
		String LANGUAGE = 'E';
		String LANGUAGE2 = 'F';
		String OFFER = 'a';
		String FAMILY = 'MHA';
		String ACADEMIC = '2008-2009';
		String PRODUCT_TYPE = 'Master Programs';
		String RECORDTYPE = '012200000004y0dAAA'; //Program
		
		String PRODUCTCUSTOM_NORENAME = 'AGAP - tbd';
		
		String PRODUCT_TYPE2 = 'Master Programs';
		Product2 p;
		Product2 p3;
		
		List<Product2> productList = [Select p.Id from Product2 p where p.Product_Line__c = :LINE and Product_Period__c = :PERIOD and Product_Language__c = :LANGUAGE and Academic_Period__c = :ACADEMIC and Offer_ID__c = :OFFER and RecordTypeId = :RECORDTYPE];

		if(!productList.isEmpty()){
			p = productList[0];
		}else{
			p = new Product2(Name = 'override', RecordTypeId = RECORDTYPE, Family = PRODUCT_TYPE, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = LINE, Product_Language__c = LANGUAGE, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
	
		
			try{
				insert p;
			}catch(System.DMLException e){
				System.debug('**** Exception occured ' +e);
				System.assert(false);
			}
			
		}
		
		//should create error, product already exist
		Product2 p2 = new Product2(Name = 'override', RecordTypeId = RECORDTYPE, Family = PRODUCT_TYPE, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = LINE, Product_Language__c = LANGUAGE, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
		try{
			insert p2;
			System.assert(false);
		}catch(System.DMLException e){
			System.debug('**** Exception, should occur ' +e);
		}
		
		//************************* REMOVE AFTER IMPORT
		//no renaming because family set to special value
		Product2 p10 = new Product2(Name = 'nooverride', RecordTypeId = RECORDTYPE, Family = PRODUCT_TYPE, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = LINE, Product_Language__c = LANGUAGE, Product_Family_custom__c = PRODUCTCUSTOM_NORENAME, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
		try{
			insert p10;
		}catch(System.DMLException e){
			System.debug('**** Exception, should occur ' +e);
			System.assert(false);
		}
		productList = [Select p.Name from Product2 p where p.Id = :p10.Id];
		System.assertEquals(productList[0].Name, 'nooverride');
		//************************* REMOVE AFTER IMPORT'
		
		
		//other language
		productList = [Select p.Id from Product2 p where p.Product_Line__c = :LINE and Product_Period__c = :PERIOD and Product_Language__c = :LANGUAGE2 and Academic_Period__c = :ACADEMIC and Offer_ID__c = :OFFER and RecordTypeId = :RECORDTYPE];
		
		if(!productList.isEmpty()){
			p3 = productList[0];
		}else{
			p3 = new Product2(Name = 'override', RecordTypeId = RECORDTYPE, Family = PRODUCT_TYPE, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = LINE, Product_Language__c = LANGUAGE2, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
		
			try{
				insert p3;
			}catch(System.DMLException e){
				System.debug('**** Exception occured ' +e);
				System.assert(false);
			}
		}
		
		//update language, should not work because already product exist
		p3.Product_Language__c = LANGUAGE;
		try{
			update p3;
			System.assert(false);
		}catch(System.DMLException e){
			System.debug('**** Exception, should occur ' +e);
		}
		
		
		//not a valid conifugration, should be able to insert
		PERIOD = '4';
		LINE = 'DHR';
		OFFER = 'b';
		FAMILY = 'BSC';
		ACADEMIC = '2008-2009';
		PRODUCT_TYPE = 'Preparatory Programs';
		
		productList = [Select p.Id from Product2 p where p.Product_Line__c = :LINE and Product_Period__c = :PERIOD and Product_Language__c = :LANGUAGE and Academic_Period__c = :ACADEMIC and Offer_ID__c = :OFFER and RecordTypeId = :RECORDTYPE];
		Product2 p4;
		
		if(!productList.isEmpty()){
			p4 = productList[0];
		}else{
			p4 = new Product2(Name = 'override', RecordTypeId = RECORDTYPE, Family = PRODUCT_TYPE, Start_Date__c = Date.newInstance(2009,01,25), Product_Period__c = PERIOD, Product_Line__c = LINE, Product_Language__c = LANGUAGE, Product_Family_custom__c = FAMILY, Offer_ID__c = OFFER, End_Date__c = Date.newInstance(2010,06,01), Academic_Period__c = ACADEMIC);
			
			try{
				insert p4;
			}catch(System.DMLException e){
				System.debug('**** Exception occured ' +e);
				System.assert(false);
			}
			
		}
	}
	
}