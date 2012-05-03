global with sharing class batchableProcessDatedOfflineOutletVisits implements Database.Batchable<sObject>
{       
    global string query;
    global integer queryChoice;
    global string myIds;
        
    global batchableProcessDatedOfflineOutletVisits(String q, integer r, string s)
    {
        query = q;
        queryChoice = r;
        myIds = s;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {        
        return Database.getQueryLocator(query); 
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        //offlineOutletVisit api = new offlineOutletVisit();
        Set<ID> setAcctIds = new Set<ID>();
        for(sObject s:scope)
        {
            Account objAcct = (Account)s;
            setAcctIds.add(objAcct.Id); //should just be one record at a time
        }           
        string strAcctIds = swapStringForCollection(setAcctIds);
        //different queries depending on which method being called
        string strQuery1 = 'Select o.Create_Offline_OVIs__c, o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, ' +  
                    '(Select Id, IsDeleted, Name, Outlet_Visit__c, Custom_Product__c, Bottle_Price__c, Bottle_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Double_Price__c, Double_Price_Special__c, Space_Placement__c, Shelf__c, Facing__c, Available__c From Outlet_Visit_Items__r), ' +
                    '(Select Id, Name, RecordTypeId, Space_Placement__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_This_Month__c, Depletions_Next_Month__c From Offline_Outlet_Visit_Items__r), ' +
                    '(Select Id, Name, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r) ' +
                    'From Outlet_Visit__c o where o.Status__c = \'New\' and o.Id in ' + myIds + ' and o.Account__c in ' + strAcctIds + ' for update';   
        string strQuery2 = 'Select o.Create_Offline_OVIs__c, o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, ' +  
                    '(Select Id, IsDeleted, Name, Outlet_Visit__c,Custom_Product__c, Bottle_Price__c, Bottle_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Double_Price__c, Double_Price_Special__c, Space_Placement__c, Shelf__c, Facing__c, Available__c From Outlet_Visit_Items__r), ' +
                    '(Select Id, Name, RecordTypeId, Space_Placement__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_This_Month__c, Depletions_Next_Month__c From Offline_Outlet_Visit_Items__r), ' +
                    '(Select Id, Name, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r) ' +                  
                    'From Outlet_Visit__c o where o.Status__c = \'New\' and o.Visit_Date__c = LAST_MONTH and o.Account__c in ' + strAcctIds + ' for update';            

        string strQuery =  queryChoice==1 ? strQuery1 : strQuery2;          
        Schema.DescribeSObjectResult de = Schema.SObjectType.Offline_Outlet_Visit_Items__c;
        Map<String,Schema.RecordTypeInfo> rtMapByName = de.getRecordTypeInfosByName();      

        Schema.DescribeSObjectResult deOV = Schema.SObjectType.Outlet_Visit__c;
        Map<String,Schema.RecordTypeInfo> rtMapByNameOV = deOV.getRecordTypeInfosByName();      
        //check if there is a NEW OV out there that needs recalc'd plus 30 days
        //process the main query in batches of 200     
        
        for(Outlet_Visit__c[] ov : Database.query(strQuery)){   
            //put the OV's into a map by Account for easy reference
                Set<ID> prodIDS = new Set<ID>();
                Set<string> outletClasses = new Set<string>(); 
                Set<string> markets = new Set<string>();                
                Map<ID,Outlet_Visit__c> mapIDsToUpdate30 = new Map<ID,Outlet_Visit__c>();
                
                for(Integer x = 0; x<ov.size(); x++){
                    mapIDsToUpdate30.put(ov[x].Account__c, ov[x]); //we only care about one (or at least assume only one OV per Account)
                    outletClasses.add(ov[x].Account__r.Outlet_Class__c); 
                    markets.add(ov[x].Account__r.Market__c);
                    for(Offline_Outlet_Visit_Items__c oovi : ov[x].Offline_Outlet_Visit_Items__r){
                        prodIDS.add(oovi.Product_ID__c);
                    }
                }               

            //need to look up previous OV's for each account per 4/16/11 change request
            string strPrevQuery = 'Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, ' +  
                        '(Select Id, IsDeleted, Name, Outlet_Visit__c, Custom_Product__c, Bottle_Price__c, Bottle_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Double_Price__c, Double_Price_Special__c, Space_Placement__c, Shelf__c, Facing__c, Available__c From Outlet_Visit_Items__r) ' +                    
                        'From Outlet_Visit__c o where o.Status__c != \'New\' and o.Account__c in ' + swapStringForCollection(mapIDsToUpdate30.keyset()) + 'order by o.Visit_Date__c';               
            Map<ID,Outlet_Visit__c> mapPrevious = new Map<ID,Outlet_Visit__c>();
       
            for(Outlet_Visit__c[] ovPrev : Database.query(strPrevQuery)){
                for(Integer x = 0; x<ovPrev.size(); x++)
                    mapPrevious.put(ovPrev[x].Account__c, ovPrev[x]);           
            }   

            //set the range of dates for depletion query
            date startdate=date.today().addmonths(-1).tostartofmonth();
            date enddate=date.today().addmonths(1).tostartofmonth().adddays(date.daysInMonth(date.today().addmonths(1).year(),date.today().addmonths(1).month()));
                    
            //build a map of Products that we can loop thru for each OV below.
            //query all the Wet Goods products and a rough range of Depletions (note that we add 1 Month to the end date)
            Map<ID,Product__c> mapProd = new Map<ID,Product__c>([Select p.Channel__c, p.Name, p.Market__c, p.Id, p.Brand__c, p.IsActive__c, 
                (Select Id, OwnerId, IsDeleted, Name, Bottles__c, Month_Of_Date__c, Account__c, Custom_Product__c From Depletions__r where 
                Account__c in: mapIDsToUpdate30.keyset() and Month_Of_Date__c >=: startDate and Month_Of_Date__c <=: endDate.addmonths(1) ORDER BY Month_Of_Date__c)
                From Product__c p where p.RecordType.Name = 'Wet Goods' ORDER BY p.Brand__r.Supplier__r.Is_B_F_Brand__c DESC, p.Sort_Order__c ASC]);
            
            Map<ID,Key_Task_Template__c> mapKeyTaskTemplates = new Map<ID,Key_Task_Template__c>([Select k.Outlet_Class__c, k.Name, k.Market__c, k.Id, k.Channel__c 
                From Key_Task_Template__c k where k.Outlet_Class__c in: outletClasses and k.Market__c in: markets]);
                                            
            Map<ID,Outlet_Visit__c> myOVInserts = new Map<ID,Outlet_Visit__c>();
            Map<ID,List<Offline_Outlet_Visit_Items__c>> myOOVIInserts = new Map<ID,List<Offline_Outlet_Visit_Items__c>>();
            Map<ID,List<Key_Task__c>> insertKT = new Map<ID,List<Key_Task__c>>(); 
                   
            //loop thru the update30's and set days to 30 days out
            for(Outlet_Visit__c ov1 : mapIDsToUpdate30.values()){
                Set<ID> setAlreadyProds = new Set<ID>();
                decimal intNumberDays = 30;
                if(!ov1.Create_Offline_OVIs__c && ov1.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c!=null && ov1.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c>0){
                    try{    
                        intNumberDays = (intNumberDays / ov1.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c);
                    }catch(exception e){} 
                }   
                ov1.Create_Offline_OVIs__c = false;                   
                ov1.Visit_Date__c = ov1.Visit_Date__c.adddays(intNumberDays.setscale(0,system.roundingmode.HALF_UP).intValue());            
                //put in a map so we can lookup the newly insert OV's ID by using our known AccountID field
                myOVInserts.put(ov1.Account__c,ov1);
                //loop thru each Offline OVI and recalculate Depletion
                for(Offline_Outlet_Visit_Items__c oovi : ov1.Offline_Outlet_Visit_Items__r){
                        Product__c p = mapProd.get(oovi.Product_ID__c);
                        if(p==null){continue;} //if we can't find the product, then we can't do much, leave it alone
                        system.debug(oovi);
                        //added in a copy function from Previous OV's 04/16/11 nds              
                        oovi = offlineOutletVisit.createOffline((mapPrevious.get(ov1.Account__c)!=null?mapPrevious.get(ov1.Account__c):ov1), p, oovi.RecordTypeID, oovi); //pass in the ToCopy OV so we can copy the OVI's to recalc Offline OVIs
                        system.debug(oovi);  
                        setAlreadyProds.add(p.Id);      
                        myOOVIInserts = mapBuilder(ov1.Account__c, myOOVIInserts, oovi); 
                                           
                }   
                Set<ID> alreadyExistKTs = new Set<ID>(); 
                for(Key_Task__c kt : ov1.Key_Tasks__r){
                    alreadyExistKTs.add(kt.Key_Task_Template__c);
                }
                //myOOVIInserts.put(ov1.Account__c,ov1.Offline_Outlet_Visit_Items__r);  
                
                string gridLayout='1';
                //determine which layout to use (in this case, record type)
                if(ov1.Account__r.Channel__c!=null && ov1.Account__r.Channel__c!='')
                    try{
                        if(ov1.Account__r.Market__r.get(ov1.Account__r.Channel__c+'_Channel__c')!=null && ov1.Account__r.Market__r.get(ov1.Account__r.Channel__c+'_Channel__c')!='')
                            gridLayout=(string)ov1.Account__r.Market__r.get(ov1.Account__r.Channel__c+'_Channel__c');
                    }catch(exception e){}               
                //lookup the recordtypeid from the schema using gridlayout variable.
                ID recordTypeID = rtMapByName.get(gridLayout).RecordTypeID;         
                ov1.RecordTypeID = rtMapByNameOV.get(gridLayout).RecordTypeID;      
                //now loop thru each possible product and fill in missings
                    for(Product__c p : mapProd.values()){
                    //narrow the valid products by Active, Market, Channel, etc.
                    if(p.IsActive__c==true && p.Market__c == ov1.Account__r.Market__c && !setAlreadyProds.contains(p.Id)){
                        if(p.Channel__c == null || p.Channel__c == 'Both' || (ov1.Account__r.Channel__c!=null && p.Channel__c == ov1.Account__r.Channel__c)){
                            //build a map by Account so we can later match the OV to the OVI record (to set the OVI.Outlet_Visit__c ID after insert of OV)
                            /*List<Offline_Outlet_Visit_Items__c> temp = myOOVIInserts.get(ov1.Account__c);
                            if(temp!=null){
                                temp.add(createOffline(ov1,p,recordTypeID, new Offline_Outlet_Visit_Items__c()));
                            }else{
                                temp = new List<Offline_Outlet_Visit_Items__c>();   
                                temp.add(createOffline(ov1,p,recordTypeID, new Offline_Outlet_Visit_Items__c()));
                            }                                       
                            myOOVIInserts.put(ov1.Account__c,temp);*/       
                            system.debug(mapPrevious.get(ov1.Account__c));
                            system.debug(mapPrevious);
                            myOOVIInserts = mapBuilder(ov1.Account__c, myOOVIInserts, offlineOutletVisit.createOffline((mapPrevious.get(ov1.Account__c)!=null?mapPrevious.get(ov1.Account__c):ov1),p,recordTypeID, new Offline_Outlet_Visit_Items__c()));                   
                        }                   
                    }
                }
                               
                //build Key Tasks
                for(Key_Task_Template__c k : mapKeyTaskTemplates.values()){
                    if(!alreadyExistKTs.contains(k.Id) && k.Outlet_Class__c == ov1.Account__r.Outlet_Class__c &&
                        k.Market__c == ov1.Account__r.Market__c &&
                        (k.Channel__c == 'Both' || k.Channel__c == ov1.Account__r.Channel__c)
                        ){ 
                            List<Key_Task__c> temp = insertKT.get(ov1.Account__c);
                            Key_Task__c kt = new Key_Task__c();
                            kt.Key_Task_Template__c = k.Id;                             
                            if(temp!=null){                 
                                temp.add(kt);                           
                            }else{
                                temp = new List<Key_Task__c>();                         
                                temp.add(kt);
                            }                                       
                            insertKT.put(ov1.Account__c,temp);                                                  
                    }
                }                       
            }
            
            upsert myOVInserts.values();
            system.debug(myOOVIInserts);
            //loop thru each Offline OVI & KT and set the Outlet_Visit__c field equal to the newly inserted OV
            List<Offline_Outlet_Visit_Items__c> myListOOVIInserts = new List<Offline_Outlet_Visit_Items__c>();
            List<Key_Task__c> myListKTInserts = new List<Key_Task__c>();
            for(ID z : myOVInserts.keyset()){   
                if(myOOVIInserts.get(z)!=null){          
                    for(Offline_Outlet_Visit_Items__c y : myOOVIInserts.get(z)){
                        if(y.Outlet_Visit__c==null)
                            y.Outlet_Visit__c = myOVInserts.get(z).Id;
                    }
                    myListOOVIInserts.addall(myOOVIInserts.get(z));
                }   
                if(insertKT.get(z)!=null){
                    for(Key_Task__c y : insertKT.get(z)){
                        if(y.Outlet_Visit__c==null)
                            y.Outlet_Visit__c = myOVInserts.get(z).Id;
                    }
                    myListKTInserts.addall(insertKT.get(z));  
                }                       
            }
            system.debug(myListOOVIInserts);
            upsert myListOOVIInserts;
            system.debug(myListKTInserts);
            insert myListKTInserts;             
        }               

    }

    Map<ID,List<sObject>> mapBuilder(ID mapKey, Map<ID,List<sObject>> mainMap, sObject newItem){
        List<sObject> temp = mainMap.get(mapKey);
        if(temp!=null){
            temp.add(newItem);
        }else{
            temp = new List<sObject>();   
            temp.add(newItem);
        }       
        mainMap.put(mapKey,temp);                                
        return mainMap;         
    }

    string swapStringForCollection(Set<ID> setIds){
        string myIds = '';
        for(ID y : setIds)
            myIds += '\'' + y + '\',';
        if(myIds.lastIndexOf(',')>0)
          myIds = myIds.substring(0,myIds.lastIndexOf(',')); 
        myIds = '(' + myIds + ')';
        return myIds;       
    }    
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}