public class WarenkorbInternView 
{
	public Person__c person {get; set;}
	public Warenkorb__c warenkorb {get; set;}
	public WarenkorbInternView()
	{
		List<Warenkorb__c> we = [Select w.Status__c, w.Person__r.Land__c, w.Person__r.PLZ__c, w.Person__r.Ort__c, w.Person__r.Strasse__c , (Select IsDeleted, Name, CreatedDate, LastModifiedDate, Abteilung__c, Ansprechpartner__c, eMail__c, Firma__c, Person__c, PLZ__c, Strasse__c, Telefax__c, Telefon__c, Warenkorb__c, Ort__c, Land__c, Ihr_Weg_zu_uns__c, Nachricht__c From Anschriften__r),  w.Person__r.Telefon__c, w.Person__r.Firma__c, w.Person__r.Titel__c, w.Person__r.Anrede__c, w.Person__r.Vorname__c, w.Person__r.Email__c, w.Person__r.Name, w.Person__c, (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Warenkorb__c, Abreise__c, Anreise__c, Bestelltermin__c, DZ_Preis__c, Doppelzimmer__c, EZ_Preis__c, Einzelzimmer__c, Entscheidung_Vorgesetzter__c, Hotel__c, Hotelreservierung__c, Inhouse_Seminar__c, Ort__c, Portfolio__c, Seminar__c, Status__c, ist_Reservierung__c, Seminarende__c, Seminarbeginn__c, Information_an_HR__c, Teilnehmer_Id__c, Teilnehmer__c, Stornogrund__c, Anderer_Stornogrund__c, Buchungstyp__c, Status2__c, Terminblock__c From Warenkorb_Elemente__r) From Warenkorb__c w WHERE id = :WebURLEncoder.decodeParam('id')];
		if(we.size()>0)
		{
			warenkorb = we.get(0);
		}
	}
	
	static testMethod void myUnitTest() {
		WarenkorbInternView c = new WarenkorbInternView();
	}
}