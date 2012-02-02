public class onOpportunity {

    public static String inFutureContextStoredId = '';
    public static boolean inFutureMethod = false;
    public class baseException extends Exception {}
    
    public static void clearStaticVariable(){
        onOpportunity.inFutureContextStoredId = '';
        onOpportunityLineItem.inFutureContextStoredId = '';
        onProduct.inFutureContextStoredId = '';
        onOpportunity.inFutureMethod = false;
        onOpportunityLineItem.onSignatureAfterInsert = True;
    }
    
    public static void onbeforeupdate(list <Opportunity> trigNew, list <Opportunity> trigOld) {
        list<String> OppId_vonInErstellung = new list<String>(); 
        map<Id, Double> OppList_vonInErstellung = new map<Id, Double>();
        
        list<String> OppId_geloescht = new list<String>(); 
        map<Id, Double> OppList_geloescht = new map<Id, Double>();
        
        for(integer i=0;i<trigNew.size();i++) {
            if(trigNew[i].StageName != 'In Erstellung' && trigNew[i].StageName != 'Gelöscht' && trigOld[i].StageName == 'In Erstellung') {
                //on an update, the stageName has been set on Bereit zur Freigabe. As it's not possible to come back in an earlier Stage, it's much more simple to execute the right task
                OppId_vonInErstellung.add(trigNew[i].Id);      
                OppList_vonInErstellung.put(trigNew[i].Id, trigNew[i].REAR2A__c);
            }
            else if(trigNew[i].StageName == 'Gelöscht' && trigOld[i].StageName != 'Gelöscht') {
                //on an update, the stageName has been set on Bereit zur Freigabe. As it's not possible to come back in an earlier Stage, it's much more simple to execute the right task
                OppId_geloescht.add(trigNew[i].Id);      
                OppList_geloescht.put(trigNew[i].Id, trigNew[i].REAR2A__c);
            }
        }
        
        if(!OppId_vonInErstellung.isEmpty())
            toFutureContext(OppId_vonInErstellung, OppList_vonInErstellung, 1);
        
        if(!OppId_geloescht.isEmpty())
            toFutureContext(OppId_geloescht, OppList_geloescht, -1);
    }
    
   
    private static void toFutureContext(list <String> OppId, map<Id, Double>OppList, Integer Sign) {
        //we now retrieve all the OLI related to each Opportunity
        list<OpportunityLineItem> tempOpp;
         
        //it is important to know this information because another callout is done from salesforce
        //to magento. we cannot make a callout in a callout. This information is used in the
        //product.trigger
        inFutureMethod = true;
        
        try{
            tempOpp = new list<OpportunityLineItem>([select Id, OpportunityId, Lizenzmenge__c, Product2Id__c
                            from OpportunityLineItem where OpportunityId IN :OppId 
                            AND (Fremdvertrieb__c = null OR Fremdvertrieb__c = '')
                            AND OppRechnungsArt__c != 7 AND OppRechnungsArt__c != 9 // Ohne Lagerbewegung
                            AND Sperrkz__c = false]);   
        }
        catch (exception e) {
        }
    
        map<Id, Product2> Product = new map<Id, Product2>();
        Product = getProduct(tempOpp);
            
        for(OpportunityLineItem temp:tempOpp) {
            Double help = OppList.get(temp.OpportunityId);
            if (Product.get(temp.Product2Id__c).RESB01__c==null)
                Product.get(temp.Product2Id__c).RESB01__c=0;
            for(Integer j :SystemSettings.Lagerabgang) {
                if(help == j) {
                    Product.get(temp.Product2Id__c).RESB01__c += temp.Lizenzmenge__c * Sign;    
                }
            }
            for(Integer j :SystemSettings.Lagerzugang) {
                if(help == j)  {
                    Product.get(temp.Product2Id__c).RESB01__c -= temp.Lizenzmenge__c * Sign;
                }
            }
        }
        
        updateProduct(tempOpp, Product);
        
    }

    private static void updateProduct(list<OpportunityLineItem> tempOpp, map<Id, Product2> Product) {
        map<String, Product2> Prod2Update = new map <String, Product2>();
        
        for(OpportunityLineItem temp:tempOpp) {   //list to update
            if(!Prod2Update.containsKey(Product.get(temp.Product2Id__c).Id))
                Prod2Update.put(Product.get(temp.Product2Id__c).Id, Product.get(temp.Product2Id__c));
        }
        try{
            update Prod2Update.values();
        }
        catch (exception e) {
            
        }
    }
    
    private static map<Id, Product2> getProduct(list<OpportunityLineItem> trigg) {
        
        list<String> OppLiId = new list<String>();
        for(OpportunityLineItem temp:trigg) {
            OppLiId.add(temp.Product2Id__c);   
        }
        map<Id, Product2> Product;
        try{
            Product = new map<Id, Product2>([select Id, RESB01__c
                            from Product2 where Id IN :OppLiId]);
        }
            catch (exception e) {
        }
        return Product; 
    }
}