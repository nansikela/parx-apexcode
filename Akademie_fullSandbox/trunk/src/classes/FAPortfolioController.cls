public class FAPortfolioController 
{
	private transient String portfolioID;
	public Portfolio2__c currentPortfolio {get; set;}
	public List<FASeminar> SeminarList {get; set;}
	public List<Inhouse_Produkt__c> inhouseProductList {get; set;}
	public List<Trainer_Portfolio_Beziehung__c>trainerList {get; set;}
	public List<Bewertung>bewertungen;
	
	
	private static FAPortfolioController singelton;
	
	public static FAPortfolioController getController()
	{
		if(singelton == null)
		{
			singelton = new FAPortfolioController();
		}
		return singelton;
	}
	
	
	private String buchungsURL;
	public FAPortfolioController()
	{
		portfolioID = WebURLEncoder.decodeParam('portfolioId');
		generateCurrentPortfolio();
		SeminarList = FASeminar.FASeminarTermine(currentPortfolio);
		trainerList = generateTrainerList();
	}
	
	private void generateCurrentPortfolio()
	{
		System.debug('portfolioID:'+portfolioID);
		List<Portfolio2__c> tempList = [SELECT ID, name, Neu__c, Buchen_deaktivieren__c, Seminartitel__c, beschreibung__c, url__c, Web_Preis__c, Inhouse_Seminar__c, Reservierungsoption__c   FROM Portfolio2__c WHERE ID = : portfolioID];
		if(tempList.size()>0)
		{
			currentPortfolio = tempList.get(0);
		}
	}
	
	private List<Trainer_Portfolio_Beziehung__c> generateTrainerList()
	{
		
		
		return [Select t.Trainer_URL__c, t.Trainer_Name__c, t.Trainer_Foto__c, t.Portfolio__c From Trainer_Portfolio_Beziehung__c t WHERE t.Portfolio__c = :currentPortfolio.id];
	}
	
	
	public boolean getisTrainer()
	{
		return trainerList.size()>0;
	}
	
	
	public boolean getIsSeminar()
	{
		if(SeminarList.size()>0)
		return true;
		else
		return false;
	}
	
	public class Bewertung
	{
		public String headline {get; set;}
		public Integer stars {get; set;}
		public String starsString {get; set;}
		public String text {get; set;}
		public String name {get; set;}
		
		public Bewertung()
		{
			headline = '';
			stars = 0;
			starsString = '0';
			text = '';
			name = '';
		}
		public Bewertung(Nutzerbewertung__c n)
		{
			this();
			
			if(n.Fazit__c != null)
			{
				headline = n.Fazit__c;
			}
			if(n.Bewertungstext__c != null)
			{
				text = n.Bewertungstext__c.replace('\n', '<br />');
			}
			if(n.Sterne__c != null)
			{
				starsString = n.Sterne__c;
				stars = Integer.valueOf(starsString);
			}
			if(n.Teilnehmer__c != null)
			{
				name = n.Teilnehmer__r.Firstname+' '+n.Teilnehmer__r.Lastname;
			}
		}
	}
	
	
	
	public List<Bewertung> getBewertungen()
	{
		if(bewertungen == null)
		{
			bewertungen = new List<Bewertung>();
			
			for(Nutzerbewertung__c n : [SELECT id, Fazit__c, Bewertungstext__c, Sterne__c, Teilnehmer__c, Teilnehmer__r.firstname, Teilnehmer__r.lastname FROM Nutzerbewertung__c WHERE Seminar__r.Seminarcode__c = :currentPortfolio.name AND Status__c = 'Anzeigen auf Website'])
			{
				bewertungen.add(new Bewertung(n));
			}
		}
		return bewertungen;
	}
	
	public String getStars()
	{
		Integer bewertung = 0;
		for(Bewertung b: getBewertungen())
		{
			bewertung+= b.stars;
		}
		Integer ratingInteger = 0;
		if(getBewertungen().size()>0)
		{
			// die Division von Integern ergibt wieder einen Integer! Das wäre hier falsch!
			Decimal d=Decimal.valueOf(bewertung) / Decimal.valueOf(getBewertungen().size());
			// die Rungung funktioniert nicht mathematisch: round(4.5)=4
			ratingInteger = (d-Math.floor(d))==0.5?Integer.ValueOf(Math.ceil(d)):Math.round(d);
			System.debug('ratingInteger: ' + bewertung +  ' size: ' + getBewertungen().size());
		}
		return String.valueOf(ratingInteger);
	}
	
	public String getBewertungCount()
	{
		String bewertungText = String.valueOf(getBewertungen().size());
		
		return bewertungText; 	
	}
	
	
	
	
	static testMethod void test() 
    {
    	Portfolio2__c p = [SELECT ID FROM Portfolio2__c LIMIT 1];
    	ApexPages.currentPage().getParameters().put('portfolioId', p.id);
    	FAPortfolioController controller = new FAPortfolioController();
    	controller.getIsSeminar();
    }
    static testMethod void test2() 
    {
    	Seminar_to_Portfolio__c p = [SELECT ID, portfolio__c FROM Seminar_to_Portfolio__c  LIMIT 1];
    	ApexPages.currentPage().getParameters().put('portfolioId', p.portfolio__c);
    	FAPortfolioController controller = new FAPortfolioController();
    	controller.getIsSeminar();
    	controller.getBewertungen();
    	controller.getStars();
    }
}