/**
 * Firmenakademie Navigationsfacade
 *
 * @author Christian Deckert
 * @version 1.0
 */
public class FaNavigationFacade {

	public  List<NaviItem>topNaviItem {get; set;}
	public  NaviItem leftNaviItem {get; set;}
	public  List<NaviItemBreadC> breadCrumb {get; set;}
	final static String STARTSEITEID = WebSiteSetting__c.getAll().get('Startseite').value__c;

	
	/** 
     * Konstruktor erstellt Top Navigation / BreadCrumb und Linke Navigation
     *
     */
	public FaNavigationFacade()
	{
		generateTopNavigation();
		generateBreadCrumb();
		generateLeftNavigation();
	}





	/** 
     * Klasse eines NavigationsElementes
     */
	public class NaviItem
	{
		public String item {get; set;}
		public String url {get; set;}
		public boolean isActive {get; set;}
		public List<NaviItem> subItemList {get; set;}
		
		public NaviItem()
		{
			isActive = false;
			subItemList = new List<NaviItem>();
		}
		
		public NaviItem(String name, String url)
		{
			this();
			this.item = name;
			this.url = url;
		}
		
		
		public String getName()
		{
			return this.item;
		}
	}
	
	/** 
     * Generiert obere Navigation
     * @see FAHelper.currentFirma()
     */
	private void generateTopNavigation()
	{
		topNaviItem = new List<NaviItem>();
		List<Navigation__c> navigation = [Select n.url__c, n.oeffentliche_url__c, n.Name, n.Id, n.Firma__c, (Select Id, Name, url__c, oeffentliche_url__c From Untergeordnet__r WHERE Breadcrumb__c != true ORDER BY Anordnung__c) From Navigation__c n  WHERE Firma__c = :FAHelper.getCurrentFirma().id AND breadCrumb__c = false ORDER BY Anordnung__c ];
		for(Navigation__c n :navigation)
		{
			NaviItem tempTop = new NaviItem(n.name, n.oeffentliche_url__c);
			for(Navigation__c nn: n.Untergeordnet__r)
			{
				tempTop.subItemList.add(new NaviItem(nn.name, nn.oeffentliche_url__c) );
			}
			topNaviItem.add(tempTop);
		}
	}
	
	
	
	
	private void generateLeftNavigation()
	{
		leftNaviItem = topNaviItem.get(0);
		for(NaviItem n : topNaviItem)
		{
			if(n.isActive)
			{
				leftNaviItem = n;
			}
		}
	}
	
	
	
