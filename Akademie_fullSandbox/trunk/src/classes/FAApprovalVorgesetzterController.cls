/**
* @author Christian Deckert
* @date 18/08/2011
* @description Klasse um das Approval von Vorgesetzten für Seminare einzuholen. Wurde für Firmenakademie / Vossloh implementiert
*/
public class FAApprovalVorgesetzterController 
{
	public Warenkorb__c thewarenkorb {get; set;}
	public List<FASeminar>seminarList {get; set;}
	String warenkorbId;
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Sammelt alle Warenkorb Infos, die zum Token (in eMail an Vorgesetzten ) gesendet wurden
	*/
	public FAApprovalVorgesetzterController()
	{
		warenkorbId = WebURLEncoder.decodeparam('token');
		if(warenkorbId !='')
		{
		thewarenkorb = [Select w.Person__r.Titel__c, w.Person__r.Anrede__c, w.Person__r.Vorname__c, w.Person__r.Name, w.Person__c, w.Person__r.eMail__c From Warenkorb__c w WHERE ID = :warenkorbId AND Status__c = 'Abgeschlossen'];
		seminarList = Warenkorb.getInstance(warenkorbId).getWarenkorbElement();
		}
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Speichert die Entscheidung des Vorgesetzten
	* @return PageReference auf eine Danke seite
	*/
	public PageReference save()
	{
		for(FASeminar s: seminarList)
		{
			if(s.vorgesetzterOK!= null && s.vorgesetzterOK)
			{
				Warenkorb.getInstance(warenkorbId).getWarenkorbElement(s.id).status__c = 'Warten auf Apporval durch Akademie';
			}
			else
			{
				Warenkorb.getInstance(warenkorbId).getWarenkorbElement(s.id).status__c = 'Storno durch Vorgesetzten';
			}
			Warenkorb.getInstance(warenkorbId).getWarenkorbElement(s.id).Entscheidung_Vorgesetzter__c = DateTime.now();
		}
		Warenkorb.getInstance(warenkorbId).save();
		FAMailSender.sendApprovalFromVorgesetzter(Warenkorb.getInstance(warenkorbId).getWarenkorbElement(), thewarenkorb);
		
		return new PageReference('/FAApproval?step=thankYou');
	}
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Test methode
	*/
	static testMethod void testMain() {
		Warenkorb__c w = [SELECT ID FROM Warenkorb__c WHERE Status__c ='Abgeschlossen' LIMIT 1];
		ApexPages.currentPage().getParameters().put('token', w.id);
		FAApprovalVorgesetzterController controller = new FAApprovalVorgesetzterController();
		controller.save();
		
	}
}