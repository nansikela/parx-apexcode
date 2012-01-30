/**
* @author Christian Deckert
* @date 20/08/2011
* @description Klasse ist für das Umbauen der URL ab 2011 verantwortlich
*/
global class WebURLRewriter implements Site.UrlRewriter{
	
	String enPrefix = '/en';
	
	/**
	* @author Christian Deckert
	* @date 20/08/2011
	* @description Mapping von URLS auf System URLs
	* @return PageReferencen (SFDC Intern) werden zurückgegeben.
	*/
	global PageReference  mapRequestUrl(PageReference myOriginalUrl){
		
		
		
		String url = myOriginalUrl.getUrl();
		
		
		
		
		String param = '';
		//Parameter
		if(url.contains('?'))
		{
			param = url.substring((1+url.indexOf('?')));
			url = url.replace('?'+param, '');
		}
		url = url.toLowerCase();
		
		/**
		* /en/, /en
		**/
		if (url.startsWith(enPrefix+'/') || (url == enPrefix)){
			url = url.substring(enPrefix.length(), url.length());
		}
		
		if(url.endsWith('/') && url.length()>2)
		{
			url = url.substring(0, url.length()-1);
		}
		System.debug('***url:'+url);
		System.debug('***param:'+param);
		if(url == '' || url == '/')
		{
			return new PageReference('/page2?pageId=a0M20000003ZtU4');
			
		}
		
		
		List<Navigation__c> navList = [SELECT ID, URL__c FROM Navigation__c WHERE Oeffentliche_URL__c = :url AND Portal__c = 'Akademie Öffentlich'];
		if(navList.size()>0)
		{
			System.debug(navList.get(0).url__c+'?'+param);
			String returnURL = navList.get(0).url__c;
			if(returnURL.contains('?'))
			{
				returnURL+='&';
			}else
			{
				returnURL +='?';
			}
			if(!returnURL.contains('id') && returnURL.contains('WebBereichUebersicht'))
			{
				returnURL+= 'id='+navList.get(0).id+'&';
			}
			return new PageReference(returnURL+param);
		}
		
		if(url.startsWith('/service/lexikon/'))
		{
			List<BWL_Lexikon__c> article = [SELECT Name FROM BWL_Lexikon__c WHERE Sprechende_URL__c = :url];
			if(article.size()>0)
			{
				return new PageReference('/WebLexikonArticle2?article='+article.get(0).Name);
			}
			else
			{
				return new PageReference('/WebLexikonOverview?lexikonChar='+url.replace('/service/lexikon/', '').toUpperCase());
			}
		}
		
		
		//order seminare
		if(url.startsWith('/seminare/') && url.endsWith('/order'))
		{
			String tempURL = url.replace('/order', '');
			List<Portfolio2__c> portfolioList = [SELECT ID FROM Portfolio2__c WHERE URL__c = : tempURL  AND Bereich__r.Hauptbereich__r.Firma__c = : 'a0g20000000If9L'];
			
			if(portfolioList.size()>0)
			{
				return new PageReference('/WebBestellung?portfolioId='+portfolioList.get(0).id+'&'+param);
			}
			else
			{
				List<Gruppe__c>gruppenList = [SELECT ID, Buchungstyp__c FROM Gruppe__c WHERE URL__c = :tempURL];
				if(gruppenList.size()>0)
				{
					if(gruppenList.get(0).Buchungstyp__c == 'Zyklus')
					{
						System.debug('Zyklus buchung');
						return new PageReference('/WebBestellung_Zyklus_No_Option?groupId='+gruppenList.get(0).id);
					}
					
					
				}
			}
			
		}
		//order seminare
		if(url.startsWith('/seminare/') && url.endsWith('/upsell'))
		{
			String tempURL = url.replace('/upsell', '');
			List<Portfolio2__c> portfolioList = [SELECT ID FROM Portfolio2__c WHERE URL__c = : tempURL AND Bereich__r.Hauptbereich__r.Firma__c = : 'a0g20000000If9L'];
			return new PageReference('/WebUpsell?portfolioId='+portfolioList.get(0).id+'&'+param);
		}
		
		//PDF Seminar
		if(url.startsWith('/seminare/') && url.endsWith('/pdf'))
		{
			String tempURL = url.replace('/pdf', '');
			List<Portfolio2__c> portfolioList = [SELECT ID, pdf__c, PDF_URL__c FROM Portfolio2__c WHERE URL__c = : tempURL AND Bereich__r.Hauptbereich__r.Firma__c = : 'a0g20000000If9L'];
			
			System.debug('*****tempURL:'+tempURL);
			
			//IF PORTFOLIO
			if(portfolioList.size()>0)
			{
				if(portfolioList.get(0).pdf__c != null)
				{
					return new PageReference(portfolioList.get(0).pdf__c);
				}
				return new PageReference('/WebPDFPortfolio?portfolioId='+portfolioList.get(0).id+'&mode=pdf&'+param);
			}
			else
			{
				System.debug('***********PRODUKTGRUPPE PDF ********/');
				List<Gruppe__c> produktgruppen = [SELECT ID, pdf__c FROM Gruppe__c WHERE URL__c = : tempURL AND Bereich__r.Hauptbereich__r.Firma__c = : 'a0g20000000If9L'];
				if(produktgruppen.size()> 0 && produktgruppen.get(0).pdf__c != null)
				{
					System.debug(new PageReference( produktgruppen.get(0).pdf__c ));
					return new PageReference( produktgruppen.get(0).pdf__c );
				}
			}
		}
		//Print Seminar
		if(url.startsWith('/seminare/') && url.endsWith('/print'))
		{
			String tempURL = url.replace('/print', '');
			List<Portfolio2__c> portfolioList = [SELECT ID FROM Portfolio2__c WHERE URL__c = : tempURL AND Bereich__r.Hauptbereich__r.Firma__c = : 'a0g20000000If9L'];
			
			System.debug('/WebPDFPortfolio?portfolioId='+portfolioList.get(0).id+'&'+param);
			
			return new PageReference('/WebPDFPortfolio?portfolioId='+portfolioList.get(0).id+'&'+param);
		}
		
		//trainer
		if(url.startsWith('/seminare/trainer/'))
		{
			List<Contact> trainerList = [SELECT ID FROM Contact WHERE Sprechende_URL__c = : url];
			if(trainerList.size()>0)
			{
				return new PageReference('/WebTrainerDetail2?trainerId='+trainerList.get(0).id);
			}
		}
		
		if(url.startsWith('/seminare/kalender/'))
		{
			String paramStringKalender = url.replace('/seminare/kalender/', '');
			String [] paramString = paramStringKalender.split('/');
			String paramToURL = '';
			if(paramString.size()>0)
			{
				paramToURL = 'fromdate='+paramString.get(0);
			}
			if(paramString.size()>1)
			{
				paramToURL = '&city='+paramString.get(1).replace('-', ' ');
			}
			return new PageReference('/WebKalender?'+paramToURL);
		}
		
		
		//Seminare finden
		if(url.startsWith('/seminare/'))
		{
			List<Portfolio2__c> portfolioList = [SELECT ID FROM Portfolio2__c WHERE URL__c = : url AND Bereich__r.Firma__c = : 'a0g20000000If9L'];
			if(portfolioList.size()>0)
			{
				return new PageReference('/WebPortfolio2?portfolioId='+portfolioList.get(0).id);
			}
		}
		List<Gruppe__c>gruppenList = [SELECT ID, Zyklus_Darstellung__c FROM Gruppe__c WHERE URL__c = :url AND Bereich__r.Hauptbereich__r.Firma__c = : 'a0g20000000If9L'];
		if(gruppenList.size()>0)
		{
			if(gruppenList.get(0).Zyklus_Darstellung__c != null && gruppenList.get(0).Zyklus_Darstellung__c)
			{
				return new PageReference('/WebPreisgruppeZyklus?groupId='+gruppenList.get(0).id);
			}
			else
			{
				return new PageReference('/WebPreisgruppe?groupId='+gruppenList.get(0).id);
			}
			
		}
		
		
		if(url.startsWith('/seminare/hotel'))
		{
			String hotelId;
			for(Hotel__c h : [SELECT ID FROM Hotel__c WHERE Account__r.Sprechende_Url__c = :url ])
 			{
 				hotelId = h.id;
 			}
 			return new PageReference('/WebHotelDetail2?hotelId='+hotelId);
		}
		
		
		if(WebCodeRedirect.redirectToSeminar(url.replace('/', '')).getUrl() != '/')
		{
			return new PageReference('/WebCodeRedirect?code='+url.replace('/', ''));
		}
		
		
		
		
		
		
 	return myOriginalUrl;
 	}
 	
 	
 	global List <PageReference> generateUrlFor(List<PageReference> myOriginalUrls){
 		
 		for(PageReference p: myOriginalUrls)
 		{
 			if(p.getUrl()== 'WebTeilnehmerRegister')
 			{
 				p = new PageReference('/registrierung');
 			}
 		}
		return myOriginalUrls;
    }
    static testMethod void testMain() {
    	Portfolio2__c p = [Select id FROM Portfolio2__c Limit 1];
    	WebURLRewriter controller = new WebURLRewriter();
    	List<PageReference> pr = new List<PageReference>();
    	pr.add(new PageReference('/FABestellung?portfolioId='+p.id));
    	controller.generateUrlFor(pr);
    }
    
   
    
}