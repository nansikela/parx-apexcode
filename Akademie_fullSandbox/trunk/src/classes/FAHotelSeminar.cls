public class FAHotelSeminar {
	
	public List<Portfolio2__c>portfolio2;
	
	public List<Portfolio2__c> getcurrentBereichPortfolioList()
	{
		Set<ID>seminare = new Set<Id>();
		for(Seminar_to_Portfolio__c p :[Select s.Seminar__r.Portfolio__c, Portfolio__c, s.Seminar__c From Seminar_to_Portfolio__c s WHERE Seminar__r.Veranstaltungsort2__c = :WebURLEncoder.decodeParam('hotelId') AND Seminar__r.Seminarbeginn__c >today])
		{
			if(!seminare.contains(p.Portfolio__c))
			{
				seminare.add(p.Portfolio__c);
			}			
		}
		portfolio2 = [SELECT name, Seminartitel__c, url__c, neu__c FROM Portfolio2__c WHERE ID IN :seminare AND LIVE__C = true AND Bereich__r.Firma__c = :FAHelper.getCurrentFirma().id];
		return portfolio2;
	}
	public boolean getisCurrentBereichPortfolioList()
	{
		if(getcurrentBereichPortfolioList().size()>0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
   
   static testMethod void myUnitTest() {
   	FAHotelSeminar controller = new FAHotelSeminar();
   	controller.getcurrentBereichPortfolioList();
   	controller.getisCurrentBereichPortfolioList();
   }
}