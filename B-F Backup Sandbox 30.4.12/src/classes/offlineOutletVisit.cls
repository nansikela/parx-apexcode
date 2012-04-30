public without sharing class offlineOutletVisit {
/*
Modification Log:
-------------------------------------------------------------------------------
Developer			Date			Description
-------------------------------------------------------------------------------
Mike Shroyer		24-Aug-2011  	Changed the Outlet_Visit_Item loop in CreateOffline to use a new select instead of the reference 
									Changed deleteOOVIMoreThanThree to include code that checks for Offline_Use set to true and turns it off if 
										it is an old completed Outlet_Visit
-------------------------------------------------------------------------------
*/

	//The Channel__c fiels are not dynamic on Market__c object. 
	//Therefore, if adding picklist values to Account.Channel__c field, you will have to update the query on line 12 to reflect the new field on Market__c
        	
	@future (callout=true) 
	public static void processOVI(Set<ID> myIDS, boolean isWebPage,  boolean isMobile)
	{
        //declarations
       
        List<Outlet_Visit_Item__c> insertOVI = new List<Outlet_Visit_Item__c>();
        List<Outlet_Visit_Item__c> deleteOVI = new List<Outlet_Visit_Item__c>();
        //Set<ID> prodIDS = new Set<ID>();
        Set<string> outletClasses = new Set<string>(); 
        Set<string> markets = new Set<string>();

        Map<ID,ID> accountIDS = new Map<ID,ID>();
        Map<ID,Outlet_Visit__c> accountOV = new Map<ID,Outlet_Visit__c>();
        Map<ID,Account> accountMap = new Map<ID,Account>();
        
        Map<ID,Map<ID,Map<date,Depletion__c>>> mapAccountDepletions = new Map<ID,Map<ID,Map<date,Depletion__c>>>();
    	List<Key_Task__c> deleteTasks = new List<Key_Task__c>();
		
		Schema.DescribeSObjectResult de = Schema.SObjectType.Offline_Outlet_Visit_Items__c;
		Map<String,Schema.RecordTypeInfo> rtMapByName = de.getRecordTypeInfosByName();

		Schema.DescribeSObjectResult deOV = Schema.SObjectType.Outlet_Visit__c;
		Map<String,Schema.RecordTypeInfo> rtMapByNameOV = deOV.getRecordTypeInfosByName();

    	//
    	        
        //get a map of all OVs, OVIs and offline OVIs
        Map<ID,Outlet_Visit__c> mapOV = new Map<ID,Outlet_Visit__c>();
        List<date> lstDate = new List<date> ();

        
        for(Outlet_Visit__c[] o : [Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, 
	        	(Select Id, Name, Outlet_Visit__c, Bottle_Price_Special__c, Bottle_Price__c, Drink_Price_Special__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Custom_Product__c, Available__c, Facing__c, Shelf__c, Location_On__c, Location_Off__c, Double_Price__c, Double_Price_Special__c From Outlet_Visit_Items__r), 
	        	(Select Id, Name, RecordTypeId, Location_On__c, Location_Off__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_Last_Month_Date__c, Depletions_This_Month__c, Depletions_This_Month_Date__c, Depletions_Next_Month__c, Depletions_Next_Month_Date__c From Offline_Outlet_Visit_Items__r),
	 			(Select Id, Name, CurrencyIsoCode, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r)         	 
	        	From Outlet_Visit__c o where o.Id in: myIDS for update]){//order by Visit_Date__c 
	    			for(Integer x = 0; x<o.size(); x++){
	    			    lstDate.add(o[x].Visit_Date__c);
	    			    mapOV.put(o[x].Id,o[x]);
	    			}		
    	} 
    	
    	             
        if(mapOV.isempty()){return;} //exit if no data

        lstDate.sort();
        
        //Build a list of Products to query
        for(Outlet_Visit__c o : mapOV.values()){
        	accountIDS.put(o.Account__c,o.ID);
        	accountOV.put(o.Account__c,o);
        	accountMap.put(o.Account__c,o.Account__r);
        	outletClasses.add(o.Account__r.Outlet_Class__c); 
        	markets.add(o.Account__r.Market__c);
        	//for(Offline_Outlet_Visit_Items__c oovi : o.Offline_Outlet_Visit_Items__r){
        	//	prodIDS.add(oovi.Product_ID__c);
        	//}
        }
        
        
        //need the start and end dates to grab depletion data
        date minDate = lstDate[0];
        date maxDate = lstDate[lstDate.size()-1];
        
        //set the range of dates for depletion query
        date startdate=minDate.addmonths(-1).tostartofmonth();
        date enddate=maxDate.addmonths(1).tostartofmonth().adddays(date.daysInMonth(maxDate.addmonths(1).year(),maxDate.addmonths(1).month()));

		//build a map of Products that we can loop thru for each OV below.
        //query all the Wet Goods products and a rough range of	Depletions (note that we add 1 Month to the end date)
        
        Map<ID,Product__c> mapProd = new Map<ID,Product__c>([Select p.Channel__c, p.Name, p.Market__c, p.Id, p.Brand__c, p.IsActive__c, 
        	
        	(Select Id, OwnerId, IsDeleted, Name, Bottles__c, Month_Of_Date__c, Account__c, Custom_Product__c From Depletions__r where 
        	Account__c in: accountIDS.keyset() and Month_Of_Date__c >=: startDate and Month_Of_Date__c <=: endDate.addmonths(1) ORDER BY Month_Of_Date__c)
			From Product__c p where p.RecordType.Name = 'Wet Goods' ORDER BY p.Brand__r.Supplier__r.Is_B_F_Brand__c DESC, p.Sort_Order__c ASC]);

			
			    		
   
	   if(!isWebPage){//only run this section if NOT from the outletVisit_Controller (web form)...push data from Offline to OV details. 	                
	        //build a map by Account of a nested map of Depletions by Product. We will lookup the depletion record for each product/account combination
	        for(Depletion__c d : [Select Id, OwnerId, IsDeleted, Name, Bottles__c, Month_Of_Date__c, Account__c, Custom_Product__c From Depletion__c where 
	       		Account__c in: accountIDS.keyset() and Month_Of_Date__c >=: startdate and Month_Of_Date__c <=: enddate ORDER BY Account__c, Custom_Product__c, Month_Of_Date__c]){                                  
					mapAccountDepletions.put(d.Account__c,storeMapValues(mapAccountDepletions.get(d.Account__c),d));       				
			}
	        List<Offline_Outlet_Visit_Items__c> myOOVIDeletes = new List<Offline_Outlet_Visit_Items__c>();
	        //loop thru each OV and process
	        
	        for(Outlet_Visit__c o : mapOV.values()){        	
				boolean bolFlag = false;
		        for(Offline_Outlet_Visit_Items__c oovi : o.Offline_Outlet_Visit_Items__r){		        	
		        	//check that valid data has been set on record
		        	bolFlag = true;
	        			        			        			        			        			        	
	                if((oovi.Bottle_Price__c!=null && oovi.Bottle_Price__c!=0) || 
	                (oovi.Drink_Price__c!=null && oovi.Drink_Price__c!=0) ||
	                oovi.Double_Price__c!=null ||
	                oovi.Location_On__c!=null ||
	                oovi.Location_Off__c != null ||
					oovi.Shelf__c!=null ||
					oovi.Facing__c!=null ||
					oovi.Available__c!=false
	                )
	                {	        	
	                	//create new OVI record
			        	Outlet_Visit_Item__c ovi = new Outlet_Visit_Item__c();
			        	ovi.Location_On__c = oovi.Location_On__c;
			        	ovi.Location_Off__c = oovi.Location_Off__c;
			        	ovi.Shelf__c = oovi.Shelf__c;

			        	ovi.Custom_Product__c = oovi.Product_ID__c;
			        	ovi.Outlet_Visit__c = oovi.Outlet_Visit__c;
			        	ovi.Facing__c = oovi.Facing__c;
			        	ovi.Drink_Price__c = oovi.Drink_Price__c;
			        	ovi.Facing__c = oovi.Facing__c;
			        	ovi.Drink_Price_Special__c = oovi.Drink_Price_Special__c;
			        	ovi.Double_Price__c = oovi.Double_Price__c;
			        	ovi.Double_Price_Special__c = oovi.Double_Price_Special__c;
			        	ovi.Bottle_Price__c = oovi.Bottle_Price__c;
			        	ovi.Bottle_Price_Special__c = oovi.Bottle_Price_Special__c;
			        	ovi.Available__c = oovi.Available__c;
						insertOVI.add(ovi);
	                }else{
	                	myOOVIDeletes.add(oovi); //3.14.2011 NDS - added delete logic to the oovi
	                }
	                //now process Depletions
	                Map<ID,Map<date,Depletion__c>> temp = mapAccountDepletions.get(o.Account__c);
				    Depletion__c dep1,dep2,dep3;     
	                if(temp!=null){
		                Map<date,Depletion__c> temp2 = temp.get(oovi.Product_ID__c);
		             	if(temp2!=null){
		             		// find correct month
			             	for(Depletion__c dp : temp2.values()){
				                //changed to not dynamically set Depletion, but rather use Depletions_This_Month_Date__c,etc fields to set Dep month
				                if(oovi.Depletions_Last_Month_Date__c!=null && oovi.Depletions_This_Month_Date__c!=null && oovi.Depletions_Next_Month_Date__c!=null){
									if((dp.Month_Of_Date__c.month() + '/' + dp.Month_Of_Date__c.year()) == oovi.Depletions_Last_Month_Date__c){dep1=dp;}
					                if((dp.Month_Of_Date__c.month() + '/' + dp.Month_Of_Date__c.year()) == oovi.Depletions_This_Month_Date__c){dep2=dp;}
					                if((dp.Month_Of_Date__c.month() + '/' + dp.Month_Of_Date__c.year()) == oovi.Depletions_Next_Month_Date__c){dep3=dp;}
				                }else{
					                if(dp.Month_Of_Date__c.month()==o.Visit_Date__c.addmonths(-1).month()){dep1=dp;}
					                if(dp.Month_Of_Date__c.month()==o.Visit_Date__c.month()){dep2=dp;}
					                if(dp.Month_Of_Date__c.month()==o.Visit_Date__c.addmonths(1).month()){dep3=dp;}
				                }		                
			             	}  	             		
		             	}
	                }	
	                //process each dep1-3 and if a correct month wasn't found, create a new Depletion__c record
	                if(oovi.Depletions_Last_Month__c!=null && oovi.Depletions_Last_Month__c!=0){               
		 				if(dep1!=null){
		 					dep1.Bottles__c = oovi.Depletions_Last_Month__c;	
		 				}else{
			                dep1 = new Depletion__c();
			                dep1.CurrencyIsoCode = o.CurrencyIsoCode;
			                
			                dep1.Custom_Product__c = oovi.Product_ID__c;
			                dep1.Account__c = o.Account__c;
			                dep1.Month_Of_Date__c = o.Visit_Date__c.addmonths(-1).tostartofmonth();
			                dep1.Bottles__c = oovi.Depletions_Last_Month__c;	
		 				}
		 				mapAccountDepletions.put(o.Account__c,storeMapValues(mapAccountDepletions.get(o.Account__c),dep1));    
		        	}
		        	if(oovi.Depletions_This_Month__c!=null && oovi.Depletions_This_Month__c!=0){
		 				if(dep2!=null){
		 					dep2.Bottles__c = oovi.Depletions_This_Month__c;	
		 				}else{
			                dep2 = new Depletion__c();
			                dep2.CurrencyIsoCode = o.CurrencyIsoCode;
			                
			                dep2.Custom_Product__c = oovi.Product_ID__c;
			                dep2.Account__c = o.Account__c;
			                dep2.Month_Of_Date__c=o.Visit_Date__c.tostartofmonth();
			                dep2.Bottles__c = oovi.Depletions_This_Month__c;	
		 				} 
		 				mapAccountDepletions.put(o.Account__c,storeMapValues(mapAccountDepletions.get(o.Account__c),dep2));
		        	}
		        	if(oovi.Depletions_Next_Month__c!=null && oovi.Depletions_Next_Month__c!=0){
			        	if(dep3!=null){
		 					dep3.Bottles__c = oovi.Depletions_Next_Month__c;	
		 				}else{
			                dep3 = new Depletion__c();
			                dep3.CurrencyIsoCode = o.CurrencyIsoCode;
			                
			                
			                dep3.Custom_Product__c = oovi.Product_ID__c;
			                
			                dep3.Account__c = o.Account__c;
			                dep3.Month_Of_Date__c = o.Visit_Date__c.addmonths(1).tostartofmonth();
			                dep3.Bottles__c = oovi.Depletions_Next_Month__c;	
		 				}
		 				mapAccountDepletions.put(o.Account__c,storeMapValues(mapAccountDepletions.get(o.Account__c),dep3));
		        	}							
		        }
		        if(!bolFlag){continue;}
		       	
		       	//if OVI records already exist, delete them
		        if(o.Outlet_Visit_Items__r!=null) // && !o.Outlet_Visit_Items__r.isempty()
		        	for(Outlet_Visit_Item__c[] ovi : o.Outlet_Visit_Items__r)
		        		deleteOVI.addall(ovi);
		        
		        //loop thru each Key Task and remove non-complete items
		        for(Key_Task__c k : o.Key_Tasks__r){
		        	if(k.Complete__c==false){
		        		deleteTasks.add(k);
		        	}
		        }	        
	        }   
	        system.debug('myOOVIDeletes'+myOOVIDeletes);
	        delete myOOVIDeletes;	
	        system.debug('deleteOVI'+deleteOVI);
	        delete deleteOVI;
	        system.debug('insertOVI'+insertOVI);
	        insert insertOVI;
	        system.debug('deleteTasks'+deleteTasks);
	        delete deleteTasks;
	        //loop thru the map and pull records out into a list for Update.
	        List<Depletion__c> myUpdates = new List<Depletion__c>(); 
	        for(Map<ID,Map<Date,Depletion__c>> t :mapAccountDepletions.values() )
	        {
	        	for(Map<Date,Depletion__c> z :t.values() )
	        	{
	        		myUpdates.addall(z.values());
	        	}
	        }        
	        system.debug('myUpdates'+myUpdates);
	        upsert myUpdates;
		}else{
			if(!isMobile){return;}
			//if here, then we have come from the Save button on the OutletVisit page.
			//3.14.2011 - nds - added logic to create Offline OVI's regardless of mobile or not
			
			List<Offline_Outlet_Visit_Items__c> myOOVIDeletes = new List<Offline_Outlet_Visit_Items__c>();
			List<Offline_Outlet_Visit_Items__c> myOOVIInserts = new List<Offline_Outlet_Visit_Items__c>();		
			for(Outlet_Visit__c ov : mapOV.values()){
	      		Map<ID,Offline_Outlet_Visit_Items__c> mapOOVIDeletes = new Map<ID,Offline_Outlet_Visit_Items__c>();	
	      		for(Offline_Outlet_Visit_Items__c y : ov.Offline_Outlet_Visit_Items__r){ // delete existing OOVI's, will recreate them
		        	mapOOVIDeletes.put(y.Product_ID__c,y);
	      		}
		        string gridLayout='1';
		        //determine which layout to use (in this case, record type)
		        if(ov.Account__r.Channel__c!=null && ov.Account__r.Channel__c!='')
		        	try{
			        	if(ov.Account__r.Market__r.get(ov.Account__r.Channel__c+'_Channel__c')!=null && ov.Account__r.Market__r.get(ov.Account__r.Channel__c+'_Channel__c')!='')
			        		gridLayout=(string)ov.Account__r.Market__r.get(ov.Account__r.Channel__c+'_Channel__c');
					}catch(exception e){}				
				//lookup the recordtypeid from the schema using gridlayout variable.
				ID recordTypeID = rtMapByName.get(gridLayout).RecordTypeID;
				
				      		
	        	for(Outlet_Visit_Item__c ovi : ov.Outlet_Visit_Items__r){
	       
	        		
					Product__c p = mapProd.get(ovi.Custom_Product__c);
					if(p==null){continue;} //if we can't find the product, then we can't do much, leave it alone
					system.debug(ovi);
					system.debug(p);
					system.debug(p.Depletions__r);		
					Offline_Outlet_Visit_Items__c oovi = mapOOVIDeletes.get(p.ID); //retrieve the existing OOVI if it exists
					if(oovi==null){
						oovi = new Offline_Outlet_Visit_Items__c();
						oovi.Outlet_Visit__c = ov.Id;	
					}
	               	oovi = createOffline(ov, p, recordTypeID, oovi); //pass in the ToCopy OV so we can copy the OVI's to recalc Offline OVIs	               	
	               	system.debug(oovi);    		
	               	//setAlreadyProds.add(p.Id);
	               	myOOVIInserts.add(oovi);
	               	mapOOVIDeletes.remove(p.Id);   
	        	}   
	        	myOOVIDeletes.addall(mapOOVIDeletes.values());		       	
			}
			INFW_Stateful.setAlreadyCreated();
			delete myOOVIDeletes;
			upsert myOOVIInserts;
			
		} 
		if(!isMobile){return;} //has to be isMobile to continue...
	       
        //now we need to check if we need to build a new Outlet Visit AND Offline Outlet Visit Items
        //also check if there is another NEW OV out there that needs recalc'd plus 30 days
        //query the OV's again (and child OVI's) for the affected Account records; Order by ID 
        Map<ID,List<Outlet_Visit__c>> mapAccountOV = new Map<ID,List<Outlet_Visit__c>>();
        for(Outlet_Visit__c[] ov : [Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c,  
			(Select Id, IsDeleted, Name, Outlet_Visit__c, Custom_Product__c, Bottle_Price__c, Bottle_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Double_Price__c, Double_Price_Special__c, Location_On__c, Location_Off__c, Shelf__c, Facing__c, Available__c From Outlet_Visit_Items__r),
			(Select Id, Name, RecordTypeId, Location_On__c, Location_Off__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_This_Month__c, Depletions_Next_Month__c From Offline_Outlet_Visit_Items__r),
			(Select Id, Name, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r)
        	From Outlet_Visit__c o where o.Account__c in: accountIDS.keyset() and (o.Status__c = 'New' or o.Id in: myIDS) for update]){
        	
        	//put the OV's into a map by Account for easy reference
        	for(Integer x = 0; x<ov.size(); x++)
        		mapAccountOV = mapBuilder(ov[x].Account__c,mapAccountOV,ov[x]);	        	
				/*List<Outlet_Visit__c> temp = mapAccountOV.get(ov.Account__c);
				if(temp!=null){
					temp.add(ov);
				}else{
					temp = new List<Outlet_Visit__c>();   
					temp.add(ov);
				}                                       
				mapAccountOV.put(ov.Account__c,temp);*/
    	}
        
        //loop thru each Account in scope, loop for a subsequent OV than the current one we just processed (using accountIDS as our guide)
        Map<ID,Outlet_Visit__c> mapIDsToDuplicate = new Map<ID,Outlet_Visit__c>();
        Map<ID,Outlet_Visit__c> mapIDsToUpdate30 = new Map<ID,Outlet_Visit__c>();
        Map<ID,Outlet_Visit__c> mapIDsToUpdate30ToCopy = new Map<ID,Outlet_Visit__c>();
		system.debug(accountIDS);
		for(ID y : accountIDS.keyset()){
			system.debug('looping acct'+y);
			integer counter = 1;
			integer mySize = mapAccountOV.get(y).size();
			// let's see if there are deglected NEW records
			boolean flag = false;
			for(Outlet_Visit__c z : mapAccountOV.get(y)){
				//if there are other NEW OV's that have been neglected, recal' plus 30				
				if(z.Status__c == 'New'){
					//we have a situation where there is already a NEW record either BEFORE or AFTER the current one we are processing
					mapIDsToUpdate30.put(z.Account__c, z);
					mapIDsToUpdate30ToCopy.put(z.Account__c,accountOV.get(y));
					flag = true;
					break;
				}				
			}
			if(flag){continue;} //skip to next account, since we have a neglected, don't need to duplicate.
			for(Outlet_Visit__c z : mapAccountOV.get(y)){
				//assume we are in ID order asc. if there AREN'T any subsequent IDs, then we need to duplicate.
				system.debug('looping Outlet_Visit__c'+z);
				system.debug('accountIDS.get(y)'+accountIDS.get(y));
				system.debug('counter'+counter);
				system.debug('mySize'+mySize);
				if(z.Id==accountIDS.get(y) && counter==mySize){ //if the LAST OV is the one we already processed
					system.debug('FOUND');
					mapIDsToDuplicate.put(z.Account__c, z);
					break;
				}else{
					counter++;
				}
			}		
		}        	

        system.debug(mapIDsToDuplicate);
        system.debug(mapIDsToUpdate30);
        system.debug(mapIDsToUpdate30ToCopy);
        				
        Map<ID,Outlet_Visit__c> myOVInserts = new Map<ID,Outlet_Visit__c>();
        Map<ID,List<Offline_Outlet_Visit_Items__c>> myOOVIInserts = new Map<ID,List<Offline_Outlet_Visit_Items__c>>();
        Map<ID,List<Key_Task__c>> insertKT = new Map<ID,List<Key_Task__c>>(); 
         	       
/*		//build a map of Products that we can loop thru for each OV below.
        //query all the Wet Goods products and a rough range of	Depletions (note that we add 1 Month to the end date)
        Map<ID,Product__c> mapProd = new Map<ID,Product__c>([Select p.Channel__c, p.Name, p.Market__c, p.Id, p.Brand__c, p.IsActive__c, 
        	(Select Id, OwnerId, IsDeleted, Name, Bottles__c, Month_Of_Date__c, Account__c, Custom_Product__c From Depletions__r where 
        	Account__c in: accountIDS.keyset() and Month_Of_Date__c >=: startDate and Month_Of_Date__c <=: endDate.addmonths(1) ORDER BY Month_Of_Date__c)
			From Product__c p where p.RecordType.Name = 'Wet Goods' ORDER BY p.Brand__r.Supplier__r.Is_B_F_Brand__c DESC, p.Sort_Order__c ASC]);
*/

        Map<ID,Key_Task_Template__c> mapKeyTaskTemplates = new Map<ID,Key_Task_Template__c>([Select k.Outlet_Class__c, k.Name, k.Market__c, k.Id, k.Channel__c 
        	From Key_Task_Template__c k where k.Outlet_Class__c in: outletClasses and k.Market__c =: markets]);
		//loop thru the update30's and set days to 30 days out
      	for(Outlet_Visit__c ov : mapIDsToUpdate30.values()){
      		//so var "ov" is the NEW one, but we need to copy the one just updated.
        	Outlet_Visit__c newOV =  mapIDsToUpdate30ToCopy.get(ov.Account__c);
        	
        	newOV.Visit_Date__c = ov.Visit_Date__c; //set dummy value since ov is what is passed into createoffline      
        	system.debug(newOv.Outlet_Visit_Items__r);		
      		//use this newOV to pass into createoffline.
      		Set<ID> setAlreadyProds = new Set<ID>();
      		decimal intNumberDays = 30;
      		if(ov.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c!=null && ov.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c>0){
      			try{	
      				intNumberDays = intNumberDays / ov.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c;
      			}catch(exception e){} 
      		}
        	ov.Visit_Date__c = date.today().adddays(intNumberDays.setscale(0,system.roundingmode.HALF_UP).intValue());        	
        	//put in a map so we can lookup the newly insert OV's ID by using our known AccountID field
        	myOVInserts.put(ov.Account__c,ov);	        	
        	//loop thru each Offline OVI and recalculate Depletion
		
        
        	for(Offline_Outlet_Visit_Items__c oovi : ov.Offline_Outlet_Visit_Items__r){
				Product__c p = mapProd.get(oovi.Product_ID__c);
				
				
				
				if(p==null){continue;} //if we can't find the product, then we can't do much, leave it alone
				system.debug(oovi);
system.debug(p);
system.debug(p.Depletions__r);		
               	oovi = createOffline(newOV, p, oovi.RecordTypeID, oovi); //pass in the ToCopy OV so we can copy the OVI's to recalc Offline OVIs
               	system.debug(oovi);    		
               	setAlreadyProds.add(p.Id);  
               	myOOVIInserts = mapBuilder(ov.Account__c, myOOVIInserts, oovi); 
        	}    
			Set<ID> alreadyExistKTs = new Set<ID>(); 
			for(Key_Task__c kt : ov.Key_Tasks__r){
				alreadyExistKTs.add(kt.Key_Task_Template__c);
			}        	
        	//myOOVIInserts.put(ov.Account__c,ov.Offline_Outlet_Visit_Items__r);
	        string gridLayout='1';
	        //determine which layout to use (in this case, record type)
	        if(ov.Account__r.Channel__c!=null && ov.Account__r.Channel__c!='')
	        	try{
		        	if(ov.Account__r.Market__r.get(ov.Account__r.Channel__c+'_Channel__c')!=null && ov.Account__r.Market__r.get(ov.Account__r.Channel__c+'_Channel__c')!='')
		        		gridLayout=(string)ov.Account__r.Market__r.get(ov.Account__r.Channel__c+'_Channel__c');
				}catch(exception e){}				
			//lookup the recordtypeid from the schema using gridlayout variable.
			ID recordTypeID = rtMapByName.get(gridLayout).RecordTypeID; 
			ov.RecordTypeID = rtMapByNameOV.get(gridLayout).RecordTypeID;				
        	//now loop thru each possible product and fill in missings        		  	
        	
        	for(Product__c p : mapProd.values()){
        		
        		//narrow the valid products by Active, Market, Channel, etc.
        		
        		
        		
        		if(p.IsActive__c==true && p.Market__c == ov.Account__r.Market__c && !setAlreadyProds.contains(p.Id)){
		            if(p.Channel__c == null || p.Channel__c == 'Both' || (ov.Account__r.Channel__c!=null && p.Channel__c == ov.Account__r.Channel__c)){
		            	//build a map by Account so we can later match the OV to the OVI record (to set the OVI.Outlet_Visit__c ID after insert of OV)
						List<Offline_Outlet_Visit_Items__c> temp = myOOVIInserts.get(ov.Account__c);
						if(temp!=null){
							temp.add(createOffline(newOV,p,recordTypeID, new Offline_Outlet_Visit_Items__c()));
						}else{
							temp = new List<Offline_Outlet_Visit_Items__c>();   
							temp.add(createOffline(newOV,p,recordTypeID, new Offline_Outlet_Visit_Items__c()));
						}  
						system.debug(temp);                                     
						myOOVIInserts.put(ov.Account__c,temp);			            	
		            }          			
        		}
        	}	    
        	//build Key Tasks
        	for(Key_Task_Template__c k : mapKeyTaskTemplates.values()){
        		if(!alreadyExistKTs.contains(k.Id) && k.Outlet_Class__c == ov.Account__r.Outlet_Class__c &&
	        		k.Market__c == ov.Account__r.Market__c &&
	        		(k.Channel__c == 'Both' || k.Channel__c == ov.Account__r.Channel__c)
	        		){ 
						List<Key_Task__c> temp = insertKT.get(ov.Account__c);
		                Key_Task__c kt = new Key_Task__c();
		                kt.Key_Task_Template__c = k.Id;								
						if(temp!=null){					
							temp.add(kt);							
						}else{
							temp = new List<Key_Task__c>();   						
							temp.add(kt);
						}                                       
						insertKT.put(ov.Account__c,temp);				                    				
        		}
        	}            	       	
      	}
      	
        //now we have a map of Account & existing OV that we need to duplicate
        //notice that we have assume that even if more than one OV per account was processed in this transaction, only ONE new OV need be created
        //out map will hold one OV per account; loop thru each OV and clone
        for(Outlet_Visit__c ov : mapIDsToDuplicate.values()){
        	Outlet_Visit__c newOV = ov.Clone(false);
      		decimal intNumberDays = 30;
      		if(ov.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c!=null && ov.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c>0){
      			try{	
      				intNumberDays = intNumberDays / ov.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c;
      			}catch(exception e){} 
      		}          	
        	newOV.Visit_Date__c = newOV.Visit_Date__c.adddays(intNumberDays.setscale(0,system.roundingmode.HALF_UP).intValue());
        		ov.Visit_Date__c = newOV.Visit_Date__c; //set dummy value since ov is what is passed into createoffline
        	newOV.Visit_Comments__c = null;
        	newOV.Status__c = 'New';
        	newOV.Competitor_Activity__c = null;
        	//put in a map so we can lookup the newly insert OV's ID by using our known AccountID field
        	myOVInserts.put(ov.Account__c,newOV);

	        string gridLayout='1';
	        //determine which layout to use (in this case, record type)
	        if(ov.Account__r.Channel__c!=null && ov.Account__r.Channel__c!='')
	        	try{
		        	if(ov.Account__r.Market__r.get(ov.Account__r.Channel__c+'_Channel__c')!=null && ov.Account__r.Market__r.get(ov.Account__r.Channel__c+'_Channel__c')!='')
		        		gridLayout=(string)ov.Account__r.Market__r.get(ov.Account__r.Channel__c+'_Channel__c');
				}catch(exception e){}
			//lookup the recordtypeid from the schema using gridlayout variable.
			ID recordTypeID = rtMapByName.get(gridLayout).RecordTypeID; 
			newOV.RecordTypeID = rtMapByNameOV.get(gridLayout).RecordTypeID;
			//loop thru each possible product
        	for(Product__c p : mapProd.values()){
        		//narrow the valid products by Active, Market, Channel, etc.
        	      system.debug('current product = ' + p); 		
        		if(p.IsActive__c==true && p.Market__c == ov.Account__r.Market__c){
		            if(p.Channel__c == null || p.Channel__c == 'Both' || (ov.Account__r.Channel__c!=null && p.Channel__c == ov.Account__r.Channel__c)){
				            	//build a map by Account so we can later match the OV to the OVI record (to set the OVI.Outlet_Visit__c ID after insert of OV)
system.debug(p);
system.debug(p.Depletions__r);									
								List<Offline_Outlet_Visit_Items__c> temp = myOOVIInserts.get(ov.Account__c);
								if(temp!=null){
									System.debug('temp='+temp);
							temp.add(createOffline(ov,p,recordTypeID, new Offline_Outlet_Visit_Items__c()));
								}else{
									System.debug('new temp='+temp);
									temp = new List<Offline_Outlet_Visit_Items__c>();   
							temp.add(createOffline(ov,p,recordTypeID, new Offline_Outlet_Visit_Items__c()));
								}                                       
								myOOVIInserts.put(ov.Account__c,temp);			            	
				            }          			
        		}
					        				
        		
        	}
			//Set<ID> alreadyExistKTs = new Set<ID>(); 
			//for(Key_Task__c kt : ov.Key_Tasks__r){
			//	alreadyExistKTs.add(kt.Key_Task_Template__c);
			//}               	
        	//build Key Tasks
        	for(Key_Task_Template__c k : mapKeyTaskTemplates.values()){
        		if(k.Outlet_Class__c == ov.Account__r.Outlet_Class__c &&  //!alreadyExistKTs.contains(k.Id) && 
	        		k.Market__c == ov.Account__r.Market__c &&
	        		(k.Channel__c == 'Both' || k.Channel__c == ov.Account__r.Channel__c)
	        		){ 
						List<Key_Task__c> temp = insertKT.get(ov.Account__c);
		                Key_Task__c kt = new Key_Task__c();
		                kt.Key_Task_Template__c = k.Id;								
						if(temp!=null){					
							temp.add(kt);							
						}else{
							temp = new List<Key_Task__c>();   						
							temp.add(kt);
						}                                       
						insertKT.put(ov.Account__c,temp);				                    				
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
        deleteOOVIMoreThanThree(accountIDS.keyset());
    }

	public static void deleteOOVIMoreThanThree(Set<ID> setAcctIds)
	{
        //03.14.11 nds - added logic to delete the previous three OV's OOVI line data
        Map<ID,List<Outlet_Visit__c>> mapAccountOV = new Map<ID,List<Outlet_Visit__c>>();
        for(Outlet_Visit__c[] o : [Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, o.Offline_Use__c 
		        	From Outlet_Visit__c o where o.Status__c = 'Complete' and o.Account__c in: setAcctIds ORDER BY o.Visit_Date__c desc]){
			system.debug(o.size());
			for(Integer x = 0; x<o.size(); x++)
				mapAccountOV = mapBuilder(o[x].Account__c, mapAccountOV, o[x]);       		
       	}
       	system.debug('got here');
       	Set<ID> myDeletes = new Set<ID>();
       	List<Outlet_Visit__c> ovUpdates = new List<Outlet_Visit__c>();
       	
       	for(ID y : mapAccountOV.keyset()){       		
       		integer counter=0;
       		for(Outlet_Visit__c ov : mapAccountOV.get(y)){
       			system.debug(ov);
       			if(counter>=2) { //older than 2, then let's delete the OOVIs
       				//If the old Outlet Visit is still set for Offline Use, turn it off and add it to the list.
       				if (ov.Offline_Use__c) {
       					ov.Offline_Use__c = false;
       					ovUpdates.add(ov);
       				}
       				myDeletes.add(ov.ID);
       			}
       			counter++;
       		}
       	}
       	//If there are any offline use updates to be made, make them
       	if (ovUpdates.size() > 0) {
       		update ovUpdates;
       	}
       	
       	for(Offline_Outlet_Visit_Items__c[] oovi : [Select Id from Offline_Outlet_Visit_Items__c where Outlet_Visit__c in: myDeletes for update])
       		delete oovi;
   		
	}	

    static Map<ID,List<sObject>> mapBuilder(ID mapKey, Map<ID,List<sObject>> mainMap, sObject newItem){
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
    	
	//function used to match Product Ids
    static Outlet_Visit_Item__c selectRow (List<Outlet_Visit_Item__c> ovis, Product__c p){
    		
    	for(Outlet_Visit_Item__c y : ovis){
    	
    		if(y.Custom_Product__c == p.Id){
    			return y;
    		}
    	}
    	return null;
    		}
    
    //function used to create Offline OVI records    
    public static Offline_Outlet_Visit_Items__c createOffline(Outlet_Visit__c ov, Product__c p, ID recordTypeID, Offline_Outlet_Visit_Items__c oovi){
    	
    	
        //Offline_Outlet_Visit_Items__c oovi = new Offline_Outlet_Visit_Items__c();
        oovi.RecordTypeId = recordTypeID;
        

        oovi.Name = p.Name;
        oovi.Product_ID__c = p.Id;
		
        
        oovi.CurrencyIsoCode = ov.CurrencyIsoCode;                
        //if existing OVI data is found, copy that record's values to new Offline OVI
        system.debug(ov);
       	// Loop through the Outlet_Visit_Items for the the current Outlet_Vist
        // for(Outlet_Visit_Item__c ovi : ov.Outlet_Visit_Items__r){
        for(Outlet_Visit_Item__c ovi : [Select o.Name, o.Custom_Product__c, o.Drink_Price__c, o.Drink_Price_Special__c, o.Bottle_Price__c, 
        		o.Bottle_Price_Special__c, o.Double_Price__c, o.Double_Price_Special__c, o.Location_On__c, o.Location_Off__c, o.Shelf__c, o.Facing__c, o.Available__c 
        		from Outlet_Visit_Item__c o 
        		where o.Outlet_Visit__c = :ov.Id] ) {
        	        	
    		if(ovi.Custom_Product__c == p.Id){
    		
	            oovi.Name = p.Name;
    			oovi.Product_ID__c = ovi.Custom_Product__c;
	            
	            oovi.Drink_Price__c=ovi.Drink_Price__c;
	            oovi.Drink_Price_Special__c=ovi.Drink_Price_Special__c;
	            oovi.Bottle_Price__c=ovi.Bottle_Price__c;
	            oovi.Bottle_Price_Special__c=ovi.Bottle_Price_Special__c;
	            oovi.Double_Price__c=ovi.Double_Price__c;
	            oovi.Double_Price_Special__c=ovi.Double_Price_Special__c;
	            
	            oovi.Location_On__c = ovi.Location_On__c;
	            oovi.Location_Off__c = ovi.Location_Off__c;
				oovi.Shelf__c=ovi.Shelf__c;
				oovi.Facing__c=ovi.Facing__c;
				oovi.Available__c=ovi.Available__c;   
				break;
    		}
        }
        /*if(ov.Outlet_Visit_Items__r!=null) // && !ov.Outlet_Visit_Items__r.isempty() 
        {
            Outlet_Visit_Item__c ovi = selectRow(ov.Outlet_Visit_Items__r, p);
            if(ovi==null){ovi = new Outlet_Visit_Item__c(Product__c = p.Id);}  
            oovi.CurrencyIsoCode = ov.CurrencyIsoCode;
            oovi.Name = p.Name;
            oovi.Product_ID__c = ovi.Product__c;
            oovi.Drink_Price__c=ovi.Drink_Price__c;
            oovi.Drink_Price_Special__c=ovi.Drink_Price_Special__c;
            oovi.Bottle_Price__c=ovi.Bottle_Price__c;
            oovi.Bottle_Price_Special__c=ovi.Bottle_Price_Special__c;
            oovi.Double_Price__c=ovi.Double_Price__c;
            oovi.Double_Price_Special__c=ovi.Double_Price_Special__c;
            
			oovi.Space_Placement__c=ovi.Space_Placement__c;
			oovi.Shelf__c=ovi.Shelf__c;
			oovi.Facing__c=ovi.Facing__c;
			oovi.Available__c=ovi.Available__c;     
        }else{
        	//no existing OVI, so no data to copy
            oovi.Name = p.Name;
            oovi.Product_ID__c = p.Id;
            oovi.CurrencyIsoCode = ov.CurrencyIsoCode;
        }*/
        //loop thru the Depletion data and find a match based on month.
        //copy the Bottles__c field into the Depletions_XXX_Month__c fields
		oovi.Depletions_Last_Month_Date__c = ov.Visit_Date__c.addmonths(-1).month() + '/' + ov.Visit_Date__c.addmonths(-1).year();
		oovi.Depletions_This_Month_Date__c = ov.Visit_Date__c.month() + '/' + ov.Visit_Date__c.year();
		oovi.Depletions_Next_Month_Date__c = ov.Visit_Date__c.addmonths(+1).month() + '/' + ov.Visit_Date__c.addmonths(-1).year();		
		oovi.Depletions_Last_Month__c = null;		        	
		oovi.Depletions_This_Month__c = null;		        	
		oovi.Depletions_Next_Month__c = null;
		
		for(Depletion__c y : p.Depletions__r){		
			if(y.Account__c == ov.Account__c){			    	
		        if(y.Month_Of_Date__c.month()==ov.Visit_Date__c.addmonths(-1).month()){
		        	oovi.Depletions_Last_Month__c = y.Bottles__c;		        	
	        	}
		        if(y.Month_Of_Date__c.month()==ov.Visit_Date__c.month()){
		        	oovi.Depletions_This_Month__c=y.Bottles__c;		        	
		        }
		        if(y.Month_Of_Date__c.month()==ov.Visit_Date__c.addmonths(1).month()){
		        	oovi.Depletions_Next_Month__c=y.Bottles__c;							        	
		        }
			}    	
    	}
    	return oovi;
    }
    
    //function used to store nested Map data    
    static Map<ID,Map<date,Depletion__c>> storeMapValues (Map<ID,Map<date,Depletion__c>> temp, Depletion__c d){
		if(temp!=null){
			
			Map<Date,Depletion__c> temp2 = temp.get(d.Custom_Product__c);
			
			
			if(temp2!=null){
				temp2.put(d.Month_Of_Date__c, d);				
			}else{
				temp2 = new Map<Date,Depletion__c>();   
				temp2.put(d.Month_Of_Date__c, d);
			}
		
			temp.put(d.Custom_Product__c, temp2);
		
		
		}else{
			temp = new Map<ID,Map<Date,Depletion__c>>();   
				temp.put(d.Custom_Product__c, new Map<Date,Depletion__c>{d.Month_Of_Date__c=>d});
		}                                       
		return temp;       
    }

	//@future (callout=true) 
	public static void processDatedOOVIsIDS(){ //this one used for new Accounts (dummy OV record set to 30 days old)
		//need to batch over the OV's in groups by Account (really, 1 account at a time);
		//setIds will have Ids of inserted OV's that need bumped up 30 days.
		Set<ID> myAccountIds = new Set<ID>();
		Set<ID> setIds = new Set<ID>();
		for(Outlet_Visit__c ov : [Select ID, Account__c from Outlet_Visit__c where Create_Offline_OVIs__c = true]){ // in: setIds
			setIds.add(ov.Id);
			if(ov.Account__c!=null)
				myAccountIds.add(ov.Account__c);		
		}
		if(myAccountIds==null){return;}
		string acctIds = offlineOutletVisit.swapStringForCollection(myAccountIds);
		string myIds = offlineOutletVisit.swapStringForCollection(setIds);
		string strQuery = 'Select Id from Account where Id in ' + acctIds;
		
		/*string strQuery = 'Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, ' +  
					'(Select Id, IsDeleted, Name, Outlet_Visit__c, Product__c, Bottle_Price__c, Bottle_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Double_Price__c, Double_Price_Special__c, Space_Placement__c, Shelf__c, Facing__c, Available__c From Outlet_Visit_Items__r), ' +
					'(Select Id, Name, RecordTypeId, Space_Placement__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_This_Month__c, Depletions_Next_Month__c From Offline_Outlet_Visit_Items__r), ' +
					'(Select Id, Name, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r) ' +
		        	'From Outlet_Visit__c o where o.Status__c = \'New\' and o.Id in ' + myIds + ' ORDER BY o.Id';	*/
		//processDatedOOVIsLogic(strQuery);
		integer myCount = [Select count() From AsyncApexJob a where a.ApexClass.Name = 'batchableProcessDatedOfflineOutletVisits' and Status in ('Queued','Processing','Preparing')];		
        batchableProcessDatedOfflineOutletVisits batch1 = new batchableProcessDatedOfflineOutletVisits(strQuery,1,myIds);
        if(myCount!=5)
        	Database.executebatch (batch1,1);			   
	}
	
	//@future (callout=true) 
	public static void processDatedOOVIs(){ //this one used by schedulable class to run monthly.
		//need to batch over the OV's in groups by Account (really, 1 account at a time);
		//setIds will have Ids of inserted OV's that need bumped up 30 days.
		Set<ID> myAccountIds = new Set<ID>();
		for(Outlet_Visit__c ov : [Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c   			
		        	From Outlet_Visit__c o where o.Status__c = 'New' and o.Visit_Date__c = LAST_MONTH ORDER BY o.Id]){
			system.debug(ov);
			if(ov.Account__c!=null)
				myAccountIds.add(ov.Account__c);		
		}
		if(myAccountIds==null){return;}
		string acctIds = offlineOutletVisit.swapStringForCollection(myAccountIds);
		string strQuery = 'Select Id from Account where Id in ' + acctIds;		
		system.debug(strQuery);
		/*string strQuery = 'Select o.Account__r.Outlet_Class__c, o.Account__r.Outlet_Class__r.Monthly_Visit_Goal__c, o.Account__r.Channel__c, o.Account__r.Market__r.On_Channel__c, o.Account__r.Market__r.Off_Channel__c, o.Visit_Date__c, o.Visit_Comments__c, o.Status__c, o.OwnerId, o.Name, o.Met_With__c, o.Legacy_ID__c, o.Id, o.CurrencyIsoCode, o.Competitor_Activity__c, o.Account__c, ' +  
					'(Select Id, IsDeleted, Name, Outlet_Visit__c, Product__c, Bottle_Price__c, Bottle_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Double_Price__c, Double_Price_Special__c, Space_Placement__c, Shelf__c, Facing__c, Available__c From Outlet_Visit_Items__r), ' +
					'(Select Id, Name, RecordTypeId, Space_Placement__c, Available__c, Bottle_Price__c, Shelf__c, Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c, Product_ID__c, Drink_Price__c, Outlet_Visit_Item_Key__c, Drink_Price_Special__c, Facing__c, Outlet_Visit__c, Depletions_Last_Month__c, Depletions_This_Month__c, Depletions_Next_Month__c From Offline_Outlet_Visit_Items__r), ' +
					'(Select Id, Name, Outlet_Visit__c, Comments__c, Key_Task_Template__c, Met_With__c, Complete__c From Key_Tasks__r) ' +					
		        	'From Outlet_Visit__c o where o.Status__c = \'New\' and o.Visit_Date__c = LAST_MONTH ORDER BY o.Id';*/	
		//processDatedOOVIsLogic(strQuery);
		integer myCount = [Select count() From AsyncApexJob a where a.ApexClass.Name = 'batchableProcessDatedOfflineOutletVisits' and Status in ('Queued','Processing','Preparing')];
        batchableProcessDatedOfflineOutletVisits batch1 = new batchableProcessDatedOfflineOutletVisits(strQuery,2,null);
        if(myCount!=5)
        	Database.executebatch (batch1,1);		        		
	}

    public static string swapStringForCollection(Set<ID> setIds){
		string myIds = '';
		for(ID y : setIds)
			myIds += '\'' + y + '\',';
        if(myIds.lastIndexOf(',')>0)
        	myIds = myIds.substring(0,myIds.lastIndexOf(',')); 
		myIds = '(' + myIds + ')';
		return myIds;    	
    }     	
}