trigger beforeInsertUpdateMissingMarket on Account (before insert) {
/*
Modification Log:
-------------------------------------------------------------------------------
Developer			Date		Description
-------------------------------------------------------------------------------
Jishad P A (DC)		15-Jun-2011 Modified to add record type check to exclude 
								 POS Ship-to record type.
-------------------------------------------------------------------------------
*/
    // Get the Account record types by name
    Map<String,Schema.RecordTypeInfo> promoRTMap = 
    	Schema.SObjectType.Account.getRecordTypeInfosByName();
    // Id for POS Ship-To record type
    Id posShiptoRecType = null;
    // Get the record type id for POS Ship-To from the record type map
    if(promoRTMap.containsKey('POS Ship-To')){
    	posShiptoRecType = promoRTMap.get('POS Ship-To').getRecordTypeId();
	}
    Map<string,ID> mapMarkets = new Map<string,ID>();
    for(Market__c m :[Select Id, Name from Market__c]){
        mapMarkets.put(m.Name,m.Id);
    }
    User u = [Select Id, Market__c from User where Id = :UserInfo.getUserId()];
    for(Account a : Trigger.new){
    	// Execute the login only for record types other than POS Shipto type
    	if(a.RecordTypeId!=posShiptoRecType){
	        if(a.Market__c==null){ //try and fill in missing Markets
	            if(u.Market__c!=null && u.Market__c!='' && mapMarkets.get(u.Market__c)!=null){
	                a.Market__c = mapMarkets.get(u.Market__c);
	            }
	        }
    	}
    }
}