public class XMLSiteMap 
{
	public String sitemap {get; set;}
	private XmlStreamWriter w;
	
	public XMLSiteMap()
	{
		w = new XmlStreamWriter();
		w.writeStartDocument('utf-8', '1.0');
		w.writeStartElement(null, 'urlset', null);
		w.writeAttribute(null, null, 'xmlns', 'http://www.sitemaps.org/schemas/sitemap/0.9');
			
			addNavigationPages();
			addPortfolio();
			addProduktgruppe();
			addLexikon();
			addTrainer();
			addHotel();
			
		w.writeEndElement();
		w.writeEndDocument();
		sitemap = w.getXmlString();
		w.close();
	}
	
	
	private void addProduktgruppe()
	{
		for(Gruppe__c g : [Select g.change_frequency__c, g.URL__c, g.Priority__c, g.LastModifiedDate, g.Buchbar__c From Gruppe__c g WHERE g.URL__c != null])
		{
			writeURL('http://www.die-akademie.de'+g.URL__c, g.LastModifiedDate, g.change_frequency__c, g.priority__c);
		}
	}
	
	
	private void addHotel()
	{
		for(Account a : [Select a.priority__c, a.change_frequency__c, a.Sprechende_URL__c, a.LastModifiedDate From Account a WHERE  a.Sprechende_URL__c != null])
		{
			writeURL('http://www.die-akademie.de'+a.Sprechende_URL__c, a.LastModifiedDate, a.change_frequency__c, a.priority__c);
		}
	}
	
	private void addTrainer()
	{
		for(Contact c : [Select c.priority__c, c.change_frequency__c, c.Sprechende_URL__c, c.LastModifiedDate From Contact c WHERE c.Sprechende_URL__c != null AND Anzeige_auf_Website__c = true])
		{
			writeURL('http://www.die-akademie.de'+c.Sprechende_URL__c, c.LastModifiedDate, c.change_frequency__c, c.priority__c);
		}
	}
	
	
	
	private void addLexikon()
	{
		for(BWL_Lexikon__c b : [Select b.priority__c, b.change_frequency__c, b.Sprechende_URL__c, b.LastModifiedDate From BWL_Lexikon__c b WHERE b.Sprechende_URL__c!= null])
		{
			writeURL('http://www.die-akademie.de'+b.Sprechende_URL__c, b.LastModifiedDate, b.change_frequency__c, b.priority__c);
		}
	}
	
	private void addPortfolio()
	{
		for(Portfolio2__c p : [Select p.priority__c, p.change_frequency__c, p.URL__c, p.LastModifiedDate From Portfolio2__c p WHERE URL__c != null AND LIVE__c = true AND Bereich__r.Hauptbereich__r.Firma__c = 'a0g20000000If9L'])
		{
			writeURL('http://www.die-akademie.de'+p.url__c, p.LastModifiedDate, p.change_frequency__c, p.priority__c);
			writeURL('http://www.die-akademie.de'+p.url__c+'/order', p.LastModifiedDate, p.change_frequency__c, p.priority__c);
		}
	}
	
	
	private void addNavigationPages()
	{
		for(Navigation__c n : [Select n.Oeffentliche_URL__c, change_frequency__c, priority__c, LastModifiedDate From Navigation__c n WHERE Portal__c = 'Akademie Öffentlich'])
		{
			writeURL('http://www.die-akademie.de'+n.Oeffentliche_URL__c, n.LastModifiedDate, n.change_frequency__c, n.priority__c);
		}
	}
	
	
	private void writeURL(String url, Date lastModified, String changeFreq, Decimal priority)
	{
		writeURL(url, DateTime.newInstance(lastModified.year(), lastModified.month(), lastModified.day()), changeFreq, priority);
	}
	
	
	
	private void writeURL(String url, DateTime lastModified, String changeFreq, Decimal priority)
	{
		w.writeStartElement(null, 'url', null);
			if(url!= null)
			{
				w.writeStartElement(null, 'loc', null);
					w.writeCharacters(url);
				w.writeEndElement();
			}
			if(lastModified != null)
			{
				w.writeStartElement(null, 'lastmod', null);
					w.writeCharacters(lastModified.format('yyyy-MM-dd'));
				w.writeEndElement();
			}
			if(changefreq != null)
			{
				w.writeStartElement(null, 'changefreq', null);
					w.writeCharacters(changeFreq);
				w.writeEndElement();
			}
			if(priority != null)
			{
				w.writeStartElement(null, 'priority', null);
					w.writeCharacters(String.valueOf(priority));
				w.writeEndElement();
			}
		w.writeEndElement();
	}
	
	
	static testMethod void test()
	{
		XMLSiteMap x = new XMLSiteMap();
	}
}