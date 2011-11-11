trigger beforeInsertUpdatePromotion on Promotion__c (before insert, before update, before delete){
/*
Modification Log:
-------------------------------------------------------------------------------
Developer           Date        Description
-------------------------------------------------------------------------------
Mani Kolipakula(DC) 28-Apr-2011 Added validation on Status for deletion of 
                                 National Promotions
Jishad P A(DC)      15-Jun-2011 Modified to add record type check to exclude 
                                 National Promotions US record type.
-------------------------------------------------------------------------------
*/
    // Get the Promotion record types by name
    Map<String,Schema.RecordTypeInfo> promoRTMap = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName();
    // Id for National Promotions US record type
    Id natPromoUSRecType = null;
    // Get the record type id for National Promotions US from the record type map
    if(promoRTMap.containsKey('National Promotion - US')){
        natPromoUSRecType = promoRTMap.get('National Promotion - US').getRecordTypeId();
    }

    if((trigger.isBefore && trigger.isInsert)||(trigger.isBefore && trigger.isUpdate) ){
        Set<ID> ownerIds = new Set<ID>();
        if(Trigger.isInsert){
            for(Integer x = 0; x<Trigger.new.size(); x++){
                ownerIds.add(Trigger.new[x].OwnerId);
            }
        } else{
            for(Integer x = 0; x<Trigger.new.size(); x++){
                if(Trigger.new[x].OwnerId!=Trigger.old[x].OwnerId){
                    ownerIds.add(Trigger.new[x].OwnerId);
                }
            }
        }

        Map<ID,User> mapUser = new Map<ID,User>([Select Id, Brand_Manager__c, Finance_Manager__c, 
                Sales_Manager__c from User where Id in: ownerIds]);
        for(Promotion__c p : Trigger.new){
            if(p.RecordTypeId!=natPromoUSRecType){
                User u = mapUser.get(p.OwnerId);
                if(u==null){continue;}
                p.Brand_Manager__c = u.Brand_Manager__c;
                p.Finance_Manager__c = u.Finance_Manager__c;
                p.Sales_Manager__c = u.Sales_Manager__c;
            }
        }
    }

    // Validates the status of National Promotion records being deleted is Created
    if(Trigger.isbefore && Trigger.isDelete){
        for(Promotion__c promo: Trigger.old){
            // Check for record type and status
            if((promo.RecordTypeId == natPromoUSRecType) && (promo.Promotion_Status__c != 'Created')){
                // Show error for the user
                promo.addError('Only Promotions with Status Created can be deleted.');
            }
        }
    }
}