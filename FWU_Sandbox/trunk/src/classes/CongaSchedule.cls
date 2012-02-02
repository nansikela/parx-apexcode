global class CongaSchedule {
	
	private static list<Opportunity> listOpp = new list<Opportunity>();
	private static list<Rechnung__c> listRechnung = new list<Rechnung__c>();
	private static list<EinkaufBestellung__c> listBestellung = new list<EinkaufBestellung__c>();
	private static Integer NumberOfPage = 100;
	private static Integer NumberOfOlisPerPage = 8;
		
	public static void init() {
		getThem();
		if(!listOpp.isEmpty()) { 
			setOpp();
			updateOpp();
		}
		else if(!listRechnung.isEmpty()) { //"else if": we can't mix the job cause of the limitation of 50 for conga
			setRechnung();
			updateRechnung();			
		}
		else if(!listBestellung.isEmpty()) { //"else if": we can't mix the job cause of the limitation of 50 for conga
			setBestellung();
			updateBestellung();			
		}
		
      }
      
      private static void getThem(){
      	//the current limitation of Conga Workflow is 50, so we have to update no more than 50 opp per batch.
      	listOpp = [select id, Conga_Workflow_Trigger__c, Conga_Workflow_for_Activation__c from Opportunity where Conga_Workflow_for_Activation__c = True limit 5];
      	listRechnung = [select id, Conga_Workflow_Trigger__c, Conga_Workflow_for_Activation__c from Rechnung__c where Conga_Workflow_for_Activation__c = True limit 5];
        	listBestellung = [select id, Conga_Workflow_Trigger__c, Conga_Workflow_for_Activation__c from EinkaufBestellung__c where Conga_Workflow_for_Activation__c = True limit 5];
      	if(!listOpp.isEmpty()) {
      		map<Id, Integer> NumberOfElements = new map<Id, Integer>();
      		list<Id> OppIds = new list<Id>();
      		for(Opportunity opp:listOpp) {
      			OppIds.add(opp.Id);
      			NumberOfElements.put(opp.Id, 0);
      		}
      		for(OpportunityLineItem oli:[select id, OpportunityId from OpportunityLineItem where OpportunityId IN:OppIds]) {
      			NumberOfElements.put(oli.OpportunityId, NumberOfElements.get(oli.OpportunityId) + 1 );
      		}
      		list<Opportunity> TempOpps = new list<Opportunity>(listOpp);
      		Integer Counter = 0;
      		listOpp = new list<Opportunity>();
      		for(Opportunity opp:TempOpps) {
      			Counter += NumberOfElements.get(opp.Id);
      			if(Counter > NumberOfPage * NumberOfOlisPerPage) {
      				if(Counter == NumberOfElements.get(opp.Id))  { // the first document is already to big. But we however try to print it out ...
      					//SystemSettings.logError('Operation is too big to be printed out, please do it manually', 'Conga Doc Generation', 'Opportunity', Opp.Id);
      					//opp.Conga_Workflow_for_Activation__c = false;
      					//update opp;
      					listOpp.add(opp);
      				}
      				break;
      			}
      			else {
      				listOpp.add(opp);
      			}
      		}
      	}

      	//SystemSettings.insertErrors();
      }  
      
      private static void setOpp(){
      	for(Opportunity o:listOpp ){
      		o.Conga_Workflow_Trigger__c = True;
      		o.Conga_Workflow_for_Activation__c = false;
      	}		
      }
      
      private static void updateOpp(){
      	update listOpp;
      }
      
      private static void setRechnung(){
      	for(Rechnung__c o:listRechnung ){
      		o.Conga_Workflow_Trigger__c = True;
      		o.Conga_Workflow_for_Activation__c = false;
      	}		
      }
       
      private static void updateRechnung(){
      	update listRechnung;
      }
      
      private static void setBestellung(){
      	for(EinkaufBestellung__c o:listBestellung ){
      		o.Conga_Workflow_Trigger__c = True;
      		o.Conga_Workflow_for_Activation__c = false;
      	}		
      }
      
      private static void updateBestellung(){
      	update listBestellung;
      }
      
      @isTest
      private static void myUnitTest() {
	      	String AccId = testData.creationAccount();
        	Opportunity opp = new Opportunity(Name='Test', AccountId = AccId, StageName = 'In Erstellung', CloseDate = System.today(), REAR2A__c = 0, Lizenznummer__c = '10206', Conga_Workflow_for_Activation__c = True);
        	insert opp;
        	
        	Rechnung__c rechnung = new Rechnung__c(Name='Anyway1', AUN211__c = opp.id, Conga_Workflow_for_Activation__c = True);
    	    	insert rechnung;    	
        	
    	    	EinkaufBestellung__c EB = new EinkaufBestellung__c(Conga_Workflow_for_Activation__c = True);
    	    	insert EB;
    	    	
      	CongaSchedule.init();
      	CongaSchedule.init();
      	CongaSchedule.init();
      }
}