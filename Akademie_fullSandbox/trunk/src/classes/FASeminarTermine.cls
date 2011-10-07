public class FASeminarTermine 
{
	public List<Seminar> seminarList {get;set;}
	
		
	public FASeminarTermine(Portfolio2__c portfolio)
	{
		seminarList = new List<Seminar>();
		for(Inhouse_Produkt__c inhouseProduct : [SELECT id, Enddatum__c, Portfolio2__r.seminartitel__c, Beginndatum__c, Veranstaltungsort__c, Reservierungen__c, Max_Teilnehmerzahl__c, Anmeldungen__c, Portfolio2__c, Portfolio2__r.URL__c FROM Inhouse_Produkt__c WHERE Portfolio2__c = :portfolio.id ORDER BY Beginndatum__c])
		{
			seminarList.add(new Seminar(inhouseProduct));
		}
		
		for(Seminar_to_Portfolio__c product2 : [SELECT ID, Seminar__c, seminar__r.id, Seminar__r.Seminarbeginn__c, Ort__c, Seminar__r.Seminarende__c, seminar__r.Trainer__c , seminar__r.Trainer__r.Firstname, seminar__r.Trainer__r.Lastname, seminar__r.CO_Trainer__c, seminar__r.CO_Trainer__r.Firstname, seminar__r.CO_Trainer__r.Lastname, seminar__r.Restpl_tze__c, Portfolio__r.url__c, Portfolio__r.seminartitel__c FROM Seminar_to_Portfolio__c WHERE Portfolio__c = :portfolio.id AND seminar__r.Anzeige_Auf_website__c = true ORDER BY Seminar__r.Seminarbeginn__c ])
		{
			seminarList.add(new Seminar(product2));
			
		}
		
	}
	
	public FASeminarTermine(List<Portfolio2__c> portfolioList)
	{
		Set<ID> portfolioIdSet = new Set<ID>();
		for(Portfolio2__c p : portfolioList)
		{
			portfolioIdSet.add(p.id);
		}
		seminarList = new List<Seminar>();
		for(Inhouse_Produkt__c inhouseProduct : [SELECT id, Enddatum__c, Portfolio2__r.seminartitel__c, Beginndatum__c, Veranstaltungsort__c, Reservierungen__c, Max_Teilnehmerzahl__c, Anmeldungen__c, Portfolio2__c, Portfolio2__r.URL__c FROM Inhouse_Produkt__c WHERE Portfolio2__c IN : portfolioIdSet AND Beginndatum__c > today ORDER BY Beginndatum__c LIMIT 6])
		{
			seminarList.add(new Seminar(inhouseProduct));
		}
		
		for(Seminar_to_Portfolio__c product2 : [SELECT ID, Seminar__c, seminar__r.id,  Seminar__r.Seminarbeginn__c, Ort__c, Seminar__r.Seminarende__c, seminar__r.Trainer__c , seminar__r.Trainer__r.Firstname, seminar__r.Trainer__r.Lastname, seminar__r.CO_Trainer__c, seminar__r.CO_Trainer__r.Firstname, seminar__r.CO_Trainer__r.Lastname, seminar__r.Restpl_tze__c, Portfolio__r.url__c, Portfolio__r.seminartitel__c FROM Seminar_to_Portfolio__c WHERE Portfolio__c IN :portfolioIdSet AND seminar__r.Anzeige_Auf_website__c = true AND Seminarbeginn__c >today ORDER BY Seminar__r.Seminarbeginn__c LIMIT 6])
		{
			seminarList.add(new Seminar(product2));
			
		}
	}
	
	
	
	public class Seminar
	{
		public String id {get; set;}
		public String titel {get; set;}
		public String datum {get; set;}
		public String trainer {get; set;}
		public String url {get;set;}
		public String ort {get; set;}
		public String buchen {get; set;}
		public boolean isAusgebucht {get; set;}
		public boolean isInhouse {get; set;}
		
		public Seminar()
		{
			isInhouse = false;
			isAusgebucht = false;
		}
		
		//Seminar for Inhouse Konstruktor
		public Seminar(Inhouse_Produkt__c inhouseProduct)
		{
			this();
			isInhouse = true;
			if(inhouseProduct.Beginndatum__c!= null)
			{
				datum = inhouseProduct.Beginndatum__c.format()+' - '+inhouseProduct.Enddatum__c.format();
			}
			if(inhouseProduct.Veranstaltungsort__c != null)
			{
				ort = inhouseProduct.Veranstaltungsort__c;
			}
			if(inhouseProduct.Portfolio2__r.seminartitel__c != null)
			{
				titel = inhouseProduct.Portfolio2__r.seminartitel__c;
				url = inhouseProduct.Portfolio2__r.url__c;
			}
			
			//IMPLEMENT TRAINER HERE
			id = inhouseProduct.id;
			buchen = '<a href="'+inhouseProduct.portfolio2__r.url__c+'/order?seminar='+inhouseProduct.id+'&step=1">';
			if(inhouseProduct.Anmeldungen__c == null) inhouseProduct.Anmeldungen__c = 0;
			if(inhouseProduct.Reservierungen__c == null) inhouseProduct.Reservierungen__c = 0;
			if(inhouseProduct.Max_Teilnehmerzahl__c == null) inhouseProduct.Max_Teilnehmerzahl__c = 0;
			if((inhouseProduct.Anmeldungen__c+inhouseProduct.Reservierungen__c)<inhouseProduct.Max_Teilnehmerzahl__c)
			{
				buchen+='Buchen';
			}
			else
			{
				buchen+='Warteliste';
				isAusgebucht = true;
			}
			buchen+='</a>';
		}
		
		public Seminar(Seminar_to_Portfolio__c seminarPortfolio)
		{
			this();
			id = seminarPortfolio.seminar__r.id;
			if(seminarPortfolio.Seminar__c != null && seminarPortfolio.Seminar__r.Seminarbeginn__c!= null)
			{
				datum = seminarPortfolio.Seminar__r.Seminarbeginn__c.format()+' - '+seminarPortfolio.Seminar__r.Seminarende__c.format();
			}
			if(seminarPortfolio.Ort__c != null)
			{
				ort = seminarPortfolio.Ort__c;
			}
			
			if(seminarPortfolio.seminar__c!= null && seminarPortfolio.seminar__r.Trainer__c != null)
			{
				trainer = seminarPortfolio.seminar__r.Trainer__r.Firstname +' '+seminarPortfolio.seminar__r.Trainer__r.Lastname;
				
				if(seminarPortfolio.seminar__c!= null && seminarPortfolio.seminar__r.Co_Trainer__c != null)
				{
					trainer+= ' und '+seminarPortfolio.seminar__r.Co_Trainer__r.Firstname+' '+seminarPortfolio.seminar__r.Co_Trainer__r.Lastname;
				}
			}
			
			if(seminarPortfolio != null && seminarPortfolio.Portfolio__c!= null && seminarPortfolio.Portfolio__r.seminartitel__c!= null)
			{
				titel = seminarPortfolio.Portfolio__r.seminartitel__c;
				url = seminarPortfolio.Portfolio__r.url__c;
			}
			
			buchen = '<a href="'+seminarPortfolio.portfolio__r.url__c+'/order?seminar='+seminarPortfolio.seminar__r.id+'&step=1">';
			if(seminarPortfolio.seminar__r.Restpl_tze__c>0)
			{
				buchen+='Buchen</a>';
			}
			else
			{
				buchen = '<a href="#">Ausgebucht</a>';
				isAusgebucht = true;
			}
		}
		
	}
	
	static testMethod void test(){
		FASeminarTermine controller = new FASeminarTermine([SELECT ID FROM Portfolio2__c LIMIT 20]);
		controller = new FASeminarTermine([SELECT ID FROM Portfolio2__c LIMIT 20].get(0));
	}
}