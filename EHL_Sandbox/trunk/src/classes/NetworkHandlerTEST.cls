public class NetworkHandlerTEST {
	
	static testMethod void networkTestMethodCONTACTTOCONTACT(){
		String CONTACTTOCONTACT_ID = '0122000000050LAAAY';
        
        Map<String, String> networkRelationship = new Map<String, String>();
        try{
        	List<Network_Config__c> relationList = new List<Network_Config__c>();
        	
			Network_Config__c rel1 = new Network_Config__c();
			rel1.Relation_from__c = 'a';
			rel1.Relation_to__c = 'aa';
			relationList.add(rel1);
			
			Network_Config__c rel2 = new Network_Config__c();
			rel2.Relation_from__c = 'b';
			rel2.Relation_to__c = 'bb';
			relationList.add(rel2);
			
			Network_Config__c rel3 = new Network_Config__c();
			rel3.Relation_from__c = 'c';
			rel3.Relation_to__c = 'cc';
			relationList.add(rel3);
		   
			Account a = new Account(Name = 'parx test ag');
			try{
   				insert relationList;
       			insert a;
			}catch(System.DMLException e){
				System.debug('**** TEST Exception insert account> ' + e);
				System.assert(false);
			}
   
			List<Contact> contactList = new List<Contact>();    
			Contact c1 = new Contact(AccountId = a.Id, Lastname = 'MUSTER1', Firstname = 'Max1');
			contactList.add(c1);
			Contact c2 = new Contact(AccountId = a.Id, Lastname = 'MUSTER2', Firstname = 'Max2');
			contactList.add(c2);
			Contact c3 = new Contact(AccountId = a.Id, Lastname = 'MUSTER3', Firstname = 'Max3');
			contactList.add(c3);
			Contact c4 = new Contact(AccountId = a.Id, Lastname = 'MUSTER4', Firstname = 'Max4');
			contactList.add(c4);
			Contact c5 = new Contact(AccountId = a.Id, Lastname = 'MUSTER5', Firstname = 'Max5');
			contactList.add(c5);
			Contact c6 = new Contact(AccountId = a.Id, Lastname = 'MUSTER6', Firstname = 'Max6');
			contactList.add(c6);
	       
	       try{
	           insert contactList;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception insert contact> ' + e);
	           System.assert(false);
	       }
	       
	       List<Network__c> networks = new List<Network__c>();
	       Network__c n1 = new Network__c(RecordTypeId = CONTACTTOCONTACT_ID);
	       n1.Contact_to__c = c1.Id; 
	       n1.Contact_from__c = c2.Id;
	       n1.Relation_Type__c = rel1.Relation_from__c;
	       networks.add(n1);
	       
	       Network__c n2 = new Network__c(RecordTypeId = CONTACTTOCONTACT_ID);
	       n2.Contact_to__c = c3.Id; 
	       n2.Contact_from__c = c4.Id;
	       n2.Relation_Type__c = rel3.Relation_from__c;
	       networks.add(n2);
	       
	       Network__c n3 = new Network__c(RecordTypeId = CONTACTTOCONTACT_ID);
	       n3.Contact_to__c = c5.Id; 
	       n3.Contact_from__c = c6.Id;
	       n3.Relation_Type__c = rel2.Relation_from__c;
	       networks.add(n3);
	       
	       try{
	           insert networks;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception insert network> ' + e);
	           System.assert(false);
	       }
	       
	       networks.clear();
	       
	      networks = [select n.Contact_to__c, n.Contact_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :CONTACTTOCONTACT_ID and n.Contact_from__c = :c1.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel1.Relation_to__c );
	      	System.assertEquals(networks[0].Contact_to__c, c2.Id );
	      	System.assertEquals(networks[0].Contact_from__c, c1.Id );
	      }
	      
	      
	      networks.clear();
	       
	      networks = [select n.Contact_to__c, n.Contact_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :CONTACTTOCONTACT_ID and n.Contact_from__c = :c3.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel3.Relation_to__c);
	      	System.assertEquals(networks[0].Contact_to__c, c4.Id );
	      	System.assertEquals(networks[0].Contact_from__c, c3.Id );
	      }
	      
	      networks.clear();
	       
	      networks = [select n.Contact_to__c, n.Contact_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :CONTACTTOCONTACT_ID and n.Contact_from__c = :c5.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel2.Relation_to__c );
	      	System.assertEquals(networks[0].Contact_to__c, c6.Id );
	      	System.assertEquals(networks[0].Contact_from__c, c5.Id );
	      }

	       //select other network of n1, delete this and check that n1 also deleted
	       networks.clear();
	       
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :CONTACTTOCONTACT_ID and n.Contact_from__c = :c1.Id and n.Contact_to__c = :c2.Id and Relation_Type__c = :rel1.Relation_to__c];
	      System.debug('**** TEST  networkTestMethodCONTACTTOCONTACT size: ' + networks.size());
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
		      try{
		          delete networks[0];
		      }catch(System.DMLException e){
		           System.debug('**** TEST Exception delete network> ' + e);
		           System.assert(false);
		      }
	      	
	      	//check that n1 is deleted
		      networks = [select n.Id From Network__c n where n.Id = :n1.Id];
		      if(!networks.isEmpty()){
		      	System.debug('networks size ' + networks.size());
		      	System.assert(false);
		      }
	      }
	       
	       
	       //delete n2
	    	try{
	           delete n2;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception delete network> ' + e);
	           System.assert(false);
	       }
	       
	       //check that other network also deleted
	       networks.clear();
	       
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :CONTACTTOCONTACT_ID and n.Contact_from__c = :c3.Id and n.Contact_to__c = :c4.Id and Relation_Type__c = :rel3.Relation_to__c];
	      
	      if(!networks.isEmpty()){
	      	System.debug('networks size ' + networks.size());
	      	System.assert(false);
	      }
	       
	      //delete n3
	    	try{
	           delete n3;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception delete network> ' + e);
	           System.assert(false);
	       }
	       
	       //check that other network also deleted
	       networks.clear();
	       
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :CONTACTTOCONTACT_ID and n.Contact_from__c = :c5.Id and n.Contact_to__c = :c6.Id and Relation_Type__c = :rel2.Relation_to__c];
	      
	      if(!networks.isEmpty()){
	      	System.debug('networks size ' + networks.size());
	      	System.assert(false);
	      }

	    }catch(System.Exception e){
	        System.debug('**** Final Exception Testmethod> ' + e);
	        System.assert(false);

	    }
	}
	
	
	static testMethod void networkTestMethodACCOUNTACCOUNT(){
        String ACCOUNTACCOUNT_ID = '0122000000050L5AAI';
        
		List<Network_Config__c> relationList = new List<Network_Config__c>();
        try{	
			Network_Config__c rel1 = new Network_Config__c();
			rel1.Relation_from__c = 'eins';
			rel1.Relation_to__c = 'zwei';
			relationList.add(rel1);
			
			Network_Config__c rel2 = new Network_Config__c();
			rel2.Relation_from__c = 'one';
			rel2.Relation_to__c = 'two';
			relationList.add(rel2);
			
			Network_Config__c rel3 = new Network_Config__c();
			rel3.Relation_from__c = 'un';
			rel3.Relation_to__c = 'dos';
			relationList.add(rel3);
		
		
		   
			List<Account> accountList = new List<Account>(); 
			Account a1 = new Account(Name = 'parx test ag1');
			accountList.add(a1);
			Account a2 = new Account(Name = 'parx test ag2');
			accountList.add(a2);
			Account a3 = new Account(Name = 'parx test ag3');
			accountList.add(a3);
			Account a4 = new Account(Name = 'parx test ag4');
			accountList.add(a4);
			Account a5 = new Account(Name = 'parx test ag5');
			accountList.add(a5);
			Account a6 = new Account(Name = 'parx test ag6');
			accountList.add(a6);

		
			try{
				insert relationList;
			 	insert accountList;
			}catch(System.DMLException e){
			  	System.debug('**** TEST Exception insert account> ' + e);
			  	System.assert(false);
			}
	 
			List<Network__c> networks = new List<Network__c>();
			Network__c n1 = new Network__c(RecordTypeId = ACCOUNTACCOUNT_ID);
			n1.Account_to__c = a1.Id; 
			n1.Account_from__c = a2.Id;
			n1.Relation_Type__c = rel1.Relation_from__c;
			networks.add(n1);
			 
			Network__c n2 = new Network__c(RecordTypeId = ACCOUNTACCOUNT_ID);
			n2.Account_to__c = a3.Id; 
			n2.Account_from__c = a4.Id;
			n2.Relation_Type__c = rel3.Relation_from__c;
			networks.add(n2);
			 
			Network__c n3 = new Network__c(RecordTypeId = ACCOUNTACCOUNT_ID);
			n3.Account_to__c = a5.Id; 
			n3.Account_from__c = a6.Id;
			n3.Relation_Type__c = rel2.Relation_from__c;
			networks.add(n3);
	       
	       try{
	           insert networks;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception insert network> ' + e);
	           System.assert(false);
	       }
	       
	       networks.clear();
	       
	      networks = [select n.Account_to__c, n.Account_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :ACCOUNTACCOUNT_ID and n.Account_from__c = :a1.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel1.Relation_to__c );
	      	System.assertEquals(networks[0].Account_to__c, a2.Id );
	      	System.assertEquals(networks[0].Account_from__c, a1.Id );
	      }
	      
	      
	      networks.clear();
	       
	      networks = [select n.Account_to__c, n.Account_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :ACCOUNTACCOUNT_ID and n.Account_from__c = :a3.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel3.Relation_to__c );
	      	System.assertEquals(networks[0].Account_to__c, a4.Id );
	      	System.assertEquals(networks[0].Account_from__c, a3.Id );
	      }
	      
	      networks.clear();
	       
	      networks = [select n.Account_to__c, n.Account_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :ACCOUNTACCOUNT_ID and n.Account_from__c = :a5.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel2.Relation_to__c );
	      	System.assertEquals(networks[0].Account_to__c, a6.Id );
	      	System.assertEquals(networks[0].Account_from__c, a5.Id );
	      }

	       //select other network of n1, delete this and check that n1 also deleted
	       networks.clear();
	       
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :ACCOUNTACCOUNT_ID and n.Account_from__c = :a1.Id and n.Account_to__c = :a2.Id and Relation_Type__c = :rel1.Relation_to__c];
	      System.debug('**** TEST  networkTestMethodACCOUNTACCOUNT size: ' + networks.size());
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
		      try{
		          delete networks[0];
		      }catch(System.DMLException e){
		           System.debug('**** TEST Exception delete network> ' + e);
		           System.assert(false);
		      }
	      	
	      	//check that n1 is deleted
		      networks = [select n.Id From Network__c n where n.Id = :n1.Id];
		      if(!networks.isEmpty()){
		      	System.debug('networks size ' + networks.size());
		      	System.assert(false);
		      }
	      }
	       
	       
	       //delete n2
	    	try{
	           delete n2;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception delete network> ' + e);
	           System.assert(false);
	       }
	       
	       //check that other network also deleted
	       networks.clear();
	       
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :ACCOUNTACCOUNT_ID and n.Account_from__c = :a3.Id and n.Account_to__c = :a4.Id and Relation_Type__c = :rel3.Relation_to__c];
	      
	      if(!networks.isEmpty()){
	      	System.debug('networks size ' + networks.size());
	      	System.assert(false);
	      }
	       
	      //delete n3
	    	try{
	           delete n3;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception delete network> ' + e);
	           System.assert(false);
	       }
	       
	       //check that other network also deleted
	       networks.clear();
	       
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :ACCOUNTACCOUNT_ID and n.Account_from__c = :a5.Id and n.Account_to__c = :a6.Id and Relation_Type__c = :rel2.Relation_to__c];
	      
	      if(!networks.isEmpty()){
	      	System.debug('networks size ' + networks.size());
	      	System.assert(false);
	      }

	    }catch(System.Exception e){
	        System.debug('**** Final Exception Testmethod> ' + e);
	        System.assert(false);

	    }
	}
	
	
	static testMethod void networkTestMethodACCOUNTCONTACT(){
        String ACCOUNTCONTACT_ID = '0122000000050L6AAI';
        String CONTACTACCOUNT_ID = '0122000000057jLAAQ'; //LIVE
  		//String CONTACTACCOUNT_ID = '012R0000000CrSbIAK'; //SANDBOX
  		
		List<Network_Config__c> relationList = new List<Network_Config__c>();
        try{	
			Network_Config__c rel1 = new Network_Config__c();
			rel1.Relation_from__c = '1';
			rel1.Relation_to__c = '123';
			relationList.add(rel1);
			
			Network_Config__c rel2 = new Network_Config__c();
			rel2.Relation_from__c = '9';
			rel2.Relation_to__c = '987';
			relationList.add(rel2);
			
			Network_Config__c rel3 = new Network_Config__c();
			rel3.Relation_from__c = '5';
			rel3.Relation_to__c = '567';
			relationList.add(rel3);
			
		
		   
			List<Account> accountList = new List<Account>(); 
			Account a1 = new Account(Name = 'parx test ag1');
			accountList.add(a1);
			Account a2 = new Account(Name = 'parx test ag2');
			accountList.add(a2);
			Account a3 = new Account(Name = 'parx test ag3');
			accountList.add(a3);
			Account a4 = new Account(Name = 'parx test ag4');
			accountList.add(a4);
					
			try{
				insert relationList;
			 	insert accountList;
			}catch(System.DMLException e){
			 	System.debug('**** TEST Exception insert account> ' + e);
			 	System.assert(false);
			}
	 
			List<Contact> contactList = new List<Contact>(); 
			Contact c1 = new Contact(AccountId = a4.Id, Lastname = 'MUSTER1', Firstname = 'Max1');
			contactList.add(c1);
			Contact c2 = new Contact(AccountId = a4.Id, Lastname = 'MUSTER2', Firstname = 'Max2');
			contactList.add(c2);
			Contact c3 = new Contact(AccountId = a4.Id, Lastname = 'MUSTER3', Firstname = 'Max3');
			contactList.add(c3);
			
			try{
			 	insert contactList;
			}catch(System.DMLException e){
			 	System.debug('**** TEST Exception insert contact> ' + e);
			 	System.assert(false);
			}
	    
	       //from account a1
	       //to contact c1
	       List<Network__c> networks = new List<Network__c>();
	       Network__c n1 = new Network__c(RecordTypeId = ACCOUNTCONTACT_ID);
	       n1.Account_from__c = a1.Id; 
	       n1.Contact_to__c = c1.Id;
	       n1.Relation_Type__c = rel1.Relation_from__c;
	       n1.Valid_till__c = Date.today();
	       n1.Valid_from__c = Date.today()-10;
	       networks.add(n1);
	       
	      
	       //from account a2
	       // to contact c2
	       Network__c n2 = new Network__c(RecordTypeId = ACCOUNTCONTACT_ID);

	       n2.Account_from__c = a2.Id;
	       n2.Contact_to__c = c2.Id; 
	       n2.Relation_Type__c = rel2.Relation_from__c;
	       networks.add(n2);
	       
	       //from account a3
	       //to contact c3
	       Network__c n3 = new Network__c(RecordTypeId = ACCOUNTCONTACT_ID);
	       n3.Account_from__c = a3.Id;
	       n3.Contact_to__c = c3.Id; 
	       n3.Relation_Type__c = rel2.Relation_from__c;
	       networks.add(n3);
	       
	       try{
	           insert networks;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception insert network> ' + e);
	           System.assert(false);
	       }
	       
	       networks.clear();
	      
	      networks = [select n.Contact_to__c, n.RecordTypeId, n.Valid_till__c, n.Valid_from__c, n.Contact_from__c, n.Account_to__c, n.Account_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and n.Account_to__c = :a1.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel1.Relation_to__c);
	      	System.assertEquals(networks[0].Contact_to__c, null);
	      	System.assertEquals(networks[0].Contact_from__c, c1.Id);
	      	System.assertEquals(networks[0].Account_to__c, a1.Id);
	      	System.assertEquals(networks[0].Account_from__c, null); 
	      	System.assertEquals(networks[0].Valid_till__c, Date.today());
	      	System.assertEquals(networks[0].Valid_from__c, Date.today()-10);
	      }
	      
	      
	      networks.clear();
	       
	      
	      networks = [select n.Contact_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and n.Account_to__c = :a2.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel2.Relation_to__c );
	      	System.assertEquals(networks[0].Contact_from__c, c2.Id );
	      }
	      
	      networks.clear();
	      networks = [select n.Contact_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and n.Account_to__c = :a3.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel2.Relation_to__c );
	      	System.assertEquals(networks[0].Contact_from__c, c3.Id );
	      }

	       //select other network of n1, delete this and check that n1 also deleted
	       networks.clear();

	      networks = [select n.Id From Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and n.Contact_from__c = :c1.Id and n.Account_to__c = :a1.Id and Relation_Type__c = :rel1.Relation_to__c];
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
		      try{
		          delete networks[0];
		      }catch(System.DMLException e){
		           System.debug('**** TEST Exception delete network> ' + e);
		           System.assert(false);
		      }
	      	
	      	//check that n1 is deleted
		      networks = [select n.Id From Network__c n where n.Id = :n1.Id];
		      if(!networks.isEmpty()){
		      	System.debug('networks size ' + networks.size());
		      	System.assert(false);
		      }
	      }

	       //delete n2
	    	try{
	           delete n2;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception delete network> ' + e);
	           System.assert(false);
	       }
	       
	       //check that other network also deleted
	       networks.clear();
	       
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and n.Account_to__c = :a2.Id and n.Contact_from__c = :c2.Id and Relation_Type__c = :rel2.Relation_to__c];
	      
	      if(!networks.isEmpty()){
	      	System.debug('networks size ' + networks.size());
	      	System.assert(false);
	      }
	       
	      //delete n3
	    	try{
	           delete n3;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception delete network> ' + e);
	           System.assert(false);
	       }
	       
	       //check that other network also deleted
	       networks.clear();
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and n.Contact_from__c = :c3.Id and n.Account_to__c = :a3.Id and Relation_Type__c = :rel2.Relation_to__c];
	      
	      if(!networks.isEmpty()){
	      	System.debug('networks size ' + networks.size());
	      	System.assert(false);
	      }

	    }catch(System.Exception e){
	        System.debug('**** Final Exception Testmethod> ' + e);
	        System.assert(false);

	    }
	}
	
	
	static testMethod void networkTestMethodCONTACTACCOUNT(){
        String ACCOUNTCONTACT_ID = '0122000000050L6AAI';
        String CONTACTACCOUNT_ID = '0122000000057jLAAQ'; //LIVE
  		//String CONTACTACCOUNT_ID = '012R0000000CrSbIAK'; //SANDBOX
  		
		List<Network_Config__c> relationList = new List<Network_Config__c>();
        try{	
			Network_Config__c rel1 = new Network_Config__c();
			rel1.Relation_from__c = '1';
			rel1.Relation_to__c = '123';
			relationList.add(rel1);
			
			Network_Config__c rel2 = new Network_Config__c();
			rel2.Relation_from__c = '9';
			rel2.Relation_to__c = '987';
			relationList.add(rel2);
			
			Network_Config__c rel3 = new Network_Config__c();
			rel3.Relation_from__c = '5';
			rel3.Relation_to__c = '567';
			relationList.add(rel3);
			
		
		   
			List<Account> accountList = new List<Account>(); 
			Account a1 = new Account(Name = 'parx test ag1');
			accountList.add(a1);
			Account a2 = new Account(Name = 'parx test ag2');
			accountList.add(a2);
			Account a3 = new Account(Name = 'parx test ag3');
			accountList.add(a3);
			Account a4 = new Account(Name = 'parx test ag4');
			accountList.add(a4);
					
			try{
				insert relationList;
			 	insert accountList;
			}catch(System.DMLException e){
			 	System.debug('**** TEST Exception insert account> ' + e);
			 	System.assert(false);
			}
	 
			List<Contact> contactList = new List<Contact>(); 
			Contact c1 = new Contact(AccountId = a4.Id, Lastname = 'MUSTER1', Firstname = 'Max1');
			contactList.add(c1);
			Contact c2 = new Contact(AccountId = a4.Id, Lastname = 'MUSTER2', Firstname = 'Max2');
			contactList.add(c2);
			Contact c3 = new Contact(AccountId = a4.Id, Lastname = 'MUSTER3', Firstname = 'Max3');
			contactList.add(c3);
			
			try{
			 	insert contactList;
			}catch(System.DMLException e){
			 	System.debug('**** TEST Exception insert contact> ' + e);
			 	System.assert(false);
			}
	    
	       //from contact c1
	       //to account a1
	       List<Network__c> networks = new List<Network__c>();
	       Network__c n1 = new Network__c(RecordTypeId = CONTACTACCOUNT_ID);
	       n1.Contact_from__c = c1.Id; 
	       n1.Account_to__c = a1.Id;
	       n1.Relation_Type__c = rel1.Relation_from__c;
	       n1.Valid_till__c = Date.today();
	       n1.Valid_from__c = Date.today()-10;
	       networks.add(n1);
	       
	      
	       //from contact c2
	       // to account a2
	       Network__c n2 = new Network__c(RecordTypeId = CONTACTACCOUNT_ID);
	       n2.Contact_from__c = c2.Id;
	       n2.Account_to__c = a2.Id; 
	       n2.Relation_Type__c = rel2.Relation_from__c;
	       networks.add(n2);
	       
	       //from contact c3
	       //to account a3
	       Network__c n3 = new Network__c(RecordTypeId = CONTACTACCOUNT_ID);
	       n3.Contact_from__c = c3.Id; 
	       n3.Account_to__c = a3.Id;
	       n3.Relation_Type__c = rel2.Relation_from__c;
	       networks.add(n3);
	       
	       try{
	           insert networks;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception insert network> ' + e);
	           System.assert(false);
	       }
	       
	       networks.clear();
	       
	      networks = [select n.Contact_to__c, n.RecordTypeId, n.Valid_till__c, n.Valid_from__c, n.Contact_from__c, n.Account_to__c, n.Account_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :ACCOUNTCONTACT_ID and n.Account_from__c = :a1.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel1.Relation_to__c);
	      	System.assertEquals(networks[0].Contact_from__c, null);
	      	System.assertEquals(networks[0].Contact_to__c, c1.Id);
	      	System.assertEquals(networks[0].Account_from__c, a1.Id);
	      	System.assertEquals(networks[0].Account_to__c, null); 
	      	System.assertEquals(networks[0].Valid_till__c, Date.today());
	      	System.assertEquals(networks[0].Valid_from__c, Date.today()-10);
	      }
	      
	      
	      networks.clear();
	       
	      
	      networks = [select n.Contact_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and n.Account_to__c = :a2.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel2.Relation_from__c );
	      	System.assertEquals(networks[0].Contact_from__c, c2.Id );
	      }
	      
	      networks.clear();
	      networks = [select n.Contact_from__c, n.Relation_Type__c From Network__c n where n.RecordTypeId = :CONTACTACCOUNT_ID and n.Account_to__c = :a3.Id];
	      
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
	      	System.assertEquals(networks[0].Relation_Type__c, rel2.Relation_from__c );
	      	System.assertEquals(networks[0].Contact_from__c, c3.Id );
	      }

	       //select other network of n1, delete this and check that n1 also deleted
	       networks.clear();

	      networks = [select n.Id From Network__c n where n.RecordTypeId = :ACCOUNTCONTACT_ID and n.Account_from__c = :a1.Id and n.Contact_to__c = :c1.Id and Relation_Type__c = :rel1.Relation_to__c];
	      if(networks.isEmpty()){
	      	System.assert(false);
	      }else{
		      try{
		          delete networks[0];
		      }catch(System.DMLException e){
		           System.debug('**** TEST Exception delete network> ' + e);
		           System.assert(false);
		      }
	      	
	      	//check that n1 is deleted
		      networks = [select n.Id From Network__c n where n.Id = :n1.Id];
		      if(!networks.isEmpty()){
		      	System.debug('networks size ' + networks.size());
		      	System.assert(false);
		      }
	      }
	
	       //delete n2
	    	try{
	           delete n2;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception delete network> ' + e);
	           System.assert(false);
	       }
	       
	       //check that other network also deleted
	       networks.clear();
	       
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :ACCOUNTCONTACT_ID and n.Account_to__c = :a2.Id and n.Contact_from__c = :c2.Id and Relation_Type__c = :rel2.Relation_to__c];
	      
	      if(!networks.isEmpty()){
	      	System.debug('networks size ' + networks.size());
	      	System.assert(false);
	      }
	       
	      //delete n3
	    	try{
	           delete n3;
	       }catch(System.DMLException e){
	           System.debug('**** TEST Exception delete network> ' + e);
	           System.assert(false);
	       }
	       
	       //check that other network also deleted
	       networks.clear();
	      networks = [select n.Id From Network__c n where n.RecordTypeId = :ACCOUNTCONTACT_ID and n.Account_from__c = :a3.Id and n.Contact_to__c = :c3.Id and Relation_Type__c = :rel2.Relation_to__c];
	      
	      if(!networks.isEmpty()){
	      	System.debug('networks size ' + networks.size());
	      	System.assert(false);
	      }

	    }catch(System.Exception e){
	        System.debug('**** Final Exception Testmethod> ' + e);
	        System.assert(false);

	    }
	}
}