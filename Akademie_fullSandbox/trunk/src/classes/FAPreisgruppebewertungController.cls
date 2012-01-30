public class FAPreisgruppebewertungController {

    public List<Nutzerbewertung__c> ratings { get; set; }
    
    public FAPreisgruppebewertungController()
    {
    	ratings = [Select n.Status__c, n.Produktgruppe__c, n.Name, n.Teilnehmer__r.FirstName, n.Teilnehmer__r.LastName, n.Id, n.Fazit__c, n.Bewertungstext__c From Nutzerbewertung__c n WHERE Status__c = 'Anzeigen auf Website' AND n.Produktgruppe__c = :FAHelper.getCurrentProduktGruppe().id];
    }
    
    public boolean getIsBewertung()
    {
    	if(ratings.size()>0) return true;
    	else return false;
    }
    
    static testMethod void test() 
    {
    	Gruppe__c g = [SELECT ID FROM Gruppe__c LIMIT 1];
    	ApexPages.currentPage().getParameters().put('groupId', g.id);
    	FAPreisgruppebewertungController controller = new FAPreisgruppebewertungController();
    	controller.getIsBewertung();
    }
}