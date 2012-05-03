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
    public Boolean isFinished {get;set;}
    public list<Promotion__c> resultSet {get;set;} 
    public String domain {get;set;}
    
    
    public PromotionCloneController(ApexPages.StandardController ctrl) {
        domain = Site.getDomain();  
        promotion = (Promotion__c) Database.query(getCreatableFieldsSOQL('Promotion__c', 'ID = \''+ctrl.getRecord().Id+'\''));
        resetList();
        isFinished = false;
        if(promotion == null)
            throwError(null, system.label.clonePromotion_record_not_found); 
 
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
        system.debug('Orginal PromotionID: '+promotion.Id);
        
        list<Promotion__c> allPromotions = cloneAndReturnAllPromotions(sp);
        if(allPromotions == null || allPromotions.size() == 0)
            return null;
        
        //if(!insertAllPromotionResults(sp, allPromotions))
        //  return null;
        
        if(!insertAllPromotionMaterialItems(sp, allPromotions))
            return null;
            
        //if(!insertAllPromotionGoals(sp, allPromotions))
        //  return null;
        
        resultSet = allPromotions;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, system.label.clonePromotion_successful));
        resetList();
        isFinished = true;
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
        
        for(Promotion__c p : allPromotions)
            for(Promotion_Material_Item__c promotion_material_item : promotion_material_items) {
                Promotion_Material_Item__c newRecord = promotion_material_item.clone(false, true);
                newRecord.Promotion__c = p.ID;
                system.debug('PMI: '+newRecord.Promotion__c);
                if(newRecord.Promotion__c != null)
                    duplicates.add(newRecord);
            }
        
        try {
            if(duplicates.size() > 0)
                insert duplicates;
        } catch(Exception e) { return throwError(sp, e.getMessage()); }
        
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
            for(DTO dto : targetAccounts){
                if(dto.record.Account__c != null)
                    allPromotions.add(dto.record);
            }
            insert allPromotions;
        } catch( Exception e ) { throwError(sp, e.getMessage()); }
        return allPromotions;
    }
    
    public Boolean throwError(SavePoint sp, String msg) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
        isFinished = false;
        
        if(sp != null)
            Database.rollback(sp);
        
        return isFinished;
    }
    
    public PageReference redirectTo() {
        String id = ApexPages.currentPage().getParameters().get('promotionID');
        PageReference ref = new PageReference('/'+id);
        
        if(id == null)
            return null;
            
        return ref; 
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
   
   
    /*  UnitTest for PromotionCloneController
     *  @date: 02.01.12
     *  @author: Michael Mickiewicz
     */
    public static testMethod void MainTest(){
        
        /*  The complete input domain is divided in following characteristics:
            -  First test case contains an account with only one promotion records that contians none material item.
            -  Second test case presents a native case with one account containing a promotion with one material item.
            -  Third test case covers all other cases which contains a promotion with more than one material item.
        */
        
        Market__c market = new Market__c(Market_Code__c = 'GER', Name = 'Germany', Off_Channel__c = '2', On_Channel__c = '3');
        
        insert market;
        
        Account account1 = new Account(Name = 'Test Account 1', Market__c = market.Id, Channel__c = 'Off', BillingCountry = 'DE');
        Account account2 = new Account(Name = 'Test Account 2', Market__c = market.Id, Channel__c = 'Off', BillingCountry = 'DE');
        Account account3 = new Account(Name = 'Test Account 3');
        
        insert account1;
        insert account2;
        insert account3;
        
        Contact contact1 = new Contact(LastName = 'Roger', AccountId = account1.Id);
        Contact contact2 = new Contact(LastName = 'Alex', AccountId = account2.Id);
        Contact contact3 = new Contact(LastName = 'Tim', AccountId = account3.Id);
         
        insert contact1;
        insert contact2;
        insert contact3;
        
        Promotion__c promotion1 = new Promotion__c(Name = 'Test Promotion 1', Account__c = account1.ID, Contact__c = contact1.ID); //No material item children 
        Promotion__c promotion2 = new Promotion__c(Name = 'Test Promotion 2', Account__c = account2.ID, Contact__c = contact2.ID); //One material item children
        Promotion__c promotion3 = new Promotion__c(Name = 'Test Promotion 3', Account__c = account3.ID, Contact__c = contact3.ID); //Two material item children
        
        insert promotion1;
        insert promotion2;
        insert promotion3;
        
        Promotion_Material_Item__c material_item1 = new Promotion_Material_Item__c(Promotion__c = promotion2.Id);
        Promotion_Material_Item__c material_item2 = new Promotion_Material_Item__c(Promotion__c = promotion3.Id);
        Promotion_Material_Item__c material_item3 = new Promotion_Material_Item__c(Promotion__c = promotion3.Id); 

        insert material_item1; 
        insert material_item2;
        insert material_item3;
         
        Brand__c brand1 = new Brand__c(Name = 'Jack Daniel\'s');
        Brand__c brand2 = new Brand__c(Name = 'Herradura');
        
        insert brand1;
        insert brand2;
        
        Product__c product1 = new Product__c(Brand__c = brand1.ID);
        Product__c product2 = new Product__c(Brand__c = brand2.ID);
        
        insert product1;
        insert product2; 
        
        ApexPages.StandardController stdCtrl;
        PromotionCloneController ctrl;
        list<Promotion__c> promotions;
        list<Promotion_Material_Item__c> promotionitems;
        Promotion__c originalRecord; 
        Integer recordAmount = 0;
        set<ID> allPromotionIDs;
        
        //First test case
        stdCtrl = new ApexPages.StandardController(promotion1);
        ctrl = new PromotionCloneController(stdCtrl);
        originalRecord = (Promotion__c) stdCtrl.getRecord();
        
        //Check if there is an starting row available and assign 
        recordAmount = ctrl.getAmountOfAccounts();
        System.assertEquals(recordAmount, 1);
        ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = account2.ID;
        
        ctrl.addAccount();
        ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = account3.ID;
        recordAmount = ctrl.getAmountOfAccounts();
        System.assertEquals(recordAmount, 2);
        
        ctrl.save();
        
        //Check if there are 3 records (original and 2 duplicates) available
        promotions = [Select Id, Name, Account__c From Promotion__c Where Name LIKE :originalRecord.Name];
        System.assertEquals(promotions.size(), 3);
        //Note: UnitTest for content of Promotion__c record is not necessary, because the apex deepclone-mechanism is used.
        
        //Second test case
        stdCtrl = new ApexPages.StandardController(promotion2);
        ctrl = new PromotionCloneController(stdCtrl);
        originalRecord = (Promotion__c) stdCtrl.getRecord();
        
        //Check if there is an starting row available and assign
        System.assertEquals(ctrl.getAmountOfAccounts(), 1);
        ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = account1.ID;
        
        ctrl.addAccount();
        ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = account3.ID;
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
        stdCtrl = new ApexPages.StandardController(promotion3);
        ctrl = new PromotionCloneController(stdCtrl);
        
        //Check if there is an starting row available and assign 
        System.assertEquals(ctrl.getAmountOfAccounts(), 1);
        ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = account1.ID;
        
        ctrl.addAccount();
        ctrl.targetAccounts.get(ctrl.getAmountOfAccounts()-1).record.Account__c = account2.ID;
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