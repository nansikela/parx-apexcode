global class WebURLRewriterDieAkademieSite implements Site.UrlRewriter{
	global PageReference mapRequestUrl(PageReference myOriginalUrl){
	 	
	 	/******************LEXIKON***********************/
 			String url = myOriginalUrl.getUrl();
 			url = url.toLowerCase();
 			
 			String pdf = '';
 			if(url.endsWith('/pdf'))
 			{
 				url = url.replace('/pdf', '');
 				pdf = '&pdf=true';
 			}
 			
 			
 			
 			if(url.endsWith('/')){
 				url = url.substring(0, url.length()-1);
 			}
 			
 			if(url=='/' || url == ''){
 				return new PageReference('/page?pageid=a0M20000003X6ppEAC');
 			}
 			
 			
 			if(url.contains('/service/lexikon/') ){
 				if(url.replace('/service/lexikon/', '').length()>1 && !url.endsWith('xyz')){
 					BWL_Lexikon__c article = [SELECT Name FROM BWL_Lexikon__c WHERE Sprechende_URL__c = :url];
 					return new PageReference('/page?pageid=a0M20000003Y02o&article='+article.name+pdf);
 				}else{
 					return new PageReference('/page?pageid=a0M20000003Y3MjEAK&lexikonChar='+url.replace('/service/lexikon/', '').toUpperCase()+pdf);
 				}
 				
 			}
	 		
	 		if(url.contains('/sitesearch'))
	 		{
	 			String googlequery = url;
	 			googlequery = googlequery.replace('/sitesearch/', '');
	 			
	 			return new PageReference('/page?pageid=a0M20000003YntV&q='+googlequery+pdf);
	 		}
	 	
	 
	 /******************TRAINER****************************/
	 		if(url.contains('/seminare/trainer/')){
 				
 				if(url.replace('/seminare/trainer/','').length()>1 && !url.endsWith('xyz')){
 					Contact myContact = [SELECT id FROM Contact WHERE Sprechende_URL__c = :url];
 					return new PageReference('/page?pageid=a0M20000003XFpTEAW&trainerId='+myContact.id);
 				}else{
 					return new PageReference('/page?pageid=a0M20000003XF8BEAW&trainerChar='+url.replace('/seminare/trainer/','').toUppercase()+pdf);
 				}
 				
 			}
 	/************SEMINARE**************************/
 			if(url.contains('/seminare/intensivprogramm/')){
 				Portfolio__c myPortfolio = [SELECT intensiv_seminar_url__c FROM Portfolio__c WHERE Sprechende_URL__c = : url LIMIT 1];
 				return new PageReference('/'+myPortfolio.intensiv_seminar_url__c);
 			}
 			
 			
 			if(url.contains('/seminare/fuehrung/')){
 				Portfolio__c myPortfolio = [SELECT name FROM Portfolio__c WHERE Sprechende_URL__c = : url LIMIT 1];
 				return new PageReference('/page?pageid=a0M20000003X6z1EAC&category=F_81hrung&seminarCode='+myPortfolio.name+pdf);
 			}
 			if(url.contains('/seminare/strategie-und-organisationsentwicklung/')){
 				Portfolio__c myPortfolio = [SELECT name FROM Portfolio__c WHERE Sprechende_URL__c = : url LIMIT 1];
 				return new PageReference('/page?pageid=a0M20000003X6z1EAC&category=Strategie+und+Organisationsentwicklung&seminarCode='+myPortfolio.name+pdf);
 			}
 			if(url.contains('/seminare/persoenlichkeitsentwicklung/')){
 				Portfolio__c myPortfolio = [SELECT name FROM Portfolio__c WHERE Sprechende_URL__c = : url LIMIT 1];
 				return new PageReference('/page?pageid=a0M20000003X6z1EAC&category=Pers_94nlichkeitsentwicklung&seminarCode='+myPortfolio.name+pdf);
 			}
 			if(url.contains('/seminare/fachkompetenz/')){
 				Portfolio__c myPortfolio = [SELECT name FROM Portfolio__c WHERE Sprechende_URL__c = : url LIMIT 1];
 				return new PageReference('/page?pageid=a0M20000003X6z1EAC&category=Fachkompetenz&seminarCode='+myPortfolio.name+pdf);
 			}
 			if(url.contains('/seminare/coaching/')){
 				Portfolio__c myPortfolio = [SELECT name FROM Portfolio__c WHERE Sprechende_URL__c = : url LIMIT 1];
 				return new PageReference('/page?pageid=a0M20000003X6z1EAC&category=Coaching&seminarCode='+myPortfolio.name+pdf);
 			}
 			
 			if(url.contains('/seminare/intensivprogramm/')){
 				Portfolio__c myPortfolio = [SELECT intensiv_seminar_url__c FROM Portfolio__c WHERE Sprechende_URL__c = : url LIMIT 1];
 				return new PageReference('/'+myPortfolio.intensiv_seminar_url__c+pdf);
 			}
 					
 			
 			
 	/****************SEMINARÜBERSICHT******************/
 			if(url.contains('/seminare/fuehrung')){
 				return new PageReference('/page?pageid=a0M20000003X6tmEAC&category=F_81hrung'+pdf);
 			}
 			if(url.contains('/seminare/strategie-und-organisationsentwicklung')){
 				return new PageReference('/page?pageid=a0M20000003X6tmEAC&category=Strategie+und+Organisationsentwicklung'+pdf);
 			}
 			if(url.contains('/seminare/persoenlichkeitsentwicklung')){
 				return new PageReference('/page?pageid=a0M20000003X6tmEAC&category=Pers_94nlichkeitsentwicklung'+pdf);
 			}
 			if(url.contains('/seminare/fachkompetenz')){
 				return new PageReference('/page?pageid=a0M20000003X6tmEAC&category=Fachkompetenz'+pdf);
 			}
 			if(url.contains('/seminare/coaching') || url.contains('/seminare/ausbildungen')){
 				return new PageReference('/page?pageid=a0M20000003X6tmEAC&category=Ausbildungen'+pdf);
 			}
 	///Hotels
 			if(url.contains('/seminare/hotel/'))
 			{
 				String hotelId = '';
 				
 				for(Hotel__c h : [SELECT ID FROM Hotel__c WHERE Account__r.Sprechende_Url__c = :url])
 				{
 					hotelId = h.id;
 				}
 				
 				return new PageReference('/page?pageid=a0M20000003XGDw&hotelId='+hotelId);
 				
 			}
 			
	 		if(!url.contains('pageid=')){
	 			try{
	 			Page__c myPage = [SELECT id FROM Page__c WHERE sprechende_URL__c <>'' AND sprechende_URL__c = :url];
	 			return new PageReference('/page?pageid='+myPage.id+pdf);
	 			}catch(Exception e){
	 				
	 			}
	 			
	 		}
		return myOriginalUrl;
	}
	 global List <PageReference> generateUrlFor(List<PageReference> myOriginalUrls){
		return myOriginalUrls;
    }
	static testMethod void myUnitTest() {
		WebURLRewriterDieAkademieSite controller = new WebURLRewriterDieAkademieSite();
		controller.mapRequestUrl(new PageReference('/seminare'));
		controller.mapRequestUrl(new PageReference('/seminare/trainer'));
		controller.mapRequestUrl(new PageReference('/seminare/fuehrung'));
		controller.mapRequestUrl(new PageReference('/seminare/strategie-und-organisationsentwicklung'));
		controller.mapRequestUrl(new PageReference('/seminare/coaching'));
		controller.mapRequestUrl(new PageReference('/sitesearch'));
		controller.mapRequestUrl(new PageReference('/service/lexikon'));
		controller.mapRequestUrl(new PageReference('/service/lexikon/a/abschreibung'));
	}
}