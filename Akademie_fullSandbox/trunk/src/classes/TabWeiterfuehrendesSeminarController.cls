public class TabWeiterfuehrendesSeminarController {
	
	public List<SeminarWeiterfuehrendContainer> portfolioContainer {get; set;}
	private String portfolioId;
	public TabWeiterfuehrendesSeminarController()
	{
		portfolioId = WebURLEncoder.decodeparam('portfolioId');
		Portfolio2__c currentPortfolio = [SELECT id, name, Bereich__r.Firma__c FROM Portfolio2__c WHERE ID = :portfolioId];
		
		Set<ID> currentWeiterfuehrende = new Set<ID>();
		for(Weiterfuehrendes_Portfolio__c wp : [SELECT ID, End_Portfolio__c FROM Weiterfuehrendes_Portfolio__c WHERE Start_Portfolio__c =:portfolioId])
		{
			currentWeiterfuehrende.add(wp.End_Portfolio__c);
		}
		currentWeiterfuehrende.add(currentPortfolio.id);
		portfolioContainer = new List<SeminarWeiterfuehrendContainer>();
		for(Portfolio2__c p : [SELECT ID, name, seminartitel__c FROM Portfolio2__c WHERE ID NOT IN : currentWeiterfuehrende AND Bereich__r.firma__c = :currentPortfolio.Bereich__r.Firma__c])
		{
			portfolioContainer.add(new SeminarWeiterfuehrendContainer(p));
		}
		
	}
	
	
	public PageReference save()
	{
		List<Weiterfuehrendes_Portfolio__c> insertList = new List<Weiterfuehrendes_Portfolio__c>();
		for(SeminarWeiterfuehrendContainer wp: portfolioContainer)
		{
			if(wp.forInsert)
			{
				Weiterfuehrendes_Portfolio__c wptemp = new Weiterfuehrendes_Portfolio__c();
				wptemp.Start_Portfolio__c = portfolioId;
				wptemp.End_Portfolio__c = wp.portfolio.id;
				insertList.add(wptemp);
			}
		}
		if(insertList.size()>0)
		{
			insert insertList;
		}
		
		return new PageReference('/'+portfolioId);
	}
	
	
	class SeminarWeiterfuehrendContainer
	{
		public Portfolio2__c portfolio {get; set;}
		public boolean forInsert {get; set;}
	
		public SeminarWeiterfuehrendContainer(Portfolio2__c p)
		{
			portfolio = p;
			forInsert = false;
		}
	}
	
	static testMethod void test(){
		Portfolio2__c b = [SELECT id FROM Portfolio2__c  LIMIT 1];
		ApexPages.currentPage().getParameters().put('portfolioId', b.id);
		TabWeiterfuehrendesSeminarController controller = new TabWeiterfuehrendesSeminarController();
		controller.save();
	}
}