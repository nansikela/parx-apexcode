public class NetworkHandler {
    
    String CONTACTTOCONTACT_ID;
    String ACCOUNTACCOUNT_ID;
    String ACCOUNTCONTACT_ID;
    String CONTACTACCOUNT_ID;
    
    Map<String, String> networkRelationship = new Map<String, String>();
    
    /*
    *Select n.Relation_Type__c, n.Contact_to__c, n.Contact_from__c From Network__c n
    */
    
    
    public NetworkHandler (String ccId, String aaId, String acId, String caId){
        CONTACTTOCONTACT_ID = ccId;
        ACCOUNTACCOUNT_ID = aaId;
        ACCOUNTCONTACT_ID = acId;
        CONTACTACCOUNT_ID = caId;
        
        try{
            List<Network_Config__c> configList = [Select n.Relation_from__c, n.Relation_to__c from Network_Config__c n limit 100];
            System.debug('***** NetworkHandler length: ' + configList.size());
            for(Network_Config__c n : configList){
            
                networkRelationship.put(n.Relation_from__c, n.Relation_to__c);
                if(n.Relation_from__c != n.Relation_to__c){
                    networkRelationship.put(n.Relation_to__c, n.Relation_from__c);
                }
            }
        }catch(System.Exception e){
            System.debug('***** NetworkHandler Exception occured: ' + e);
        }
    }
    
    
    ////////*****************************  CONTACT TO CONTACT **************************************
    public void insertNetworkCC(List<Network__c> networkList){
        
        try{
            List<Network__c> newNetworkListToInsert = new List<Network__c>();
            
            for(Network__c n: networkList){
                            
                Network__c newNetwork = new Network__c();
                newNetwork.RecordTypeId = CONTACTTOCONTACT_ID;
                newNetwork.Contact_from__c = n.Contact_to__c;
                newNetwork.Contact_to__c = n.Contact_from__c;
                newNetwork.IsSecondNetwork__c = true;
                
                if(networkRelationship.containsKey(n.Relation_Type__c)){
                    newNetwork.Relation_Type__c = networkRelationship.get(n.Relation_Type__c);
                }else{
                    newNetwork.Relation_Type__c = 'n/a';
                }
                newNetworkListToInsert.add(newNetwork);
            }
            
            System.debug('***** insertNetwork size to insert CC: ' + newNetworkListToInsert.size());
            if(!newNetworkListToInsert.isEmpty()){
                try{
                    insert newNetworkListToInsert;
                }catch(System.DMLException e){
                    System.debug('***** insertNetwork CC Exception occured: ' + e);
                }
            }
        }catch(System.Exception e){
            System.debug('***** insertNetwork CC Exception occured: ' + e);
        }
    }
    
    public void deleteNetworkCC(List<Network__c> networkList, List<Id> contactFromId, List<Id> contactToId, Set<String> relationSet){
        List<Network_Config__c> networkConfigList = [Select Relation_To__c, Relation_From__c from Network_Config__c where Relation_From__c in :relationSet or Relation_To__c in :relationSet];
        
        Set<String> counterRelationSet = new Set<String>();
        for(Network_Config__c nconfig : networkConfigList){
            counterRelationSet.add(nconfig.Relation_To__c);
            counterRelationSet.add(nconfig.Relation_From__c);
        }

        List<Network__c> otherNetworkList = [Select n.Contact_to__c, n.Contact_from__c, Relation_Type__c, n.Id from Network__c n where n.RecordTypeId = :CONTACTTOCONTACT_ID and n.Contact_from__c in :contactToId and n.Contact_to__c in :contactFromId and n.Relation_Type__c in :counterRelationSet];
        Map<Id,Network__c> newNetworkMapToDelete = new Map<Id,Network__c>();
      

        try{
            if(! otherNetworkList.isEmpty()){
                for(Network__c n : networkList){
                
                    for(Network__c otherNetwork : otherNetworkList){
                        if(n.Contact_to__c == otherNetwork.Contact_from__c  && n.Contact_from__c == otherNetwork.Contact_to__c){
            
                            if(networkRelationship.containsKey(n.Relation_Type__c) && otherNetwork.Relation_Type__c == networkRelationship.get(n.Relation_Type__c) && !newNetworkMapToDelete.containsKey(otherNetwork.Id)){
                                newNetworkMapToDelete.put(otherNetwork.Id, otherNetwork);
                            }
                        }
                    }
                }
                
                System.debug('***** deleteNetwork CC newNetworkMapToDelete: ' + newNetworkMapToDelete.size());
                if(!newNetworkMapToDelete.isEmpty()){
                    List<Network__c> nToDelete = new List<Network__c>();
                    for(Id nId : newNetworkMapToDelete.keySet()){
                       nToDelete.add(newNetworkMapToDelete.get(nId)); 
                    }
                    try{
                        delete nToDelete ;
                    }catch(System.DMLException e){
                        System.debug('***** deleteNetwork CC Exception occured: ' + e);
                    }
                }
            }
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
     ////////*****************************  ACCOUNT TO ACCOUNT **************************************
    public void insertNetworkAA(List<Network__c> networkList){
        
        try{
            List<Network__c> newNetworkListToInsert = new List<Network__c>();
            
            for(Network__c n: networkList){
                            
                Network__c newNetwork = new Network__c();
                newNetwork.RecordTypeId = ACCOUNTACCOUNT_ID;
                newNetwork.Account_from__c = n.Account_to__c;
                newNetwork.Account_to__c = n.Account_from__c;
                newNetwork.IsSecondNetwork__c = true;
                
                if(networkRelationship.containsKey(n.Relation_Type__c)){
                    newNetwork.Relation_Type__c = networkRelationship.get(n.Relation_Type__c);
                }else{
                    newNetwork.Relation_Type__c = 'n/a';
                }
                newNetworkListToInsert.add(newNetwork);
            }
            
            System.debug('***** insertNetwork AA size to insert: ' + newNetworkListToInsert.size());
            if(!newNetworkListToInsert.isEmpty()){
                try{
                    insert newNetworkListToInsert;
                }catch(System.DMLException e){
                    System.debug('***** insertNetwork AA Exception occured: ' + e);
                }
            }
        }catch(System.Exception e){
            System.debug('***** insertNetwork AA Exception occured: ' + e);
        }
    }
    
    public void deleteNetworkAA(List<Network__c> networkList, List<Id> accountFromId, List<Id> accountToId, Set<String> relationSet){
        List<Network_Config__c> networkConfigList = [Select Relation_To__c, Relation_From__c from Network_Config__c where Relation_From__c in :relationSet or Relation_To__c in :relationSet];
        
        Set<String> counterRelationSet = new Set<String>();
        for(Network_Config__c nconfig : networkConfigList){
            counterRelationSet.add(nconfig.Relation_To__c);
            counterRelationSet.add(nconfig.Relation_From__c);
        }
        
        List<Network__c> otherNetworkList = [Select n.Account_to__c, n.Account_from__c, Relation_Type__c, n.Id from Network__c n where n.RecordTypeId = :ACCOUNTACCOUNT_ID and n.Account_from__c in :accountToId and n.Account_to__c in :accountFromId and n.Relation_Type__c in :counterRelationSet];
        Map<Id,Network__c> newNetworkMapToDelete = new Map<Id,Network__c>();
        
        try{
            if(! otherNetworkList.isEmpty()){
                for(Network__c n : networkList){
                
                    for(Network__c otherNetwork : otherNetworkList){
                        if(n.Account_to__c == otherNetwork.Account_from__c  && n.Account_from__c == otherNetwork.Account_to__c){
            
                            if(networkRelationship.containsKey(n.Relation_Type__c) && otherNetwork.Relation_Type__c == networkRelationship.get(n.Relation_Type__c)){
                                newNetworkMapToDelete.put(otherNetwork.Id, otherNetwork);
                            }
                        }
                    }
                }
                
                System.debug('***** deleteNetwork AA newNetworkMapToDelete: ' + newNetworkMapToDelete.size());
                if(!newNetworkMapToDelete.isEmpty()){
                    List<Network__c> nToDelete = new List<Network__c>();
                    for(Id nId : newNetworkMapToDelete.keySet()){
                       nToDelete.add(newNetworkMapToDelete.get(nId)); 
                    }
                    try{
                        delete nToDelete;
                    }catch(System.DMLException e){
                        System.debug('***** deleteNetwork AA Exception occured: ' + e);
                    }
                }
            }
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
    
    
     ////////*****************************  ACCOUNT TO CONTACT **************************************
      public void insertNetworkAC(List<Network__c> networkList){
        
        try{
            List<Network__c> newNetworkListToInsert = new List<Network__c>();
            
            for(Network__c n: networkList){
                Network__c newNetwork = new Network__c();
                newNetwork.RecordTypeId = CONTACTACCOUNT_ID;
                newNetwork.IsSecondNetwork__c = true;
                
                newNetwork.Contact_from__c = n.Contact_to__c;
                newNetwork.Account_to__c = n.Account_from__c;
                newNetwork.Valid_from__c = n.Valid_from__c;
                newNetwork.Valid_till__c = n.Valid_till__c;
                    
                if(networkRelationship.containsKey(n.Relation_Type__c)){
                    newNetwork.Relation_Type__c = networkRelationship.get(n.Relation_Type__c);
                }else{
                    newNetwork.Relation_Type__c = 'n/a';
                }
                newNetworkListToInsert.add(newNetwork);
            }
            
            System.debug('***** insertNetwork AC size to insert: ' + newNetworkListToInsert.size());
            if(!newNetworkListToInsert.isEmpty()){
                try{
                    insert newNetworkListToInsert;
                }catch(System.DMLException e){
                    System.debug('***** insertNetwork AC Exception occured: ' + e);
                }
            }
        }catch(System.Exception e){
            System.debug('***** insertNetwork AC Exception occured: ' + e);
        }
    }
    
    public void deleteNetworkAC(List<Network__c> networkList, List<Id> accountFromId, List<Id> contactToId, Set<String> relationSet){
        List<Network_Config__c> networkConfigList = [Select Relation_To__c, Relation_From__c from Network_Config__c where Relation_From__c in :relationSet or Relation_To__c in :relationSet];
        
        Set<String> counterRelationSet = new Set<String>();
        for(Network_Config__c nconfig : networkConfigList){
            counterRelationSet.add(nconfig.Relation_To__c);
            counterRelationSet.add(nconfig.Relation_From__c);
        }
        
        List<Network__c> otherNetworkList = [Select n.Contact_from__c, n.Contact_to__c, n.Account_to__c, n.Account_from__c, Relation_Type__c, n.Id from Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and n.Contact_from__c in :contactToId and n.Account_to__c in :accountFromId and n.Relation_Type__c in :counterRelationSet];
       	Map<Id,Network__c> newNetworkMapToDelete = new Map<Id,Network__c>();
        
        try{
            System.debug('***** deleteNetwork AC otherNetworkLis size: ' + otherNetworkList.size());
            if(!otherNetworkList.isEmpty()){
                for(Network__c n : networkList){
                    for(Network__c otherNetwork : otherNetworkList){
                        if(n.Account_from__c == otherNetwork.Account_to__c  && n.Contact_to__c == otherNetwork.Contact_from__c){
            
                            if(networkRelationship.containsKey(n.Relation_Type__c) && otherNetwork.Relation_Type__c == networkRelationship.get(n.Relation_Type__c)){
                                newNetworkMapToDelete.put(otherNetwork.Id, otherNetwork);
                            }
                        }
                    }
                }
                
                System.debug('***** deleteNetwork AC newNetworkMapToDelete: ' + newNetworkMapToDelete.size());
        
                if(!newNetworkMapToDelete.isEmpty()){
                    List<Network__c> nToDelete = new List<Network__c>();
                    for(Id nId : newNetworkMapToDelete.keySet()){
                       nToDelete.add(newNetworkMapToDelete.get(nId)); 
                    }
                    try{
                        delete nToDelete;
                    }catch(System.DMLException e){
                        System.debug('***** deleteNetwork AC Exception occured: ' + e);
                    }
                }
            }
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
    
    
     ////////*****************************  CONTACT TO ACCOUNT **************************************
      public void insertNetworkCA(List<Network__c> networkList){
        
        try{
            List<Network__c> newNetworkListToInsert = new List<Network__c>();
            
            for(Network__c n: networkList){
                Network__c newNetwork = new Network__c();
                newNetwork.RecordTypeId = ACCOUNTCONTACT_ID;
                newNetwork.IsSecondNetwork__c = true;
                
                newNetwork.Account_from__c = n.Account_to__c;
                newNetwork.Contact_to__c = n.Contact_from__c;
                newNetwork.Valid_from__c = n.Valid_from__c;
                newNetwork.Valid_till__c = n.Valid_till__c;
                
                if(networkRelationship.containsKey(n.Relation_Type__c)){
                    newNetwork.Relation_Type__c = networkRelationship.get(n.Relation_Type__c);
                }else{
                    newNetwork.Relation_Type__c = 'n/a';
                }
                newNetworkListToInsert.add(newNetwork);
            }
            
            System.debug('***** insertNetwork CA size to insert: ' + newNetworkListToInsert.size());
            if(!newNetworkListToInsert.isEmpty()){
                try{
                    insert newNetworkListToInsert;
                }catch(System.DMLException e){
                    System.debug('***** insertNetwork CA Exception occured: ' + e);
                }
            }
        }catch(System.Exception e){
            System.debug('***** insertNetwork CA Exception occured: ' + e);
        }
    }
    
    public void deleteNetworkCA(List<Network__c> networkList, List<Id> contactFromId, List<Id> accountToId, Set<String> relationSet){
        List<Network_Config__c> networkConfigList = [Select Relation_To__c, Relation_From__c from Network_Config__c where Relation_From__c in :relationSet or Relation_To__c in :relationSet];
        
        Set<String> counterRelationSet = new Set<String>();
        for(Network_Config__c nconfig : networkConfigList){
            counterRelationSet.add(nconfig.Relation_To__c);
            counterRelationSet.add(nconfig.Relation_From__c);
        }
        
        List<Network__c> otherNetworkList = [Select n.Contact_from__c, n.Contact_to__c, n.Account_to__c, n.Account_from__c, Relation_Type__c, n.Id from Network__c n where n.RecordTypeId = :ACCOUNTCONTACT_ID and n.Account_from__c in :accountToId and n.Contact_to__c in :contactFromId and n.Relation_Type__c in :counterRelationSet];
        Map<Id,Network__c> newNetworkMapToDelete = new Map<Id,Network__c>();
        
        try{
            if(!otherNetworkList.isEmpty()){
                for(Network__c n : networkList){
                    for(Network__c otherNetwork : otherNetworkList){
                        if(n.Contact_from__c == otherNetwork.Contact_to__c  &&  n.Account_to__c == otherNetwork.Account_from__c){
            
                            if(networkRelationship.containsKey(n.Relation_Type__c) && otherNetwork.Relation_Type__c == networkRelationship.get(n.Relation_Type__c)){
                                newNetworkMapToDelete.put(otherNetwork.Id, otherNetwork);
                            }
                        }
                    }
                    
                }
                
                System.debug('***** deleteNetwork CA newNetworkMapToDelete: ' + newNetworkMapToDelete.size());
        
                if(!newNetworkMapToDelete.isEmpty()){
                    List<Network__c> nToDelete = new List<Network__c>();
                    for(Id nId : newNetworkMapToDelete.keySet()){
                       nToDelete.add(newNetworkMapToDelete.get(nId)); 
                    }
                    try{
                        delete nToDelete;
                    }catch(System.DMLException e){
                        System.debug('***** deleteNetwork CA Exception occured: ' + e);
                    }
                }
            }
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
        }
    }
}