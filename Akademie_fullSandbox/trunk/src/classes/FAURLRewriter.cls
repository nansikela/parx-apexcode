global class FAURLRewriter implements Site.UrlRewriter{
	/** The Page reference. */
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
		System.debug('***url:'+url);
		System.debug('***param:'+param);
		
		List<Navigation__c> navList = [SELECT ID, URL__c FROM Navigation__c WHERE Oeffentliche_URL__c = :url AND Portal__c = 'Vossloh'];
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
			return new PageReference(returnURL+param);
		}
		
		//order seminare
		if(url.startsWith('/seminare/') && url.endsWith('/order'))
		{
			String tempURL = url.replace('/order', '');
			List<Portfolio2__c> portfolioList = [SELECT ID FROM Portfolio2__c WHERE URL__c = : tempURL];
			return new PageReference('/FABestellung?portfolioId='+portfolioList.get(0).id+'&'+param);
		}
		//trainer
		if(url.startsWith('/seminare/trainer/'))
		{
			List<Contact> trainerList = [SELECT ID FROM Contact WHERE Sprechende_URL__c = : url];
			if(trainerList.size()>0)
			{
				return new PageReference('/FATrainerDetail?trainerId='+trainerList.get(0).id);
			}
		}
		
		
		
		
		//Seminare finden
		if(url.startsWith('/seminare/'))
		{
			List<Portfolio2__c> portfolioList = [SELECT ID FROM Portfolio2__c WHERE URL__c = : url];
			return new PageReference('/FAPortfolio?portfolioId='+portfolioList.get(0).id);
		}
 	return myOriginalUrl;
 	}
 	
 	
 	global List <PageReference> generateUrlFor(List<PageReference> myOriginalUrls){
 		
 		
		return myOriginalUrls;
    }
    static testMethod void testMain() {
    	Portfolio2__c p = [Select id FROM Portfolio2__c Limit 1];
    	FAURLRewriter controller = new FAURLRewriter();
    	List<PageReference> pr = new List<PageReference>();
    	pr.add(new PageReference('/FABestellung?portfolioId='+p.id));
    	controller.generateUrlFor(pr);
    }
    
}