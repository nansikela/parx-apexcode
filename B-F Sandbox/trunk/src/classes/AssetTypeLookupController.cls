public class AssetTypeLookupController {
	String searchText;
	List<Asset_Type__c> results;
	
	public String getSearchText() {
		return searchText;
	}
	public void setSearchText(String s) {
		searchText = s;
	}
	public List<Asset_Type__c> getResults() {
		return results;
	}
	public PageReference doSearch() {
		if (searchText.length() == 0) {
			results = [SELECT Id, Name FROM Asset_Type__c];			
		} else {
			results = [SELECT Id, Name FROM Asset_Type__c WHERE Name LIKE '%:searchText%'];
		}
		
		return null;
	}
}