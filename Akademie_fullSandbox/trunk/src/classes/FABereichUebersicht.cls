/**
* @author Christian Deckert
* @date 18/08/2011
* @description Bereich übersicht controller gibt liefert daten für die Bereich übersicht zurück
*/
 public class FABereichUebersicht 
{
	private transient String bereichId;
	public transient Bereich__c currentBereich {get; set;}
	public transient List<Portfolio2__c> currentBereichPortfolioList {get; set;}
	private transient Map<Id, bereichPortfolioAggregat> currentSubBereich;
	private transient List<bereichPortfolioAggregat>currentSubBereichList;
	private static Map<Id, List<Gruppe__c>> bereichgruppe;
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Constructor
	*/
	public FABereichUebersicht()
	{
		bereichId = WebURLEncoder.decodeParam('bereich');
		findCurrentBereich();
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Der aktuelle Bereich wird gefunden / Portfolios werden eingeordnet
	*/
	private void findCurrentBereich()
	{
		currentSubBereich = new Map<Id, bereichPortfolioAggregat>();
		currentSubBereichList = new List<bereichPortfolioAggregat>();
		currentBereichPortfolioList = new List<Portfolio2__c>();
		//Bereiche Erstellen
		for(Bereich__c b : FAHelper.getBereichList())
		{
			if(b.Beschreibung__c != null)
			{
				b.Beschreibung__c = b.Beschreibung__c.replace('target="_blank"', '');
			}
			System.debug('b.id:'+b.id);
			if(b.id == bereichId)
			{
				currentBereich = b;
			}
			if(b.Hauptbereich__c == bereichId)
			{
				currentSubBereich.put(b.id, new bereichPortfolioAggregat(b));
				currentSubBereichList.add(currentSubBereich.get(b.id));
			}
		}
		//Bereiche Erstellen Ende
		
			System.debug('***Bereiche:'+currentSubBereich);
			for(Portfolio2__c p : FAHelper.getPortfolioList())
			{
				if(currentSubBereich.containsKey(p.Bereich__c))
				{
					tryToAddGruppe(p.Bereich__c, currentSubBereich.get(p.Bereich__c));
					currentSubBereich.get(p.Bereich__c).add(p);
				}
				else if(p.Bereich__c!= null &&currentBereich != null && currentBereich.id != null && currentBereich.id==p.Bereich__c)
				{
					tryToAddGruppe(p.Bereich__c, currentBereichPortfolioList);
					currentBereichPortfolioList.add(p);
				}
			}
			try
			{
			for(Id bereichId : currentSubBereich.keySet())
			{
				tryToAddGruppe(bereichId, currentSubBereich.get(bereichId));
			}
			tryToAddGruppe(bereichId, currentBereichPortfolioList);		
			}catch(Exception e){}
		
		
		
		System.debug('***Bereiche:'+currentSubBereich);
	}
	
	
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Fügt zum aktuellen Bereich die dazu passenden Gruppen hinzu
	* @param
	*/
	private void tryToAddGruppe(Id bereichId, bereichPortfolioAggregat portfolio)
	{
		initGruppen();
		if(bereichgruppe.containsKey(bereichId) && bereichgruppe.get(bereichId).size()>0 && portfolio.size()+1 == bereichgruppe.get(bereichId).get(0).Anordnung__c)
		{
			
			portfolio.add(bereichgruppe.get(bereichId).get(0));
			bereichgruppe.get(bereichId).remove(0);
			tryToAddGruppe(bereichId, portfolio);
		}
		
		
	}
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Der aktuelle Bereich wird gefunden / Portfolios werden eingeordnet
	* @param bereichId beriech id des gewählen bereichs zu dem die gruppe hinzugefügt werden soll
	* @param portfolio liste an Portfolios zu denen die gruppe hinzugefpgt werden soll
	*/
	
	private void tryToAddGruppe(Id bereichId, List<Portfolio2__c> portfolio)
	{
		initGruppen();
		if(bereichgruppe.containsKey(bereichId) && bereichgruppe.get(bereichId).size()>0 && portfolio.size()+1 == bereichgruppe.get(bereichId).get(0).Anordnung__c)
		{
			Gruppe__c g = bereichgruppe.get(bereichId).get(0);
			Portfolio2__c temp = new Portfolio2__c();
			temp.name = g.name;
			temp.Seminartitel__c = g.name__c;
			temp.url__c = g.url__c;
			portfolio.add(temp);
			bereichgruppe.get(bereichId).remove(0);	
			tryToAddGruppe(bereichId, portfolio);
		}
	}
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Inizialisiert Gruppen
	*/
	private void initGruppen()
	{
		if(bereichgruppe == null)
		{
			
			bereichgruppe = new Map<Id, List<Gruppe__c>>();
			for(Gruppe__c g : [SELECT ID, Name, Name__c, URL__c, Bereich__c, Anordnung__c FROM Gruppe__c WHERE Bereich__c <> null AND (Bereich__c = :currentBereich.id OR Bereich__r.Hauptbereich__c =:currentBereich.id) AND Anordnung__c != null ORDER BY Anordnung__c])
			{
				System.debug('******'+g);
				if(!bereichgruppe.containsKey(g.Bereich__c))
				{
					bereichgruppe.put(g.Bereich__c, new List<Gruppe__c>());
				}
				bereichgruppe.get(g.Bereich__c).add(g);
			}
			System.debug( '**********'+ bereichgruppe);
		}
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Prüft ob zum aktuellen Bereich ein Portfolio existiert
	* @return boolean true = ein Portfolio existiert / false kein Portfolio existiert
	*/
	public boolean getIsCurrentBereichPortfolioList()
	{
		return currentBereichPortfolioList.size()>0;
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Liefert aktuellen Subbereich zurück
	* @return Liste von Portfolio Aggregaten
	*/
	public List<bereichPortfolioAggregat> getcurrentSubBereich()
	{
		return currentSubBereichList;
	}
	
	
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Bereich Aggregat Container um breich und deren subbereiche ink. Portfolios zu speichern
	*/
	public class bereichPortfolioAggregat
	{
		public Bereich__c bereich {get; set;}
		public List<Portfolio2__c> portfolioList {get;set;}
		
		/**
		* @author Christian Deckert
		* @date 18/08/2011
		* @description Construktor für Portfolio Aggregate
		* @param b Bereich der aggregiert werden soll
		*/
		public bereichPortfolioAggregat(Bereich__c b)
		{
			this.bereich = b;
			this.portfolioList = new List<Portfolio2__c>();
		}
		/**
		* @author Christian Deckert
		* @date 18/08/2011
		* @description Portfolios bereich zuweisen
		* @param p fügt portfolios zu aktuellem Bereich hinzu
		*/
		public void add(Portfolio2__c p)
		{
			this.portfolioList.add(p);
		}
		/**
		* @author Christian Deckert
		* @date 18/08/2011
		* @description Portfolios bereich zuweisen
		* @return gibt die Anzahl der im Aggregat gespeicherten Portfolios zurück
		*/
		public Integer size()
		{
			return portfolioList.size();
		}
		/**
		* @author Christian Deckert
		* @date 18/08/2011
		* @description Gruppe bereich zuweisen
		* @param g fügt Gruppen 
		*/
		public void add(Gruppe__c g)
		{
			Portfolio2__c temp = new Portfolio2__c();
			temp.name = g.name;
			temp.Seminartitel__c = g.name__c;
			temp.url__c = g.url__c;
			this.add(temp);
		}
		/**
		* @author Christian Deckert
		* @date 18/08/2011
		* @description name des Portfolios ausgeben
		* @return Name des Bereichs
		*/
		public String getName()
		{
			return bereich.name;
		}
	}
	
		/**
		* @author Christian Deckert
		* @date 18/08/2011
		* @description Einfacher Unit Test
		*/
	static testMethod void myUnitTest() {
		Person__c p = [SELECT id, Benutzer__r.id FROM Person__c WHERE Benutzer__c <>'' LIMIT 1];
		
		System.runAs(p.Benutzer__r){
		
			Bereich__c b = [SELECT ID FROM Bereich__c WHERE Hauptbereich__c = '' LIMIT 1];
			ApexPages.currentPage().getParameters().put('bereich', b.id);
			FABereichUebersicht controller = new FABereichUebersicht();
		}
	}
	
	static testMethod void myUnitTest1() {
		
		
			Gruppe__c b = [SELECT Bereich__c FROM Gruppe__c WHERE Bereich__c != null LIMIT 1];
			ApexPages.currentPage().getParameters().put('bereich', b.Bereich__c);
			FABereichUebersicht controller = new FABereichUebersicht();
		
	}
	static testMethod void myUnitTest2() {
		
		
			Gruppe__c b = [SELECT Bereich__r.Hauptbereich__c FROM Gruppe__c WHERE Bereich__r.Hauptbereich__c != null LIMIT 1];
			ApexPages.currentPage().getParameters().put('bereich', b.Bereich__r.Hauptbereich__c);
			FABereichUebersicht controller = new FABereichUebersicht();
		
	}
}