/**
* @author Christian Deckert
* @date 18/08/2011
* @description Executes a batch / Funktion wurde implementiert, da mehr als 200 Datensätze pro Kostengruppe aktualisiert werden sollten.
*/
public class DBKostengruppeExecuteBatch {
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Batch ausführen
	*/
	public PageReference executeBatch()
	{
		String id = ApexPages.currentPage().getParameters().get('id');
		DB_Kostengruppe__c b = [SELECT ID, b.Gueltig_von__c, b.Gueltig_bis__c FROM DB_Kostengruppe__c b WHERE ID = :id];
	
		database.executeBatch(new ProductUpdateBatch(b.Gueltig_von__c, b.Gueltig_bis__c), 100);
		database.executeBatch(new InhouseProductUpdateBatch(b.Gueltig_von__c, b.Gueltig_bis__c), 100);
		return new PageReference('/'+id);
	}
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Test
	*/
	static testMethod void test()
	{
		DB_Kostengruppe__c b = [SELECT ID FROM DB_Kostengruppe__c WHERE Gueltig_von__c>2009-12-31 LIMIT 1];
		ApexPages.currentPage().getParameters().put('id', b.id);
		DBKostengruppeExecuteBatch controller = new DBKostengruppeExecuteBatch();
		controller.executeBatch();
	}
	
	
}