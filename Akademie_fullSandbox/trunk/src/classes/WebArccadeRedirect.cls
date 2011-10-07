public class WebArccadeRedirect {
	public boolean isArccade {get; set;}
	public String currUrl {get; set;}
	public String newURL {get; set;}
	
	public WebArccadeRedirect(){
		currUrl = ApexPages.currentPage().getUrl();
		if(currUrl.contains('/apex/FileNotFound?user=')){
			isArccade = true;
			newURL = 'http://arccade.de/arccade/arccadownloads.hei'+currUrl.replace('/apex/FileNotFound', '');
		}else{
			isArccade = false;
		}
	}
	
	
	
	
}