/*Controller stellt die Beziehung zwschen Portfolio2 und einem Seminar (Product2) her.*/

public class Portfolio2BeziehungController 
{
	public List<Seminar_to_PortfolioContainer> seminarToPortfolioList {get; set;}
	String id;
	public Portfolio2BeziehungController()
	{
		seminarToPortfolioList = new List<Seminar_to_PortfolioContainer>();
		
		List<String> seminarIdList = new List<String>();
		
		for(Seminar_to_Portfolio__c s2p : [SELECT ID, Seminar__c FROM Seminar_to_Portfolio__c WHERE Seminar__r.Seminarbeginn__c>=today AND Portfolio__c =:WebURLEncoder.decodeParam('id')])
		{
			seminarIdList.add(s2p.Seminar__c);
		}
		//get all Products in > today
		id = WebURLEncoder.decodeParam('id');
		for(Product2 p : [SELECT ID, name, Seminarbeginn__c, Seminarende__c, Veranstaltungsort2__r.account__r.BillingCity FROM Product2 WHERE Seminarcode__c = :WebURLEncoder.decodeParam('code') AND Seminarbeginn__c>=today AND id Not IN :seminarIdList ORDER BY Seminarbeginn__c LIMIT 1000])
		{
			seminarToPortfolioList.add(new Seminar_to_PortfolioContainer(p, id));
		}
	}
	
	public PageReference save()
	{
		List<Seminar_to_Portfolio__c> insertList = new List<Seminar_to_Portfolio__c>();
		for(Seminar_to_PortfolioContainer s : seminarToPortfolioList)
		{
			if(s.toInsert)
			{
				insertList.add(s.seminarToPortfolio);
			}
		}
		insert insertList;
		return new PageReference('/'+id);
	}
	
	
	public class Seminar_to_PortfolioContainer
	{
		public Seminar_to_Portfolio__c seminarToPortfolio {get; set;}
		public Product2 product {get; set;}
		public boolean toInsert {get; set;}
		
		public Seminar_to_PortfolioContainer(Product2 p, String id)
		{
			this.seminarToPortfolio = new Seminar_to_Portfolio__c();
			this.seminarToPortfolio.Seminar__c = p.id;
			this.seminarToPortfolio.seminarbeginn__c = p.Seminarbeginn__c;
			this.seminarToPortfolio.Portfolio__c = id;
			this.product = p;
			this.toInsert = false;
		}
	}
	
	static testMethod void test() {
		Seminar_to_Portfolio__c p2 = [SELECT Portfolio__c, Portfolio__r.ID, Portfolio__r.name FROM Seminar_to_Portfolio__c LIMIT 1];
		Portfolio2__c p = p2.Portfolio__r;
    	ApexPages.currentPage().getParameters().put('id', p.id);
    	ApexPages.currentPage().getParameters().put('code', p.name);
		Portfolio2BeziehungController controller = new Portfolio2BeziehungController();
		for(Portfolio2BeziehungController.Seminar_to_PortfolioContainer c : controller.seminarToPortfolioList)
		{
			c.toInsert = true;
		}
		controller.save();
	}
}