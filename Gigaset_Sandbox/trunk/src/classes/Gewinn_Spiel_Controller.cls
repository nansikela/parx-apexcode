public class Gewinn_Spiel_Controller {
	public String targetiFrame {get;set;}
	public User u{get;set;}
	public Contact c{get;set;}
	public CampaignMember cm{get;set;}
	public Campaign camp{get;set;}
	public String GeneralConditionId{get;set;}
	public Boolean GeneralCondition{get;set;}

    
	public Gewinn_Spiel_Controller() {
		String name = 'GewinnSpielGeneralCondition';
	    for (Pages__c p: Pages__c.getAll().values()) {
	        if (p.IsActive__c && p.Portal__c==systemSettings.Portal.substring(0,2) && p.Label__c==name && p.isPro__c==SystemSettings.isPro) GeneralConditionId=p.PageId__c;
	    }
		
		u = [select ContactId from User where Id=:UserInfo.getUserId()];
		try{
		   c = [select Keine_Teilnahme_Campus_Incentiv__c from Contact where Id =: u.ContactId];
		   camp = [select id from Campaign where RecordType.developerName = 'Campus_Incentive' AND Portal__c =: SystemSettings.portal and isActive = true and StartDate <=: system.today() and EndDate >=: system.today() limit 1];
        }
        catch(exception e) {}
        try{
        	CM = [select id from CampaignMember where ContactId =: u.ContactId AND CampaignId =: camp.Id];
        	GeneralCondition = true;
        }
        catch(exception e) {}
        
		targetiFrame = System_Settings.TrainingId;
	}
	
  	public PageReference goHome() {
  		Cookie GewinnSpiel = new Cookie('HideGewinnSpiel', UserInfo.getSessionId(),null,-1,false);
  		ApexPages.currentPage().setCookies(new Cookie[]{GewinnSpiel});
  		return SystemSettings.goHome();
  	} 
  	
  	public PageReference lockGame() {
  		c.Keine_Teilnahme_Campus_Incentiv__c = true;
        update c;

		return SystemSettings.goHome();
  	}
  	  	
  	public void Training() {

        system.debug('CM:' + CM);
        try {
        	c.Keine_Teilnahme_Campus_Incentiv__c = true;
            update c;
         }
        catch(exception e) {
        }
        try {
        	if(CM == null || CM.Id == null) {
	            CM = new CampaignMember();
	            CM.ContactId = u.ContactId;
	            CM.CampaignId = camp.Id;
	            CM.Teilnahme_akzeptiert__c = system.today();
	            insert CM;
        	}
        }
        catch(exception e) {
        }

	//	return null;
  	}

}