trigger Network_afterInsertUpdateDelete on Network__c (after insert, after delete) {
    try{
        String CONTACTTOCONTACT_ID = '0122000000050LAAAY';
        String ACCOUNTACCOUNT_ID = '0122000000050L5AAI';
        String ACCOUNTCONTACT_ID = '0122000000050L6AAI';
        String CONTACTACCOUNT_ID = '0122000000057jLAAQ'; //LIVE
  		//String CONTACTACCOUNT_ID = '012R0000000CrSbIAK'; //SANDBOX
         
        //contact to contact      
        List<Network__c> newNetworkCCList = new List<Network__c>();
        List<Network__c> oldNetworkCCList = new List<Network__c>();
        List<Id> contactFromCCList = new List<Id>();
        List<Id> contactToCCList = new List<Id>();
        
        //account to account
        List<Network__c> newNetworkAAList = new List<Network__c>();
        List<Network__c> oldNetworkAAList = new List<Network__c>();
        List<Id> accountFromAAList = new List<Id>();
        List<Id> accountToAAList = new List<Id>();
        
        //account to contact
        List<Network__c> newNetworkACList = new List<Network__c>();
        List<Network__c> oldNetworkACList = new List<Network__c>();
        List<Id> accountFromACList = new List<Id>();
        List<Id> contactToACList = new List<Id>();
        
         //contact to account
        List<Network__c> newNetworkCAList = new List<Network__c>();
        List<Network__c> oldNetworkCAList = new List<Network__c>();
        List<Id> contactFromCAList = new List<Id>();
        List<Id> accountToCAList = new List<Id>();
       
        //set with relation type for deletion
        Set<String> relationSet = new Set<String>();
        
        //initalize handler
        NetworkHandler nHandler = new NetworkHandler(CONTACTTOCONTACT_ID, ACCOUNTACCOUNT_ID, ACCOUNTCONTACT_ID, CONTACTACCOUNT_ID);
        
        
        //get data
        if(Trigger.isInsert){
            for(Network__c n : Trigger.new){
                if(n.IsSecondNetwork__c != true){
                    if(n.RecordTypeId == CONTACTTOCONTACT_ID){
                    	//CONTACT TO CONTACT
                    	newNetworkCCList.add(n);
                    	contactFromCCList.add(n.Contact_from__c);
                    }else if(n.RecordTypeId == ACCOUNTACCOUNT_ID){
                    	//ACCOUNT TO ACCOUNT
                    	newNetworkAAList.add(n);
                    	accountFromAAList.add(n.Account_from__c);
                    }else if(n.RecordTypeId == ACCOUNTCONTACT_ID){
                    	//ACCOUNT TO CONTACT
                    	newNetworkACList.add(n);
                    }
                    else if(n.RecordTypeId == CONTACTACCOUNT_ID){
                    	//ACCOUNT TO CONTACT
                    	newNetworkCAList.add(n);
                    }	
                }
            }
        }
        else if(Trigger.isDelete){
            for(Network__c n : Trigger.old){
                if(n.RecordTypeId == CONTACTTOCONTACT_ID){
                    //CONTACT TO CONTACT
                    oldNetworkCCList.add(n);
                    contactFromCCList.add(n.Contact_from__c);
                    contactToCCList.add(n.Contact_to__c);
                }else if(n.RecordTypeId == ACCOUNTACCOUNT_ID){
                	//ACCOUNT TO ACCOUNT
                	oldNetworkAAList.add(n);
                	accountFromAAList.add(n.Account_from__c);
                	accountToAAList.add(n.Account_to__c);
                }else if(n.RecordTypeId == ACCOUNTCONTACT_ID){
                	//ACCOUNT TO CONTACT
                	oldNetworkACList.add(n);
                	accountFromACList.add(n.Account_from__c);
                	contactToACList.add(n.Contact_to__c);
                }else if(n.RecordTypeId == CONTACTACCOUNT_ID){
                	//CONTACT TO ACCOUNT
                	oldNetworkCAList.add(n);
                	contactFromCAList.add(n.Contact_from__c);
                	accountToCAList.add(n.Account_to__c);
                }
                relationSet.add(n.Relation_Type__c);
            }
        }
                
        //process data
        if(Trigger.isInsert){
            System.debug('**** Network_afterInsertUpdateDelete, insert ' +newNetworkCCList.size() + ' ' + newNetworkAAList.size() + ' ' + newNetworkACList.size() + ' ' +newNetworkCAList.size());
            //CONTACT TO CONTACT
            if(!newNetworkCCList.isEmpty()){
                nHandler.insertNetworkCC(newNetworkCCList);
            }
            
            //ACCOUNT TO ACCOUNT
            if(!newNetworkAAList.isEmpty()){
                nHandler.insertNetworkAA(newNetworkAAList);
            }
            
            //ACCOUNT TO CONTACT
            if(!newNetworkACList.isEmpty()){
                nHandler.insertNetworkAC(newNetworkACList);
            }
            
            //CONTACT TO ACCOUNT
            if(!newNetworkCAList.isEmpty()){
                nHandler.insertNetworkCA(newNetworkCAList);
            }
            
        }else if(Trigger.isDelete){
            //CONTACT TO CONTACT
            if(!oldNetworkCCList.isEmpty()){
                nHandler.deleteNetworkCC(oldNetworkCCList, contactFromCCList, contactToCCList, relationSet);
            }
            
            //ACCOUNT TO ACCOUNT
            if(!oldNetworkAAList.isEmpty()){
                nHandler.deleteNetworkAA(oldNetworkAAList, accountFromAAList, accountToAAList, relationSet);
            }
            
            //ACCOUNT TO CONTACT
            if(!oldNetworkACList.isEmpty()){
                nHandler.deleteNetworkAC(oldNetworkACList, accountFromACList, contactToACList, relationSet);
            }
            
            //CONTACT TO ACCOUNT
            if(!oldNetworkCAList.isEmpty()){
                nHandler.deleteNetworkCA(oldNetworkCAList, contactFromCAList, accountToCAList, relationSet);
            }
        }
        
    }catch(System.Exception e){
        System.debug('**** Exception: ' + e);   
    }
}