trigger Application_beforeInsertBeforeUpdate on Application__c (before insert, before update) {

    /**********************************************************************************************
     *  For each application, go through chain link
     *  application -> opportunity -> opplineitem -> pricebookentry -> product, and write some
     *  product data back on the application
     *********************************************************************************************/

    // all incoming apps
    List<Application__c> newApplicationList = Trigger.new;

    // Root map
    Map<Id,Map<String,String>> rootMap = new Map<Id,Map<String,String>>();

    // all opportunities of the apps
    List<Id> allOpportunityIds = new List<Id>();

    
    // create list with opportunities, init root map
    for (Application__c app : newApplicationList)
    {
        
        Map<String,String> innerMap = new Map<String,String>();
        innerMap.put('APPLICATION_ID',app.id);
        
        if(app.Opportunity__c != null){
            rootMap.put(app.Opportunity__c, innerMap);
            allOpportunityIds.add(app.Opportunity__c);
        }
    }

    // get Line items
    List<OpportunityLineItem> opportunityLineItems = [Select o.PricebookEntry.Product2Id, o.PricebookEntryId, o.OpportunityId, o.CurrencyIsoCode From OpportunityLineItem o WHERE o.OpportunityId IN :allOpportunityIds];
    List<Id> productIdList = new list<Id>();

    // Put product id's in root map
    for (OpportunityLineItem opplineItem : opportunityLineItems)
    {
        if(rootmap.containsKey(opplineItem.OpportunityId)){
            Map<String,String> innerMap = rootmap.get(opplineItem.OpportunityId);
            
            // If an opportunity has more then one product, do nothing (no decision possible)
            if(innerMap.get('PRODUCT_ID') != null){
                innerMap.remove('PRODUCT_ID');
                innerMap.put('MORE_THAN_1_PRODUCT','TRUE');
            }
            else if(innerMap.containsKey('MORE_THAN_1_PRODUCT') == false){
                innerMap.put('PRODUCT_ID', opplineItem.PricebookEntry.Product2Id);
            }
            productIdList.add(opplineItem.PricebookEntry.product2Id);
        }
    }
    
    // get products
    List<Product2> productList = [Select p.id, p.Start_Date__c, p.HES_SO_Start_Date__c, p.Product_Language__c, p.End_Date__c From Product2 p where p.id IN :productIdList];

    // Update fields of application
    for (Application__c app : newApplicationList)
    {
        if(rootmap.containsKey(app.Opportunity__c)){
        
            // Only do if there is a (single!) product
            if(rootmap.get(app.Opportunity__c).containsKey('PRODUCT_ID')){
            
                String currentProductId = rootmap.get(app.Opportunity__c).get('PRODUCT_ID');
    
                for(Product2 p : productList){
            
                    if(p.id == currentProductId ){
                        app.Product_Start_Date__c = p.Start_Date__c;
                        app.Product_Start_Date_HES_SO__c = p.HES_SO_Start_Date__c;
                        app.Product_End_Date__c = p.End_Date__c;
                        app.Product_Language__c = p.Product_Language__c;
                    }
                }       
            }
        }
    }
}