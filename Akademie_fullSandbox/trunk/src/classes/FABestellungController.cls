/**
* @author Christian Deckert
* @date 18/08/2011
* @description wird nicht mehr verwendet
*/
public class FABestellungController {
	/* public Bestellung2__c bestellung {get; set;}
	public Portfolio2__c portfolio {get; set;}
	public List<FASeminar> seminarList {get; set;}
	public List<SelectOption> terminOptionList {get;set;}
	public String terminString {get; set;}
	public FASeminar currentSeminar {get; set;}
	public FABestellungController()
	{
		
		FAPortfolioController portfoliocontroller = new FAPortfolioController();
		portfolio = portfoliocontroller.currentPortfolio;
		seminarList = portfoliocontroller.seminarList;
		terminString = WebURLEncoder.decodeParam('seminar');
		
		generateTerminOptions();
		
		
		generateBestellung();
	}
	
	private void generateTerminOptions()
	{
		terminOptionList = new List<SelectOption>();
		for(FASeminar s: SeminarList)
		{
			if(s.isAusgebucht!= true)
			{
				if(s.ort == null)s.ort= '';
				terminOptionList.add(new SelectOption( s.id, s.datum+' '+s.ort));
				
				if(s.id.equals(terminString))
				{
					currentSeminar = new FASeminar();
					currentSeminar = s;
				}
			}
		}
	}
	
	
	private void generateBestellung()
	{
		bestellung = new Bestellung2__c();
		bestellung.Kunde__c = FAHelper.getCurrentPerson().id;
		bestellung.Status__c = 'Bestellung durch Kunde';
		bestellung.Kunde_Datum__c = DateTime.now();
		bestellung.Portfolio__c = portfolio.id;
		System.debug('seminarList:'+seminarList);
		for(FASeminarTermine.Seminar s: seminarList)
		{
			if(s.id.equals(terminString))
			{
				currentSeminar = s;
				if(s.isInhouse)
				{
					bestellung.Inhouse_Seminar__c = terminString;
				}
				else
				{
					bestellung.seminar__c = terminString;
				}
			}
		}
	}
	
	public PageReference goToStep2()
	{
		
				return new PageReference(portfolio.url__c+'/order?seminar='+terminString+'&step=1');
			
		
	}
	
	public PageReference save()
	{
		insert bestellung;
		
		FAMailSender.sendSeminarBestellbestaetigung(bestellung, portfolio, currentSeminar);
		
		return new PageReference(portfolio.url__c+'/order?step=thankyou');
	}
	static testMethod void test()
	{
		Person__c pers = [SELECT Benutzer__c, Benutzer__r.id FROM Person__c WHERE Benutzer__c != null LIMIT 1];
		User u = pers.Benutzer__r;
		System.runAs(u){
		Portfolio2__c p = [SELECT ID FROM Portfolio2__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('portfolioId', p.id);
		FABestellungController controller = new FABestellungController();
		}
	} */
}