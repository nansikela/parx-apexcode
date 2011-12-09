/**
* @author Christian Deckert
* @date 19/08/2011
* @description Kalender / Semianrkalender View Controller
*/
public class FAKalender 
{
	private Date fromDate;
	public String city {get; set;}
	public String headLineCity {get; set;}
	public String fromDateString {get; set;}
	public List<Kalender>seminarKalender {get; set;}
	public List<Gruppe__c> groups {get; set;}
	public String query {get; set;}
	public static boolean seminarResults = false;
	private final String seminarQuery = 'SELECT ID, Seminar__c, seminar__r.id, Seminar__r.Seminarbeginn__c, Ort__c, Seminar__r.Seminarende__c, seminar__r.Trainer__c , seminar__r.Trainer__r.Firstname, seminar__r.Trainer__r.Lastname, seminar__r.CO_Trainer__c, seminar__r.CO_Trainer__r.Firstname, seminar__r.CO_Trainer__r.Lastname, seminar__r.Restpl_tze__c, Portfolio__r.url__c, Portfolio__r.seminartitel__c FROM Seminar_to_Portfolio__c WHERE Seminar__r.Anzeige_Auf_website__c = true';
	
	/**
	* @author Christian Deckert
	* @date 19/08/2011
	* @description Konstruktor
	*/
	public FAKalender()
	{
		String lastMonth = '';
		Kalender temp;
		if(WebURLEncoder.decodeParam('mode')!= 'search')
		{
			
		
			city = ApexPages.currentPage().getParameters().get('city');
			if(ApexPages.currentPage()!= null && ApexPages.currentPage().getParameters().containsKey('fromDate') && ApexPages.currentPage().getParameters().get('fromDate') != null)
			{
				fromDate = Date.valueOf(ApexPages.currentPage().getParameters().get('fromDate'));
				
			}
			else
			{
				fromDate = Date.today();
			}
			//ort = 'Göttingen';
			//city = FAHelper.getCurrentFirma().id;
			
			fromDateString = DateTime.newInstance(fromDate.year(), fromDate.month(), fromDate.day()).format('yyyy-MM-dd');
			
			
			
			query = seminarQuery;
			if(city != null)
			{
				query += ' AND Ort__c=\''+city+'\'';
			}
			query += ' AND Firma_id__c =\''+String.valueOf(FAHelper.getCurrentFirma().id).subString(0,15)+'\'';
			query+= ' AND Seminar__r.Seminarbeginn__c >= '+DateTime.newInstance(fromDate.year(), fromDate.month(), fromDate.day()).format('yyyy-MM-dd');
			
			if(WebURLEncoder.decodeParam('mode') == 'garantie')
			{
				query+= ' AND seminar__r.Garantie_Termin__c = true ';
			}
			String register = WebURLEncoder.decodeParam('register');
			if(register!= '')
			{
				query+= ' AND (';
				boolean isFirst = true;
				register = register.replace('oe', 'ö').replace('ue', 'ü');
				if(register.contains('-'))
				{
					for(String r : register.split('-'))
					{
						if(!isFirst)
						{
							query+= ' OR ';
						}
						else
						{
							isFirst = true;
						}
						query+= ' Portfolio__r.Bereich__r.Hauptbereich__c = \''+r+'\' ';
					}
				}
				else
				{
					query+= ' Portfolio__r.Bereich__r.Hauptbereich__c = \''+register+'\' ';
				}
				query+= ') ';
			}
			
			query+= ' ORDER BY Seminar__r.Seminarbeginn__c';
		
		}
		
		else
		{
			String city = WebURLEncoder.decodeParam('city');	
			String region = WebURLEncoder.decodeParam('region');
			String q = WebURLEncoder.decodeParam('query');
			query = seminarQuery;
			
			if(ApexPages.currentPage()!= null && ApexPages.currentPage().getParameters().containsKey('fromDate') && ApexPages.currentPage().getParameters().get('fromDate') != null)
			{
				fromDate = Date.valueOf(ApexPages.currentPage().getParameters().get('fromDate'));
				
			}
			else
			{
				fromDate = Date.today();
			}
			
			if(city != '')
			{
				query += ' AND ort__c = \''+city+'\' ';
			}
			
			if(region != '')
			{
				query += ' AND region__c = \''+region+'\' ';
			}
			if(q!= '')
			{
				query += ' AND (';
				query += 'Portfolio__r.name LIKE \'%'+q+'%\'';
				query += ' OR Portfolio__r.SeminarTitel__c LIKE \'%'+q+'%\'';
				query += ' OR Portfolio__r.Keywords__c LIKE \'%'+q+'%\'';
				query+=')';
			}
			
			
			query += ' AND Firma_id__c =\''+String.valueOf(FAHelper.getCurrentFirma().id).subString(0,15)+'\'';
			query+= ' AND Seminar__r.Seminarbeginn__c >= '+DateTime.newInstance(fromDate.year(), fromDate.month(), fromDate.day()).format('yyyy-MM-dd');
			query+= ' ORDER BY Seminar__r.Seminarbeginn__c';
			String queryString2 = '%'+q+'%';
			String queriedString = 'SELECT id, name, url__c, Name__c FROM Gruppe__c WHERE Bereich__c != null AND Suche_aktiviert__c = true';
			if(q!= null && q!= '')
			{
				queriedString += ' AND (name LIKE :queryString2 OR Name__c LIKE :queryString2)';
			}
			try
			{
			groups = Database.query(queriedString+' LIMIT 10');
			}catch (Exception e){}
		}
		seminarKalender = new List<Kalender>();
		
		List<Seminar_to_Portfolio__c> semiarToPortfolioList;
		semiarToPortfolioList = Database.query(query);
		for(Seminar_to_Portfolio__c p : semiarToPortfolioList)
		{
			if(headLineCity == null)
			{
				headLineCity = p.Ort__c;
			}
			if(lastMonth != getMonth(p))
			{
				lastMonth = getMonth(p);
				if(temp!= null)
				{
					seminarKalender.add(temp);
				}
				temp = new Kalender(getMonth(p));
			}
			temp.seminarList.add(new FASeminarTermine.Seminar(p));
			seminarResults = true;
		}
		seminarKalender.add(temp);
	
	}
	
