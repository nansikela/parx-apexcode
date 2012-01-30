public class SiteTemplateController {

	static String enPrefix = '/en';
	static String languageCodeEn = 'en';
	static String languageCodeDe = 'de';
	
	public SiteTemplateController(){
		System.debug('SiteTemplateController Ctor called');
	}
	
	public static String getUrl(){
		return Apexpages.currentPage().getUrl();
	}
	
	public static String getLanguage(){
		System.debug('getLanguage called');
		String url = Apexpages.currentPage().getUrl(); 
		System.debug('SiteTemplateController URL: ' + url);
		if (url.startsWith(enPrefix)){
			return languageCodeEn;
		}
		else
			return languageCodeDe;
	}
	
	static testMethod void testMain(){
		
	} 
}