	private void generateBreadCrumb()
	{
		breadCrumb = new List<NaviItemBreadC>();
		String url = ApexPages.currentPage().getUrl();
		
		//FOR DEBUG
		if(url== null)
		{
			
			Navigation__c debugNav = [SELECT ID, url__c FROM Navigation__c WHERE uebergeordnet__c != '' AND Name !='Startseite' LIMIT 1];
			url = debugNav.url__c;
			
			
		}
		
		if(url.contains('/apex/'))
		{
			url = url.replace('/apex/','/');
		}
		System.debug('********URL'+url);
		//Trainer
		String trainerId = WebURLEncoder.decodeParam('trainerId');
		if(trainerId != '')
		{
			breadCrumb.add(new NaviItemBreadC('Trainer und Berater','/seminare/trainer'));
			FATrainerDetailController controller = new FATrainerDetailController();
			breadCrumb.add(new NaviItemBreadC(FATrainerDetailController.name,'/seminare/trainer'));
			
		}
		
		try
		{
			if(WebURLEncoder.decodeParam('mode') == 'search')
			{
				breadCrumb.add(new NaviItemBreadC('Seminarsuche','/seminarsearch'));
			}
			
		}catch(Exception e){}
		
		String portfolioId = WebURLEncoder.decodeParam('portfolioId');
		String groupId = WebURLEncoder.decodeParam('groupId');
		try
		{
		if(groupId != null && groupId != '')
		{
			List<Gruppe__c> gruppeList = [SELECT URL__c, name__c, bereich__c, bereich__r.name, bereich__r.Hauptbereich__c, bereich__r.Hauptbereich__r.name FROM Gruppe__c WHERE ID = :groupId];
			if(gruppeList.size()>0)
			{
				Gruppe__c currentgruppe = gruppeList.get(0);
				
				
				
				//breadCrumb Bereich
				if(currentgruppe.bereich__c != null)
				{
					
					System.debug('*******BEREICH:'+currentgruppe.bereich__c); 
					List<String> bereichURL  = new List<String>();
					bereichURL.add('/FABereichUebersicht?bereich='+String.valueOf(currentgruppe.bereich__c).subString(0,15));
					//IF WHERE IS Hauptbereich
					
					if(currentgruppe.bereich__r.Hauptbereich__c != null)
					{
						
						bereichURL.add('/FABereichUebersicht?bereich='+String.valueOf(currentgruppe.bereich__r.Hauptbereich__c).subString(0,15));
						bereichURL.add('/WebBereichUebersicht?bereich='+String.valueOf(currentgruppe.bereich__r.Hauptbereich__c).subString(0,15));
					}
					List<Navigation__c> naviList = [SELECT ID, name, Oeffentliche_URL__c FROM Navigation__c WHERE URL__c IN:bereichURL];
					if(naviList.size()>0)
					{
						breadCrumb.add(new NaviItemBreadC(naviList.get(0).name, naviList.get(0).Oeffentliche_URL__c));
					}
				}
				//breadCrumb Gruppe
				breadCrumb.add(new NaviItemBreadC(currentgruppe.name__c, currentgruppe.url__c));
				
				//breadCrumb Bestellung
				if(url.contains('FABestellung'))
				{
					breadCrumb.add(new NaviItemBreadC('Bestellung', currentgruppe.url__c+'/order'));
				}
			}
		}
		}catch(Exception e){}
		
		try
		{
			String hotelId = WebURLEncoder.decodeParam('hotelId');
			if(WebURLEncoder.decodeParam('hotelId') != '')
			{
				Hotel__c hotel = [SELECT name, Account__r.sprechende_URL__C FROM HOTEL__C WHERE Id = :hotelId];
				breadCrumb.add(new NaviItemBreadC('Seminarhotels','/seminare/hotels'));
				breadCrumb.add(new NaviItemBreadC(hotel.name,hotel.Account__r.sprechende_URL__c));
			}
		}catch (Exception e){}
		
		try
		{
			String article = WebURLEncoder.decodeParam('article');
			if(WebURLEncoder.decodeParam('article') != '')
			{
				BWL_Lexikon__c articleDB = [SELECT name, sprechende_URL__C FROM BWL_Lexikon__c WHERE Name = :article];
				breadCrumb.add(new NaviItemBreadC('Service','/service'));
				breadCrumb.add(new NaviItemBreadC('Akademie Lexikon','/service/lexikon'));
				breadCrumb.add(new NaviItemBreadC(articleDB.name, articleDB.sprechende_URL__c));
			}
		}catch (Exception e){}
		//Portfolio
		if(portfolioId!= null && portfolioId!='')
		{
			List<Portfolio2__c> portfolioList = [SELECT URL__c, seminartitel__c, bereich__c, bereich__r.name, bereich__r.Hauptbereich__c, bereich__r.Hauptbereich__r.name FROM Portfolio2__c WHERE ID = :portfolioId];
			if(portfolioList.size()>0)
			{
				Portfolio2__c currentPortfolio = portfolioList.get(0);
				
				
				
				//breadCrumb Bereich
				if(currentPortfolio.bereich__c != null)
				{
					
					System.debug('*******BEREICH:'+currentPortfolio.bereich__c); 
					List<String> bereichURL  = new List<String>();
					bereichURL.add('/FABereichUebersicht?bereich='+String.valueOf(currentPortfolio.bereich__c).subString(0,15));
					//IF WHERE IS Hauptbereich
					
					if(currentPortfolio.bereich__r.Hauptbereich__c != null)
					{
						
						bereichURL.add('/FABereichUebersicht?bereich='+String.valueOf(currentPortfolio.bereich__r.Hauptbereich__c).subString(0,15));
						bereichURL.add('/WebBereichUebersicht?bereich='+String.valueOf(currentPortfolio.bereich__r.Hauptbereich__c).subString(0,15));
					}
					List<Navigation__c> naviList = [SELECT ID, name, Oeffentliche_URL__c FROM Navigation__c WHERE URL__c IN:bereichURL];
					if(naviList.size()>0)
					{
						breadCrumb.add(new NaviItemBreadC(naviList.get(0).name, naviList.get(0).Oeffentliche_URL__c));
					}
				}
				//breadCrumb seminar
				breadCrumb.add(new NaviItemBreadC(currentPortfolio.seminartitel__c, currentPortfolio.url__c));
				
				//breadCrumb Bestellung
				if(url.contains('FABestellung'))
				{
					breadCrumb.add(new NaviItemBreadC('Bestellung', currentPortfolio.url__c+'/order'));
				}
			}
		}
		else
		{
			if(url.contains('WebBereichUebersicht'))
			{
				url = '/WebBereichUebersicht?bereich='+WebURLEncoder.decodeParam('bereich');
				System.debug('*****url'+url);
			}
			
			List<Navigation__c> navElementList = [SELECT ID, name, oeffentliche_URL__c, Uebergeordnet__c, Uebergeordnet__r.oeffentliche_URL__c, Uebergeordnet__r.name, Uebergeordnet__r.Uebergeordnet__c, Uebergeordnet__r.Uebergeordnet__r.oeffentliche_URL__c FROM Navigation__c  WHERE URL__c = :url AND Name !='Startseite'];
			if(navElementList.size()>0)
			{
				Navigation__c navigation = navElementList.get(0);
				if(navigation.Uebergeordnet__r.Uebergeordnet__c != null && navigation.Uebergeordnet__r.Uebergeordnet__r.oeffentliche_URL__c != '/seminare')
				{
					breadCrumb.addAll(beadCrumbNav(navigation.Uebergeordnet__r.Uebergeordnet__c));
				}
				if(navigation.Uebergeordnet__c != null && navigation.Uebergeordnet__r.oeffentliche_URL__c != '/seminare')
				{
					breadCrumb.add(new NaviItemBreadC(navigation.Uebergeordnet__r.name, navigation.Uebergeordnet__r.oeffentliche_URL__c));
				}
				breadCrumb.add(new NaviItemBreadC(navigation.name, navigation.oeffentliche_URL__c));
			}
		}
		
		
		if(breadCrumb.size()>0)
		{
			NaviItemBreadC breadCrumbItem1 = breadCrumb.get(0);
			for(NaviItem nTop :topNaviItem)
			{
				if(nTop.url == breadCrumbItem1.url)
				{
					nTop.isActive = true;
				}
			}
			
		}
		
	}
	
