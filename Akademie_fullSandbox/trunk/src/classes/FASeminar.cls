public class FASeminar {
	//Define Object
	public String datum {get; set;}
	public String buchen {get; set;}
	public String titel {get; set;}
	public String code {get; set;}
	public String id {get; set;}
	public String trainer {get; set;}
	public String ort {get; set;}
	public String ortUrl {get; set;}
	public boolean isReservierung {get;set;}
	public boolean isHotelReservierung {get; set;}
	public boolean isHotelReservierungPossible {get; set;}
	public String ezPreis {get; set;}
	public String dzPreis {get; set;}
	public boolean isInhouse {get; set;}
	public String url {get; set;}
	public boolean isAusgebucht{get; set;}
	public String preis {get; set;}
	public String hotelName {get; set;}
	public boolean ezReservierung {get; set;}
	public boolean dzReservierung {get; set;}
	public String anreise {get; set;}
	public String abreise {get; set;}
	public boolean vorgesetzterOK {get; set;}
	public String status {get; set;}
	public Integer statusCode {get; set;}
	
	
	private static boolean isWarenkorb = false;
	//Define Queries
	final static private String inhouseQuery = 'SELECT id, Enddatum__c, Portfolio2__r.name, Portfolio2__r.seminartitel__c, Beginndatum__c, Veranstaltungsort__c, Reservierungen__c, Max_Teilnehmerzahl__c, Anmeldungen__c, Portfolio2__c, Portfolio2__r.URL__c, Portfolio2__r.web_preis__c,  (Select Id, d.Dozent__r.Sprechende_URL__c, d.Dozent__r.FirstName, d.Dozent__r.LastName, d.Dozent__c From Dozenteneins_tze_Inhouse__r d) FROM Inhouse_Produkt__c ';
	final static private String product2Query = 'SELECT ID,  ez_Preis__c, hotel__c, Seminar__r.name, seminar__r.Seminarort__c, seminar__r.Seminarort__r.sprechende_url__c, dz_Preis__c, Seminar__c, portfolio__r.name, portfolio__r.Web_Preis__c, seminar__r.id, Seminar__r.Seminarbeginn__c, Ort__c, Seminar__r.Seminarende__c, seminar__r.Trainer__c ,seminar__r.Trainer__r.Titel_Anrede__c, seminar__r.Co_Trainer__r.Titel_Anrede__c , seminar__r.Trainer__r.Firstname, seminar__r.Trainer__r.Lastname, seminar__r.CO_Trainer__c, seminar__r.CO_Trainer__r.Firstname, seminar__r.CO_Trainer__r.Lastname, seminar__r.Restpl_tze__c, Portfolio__r.url__c, Portfolio__r.seminartitel__c, seminar__r.Trainer__r.sprechende_Url__c, seminar__r.Co_Trainer__r.sprechende_Url__c FROM Seminar_to_Portfolio__c';
	final static private String weProduct2Queray = 'SELECT ID, Inhouse_Seminar__c, Status_Code__c, Inhouse_Seminar__r.id, Inhouse_Seminar__r.Enddatum__c, Inhouse_seminar__r.Portfolio2__r.name, Inhouse_Seminar__r.Portfolio2__r.seminartitel__c, Inhouse_Seminar__r.Beginndatum__c, Inhouse_Seminar__r.Veranstaltungsort__c, Inhouse_Seminar__r.Reservierungen__c, Inhouse_Seminar__r.Max_Teilnehmerzahl__c, Inhouse_Seminar__r.Anmeldungen__c, Inhouse_Seminar__r.Portfolio2__c, Inhouse_Seminar__r.Portfolio2__r.URL__c, Inhouse_Seminar__r.Portfolio2__r.web_preis__c, Seminar__c, Seminar__r.name, seminar__r.Seminarort__c, seminar__r.Seminarort__r.sprechende_url__c, status__c, abreise__c, anreise__c, ez_Preis__c, Einzelzimmer__c, Doppelzimmer__c, Hotelreservierung__c, hotel__c, dz_Preis__c, ist_Reservierung__c, portfolio__r.Web_Preis__c, ort__c, seminar__r.id, Seminar__r.Seminarbeginn__c, Seminar__r.Seminarende__c, seminar__r.Trainer__c , seminar__r.Trainer__r.Firstname, seminar__r.Trainer__r.Lastname, seminar__r.CO_Trainer__c, seminar__r.CO_Trainer__r.Firstname, seminar__r.CO_Trainer__r.Lastname, seminar__r.Restpl_tze__c, Portfolio__r.url__c, Portfolio__r.name, Portfolio__r.Inhouse_Seminar__c, Portfolio__r.seminartitel__c, seminar__r.Trainer__r.sprechende_Url__c, seminar__r.Trainer__r.Titel_Anrede__c, seminar__r.Co_Trainer__r.Titel_Anrede__c, seminar__r.Co_Trainer__r.sprechende_Url__c FROM Warenkorb_Element__c';
	final static private String NICHTVERFUEGBAR = 'Nicht verfügbar';
	
	public FASeminar()
	{
		this.isHotelReservierung = false;
		this.isHotelReservierungPossible = false;
		this.isInhouse = false;
		this.isReservierung = false;
		this.ezReservierung = false;
		this.dzReservierung = false;
		this.vorgesetzterOK = false;
		
	}
	
	private void addPortfolioInformation(Portfolio2__c portfolio)
	{
		if(portfolio.seminartitel__c != null)
		{
			titel = portfolio.seminartitel__c;
			url = portfolio.url__c;
			
			if(portfolio.Web_Preis__c != null)
			{
				preis = String.valueOf(portfolio.Web_Preis__c).replace('.',',').replace(',00',',-');
			}
			else
			{
				preis = NICHTVERFUEGBAR;
			}
		}
		if(portfolio.name != null)
		{
			code = portfolio.name;
		}
	}
	
	public FASeminar(Inhouse_Produkt__c inhouseProduct)
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
		Portfolio2__c portfolio = inhouseProduct.Portfolio2__r;
		
		this.addPortfolioInformation(portfolio);
		
		//IMPLEMENT TRAINER HERE
		if(isWarenkorb== false && inhouseProduct.Dozenteneins_tze_Inhouse__r != null)
		{
			trainer = '';
			for( Dozenteneinsatz_Inhouse__c  d: inhouseProduct.Dozenteneins_tze_Inhouse__r)
			{
				if(trainer!= '')
				{
					trainer= ' und ';
				}
				 trainer += '<a href= \"'+d.Dozent__r.sprechende_Url__c+'\">'+d.Dozent__r.Firstname +' '+d.Dozent__r.Lastname+'</a>';
			}
		}
		
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
	
	public FAseminar(Product2 product)
	{
		this();
		id = product.id;
		if(product != null && product.Seminarbeginn__c!= null)
		{
			datum = product.Seminarbeginn__c.format()+' - '+product.Seminarende__c.format();
		}
		if(product!= null && product.Trainer__c != null)
		{
			trainer = '<a href= \"';
			
			trainer+= product.Trainer__r.sprechende_Url__c+'\">';
			try
			{
				if(product.Trainer__r.Titel_Anrede__c != null)
				{
					trainer+= product.Trainer__r.Titel_Anrede__c+' ';
				}
				
			}catch(Exception e){}
			trainer+= product.Trainer__r.Firstname +' '+product.Trainer__r.Lastname+'</a>';
			if(product!= null && product.Co_Trainer__c != null)
			{
				trainer+= ' und '+'<a href= \"'+product.Co_Trainer__r.sprechende_Url__c+'\">';
				try
				{
					if(product.Co_Trainer__r.Titel_Anrede__c != null)
					{
						trainer+= product.Co_Trainer__r.Titel_Anrede__c+' ';
					}
				}catch(Exception e){}
				trainer+=product.Co_Trainer__r.Firstname+' '+product.Co_Trainer__r.Lastname+'</a>';
			}
		}
		if(product!= null && product.Seminarort__c != null)
		{
			ortUrl = product.Seminarort__r.sprechende_Url__c;
		}
		isHotelReservierungPossible = true;
	}
	
	public FASeminar(Seminar_to_Portfolio__c seminarPortfolio)
	{
		this(seminarPortfolio.seminar__r);
		Product2 product = seminarPortfolio.seminar__r;
		
		if(seminarPortfolio.Ort__c != null)
		{
			ort = seminarPortfolio.Ort__c;
		}
		
		Portfolio2__c portfolio = seminarPortfolio.Portfolio__r;
		addPortfolioInformation(portfolio);
		
		
		buchen = '<a href="'+seminarPortfolio.portfolio__r.url__c+'/order?seminar='+product.id+'&step=1">';
		if(product.Restpl_tze__c>0)
		{
			buchen+='Buchen</a>';
		}
		else
		{
			buchen = '<a href="#">Ausgebucht</a>';
			isAusgebucht = true;
		}
		if(seminarPortfolio.ez_preis__c != null)
		{
			ezPreis = String.valueOf(seminarPortfolio.ez_preis__c).replace('.',',').replace(',00',',-');
		}
		if(seminarPortfolio.dz_preis__c != null)
		{
			dzPreis = String.valueOf(seminarPortfolio.dz_preis__c).replace('.',',').replace(',00',',-');
		}
		hotelName = seminarPortfolio.hotel__c;
	}
	
	public FASeminar(Warenkorb_Element__c we)
	{
		isWarenkorb = true;
		if(we.Portfolio__r.Inhouse_Seminar__c == null || !we.Portfolio__r.Inhouse_Seminar__c)
		{
			this(we.seminar__r);
		}
		else
		{
			this(we.Inhouse_Seminar__r);
			
		}
		if(we.Ort__c != null)
		{
			ort = we.Ort__c;
		}
		
		
		Portfolio2__c portfolio = we.portfolio__r;
		
		this.addPortfolioInformation(portfolio);
		
		if(we.ist_Reservierung__c)
		{
			isReservierung = true;
			preis = 'Reservierung';
		}
		
		isHotelReservierung = we.Hotelreservierung__c;
		
		
		
		if(we.ez_preis__c != null)
		{
			ezPreis = String.valueOf(we.ez_preis__c).replace('.',',').replace(',00',',-');
		}
		if(we.dz_preis__c != null)
		{
			dzPreis = String.valueOf(we.dz_preis__c).replace('.',',').replace(',00',',-');
		}
		hotelName = we.hotel__c;
		ezReservierung = we.Einzelzimmer__c;
		dzReservierung = we.Doppelzimmer__c;
		if(we.anreise__c!= null) anreise = we.anreise__c.format();
		if(we.abreise__c!= null) abreise = we.abreise__c.format();
		if(we.status__c == 'Storno durch Vorgesezter')
		{
			status = 'Storno durch den Vorgesetzten';
		}else if(we.status__c == 'Warten auf Apporval durch Akademie')
		{
			status = 'Seminar wurde durch den Vorgesetzten freigegeben.';
		}
		statusCode = Integer.valueOf(we.Status_Code__c);
		
	}
	
	
	//
	public static List<FASeminar> FASeminarTermine(Portfolio2__c portfolio)
	{
		String portfolioId = portfolio.id;
		List<FASeminar> seminarList = new List<FASeminar>();
		for(Inhouse_Produkt__c inhouseProduct : Database.query(inhouseQuery+' WHERE Portfolio2__c = :portfolioId AND Beginndatum__c >today ORDER BY Beginndatum__c'))
		{
			seminarList.add(new FASeminar(inhouseProduct));
		}
		
		for(Seminar_to_Portfolio__c product2 : Database.query(product2Query+' WHERE Portfolio__c = :portfolioId AND seminar__r.Anzeige_Auf_website__c = true AND Seminar__r.Seminarbeginn__c>today ORDER BY Seminar__r.Seminarbeginn__c '))
		{
			seminarList.add(new FASeminar(product2));
			
		}
		return seminarList;
	}
	
	public static List<FASeminar> getInformationByInhouseProductId(Set<Id> inhouseIdSet)
	{
		List<FASeminar> seminarList = new List<FASeminar>();
		for(Inhouse_Produkt__c inhouseProduct : Database.query(inhouseQuery+' WHERE ID IN :inhouseIdSet  ORDER BY Beginndatum__c'))
		{
			seminarList.add(new FASeminar(inhouseProduct));
		}
		return seminarList;
	}
	
	public static List<FASeminar> getInformationByWaForProduct2(Set<Id> weId)
	{
		List<FASeminar> seminarList = new List<FASeminar>();
		
		for(Warenkorb_Element__c we : Database.query(weProduct2Queray+' WHERE ID IN :weId'))
		{
			seminarList.add(new FASeminar(we));
		}
		
		return seminarList; 
	}
	
	static testMethod void testFaHelper() {
			FASeminar seminar = new FASeminar();
			
			FASeminar.FASeminarTermine([SELECT ID FROM Portfolio2__c LIMIT 1].get(0));
	
	}
}