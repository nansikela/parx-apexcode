/**
 * Firmenakademie Preisgruppen Controller
 *
 * @author Christian Deckert
 * @version 1.0
 */
public class FAPreisgruppe 
{
	public Gruppe__c currentProductgruppe {get; set;}
	private String shortInfo;
	
	public FAPreisgruppe()
	{
		currentProductgruppe = FAHelper.getCurrentProduktGruppe();
		if(currentProductgruppe.Beschreibung__c!= null)
		{
			currentProductgruppe.Beschreibung__c = currentProductgruppe.Beschreibung__c.replace('target="_blank"', '');
		}
	}
	
	/** 
     * Liefert Short Info formatiert zurück
     *
     * @return ShortInfo String
     */
	public String getShortInfo()
	{
		if(shortInfo == null)
		{
			shortInfo = '';
			if(currentProductgruppe.ShortInfo__c!= null)
			{
				for(String line : currentProductgruppe.ShortInfo__c.split('\n'))
				{
					shortInfo+= line.replace('<strong>', '<tr><td class="labelCol  first  firstColumn"><label>').replace('</strong>', '</label></td><td class="data2Col  first  lastColumn">')+'</td></tr>';
				}
			}
			else
			{
				shortInfo = null;
			}
		}
		return shortInfo;
	}
	/** 
     * Generates price Info
     *
     * @return List of Strings of PriceInfo
     */
	public List<String> getPriceInfo()
	{
		List<String>result = new List<String>();
		if(currentProductgruppe.Preisinformation__c!= null)
		{
			for(String info : currentProductgruppe.Preisinformation__c.split('<br><br>'))
			{
				result.add(info.replaceFirst('<strong>', '<h3>').replaceFirst('</strong>', '</h3><p>')+'</p>');
			}
		}
		return result;
	}
	
	/** 
     * Prüft existenz eienr Short Info
     *
     * @return true if there is a short info
     */
	public boolean getIsShortInfo()
	{
			return getShortInfo()!= null;
	}
	
	
	public List<Terminblock__c> getTerminBlock()
	{
		return [Select t.Name, t.Anordnung__c, (Select Name, Seminarort__r.BillingCity, Modul_Nummer__c, Seminarort__r.Sprechende_URL__c, Seminarbeginn__c, Seminarende__c, Trainer__c, Trainer__r.firstname, Trainer__r.Lastname, Trainer__r.sprechende_URL__c, Co_Trainer__c, Co_Trainer__r.Titel_Anrede__c, Trainer__r.Titel_Anrede__c, Co_Trainer__r.firstname, Co_Trainer__r.Lastname, Co_Trainer__r.sprechende_URL__c From Produkte__r ORDER BY Seminarbeginn__c) From Terminblock__c t WHERE LIVE__c = true AND Produktgruppe__c = :currentProductgruppe.id ORDER BY Anordnung__c];
	}
	
	
	static testMethod void test() 
    {
    	Gruppe__c g = [SELECT ID FROM Gruppe__c LIMIT 1];
    	ApexPages.currentPage().getParameters().put('groupId', g.id);
    	FAPreisgruppe controller = new FAPreisgruppe();
    	controller.getShortInfo();
    	controller.getPriceInfo();
    	controller.getIsShortInfo();
    	controller.getTerminBlock();
    }
}