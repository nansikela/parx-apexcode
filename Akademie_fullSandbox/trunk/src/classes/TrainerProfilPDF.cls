public class TrainerProfilPDF 
{
    public Contact trainer {get; set;}
    
    public TrainerProfilPDF ()
    {
        trainer = [SELECT Firstname, Lastname, Titel_Anrede__c, Birthdate, BildURL__c, Website_Trainingsschwerpunkte__c, Website_Profil__c  FROM Contact WHERE ID = : ApexPages.currentPage().getParameters().get('id')];
    }

}