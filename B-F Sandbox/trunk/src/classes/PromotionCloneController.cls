public class PromotionCloneController {
	
	public class DTO {
		public Integer position {get;set;}
		public Promotion__c record {get;set;}
		
		public DTO(Integer pos, Promotion__c rec) {
			this.position = pos;
			this.record = rec;
		}
	}
	
	public Promotion__c promotion {get;set;}
	public list<DTO> targetAccounts {get;set;}
	
	
	public PromotionCloneController(ApexPages.StandardController ctrl) {
		
		promotion = (Promotion__c) Database.query(getCreatableFieldsSOQL('Promotion__c', 'ID = \''+ctrl.getRecord().Id+'\''));
		resetList();
		
		if(promotion == null)
			throwError(null, 'Record not found!');
	}
	
	private void resetList() {
		targetAccounts = new list<DTO>();
		addAccount();
	}
	
	public void addAccount() {
		DTO dto = new DTO(targetAccounts.size()+1, promotion.clone(false, true));
		dto.record.Account__c = null;
		targetAccounts.add(dto);
	}
	
	public Integer getAmountOfAccounts() {
		return targetAccounts.size();
	}
	
	public PageReference save() {
		Savepoint sp = Database.setSavepoint();
		Boolean errorOccurs = false;
		
		list<Promotion__c> allPromotions = cloneAndReturnAllPromotions(sp);
		if(allPromotions == null || allPromotions.size() == 0) {
			throwError(sp, 'Cloning promotions failed!');
			return null;
		}
		
		//if(!insertAllPromotionResults(sp, allPromotions))
		//	return null;
		
		if(!insertAllPromotionMaterialItems(sp, allPromotions))
			return null;
			
		//if(!insertAllPromotionGoals(sp, allPromotions))
		//	return null;
		
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Cloning process completed!'));
		resetList();
		return null;
	}
	
	/*
	private Boolean insertAllPromotionResults(SavePoint sp, list<Promotion__c> allPromotions) {
		
		list<Promotion_Result__c> promotion_results = Database.query(getCreatableFieldsSOQL('Promotion_Result__c', 'Promotion__c = \'' + promotion.ID + '\''));
		list<Promotion_Result__c> duplicates = new list<Promotion_Result__c>();
		
		for(DTO dto : targetAccounts)
			for(Promotion_Result__c promotion_result : promotion_results) {
				Promotion_Result__c newRecord = promotion_result.clone(false, true);
				newRecord.Promotion__c = dto.record.ID;
				duplicates.add(newRecord);
			}
		
		try {
			if(duplicates.size() > 0)
				insert duplicates;
		} catch ( Exception e ) { throwError(sp, e.getMessage()); }
		 	 
		return true; 
	}
	*/
	
	private Boolean insertAllPromotionMaterialItems(SavePoint sp, list<Promotion__c> allPromotions) {
		list<Promotion_Material_Item__c> promotion_material_items = Database.query(getCreatableFieldsSOQL('Promotion_Material_Item__c', 'Promotion__c = \'' + promotion.ID + '\''));
		list<Promotion_Material_Item__c> duplicates = new list<Promotion_Material_Item__c>();
		
		for(DTO dto : targetAccounts)
			for(Promotion_Material_Item__c promotion_material_item : promotion_material_items) {
				Promotion_Material_Item__c newRecord = promotion_material_item.clone(false, true);
				newRecord.Promotion__c = dto.record.ID;
				duplicates.add(newRecord);
			}
		
		try {
			if(duplicates.size() > 0)
				insert duplicates;
		} catch(Exception e) { throwError(sp, e.getMessage()); }
		
		return true;
	}
	
	/*
	private Boolean insertAllPromotionGoals(SavePoint sp, list<Promotion__c> allPromotions) {
		list<Promotion_Goal__c> promotion_goals = Database.query(getCreatableFieldsSOQL('Promotion_Goal__c', 'Promotion__c = \'' + promotion.ID + '\''));
		list<Promotion_Goal__c> duplicates = new list<Promotion_Goal__c>();
		
		for(DTO dto : targetAccounts)
			for(Promotion_Goal__c promotion_goal : promotion_goals) {
				Promotion_Goal__c newRecord = promotion_goal.clone(false, true);
				newRecord.Promotion__c = dto.record.ID;
				duplicates.add(newRecord);
			}
		
		try {
			if(duplicates.size() > 0)
				insert duplicates;	
		} catch(Exception e) { throwError(sp, e.getMessage()); }
		
		return true;
	}
	*/
	
	private list<Promotion__c> cloneAndReturnAllPromotions(SavePoint sp) {
		
		list<Promotion__c> allPromotions = new list<Promotion__c>();
		
		try {
			for(DTO dto : targetAccounts)
				allPromotions.add(dto.record);
		
			insert allPromotions;
		} catch( Exception e ) { return null; }
		return allPromotions;
	}
	
	public Boolean throwError(SavePoint sp, String msg) {
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
		
		if(sp != null)
			Database.rollback(sp);
			
		return false;
	}
	
	private string getCreatableFieldsSOQL(String objectName, String whereClause){

        String selects = '';
 
        if (whereClause == null || whereClause == '') { return null; }
 		
 		Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
 
        if (fMap != null) {
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()) { // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
 
        if (!selectFields.isEmpty()) {
            for (string s:selectFields) {
                selects += s + ',';
            }
            
            if (selects.endsWith(',')) { selects = selects.substring(0,selects.lastIndexOf(',')); }
        }
 
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
    }
   
    public static testMethod void MainTest(){
    	
    	/* 	The complete input domain is divided in following characteristics:
    		-  First test case contains an account with only one promotion records that contians none material item.
    		-  Second test case presents a native case with one account containing a promotion with one material item.
    		-  Third test case covers all other cases which contains a promotion with more than one material item.
    	*/
    	
    	UnitTestUtilities testRecords = new UnitTestUtilities();
    	ApexPages.StandardController stdCtrl;
    	PromotionCloneController ctrl;
    	list<Promotion__c> promotions;
    	list<Promotion_Material_Item__c> promotionitems;
    	Promotion__c originalRecord; 
    	Integer recordAmount = 0;
    	set<ID> allPromotionIDs;
    	
    	//First test case
    	stdCtrl = new ApexPages.StandardController(testRecords.promotion1);
    	ctrl = new PromotionCloneController(stdCtrl);
		originalRecord = (Promotion__c) stdCtrl.getRecord();
		
		//Check if there is an starting row available and assign 
		recordAmount = ctrl.getAmountOfAccounts();
		System.assertEquals(recordAmount, 1);
		ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = testRecords.account2.ID;
		
		ctrl.addAccount();
		ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = testRecords.account3.ID;
		recordAmount = ctrl.getAmountOfAccounts();
		System.assertEquals(recordAmount, 2);
		
		ctrl.save();
		
		//Check if there are 3 records (original and 2 duplicates) available
		promotions = [Select Id, Name, Account__c From Promotion__c Where Name LIKE :originalRecord.Name];
		System.assertEquals(promotions.size(), 3);
		//Note: UnitTest for content of Promotion__c record is not necessary, because the apex deepclone-mechanism is used.
		
		
		
		//Second test case
		stdCtrl = new ApexPages.StandardController(testRecords.promotion2);
    	ctrl = new PromotionCloneController(stdCtrl);
    	originalRecord = (Promotion__c) stdCtrl.getRecord();
		
    	//Check if there is an starting row available and assign
    	System.assertEquals(ctrl.getAmountOfAccounts(), 1);
		ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = testRecords.account1.ID;
		
		ctrl.addAccount();
		ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = testRecords.account3.ID;
		System.assertEquals(ctrl.getAmountOfAccounts(), 2);
		
		ctrl.save();
		
		//Check if there are 3 records (original and 2 duplicates) available
		promotions = [Select Id, Name, Account__c From Promotion__c Where Name LIKE :originalRecord.Name];
		System.assertEquals(promotions.size(), 3);
		//Note: UnitTest for content of Promotion__c record is not necessary, because the apex deepclone-mechanism is used,
		//but a check referring children and lookups are necessary. 
		
		allPromotionIDs = new set<ID>();
		
		for(Promotion__c promotion : promotions)
			if(!allPromotionIDs.contains(promotion.ID))	
				allPromotionIDs.add(promotion.ID);
		
		promotionitems = [Select ID, Name, Product__c From Promotion_Material_Item__c Where Promotion__c IN :allPromotionIDs];		
		
		
		System.assertEquals(promotionitems.size(), 3);
    	
    	
    	
		//Third test case
		stdCtrl = new ApexPages.StandardController(testRecords.promotion3);
    	ctrl = new PromotionCloneController(stdCtrl);
    	
    	//Check if there is an starting row available and assign 
    	System.assertEquals(ctrl.getAmountOfAccounts(), 1);
		ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = testRecords.account1.ID;
		
		ctrl.addAccount();
		ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = testRecords.account2.ID;
		System.assertEquals(ctrl.getAmountOfAccounts(), 2);
		
		ctrl.save();
		
		System.assertEquals(ctrl.getAmountOfAccounts(), 1);
		
		//Check if there are 3 records (original and 2 duplicates) available
		promotions = [Select Id, Name, Account__c From Promotion__c Where Name LIKE :originalRecord.Name];
		System.assertEquals(promotions.size(), 3);
		//Note: UnitTest for content of Promotion__c record is not necessary, because the apex deepclone-mechanism is used,
		//but a check referring children and lookups are necessary. 
		
		allPromotionIDs = new set<ID>();
		
		for(Promotion__c promotion : promotions)
			if(!allPromotionIDs.contains(promotion.ID))	
				allPromotionIDs.add(promotion.ID);
		
		promotionitems = [Select ID, Name, Product__c From Promotion_Material_Item__c Where Promotion__c IN :allPromotionIDs];		
		
		System.assertEquals(promotionitems.size(), 3);
    	
    }
}