	private List<NaviItemBreadC> beadCrumbNav(ID navigationID)
	{
		List<NaviItemBreadC> result =  new List<NaviItemBreadC>();
		
		List<Navigation__c> tempNavList = [SELECT id, name, oeffentliche_URL__c, uebergeordnet__c FROM Navigation__c WHERE ID = :navigationID];
		if(tempNavList.size()>0)
		{
			Navigation__c currNav = tempNavList.get(0);
			if(currNav.uebergeordnet__c != null && currNav.Uebergeordnet__r.oeffentliche_URL__c!='/seminare')
			{
				result.addAll(beadCrumbNav(currNav.uebergeordnet__c));
			}
			result.add(new NaviItemBreadC(currNav.name, currNav.oeffentliche_URL__c));
		}
		return result;
	}
	
	
	//Nav for BreadCrub
	public class NaviItemBreadC
	{
		public String item {get; set;}
		public String url {get; set;}
		
		public NaviItemBreadC(String item, String url)
		{
			
				this.item = item;
				this.url = url;
			
		}
		
		public String getName()
		{
			return item;
		}
	}
	
	
	//Tracking on webSites
	public void tracking()
	{
		try{
		Besuchte_Seite__c b = new Besuchte_Seite__c();
		b.Kunde__c = FAHelper.getCurrentPerson().id;
		b.Zeitpunkt__c = DateTime.now();
		String url = WebURLEncoder.decodeParam('url');
		b.URL__c = url.replace('http://akademie.parx.ch','');
		if(url.contains('/seminare/'))
		{
			List<Portfolio2__c> portfolios = [SELECT ID FROM Portfolio2__c WHERE URL__c = : b.url__c];
			if(portfolios.size()>0)
			{
				b.Portfolio__c = portfolios.get(0).id;
			}
		}
		insert b;
		}
		catch(Exception e){}
	}
	
	static testMethod void testMain() {
		
		Person__c p = [SELECT id, Benutzer__r.id, Firma__c FROM Person__c WHERE Benutzer__c <>'' LIMIT 1];
		Bereich__c b = [SELECT ID FROM Bereich__c WHERE Firma__c = : p.Firma__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('bereichId', b.id);
		
		
		System.runAs(p.Benutzer__r){
		FaNavigationFacade controller = new FaNavigationFacade();
		controller.tracking();
		}
	}
	
	static testMethod void testMain2() {
		
		Person__c p = [SELECT id, Benutzer__r.id, Firma__c FROM Person__c WHERE Benutzer__c <>'' LIMIT 1];
		Portfolio2__c b = [SELECT ID FROM Portfolio2__c WHERE Bereich__r.Hauptbereich__r.Firma__c = : p.Firma__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('portfolioId', b.id);
		
		
		System.runAs(p.Benutzer__r){
		FaNavigationFacade controller = new FaNavigationFacade();
		controller.tracking();
		}
	}
	
	static testMethod void testMain3() {
		
		Person__c p = [SELECT id, Benutzer__r.id, Firma__c FROM Person__c WHERE Benutzer__c <>'' LIMIT 1];
		Gruppe__c b = [SELECT ID FROM Gruppe__c  LIMIT 1];
		ApexPages.currentPage().getParameters().put('groupId', b.id);
		
		
		System.runAs(p.Benutzer__r){
		FaNavigationFacade controller = new FaNavigationFacade();
		controller.tracking();
		}
	}
	static testMethod void testMain4() {
		
		Person__c p = [SELECT id, Benutzer__r.id, Firma__c FROM Person__c WHERE Benutzer__c <>'' LIMIT 1];
		BWL_Lexikon__c b = [SELECT name FROM BWL_Lexikon__c  LIMIT 1];
		ApexPages.currentPage().getParameters().put('article', b.name);
		
		
		System.runAs(p.Benutzer__r){
		FaNavigationFacade controller = new FaNavigationFacade();
		controller.tracking();
		}
	}
	static testMethod void testMain5() {
		
		Person__c p = [SELECT id, Benutzer__r.id, Firma__c FROM Person__c WHERE Benutzer__c <>'' LIMIT 1];
		BWL_Lexikon__c b = [SELECT name FROM BWL_Lexikon__c  LIMIT 1];
		ApexPages.currentPage().getParameters().put('mode', 'search');
		
		
		System.runAs(p.Benutzer__r){
		FaNavigationFacade controller = new FaNavigationFacade();
		controller.tracking();
		}
	}
}