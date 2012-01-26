trigger OpportunityLineItem_afterInsert on OpportunityLineItem (after insert) {
    String PROGRAMID = '012200000004y0dAAA';
    String MODULEID = '012200000004y0eAAA';
    
    String BACHELOR_ID = '012200000004nPAAAY';
    String MASTER_ID = '0122000000052fsAAA';
    String DIPLOMA_ID = '0122000000057DyAAI';
    String EXECUTIVE_EDUCATION_ID = '0122000000059stAAA';
    
    Set<String> RECORDTYPESET = new Set<String>{BACHELOR_ID, MASTER_ID, DIPLOMA_ID, EXECUTIVE_EDUCATION_ID};
    //  HANDLE MODULE: if a module is attached, attach the product automatically
    //  IF Bachelor, Master, Diploma or executive education: HANDLE OPPORTUNITY NAME
    //  IF Bachelor, Master, Diploma or executive education: HANDLE PRODUCT NAME FOR CONTRACT
    
    List<OpportunityLineItem> oppLineItemAllInformaton;
    
    try{
        String currencyCode = '';
        oppLineItemAllInformaton = [Select o.Opportunity.Contact_Student__c, o.Opportunity.CurrencyIsoCode, o.PricebookEntry.Name, o.Opportunity.Contact_Student__r.Name, o.Opportunity.RecordTypeId, o.PricebookEntry.Product2Id, o.PricebookEntry.Id, o.PricebookEntry.Pricebook2Id, o.OpportunityId, o.Id from OpportunityLineItem o where o.Id in :Trigger.newMap.keySet()];
        List<OpportunityLineItem> oppLineItemToInsert = new List<OpportunityLineItem>();
        
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
    
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> moduleIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();
        
        //set currency
        if(oppLineItemAllInformaton.size() > 0){
            currencyCode = oppLineItemAllInformaton[0].Opportunity.CurrencyIsoCode;
        }
        
        System.debug('**** currency: '+ currencyCode);
        
        for(OpportunityLineItem o : oppLineItemAllInformaton){
            productIdSet.add(o.PricebookEntry.Product2Id);
        }
        
        Map<Id,Product2> productMap = new Map<Id, Product2>([Select p.Id, p.RecordTypeId, p.Product_Relation__c, p.Name From Product2 p where p.Id in :productIdSet]);
        
        for(Id productId : productMap.keySet()){
            Product2 p = productMap.get(productId);
            if(p.RecordTypeId == MODULEID && p.Product_Relation__c != null){
                programIdSet.add(p.Product_Relation__c);
            }
        }
        
        //select pricebookentry for corresponding program
        List<PricebookEntry> programPricebookEntryList = [Select p.Id, p.UnitPrice, p.Pricebook2Id, p.Product2Id From PricebookEntry p where p.Product2Id in :programIdSet and CurrencyIsoCode = :currencyCode];
        System.debug('**** pricebookEntry size: '+ programPricebookEntryList.size());
            
        for(OpportunityLineItem o : oppLineItemAllInformaton){
            Id productId = o.PricebookEntry.Product2Id;
            
            System.debug('**** product Id: '+ productId);
            
            //********************************  if is module, also attach product ****************************
            if(productMap.containsKey(productId) && productMap.get(productId).RecordTypeId == MODULEID){
                //add program
                PricebookEntry entry;
                
                for(PricebookEntry e : programPricebookEntryList){
                    if(e.Product2Id == productMap.get(productId).Product_Relation__c && e.Pricebook2Id == o.PricebookEntry.Pricebook2Id){
                        entry = e;
                        break;
                    }
                }
                if(entry != null){
                    //found pricebookentry for that product, add opplineitem
                                    
                    OpportunityLineItem oppLineItem = new OpportunityLineItem();
                    oppLineItem.Quantity = 1;
                    oppLineItem.PricebookEntryId = entry.Id;
                    oppLineItem.OpportunityId = o.OpportunityId;
                    oppLineItem.TotalPrice = entry.UnitPrice;
                    oppLineItemToInsert.add(oppLineItem);
                }
            }
            
            
            if(RECORDTYPESET.contains(o.Opportunity.RecordTypeId) && productMap.containsKey(productId)){
                
                if(productMap.get(productId).RecordTypeId == PROGRAMID){
                    //only set name if product is a program
                    System.debug('*** auto name opp: ' + o.Opportunity.Contact_Student__r.Name + ': ' + o.PricebookEntry.Name);
                    o.Opportunity.Name = o.Opportunity.Contact_Student__r.Name + ': ' + o.PricebookEntry.Name;
                    o.Opportunity.Product_Name_for_Contract__c = o.PricebookEntry.Name;
                    oppToUpdateList.add(o.Opportunity);
                }
            }
        }
        
        System.debug('**** opp line size: '+ oppLineItemToInsert.size());
        System.debug('**** opp size: '+ oppToUpdateList.size());
        if(! oppLineItemToInsert.isEmpty()){
            try{
                insert oppLineItemToInsert;
            }
            catch(System.DMLException e){
                System.debug('**** Exception: ' + e);   
            }
        }
        if(!oppToUpdateList.isEmpty()){
            try{
                update oppToUpdateList;
            }
            catch(System.DMLException e){
                System.debug('**** Exception: ' + e);   
            }
        }
        
    }catch(System.Exception e){
        System.debug('**** Exception: ' + e);   
    }
    
    /*******************************************************************************
     * Subroutine for informing the external aemm webserver of a user product change
     *******************************************************************************/
     try
     {
        // NEW: get Webservice location from global configuration
        callout_url__c myCalloutUrls = callout_url__c.getValues('AEMM_productchange_handler');
        String url = myCalloutUrls.URL__c;
        String recordData = '';
        
        // Build Json data structure
        if(oppLineItemAllInformaton.size() > 0)
        {
            Integer numberOfRecords = 0;
            for(OpportunityLineItem o : oppLineItemAllInformaton)
            {
                if(o.Opportunity != null && o.PricebookEntry != null)
                {   
                    if( numberOfRecords > 0 )
                    {
                        recordData += ',';
                    }               
                            
                    recordData += '{';
                    recordData += '"opportunityId":"' + o.Opportunity.Id + '",';
                    recordData += '"productId":"' + o.PricebookEntry.Product2Id + '",';
                    recordData += '"contactId":"' + o.Opportunity.Contact_Student__c + '",';
                    recordData += '"opplineItemId":"' + o.Id +'"';
                    recordData += '}';
                    
                    numberOfRecords++;          
                
                }
                
            }
                
        }
        
        String requestData = '{"ServiceName":"productChangeNotification", "data":[' + recordData + ']}';
        ProductChangeNotification.sendNotification(requestData, url);
     }
     catch(System.Exception e)
     {
        System.debug('**** Exception: ' + e);
     }  
    
}