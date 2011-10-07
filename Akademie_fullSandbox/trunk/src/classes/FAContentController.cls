/**
* @author Christian Deckert
* @date 18/08/2011
* @description FA Content Controller liefert die Informationen für FA Content pages zurück
*/
public class FAContentController {
	public String content {get; set;}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Text für Content Seiten
	*/
	public FAContentController()
	{
		List<Navigation__c>navList = [SELECT ID, Text__c FROM navigation__c WHERE ID= :WebURLEncoder.decodeParam('id')];
		if(navList.size()>0)
		{
			content = navList.get(0).text__c;
		}
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Test
	*/
	static testMethod void test() {
		Navigation__c n = [SELECT ID FROM Navigation__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('id', n.id);
		FAContentController controller = new FAContentController();
		
	}
}