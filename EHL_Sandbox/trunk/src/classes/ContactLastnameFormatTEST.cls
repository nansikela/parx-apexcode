public class ContactLastnameFormatTEST {
	
	static testMethod void contactLastnameMethod(){

	    try{
		
	        
		    Account a = new Account(Name = 'Test Firma');
		    insert a;
		    
		    
		   	List<Contact> contactToInsert = new List<Contact>();
		    
			Contact c1 = new Contact(AccountId = a.Id, Lastname = 'MUEllER', Firstname = 'F1');
			contactToInsert.add(c1);
			Contact c2 = new Contact(AccountId = a.Id, Lastname = 'von gunten', Firstname = 'F2');
			contactToInsert.add(c2);  
			Contact c3 = new Contact(AccountId = a.Id, Lastname = 't\'brian', Firstname = 'F3');
			contactToInsert.add(c3);  
			Contact c4 = new Contact(AccountId = a.Id, Lastname = 'PHD VON DER HEIDE', Firstname = 'F4');
			contactToInsert.add(c4);
			Contact c5 = new Contact(AccountId = a.Id, Lastname = '\'T VANDERSAAR', Firstname = 'F5');
			contactToInsert.add(c5); 
			Contact c6 = new Contact(AccountId = a.Id, Lastname = 'VON GUnTEN-MEIER', Firstname = 'F6');
			contactToInsert.add(c6); 
			Contact c7 = new Contact(AccountId = a.Id, Lastname = 'mcdonald', Firstname = 'F7');
			contactToInsert.add(c7); 
			Contact c8 = new Contact(AccountId = a.Id, Lastname = 'mueVANller-DEmeier', Firstname = 'F8');
			contactToInsert.add(c8); 
	       
	       	try{
                insert contactToInsert;
	        }catch(System.DMLException e){
	            System.debug('**** TEST Exception> ' + e);
	            System.assert(false);
	        }
	         
	        List<Contact> test = [Select c.Lastname from Contact c where c.Id in :contactToInsert];
	       	for(Contact c : test){
	       		if(c.Lastname == 'Mueller'){
	       			System.assert(true);
	       		}else if(c.Lastname == 'Mueller'){
	       			System.assert(true);
	       		}else if(c.Lastname == 'Von Gunten'){
	       			System.assert(true);
	       		}else if(c.Lastname == 't\'Brian'){
	       			System.assert(true);
	       		}else if(c.Lastname == 'PhD von der Heide'){
	       			System.assert(true);
	       		}else if(c.Lastname == '\'t Vandersaar'){
	       			System.assert(true);
	       		}else if(c.Lastname == 'von Gunten-Meier'){
	       			System.assert(true);
	       		}else if(c.Lastname == 'McDonald'){
	       			System.assert(true);
	       		}else if(c.Lastname == 'Muevanller-Demeier'){
	       			System.assert(true);
	       		}else{
	       			System.debug('*** Lastname ' + c.Lastname);
	       			System.assert(false);
	       		}
	       	}
	         
	   }catch(System.Exception e){
	        System.debug('**** Final Exception ContactLastnameFormatTEST ' + e);
	        System.assert(false);

	   }
	}
}