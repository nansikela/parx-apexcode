public class WebEnhancedSeminarSearch 
{
	public SearchObject searchObject {get; set;}
	
	public WebEnhancedSeminarSearch()
	{
		searchObject = new searchObject();
	}
	
	class SearchObject
	{
		String query;
		Date queryDate;
		String register;
		String region;
		String ort;
	}
}