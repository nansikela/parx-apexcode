public class WebLexikonOverviewController {
	public List<BWL_Lexikon__c> myArticle {get; set;}
	public String lexikonURL {get; set;}
	public Map<String, articleChar> allArticles {get; set;}
	public List<articleChar> allArticleList {get; set;}
	public List<String> ArticleNames {get; set;}
	public List<articleURL> ArticleURLMap {get;set;}
	public WebLexikonOverviewController(){
		//Artikel URL
		lexikonURL = WebURLEncoder.getPageIdById('p-01327');
		

		//Get all Article
		myArticle = new List<BWL_Lexikon__c>();
		myArticle.addAll([SELECT Name, Sprechende_url__c FROM BWL_Lexikon__c WHERE name<>'' ORDER BY name LIMIT 300]);
		if(WebURLEncoder.decodeParam('test')!='true')
		myArticle.addAll([SELECT Name, Sprechende_url__c FROM BWL_Lexikon__c WHERE name<>'' AND id NOT IN :myArticle ORDER BY name LIMIT 300]);
		initWithChars();
		String myTempChar;
		
		ArticleURLMap = new List<articleURL>();
		articleURL temparticleURL = new articleURL();
		String myChar = WebURLEncoder.decodeParam('lexikonChar');
		if(myChar== '') myChar = 'A';
		for(BWL_Lexikon__c l : myArticle){
			myTempChar = l.name.substring(0,1);
			if(myTempChar =='Ä') myTempChar = 'A';
			if(myTempChar =='Ü') myTempChar = 'U';
			if(myTempChar =='Ö') myTempChar = 'O';
			if((myTempChar == 'X' || myTempChar == 'Y' || myTempChar == 'Z' || myTempChar == '3') && myChar == 'XYZ'){
				myTempChar = 'XYZ';
			}
			if(myTempChar == myChar){
				temparticleURL = new articleURL();
				temparticleURL.name = l.name;
				temparticleURL.url = l.Sprechende_url__c;
				ArticleURLMap.add(temparticleURL);
			}
			
		}
		
		
		
		
		/*******************OLD***********************/
		for(BWL_Lexikon__c l: myArticle){
			myTempChar = l.name.substring(0,1);
			if(myTempChar =='Ä') myTempChar = 'A';
			if(myTempChar =='Ü') myTempChar = 'U';
			if(myTempChar =='Ö') myTempChar = 'O';
			
			
			if(myTempChar == 'X' || myTempChar == 'Y' || myTempChar == 'Z' || myTempChar == '3'){
				allArticles.get('XYZ').add(l.name);
			}else{
				System.debug('*************************'+myTempChar);
				allArticles.get(myTempChar).add(l.name);
			}
		}
		String myParam = WebURLEncoder.decodeParam('lexikonChar');
		if(myParam == '' || myParam == null) myParam = 'A';
		allArticles.get(myParam).selectChar();
		 
		allArticleList = new List<articleChar>();
		allArticleList.add(allArticles.get('A'));
		allArticleList.add(allArticles.get('B'));
		allArticleList.add(allArticles.get('C'));
		allArticleList.add(allArticles.get('D'));
		allArticleList.add(allArticles.get('E'));
		allArticleList.add(allArticles.get('F'));
		allArticleList.add(allArticles.get('G'));
		allArticleList.add(allArticles.get('H'));
		allArticleList.add(allArticles.get('I'));
		allArticleList.add(allArticles.get('J'));
		allArticleList.add(allArticles.get('K'));
		allArticleList.add(allArticles.get('L'));
		allArticleList.add(allArticles.get('M'));
		allArticleList.add(allArticles.get('N'));
		allArticleList.add(allArticles.get('O'));
		allArticleList.add(allArticles.get('P'));
		allArticleList.add(allArticles.get('Q'));
		allArticleList.add(allArticles.get('R'));
		allArticleList.add(allArticles.get('S'));
		allArticleList.add(allArticles.get('T'));
		allArticleList.add(allArticles.get('U'));
		allArticleList.add(allArticles.get('V'));
		allArticleList.add(allArticles.get('W'));
		allArticleList.add(allArticles.get('XYZ'));
		
		articleChar temp = allArticles.get(myParam);
		
		ArticleNames = temp.getNameList();
	}
	
	
	
	void initWithChars(){
		allArticles = new Map<String, articleChar>();
		allArticles.put('A', new articleChar('A'));
		allArticles.put('B', new articleChar('B'));
		allArticles.put('C', new articleChar('C'));
		allArticles.put('D', new articleChar('D'));
		allArticles.put('E', new articleChar('E'));
		allArticles.put('F', new articleChar('F'));
		allArticles.put('G', new articleChar('G'));
		allArticles.put('H', new articleChar('H'));
		allArticles.put('I', new articleChar('I'));
		allArticles.put('J', new articleChar('J'));
		allArticles.put('K', new articleChar('K'));
		allArticles.put('L', new articleChar('L'));
		allArticles.put('M', new articleChar('M'));
		allArticles.put('N', new articleChar('N'));
		allArticles.put('O', new articleChar('O'));
		allArticles.put('P', new articleChar('P'));
		allArticles.put('Q', new articleChar('Q'));
		allArticles.put('R', new articleChar('R'));
		allArticles.put('S', new articleChar('S'));
		allArticles.put('T', new articleChar('T'));
		allArticles.put('U', new articleChar('U'));
		allArticles.put('V', new articleChar('V'));
		allArticles.put('W', new articleChar('W'));
		allArticles.put('XYZ', new articleChar('XYZ'));
		
	}
	
	
	public class articleChar{
		public String articleChar {get; set;}
		public List<String> nameList {get; set;}
		public boolean isActive {get; set;}
		public boolean isSelected {get; set;}
		
		public articleChar(){
			this.nameList = new List<String>();
			this.isActive = false;
			this.isSelected = false;
		}
		
		public articleChar(String articleChar){
			this();
			this.articleChar = articleChar;
		}
		
		public void add(String name){
			this.isActive = true;
			this.nameList.add(name);
		}
		public void selectChar(){
			this.isSelected = true;
		}
		public List<String> getNameList(){
			return this.nameList;
		}
	
	}
	public class articleURL{
		public String name {get; set;}
		public String url {get; set;}
	}
	
}