public class WebHeadTitle {
	public String title {get; set;}
	
	public WebHeadTitle(){
		String pageid = WebURLEncoder.decodeParam('pageid');
		
		//If is Führung or other category
		if(pageid == 'a0M20000003X6tmEAC'){
			try{
			title = WebUrlEncoder.decodeParam('category');
			}catch(Exception e){
				System.debug(e);
			}
		}
		//IF is SeminardetailPage
		if(pageid == 'a0M20000003X6z1EAC'){
			try{
			String seminarCode = WebUrlEncoder.decodeParam('seminarCode');
			
			Portfolio__c portfolio = [SELECT name, seminartitel__c FROM Portfolio__c WHERE name = :seminarCode ORDER BY CreatedDate desc LIMIT 1];
			
			title = portfolio.name+ ': ' + portfolio.Seminartitel__c;
			
			}catch(Exception e){
				System.debug(e);
			}
			
		}
		//IF is Article of Lexikon
		if(pageId == 'a0M20000003Y02o'){
			try{
			title = 'Akademie Lexikon: '+WebUrlEncoder.decodeParam('article');
			}catch(Exception e){
				System.debug(e);
			}
		}
		
		//If is CMS
		if(title == null){
			try{
			Page__c myPage = [SELECT Name__c FROM Page__c WHERE id = :pageId LIMIT 1];
			title = myPage.Name__c;
			}catch(Exception e){
				System.debug(e);
			}
		}
		if(title == null){
			title = 'Die Akademie';
		}
		
	}
}