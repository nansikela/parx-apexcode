public class WebLexikonArticleController {
	public String headLine{ get; set; }
	public String articleString { get; set; }
	
	//Generating Lexikon Artikel
	public WebLexikonArticleController(){
		//URL
		String linkURL = 'page?pageid='+WebURLEncoder.getPageIdById('p-01142')+'&article=';
		
		//Headline
		headLine = WebURLEncoder.decodeParam('article');
		
		if(headLine=='' || headLine == null){
			headLine = 'Abdiskontierung';
		}
		
		//ListOfKeyWords
		List<KeyWord> keyWordList = new List<KeyWord>();
		
		BWL_Lexikon__c myArticle = [	SELECT 
												Artikel__c
											FROM BWL_Lexikon__c
											WHERE name = :headLine LIMIT 1];
		
		articleString = myArticle.Artikel__c;
		
		List<BWL_Lexikon__c> allArticle = new List<BWL_Lexikon__c>();
		allArticle.addAll([	SELECT id, name, plural__c, genitiv__c, sprechende_url__c FROM BWL_Lexikon__c WHERE name <> :headLine LIMIT 300]);
		if(WebURLEncoder.decodeParam('test')!='true')
		allArticle.addAll([	SELECT id, name, plural__c, genitiv__c, sprechende_url__c  FROM BWL_Lexikon__c WHERE name <> :headLine AND id NOT IN :allArticle LIMIT 300]);
		//Article Find
		for(BWL_Lexikon__c b : allArticle){
			
				//Adding Keywords to List 
				
				if(b.Plural__c != '' && b.Plural__c != null){
					keyWordList.add(new KeyWord(b.plural__c, b.sprechende_url__c));
				}
				if(b.Genitiv__c != '' && b.Genitiv__c != null){
					keyWordList.add(new KeyWord(b.Genitiv__c, b.sprechende_url__c));
				}
				keyWordList.add(new KeyWord(b.name, b.sprechende_url__c));
			
			
		}
		//Adding Links
		for(KeyWord kw: keyWordList){
			articleString = articleString.replace(kw.key+'&nbsp;', '<a href=\"'+kw.URL+'\">'+kw.key+'</a>&nbsp;');
			articleString = articleString.replace(kw.key+'<br>', '<a href=\"'+kw.URL+'\">'+kw.key+'</a><br>');
			articleString = articleString.replace(''+kw.key+' ', '<a href=\"'+kw.URL+'\">'+kw.key+'</a> ');
			articleString = articleString.replace(' '+kw.key+' ', ' <a href=\"'+kw.URL+'\">'+kw.key+'</a> ');
			articleString = articleString.replace('('+kw.key+'', '(<a href=\"'+kw.URL+'\">'+kw.key+'</a>');
			articleString = articleString.replace(''+kw.key+')', '<a href=\"'+kw.URL+'\">'+kw.key+'</a>)');
			articleString = articleString.replace(''+kw.key+',', '<a href=\"'+kw.URL+'\">'+kw.key+'</a>,');
			articleString = articleString.replace(''+kw.key+'.', '<a href=\"'+kw.URL+'\">'+kw.key+'</a>.');
		}
		
		
		
		
	}
	public class KeyWord{
		public String key {get; set;}
		public String URL {get; set;}
		public KeyWord(String key, String Url){
			this.key = key;
			this.URL = (URL);
		}
	}
	
}