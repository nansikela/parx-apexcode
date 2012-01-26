public class LeadConvertHandlerTEST {
	static testMethod void leadHandlerTestMethod(){
		
    	String CONVERT_STATUS = 'Qualified';
		try{
			
			//test that experience is moved
			//no opportunity should be created
			Lead l = new Lead(Company = 'Parx', LastName = 'MUSTER', FirstName = 'Max');
			try{
               insert l;
	        }catch(System.DMLException e){
	           System.debug('**** leadHandlerTestMethod Exception> ' + e);
	           System.assert(false);
	        }
			//create Profile_Experience__c
			Profile_Experience__c pex = new Profile_Experience__c();
			pex.Prospect__c = l.Id;			
			insert pex;
			
			
			
			//convert lead
			Database.LeadConvert leadToConvert = new Database.LeadConvert();
			leadToConvert.setLeadId(l.Id);
			leadToConvert.setDoNotCreateOpportunity(true);
			leadToConvert.setConvertedStatus(CONVERT_STATUS);
			
			Database.LeadConvertResult res =  Database.convertLead(leadToConvert, false);
			
			if(res.isSuccess()){
				//check no opp created
				Lead convertedLead = [Select l.ConvertedOpportunityId from Lead l where l.Id = :l.Id];
				System.assertEquals(convertedLead.ConvertedOpportunityId, null);
				//check that p&o updated
				List<Profile_Experience__c> profileExpList = [Select p.Contact__c, p.Prospect__c From Profile_Experience__c p where p.Prospect__c = :l.Id];
				if(!profileExpList.isEmpty()){
					System.assertEquals(profileExpList[0].Contact__c, res.getContactId());
				}else{
					System.assert(false);
				}
			
			}else{
				Database.Error[] errors = res.getErrors();
				for(Database.Error er : errors){
					System.debug('**** convert error ' + er.getMessage());
				}
				System.assert(false);	
			}
			
			
			//test that opportunity is deleted
			Lead l2 = new Lead(Company = 'EHL', LastName = 'Mueller', FirstName = 'T');
			try{
               insert l2;
	        }catch(System.DMLException e){
	           System.debug('**** leadHandlerTestMethod Exception> ' + e);
	           System.assert(false);
	        }		
			
			//convert lead
			Database.LeadConvert leadToConvert2 = new Database.LeadConvert();
			leadToConvert2.setLeadId(l2.Id);
			leadToConvert2.setOpportunityName('test opp name');
			leadToConvert2.setConvertedStatus(CONVERT_STATUS);
			
			Database.LeadConvertResult res2 =  Database.convertLead(leadToConvert2, false);
			
			if(res2.isSuccess()){
				//check opp created but deleted
				Lead convertedLead2 = [Select l.ConvertedOpportunityId from Lead l where l.Id = :l2.Id];
				System.debug('**** lead ' + convertedLead2);
				System.assertNotEquals(convertedLead2.ConvertedOpportunityId, null);
				List<Opportunity> oppList = [Select o.Id from Opportunity o where o.Id = :convertedLead2.ConvertedOpportunityId];
				System.assert(oppList.isEmpty());
			}else{
				Database.Error[] errors = res2.getErrors();
				for(Database.Error er : errors){
					System.debug('**** convert error ' + er.getMessage());
				}
				System.assert(false);	
			}
			
		}catch(System.Exception e){
	        System.debug('**** Final Exception leadHandlerTestMethod ' + e);
	        System.assert(false);
	  	}	
	}
}