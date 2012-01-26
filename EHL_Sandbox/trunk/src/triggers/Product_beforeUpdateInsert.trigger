trigger Product_beforeUpdateInsert on Product2 (before insert, before update) {
	//autoname and uniqness validation on product name --> only for program

	String RECORDTYPE_PROGRAM = '012200000004y0dAAA'; //Program
	
	String PRODUCTCUSTOM_NORENAME = 'AGAP - tbd';

	String ERROR_MSG = 'This product already exists';
	
	List<String> productNameList = new List<String>();
	
	//autonaming for Program product (except if product family  has value PRODUCTCUSTOM_NORENAME)
	for(Product2 p : Trigger.new){	
		//if(p.RecordTypeId == RECORDTYPE_PROGRAM){
		//************************* REMOVE AFTER IMPORT	
		if(p.RecordTypeId == RECORDTYPE_PROGRAM && p.Product_Family_custom__c!= PRODUCTCUSTOM_NORENAME){
			
			String productName = '';
			if(p.Product_Line__c != null){
				productName += p.Product_Line__c;
			}else{
				productName += '-';
			}
			
			if(p.Product_Period__c != null){
				productName += ' ' + p.Product_Period__c;
			}else{
				productName += ' -';
			}
			
			if(p.Product_Language__c != null){
				productName += ' ' + p.Product_Language__c;
			}else{
				productName += ' -';
			}
			
			if(p.Academic_Period__c != null){
				productName += ' ' + p.Academic_Period__c;
			}else{
				productName += ' -';
			}
			
			if(p.Offer_ID__c != null){
				productName += ' ' + p.Offer_ID__c;
			}else{
				productName += ' -';
			}
			
			//set name
			if(Trigger.isUpdate){
				//check if name changed
				if(p.Name != productName){
					p.Name = productName;
				}
			}else{
				p.Name = productName;
			}
		}
	}
	
	
	for(Product2 pp : Trigger.new){
		productNameList.add(pp.Name);
	}
	
	//select products with same name
	List<Product2> productList = [Select p.Name From Product2 p where p.Name in :productNameList and p.RecordTypeId = :RECORDTYPE_PROGRAM and p.Id not in :Trigger.new];
	
	for(Product2 p : Trigger.new){	
		
		//check that no other product with this name already exist
		Boolean hasDuplicate = false;
		Integer counter = 0;
		//first check if in inserted or updated city is duplicate
		System.debug('***** ProductName ' + p.Name);
		for(Product2 inTrigger : Trigger.new){
			if(inTrigger.Name == p.Name){
				counter ++;
			}
			if(counter > 1){
				hasDuplicate = true;
				break;	
			}
		}
		
		if(! hasDuplicate){
			for(Product2 pAll: productList){
				if(pAll.Name == p.Name){
					hasDuplicate = true;
					break;
				}
			}
		}
		System.debug('**** hasDuplicate ' +hasDuplicate);
		
		if(hasDuplicate){
			p.addError(ERROR_MSG);
		}
	
	}
}