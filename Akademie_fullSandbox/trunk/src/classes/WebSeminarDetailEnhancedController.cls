public class WebSeminarDetailEnhancedController 
{
	public SeminarShortInfo seminarShortInfo {get; set;}
	//Content for middle box
	public SeminarDetailContent sdetailContent {get; set;}
	public List<Seminar> veranstaltungenList {get; set;}
	public List<Nutzerbewertung__c> bewertungsList {get; set;}
	
	
	/*Sigelton*/
	private static WebSeminarDetailEnhancedController instance;
	public static WebSeminarDetailEnhancedController getInstance()
	{
		if(instance == null)
		{
			instance = new WebSeminarDetailEnhancedController();
		}
		return instance;
		
	}
	
	
	//Konstrutor
	public WebSeminarDetailEnhancedController()
	{
		String seminarCode = WebURLEncoder.decodeParam('seminarCode');
		List<Portfolio__c> portfolioList = [SELECT ID, name, Dauer_in_Tagen__c, neu__c, Seminartitel__c, Teilnehmerhinweis__c, Zielgruppe__c, Inhalte__c, Methode__c, englisch__c, Max_Teilnehmer__c, Beginn__c, Ende__c, intro__c, Untertitel__c FROM Portfolio__c WHERE name = :seminarCode AND Portfolio_Jahr__c = :WebConfig.getPortfolioYear() AND Anzeige_auf_website__c = true LIMIT 1];
		if(!portfolioList.isEmpty())
		{
			Portfolio__c portfolio = portfolioList[0];
			//Init seminarBox (Rigt First)
			if(seminarShortInfo== null)
			{
				seminarShortInfo = new SeminarShortInfo(portfolio.Dauer_in_Tagen__c, portfolio.Max_Teilnehmer__c, portfolio.Beginn__c, portfolio.Ende__c);
				seminarShortInfo.buchungslink = '/page?pageid=a0M20000003XjFrEAK&seminarCode='+seminarCode;
			}
			
			//Init Site Content
			if(sdetailContent == null)
			{
				sdetailContent = new SeminarDetailContent(portfolio.name, portfolio.Seminartitel__c);
				
				if(portfolio.NEU__c != null)
				{
					sdetailContent.code += ' NEU';
				}
				
				
				sdetailContent.seminarText = '<h3>'+portfolio.Untertitel__c+'</h3>';
				if(portfolio.intro__c != null)
				{
					sdetailContent.seminarText += '<p>'+portfolio.intro__c+'</p>';
				}
				
				
				if(portfolio.Inhalte__c != null)
				{
					
					if(portfolio.Englisch__c == 'true')
					{
						sdetailContent.seminarText += '<h3>Content</h3>';
					}
					else
					{
						sdetailContent.seminarText += '<h3>Inhalt</h3>';
					}
					sdetailContent.seminarText += ('<ul class=\"list\"><li>'+portfolio.Inhalte__c.replace('<pt>', '</li><li>')+'</li></ul>').replace('<li></li><li>', '<li>');
				}
				
				
				
				if(portfolio.Methode__c != null)
				{
					if(portfolio.Englisch__c == 'true')
					{
						sdetailContent.seminarText += '<h3>Method</h3>';
					}
					else
					{
						sdetailContent.seminarText += '<h3>Methode</h3>';
					}
					sdetailContent.seminarText += '<p>'+portfolio.Methode__c+'</p>';
				}
				if(portfolio.Zielgruppe__c != null)
				{
					if(portfolio.Englisch__c == 'true')
					{
						sdetailContent.seminarText += '<h3>Target Group</h3>';
					}
					else
					{
						sdetailContent.seminarText += '<h3>Zielgruppe</h3>';
					}
					sdetailContent.seminarText += '<p>'+portfolio.Zielgruppe__c+'</p>';
				}
				if(portfolio.Teilnehmerhinweis__c != null)
				{
					sdetailContent.seminarText += portfolio.Teilnehmerhinweis__c.replace('<b>', '<h3>').replace('</b>', '</h3><p>')+'</p>';
				}
				
				
				
			}
			
			
			
			if(veranstaltungenList == null)
			{
				veranstaltungenList = new List<Seminar>();
				for(Product2 p: [SELECT p.id, p.name, p.seminarbeginn__c, p.Restpl_tze__c, p.portfolio__r.name, p.trainer__r.name, p.trainer__r.Sprechende_URL__c, p.Co_Trainer__r.Sprechende_URL__c, p.Co_Trainer__r.name, p.seminarende__c, p.Veranstaltungsort2__r.id, p.Veranstaltungsort2__r.account__r.BillingCity, p.ist_Zusatztermin__c, p.Veranstaltungsort2__r.account__r.Sprechende_URL__c FROM Product2 p WHERE p.Portfolio__r.name = :seminarCode AND p.Anzeige_auf_Website__c = true AND p.seminarbeginn__c>=today ORDER BY p.seminarbeginn__c])
				{
					veranstaltungenList.add(new Seminar(p));
				}
			}
			
			if(bewertungsList == null)
			{
				bewertungsList = [SELECT sterne__c, Fazit__c, Bewertungstext__c, Teilnehmer__r.name FROM Nutzerbewertung__c WHERE Seminar__r.seminarcode__c = :seminarCode AND Status__c = 'Anzeigen auf Website'];
				Double counter = 0;
				Double bewertung = 0;
				for(Nutzerbewertung__c n: BewertungsList)
				{
					if(n.Bewertungstext__c != null)
					{
						n.Bewertungstext__c = n.Bewertungstext__c.replace('\n', '<br/>');
					}
					
					counter++;
					bewertung+= Double.valueOf(n.sterne__c);
				}
				
				if(counter> 0)
				{
					sdetailContent.bewertungen = String.valueOf(counter).replace('.0','')+' Bewertungen';
					sdetailContent.sterne = String.valueOf(Math.round(bewertung/counter));
				}
				
			}
		}
		
	}
	
	
	
	
	class SeminarDetailContent
	{
		public String code {get; set;}
		public String seminarTitel {get; set;}
		public String seminarText {get; set;}
		public String sterne {get; set;}
		public String bewertungen {get; set;}
		public SeminarDetailContent(String pCode, String pTitel)
		{
			sterne = '0';
			bewertungen = '0 Bewertungen';
			if(pCode != null)
			{
				code = pCode;
			}
			if(pTitel != null)
			{
				seminarTitel = pTitel;
			}
		}
	}
	
	
	
	class SeminarShortInfo
	{
		public String dauer {get; set;}
		public String teilnehmer {get; set;}
		public String beginn {get; set;}
		public String ende {get; set;}
		public String buchungslink {get; set;}
		
		public SeminarShortInfo(Decimal pDauer, Decimal pTeilnehmerMax, String pBeginn, String pEnde)
		{
			if(pDauer != null)
			{
				dauer = String.valueOf(pDauer).replace('.0','');
				//Dauer < 1 Tag
				if(dauer == '1')
				{
					dauer += ' Tag';
				}
				else // Dauer > 1Tag
				{
					dauer += ' Tage';
				}
			}
			if(pTeilnehmerMax != null)
			{
				teilnehmer = 'max. '+String.valueOf(pTeilnehmerMax).replace('.0','');
			}
			if(pBeginn!=null)
			{
				beginn = pBeginn;
			}
			if(pEnde != null)
			{
				ende = pEnde.replace(',','<br/>');
			}
		}
	}
	
	
	class Seminar
	{
		public String datum{get; set;}
		public String ort{get; set;}
		public String ortUrl{get; set;}
		public String trainer{get; set;}
		public String cotrainer{get; set;}
		public String trainerURL{get; set;}
		public String cotrainerURL{get; set;}
		public String buchungsText{get; set;}
		public String buchungsURL{get; set;}
		
		public Seminar(Product2 product)
		{
			datum = product.Seminarbeginn__c.format()+' - '+product.Seminarende__c.format();
			if(product.Veranstaltungsort2__c !=null && product.Veranstaltungsort2__r.account__c != null)
			{
				ort = product.Veranstaltungsort2__r.account__r.BillingCity;
				ortUrl = product.Veranstaltungsort2__r.account__r.Sprechende_URL__c;
			}
			
			
			trainer = product.trainer__r.name;
			trainerURL = product.trainer__r.Sprechende_URL__c;
			if(product.Co_Trainer__c != null)
			{
				cotrainer = product.Co_Trainer__r.name;
				cotrainerURL = product.Co_Trainer__r.Sprechende_URL__c;
			}
			buchungsText = 'Buchen';
			buchungsURL = '/page?pageid=a0M20000003XjFrEAK&seminarCode='+product.portfolio__r.name+'&seminarId='+product.id;
			if(product.ist_Zusatztermin__c)
			{
				buchungsText = 'Zusatztermin buchen';
			}
			if(product.Restpl_tze__c < 1.0)
			{
				buchungsText = 'Ausgebucht';
				buchungsURL = '#';
			}
			
			
		}
	}
}