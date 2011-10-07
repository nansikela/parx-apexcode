public class WebNavigationFacadeEnhanced11 
{
	public transient List<NaviItem>topNaviItem {get; set;}
	public transient NaviItem leftNaviItem {get; set;}
	public transient List<NaviItemBreadC> breadCrumb {get; set;}
	public transient String seitenTitel {get; set;}
	final static String STARTSEITEID = WebSiteSetting__c.getAll().get('Startseite').value__c;
	
	private static List<Page__c> queryResultForElementsInLevelOneAndTow;
	
	private static WebNavigationFacadeEnhanced11 instance;
	
	public static WebNavigationFacadeEnhanced11 getInstance()
	
	{
		if(instance == null)
		{
			instance = new WebNavigationFacadeEnhanced11();
		}
		return instance;
	}
	
	
	public WebNavigationFacadeEnhanced11()
	{
		seitenTitel = '';
		generateTopNavigation();
		generateBreadCrumb();
		generateLeftNavigation();
		
		System.debug('************leftNaviItem:'+leftNaviItem);
	}
	
	
	private static List<Page__c> getResultsForElementsLevelOneAndTwo()
	{
		
		if(queryResultForElementsInLevelOneAndTow == null)
		{
			queryResultForElementsInLevelOneAndTow = [Select p.name, p.name__c, p.Sprechende_URL__c, p.Oberseite__c, p.Id, (Select Id, Name, Name__c, Sprechende_URL__c From Pages__r WHERE Hidden__c = false ORDER BY Anordnung__c) From Page__c p WHERE Oberseite__c = :STARTSEITEID AND Hidden__c = false ORDER BY Anordnung__c];
		}
		return queryResultForElementsInLevelOneAndTow;
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
	
	
	
	//Generates the Top Navigation
	private void generateTopNavigation()
	{
		topNaviItem = new List<NaviItem>();
		
		for(Page__c p : getResultsForElementsLevelOneAndTwo())
		{
			NaviItem temp = new NaviItem(p.Name__c, p.Sprechende_URL__c);
			for(Page__c pp : p.Pages__r)
			{
				if(pp.Name__c != 'WebSeminarKategorieUebersicht')
				{
					NaviItem tempsub = new NaviItem(pp.Name__c, pp.Sprechende_URL__c);
					temp.subItemList.add(tempsub);
				}
				else
				{
					NaviItem tempsub =  new NaviItem('Führung', '/seminare/fuehrung');
					temp.subItemList.add(tempsub);
					
					tempsub =  new NaviItem('Strategie und Organisationsentwicklung', '/seminare/strategie-und-organisationsentwicklung');
					temp.subItemList.add(tempsub);
					
					tempsub =  new NaviItem('Persönlichkeitsentwicklung', '/seminare/persoenlichkeitsentwicklung');
					temp.subItemList.add(tempsub);
					
					tempsub =  new NaviItem('Fachkompetenz', '/seminare/fachkompetenz');
					temp.subItemList.add(tempsub);
					
					tempsub =  new NaviItem('Ausbildungen', '/seminare/ausbildungen');
					temp.subItemList.add(tempsub);
				}
			
			}
			topNaviItem.add(temp);
		}
	}
	
	
	
	private void generateBreadCrumb()
	{
		breadCrumb = new List<NaviItemBreadC>();
		String tempPageId = WebURLEncoder.decodeParam('pageid');
		System.debug('**************tempPageId:'+tempPageId);
		List<Page__c> breadCrumbTemp = new List<Page__c>();
		Integer i = 0;
		while(i<6 && tempPageId != null)
		{
			i++;
			List<Page__c> pages = [Select p.name, p.name__c, p.Sprechende_URL__c, p.Oberseite__c, p.Id FROM Page__c p WHERE id = :tempPageId AND p.Oberseite__c != null];
			if(!pages.isEmpty() && tempPageId != null)
			{
				breadCrumbTemp.add(pages.get(0));
				
				tempPageId = pages.get(0).Oberseite__c;
				System.debug('************tempPageId:'+tempPageId);
			}
			else
			{
				tempPageId = null;
			}
		}
		for(i = breadCrumbTemp.size()-1; i>=0; i--)
		{
			String nameForBreadCrumb = breadCrumbTemp.get(i).name__c;
			
			if(nameForBreadCrumb == 'Seminar Detail')
			{
				String code = WebURLEncoder.decodeParam('seminarCode');
				if(code != null && code != '')
				{
					List<Portfolio__c> temp = [SELECT Seminartitel__c FROM Portfolio__c WHERE name = :code AND Portfolio_Jahr__c = :WebConfig.getPortfolioYear()];
					if(temp.size()>0)
					{
						nameForBreadCrumb = temp.get(0).Seminartitel__c;
					}
				}
			}else if(nameForBreadCrumb == 'Trainer Detail')
			{
				String trainerId = WebURLEncoder.decodeParam('trainerId');
				if(trainerId!= null && trainerId != '')
				{
					for(Contact c : [SELECT firstname, lastname FROM Contact WHERE ID = :trainerId LIMIT 1])
					{
						nameForBreadCrumb = c.firstname +' '+c.lastname;
					}
				}
			}else if(nameForBreadCrumb == 'Hotel Detail')
			{
				String hotelId = WebURLEncoder.decodeParam('hotelId');
				if(hotelId!= null && hotelId != '')
				{
					for(Hotel__c h : [SELECT name FROM Hotel__c WHERE ID = :hotelId LIMIT 1])
					{
						nameForBreadCrumb = h.name;
					}
				}
			}else if(nameForBreadCrumb == 'Artikel')
			{
						nameForBreadCrumb = WebURLEncoder.decodeParam('article');
			}
			
			
			breadCrumb.add(new NaviItemBreadC(nameForBreadCrumb, breadCrumbTemp.get(i).Sprechende_URL__c));
		}
		if(breadCrumb.size()>=1)
		{
			String activeCategory = breadCrumb.get(0).item;
			for(NaviItem n :topNaviItem)
			{
				if(n.item == activeCategory)
				{
					n.isActive = true;
				}
			}
			
			//seitentitel
			seitenTitel= '';
			try{
			if( (breadCrumb.size()==3 || breadCrumb.size()==2) && (breadCrumb.get(1).item == 'Persönlichkeitsentwicklung' || breadCrumb.get(1).item == 'Führung' || breadCrumb.get(1).item == 'Strategie und Organisationsentwicklung' || breadCrumb.get(1).item == 'Fachkompetenz' || breadCrumb.get(1).item == 'Intensivprogramme'))
			{
				seitenTitel+= 'Seminar - ';
				seitenTitel += breadCrumb.get(breadCrumb.size()-1).item;
			}
			else
			{
				for(i = breadCrumb.size()-1; i>=0; i--)
				{
					seitenTitel += ' '+breadCrumb.get(i).item;
				}
				if(seitenTitel.contains('Seminarübersicht'))
				{
					seitenTitel = seitenTitel.replace('Seminarübersicht ', '');
				}
			}
			
			
			}catch(Exception e){}
				
				
			
		}
		seitenTitel += ' - Die Akademie';
		if(seitenTitel == ' - Die Akademie')
		{
			seitenTitel = 'Akademie für Führungskräfte der Wirtschaft GmbH';
		}
	}
	
	
	//Nav for BreadCrub
	class NaviItemBreadC
	{
		public String item {get; set;}
		public String url {get; set;}
		
		public NaviItemBreadC(String item, String url)
		{
			if(item == 'WebSeminarKategorieUebersicht')
			{
				String category = WebURLEncoder.decodeParam('category');
				if(category == 'Führung')
				{
					this.item= 'Führung';
					this.url = '/seminare/fuehrung';
				}
				else if(category == 'Strategie und Organisationsentwicklung')
				{
					this.item= 'Strategie und Organisationsentwicklung';
					this.url = '/seminare/strategie-und-organisationsentwicklung';
				}
				else if(category == 'Persönlichkeitsentwicklung')
				{
					this.item= 'Persönlichkeitsentwicklung';
					this.url = '/seminare/persoenlichkeitsentwicklung';
				}
				else if(category == 'Fachkompetenz')
				{
					this.item= 'Fachkompetenz';
					this.url = '/seminare/fachkompetenz';
				}
				else if(category == 'Ausbildungen')
				{
					this.item= 'Ausbildungen';
					this.url = '/seminare/ausbildungen';
				}
				else
				{
					this.item = item;
				}
			}
			else
			{
				this.item = item;
				this.url = url;
			}
		}
		
		public String getName()
		{
			return item;
		}
	}
	
	
	
	//a Navi Element
	class NaviItem
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
}