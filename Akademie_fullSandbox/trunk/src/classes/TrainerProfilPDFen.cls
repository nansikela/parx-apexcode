public class TrainerProfilPDFen
{
    public Contact trainer {get; set;}
    
    public TrainerProfilPDFen ()
    {
        trainer = [SELECT Firstname, Lastname, Titel_Anrede__c, Birthdate, BildURL__c, Zitat_ENG__c, Website_Trainingsschwerpunkte_ENG__c, Website_Profil_ENG__c  FROM Contact WHERE ID = : ApexPages.currentPage().getParameters().get('id')];
    }

}