	/**
	* @author Christian Deckert
	* @date 19/08/2011
	* @description Prüft ob die City bekannt ist
	* @return boolean ob City Angegeben ist
	*/
	public boolean getIsCity()
	{
		if(city!= null) return true;
		else return false;
	}
	
	
	
	public boolean getisSeminarResult()
	{
		return seminarResults;
	}
	
	public boolean getisRegion()
	{
		if(WebURLEncoder.decodeParam('region') != '')
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public boolean getisGroupResult()
	{
		if(groups != null && groups.size()>0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public boolean getisResult()
	{
		if(getisGroupResult() || getisSeminarResult())
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	/**
	* @author Christian Deckert
	* @date 19/08/2011
	* @description Seminarmonate
	* @return String von deutschen Seminarbeginn
	*/
	private String getMonth(Seminar_to_Portfolio__c p)
	{
		if(p.Seminar__r.Seminarbeginn__c.Month() == 1)
		{
			return Label.month_january;
		}
		else if(p.Seminar__r.Seminarbeginn__c.Month() == 2)
		{
			return Label.month_february;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 3)
		{
			return Label.month_march;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 4)
		{
			return Label.month_april;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 5)
		{
			return Label.month_may;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 6)
		{
			return Label.month_june;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 7)
		{
			return Label.month_july;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 8)
		{
			return Label.month_august;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 9)
		{
			return Label.month_september;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 10)
		{
			return Label.month_october;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 11)
		{
			return Label.month_november;
		}else if(p.Seminar__r.Seminarbeginn__c.Month() == 12)
		{
			return Label.month_december;
		}
		else
		{
			return null;
		}
		
	}
	/**
	* @author Christian Deckert
	* @date 19/08/2011
	* @description Kalender Container
	*/
	public class Kalender
	{
		public String month {get; set;}
		public List<FASeminarTermine.Seminar> seminarList {get; set;}
		Kalender()
		{
			seminarList = new List<FASeminarTermine.Seminar>();
		}
		Kalender(String month)
		{
			this();
			this.month = month;
		}
	}
	static testMethod void test()
	{
		Person__c p = [SELECT id, Benutzer__r.id FROM Person__c WHERE Benutzer__c <>'' LIMIT 1];
		
		System.runAs(p.Benutzer__r){
		FAKalender kalender = new FAKalender();
		kalender.getIsCity();
		kalender.getisResult();
		}
	}
	
}