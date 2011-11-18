public class FAReporting {
	
	private List<AggregateResult> seminareNachWochen {get; set;}
	public FAReporting()
	{
	
	}
	
	
	public List<UserPerBusinessUnit> getUserPerBusinessUnit()
	{
		List<UserPerBusinessUnit> result = new List<UserPerBusinessUnit>();
		
		for(AggregateResult a : [Select count(id) Counter, p.Nachgeordnete_Firma__r.name unit From Person__c p WHERE p.Nachgeordnete_Firma__c IN: FAReportingHelper.getPossibleCompanyIds() GROUP BY p.Nachgeordnete_Firma__r.name ])
		{
			result.add(new UserPerBusinessUnit(String.valueOf(a.get('unit')), String.valueOf(a.get('Counter'))));
		}
		return result;
	}
	class UserPerBusinessUnit
	{
		public String name {get; set;}
		public String counter {get; set;}
		public UserPerBusinessUnit(String unit, String counter)
		{
			this.name = unit;
			this.counter = counter;
		}
	}
	
	public List<Firma__c> getPersonalOfBusinessUnit()
	{
		return [Select name, (Select Id, CreatedDate, Email__c, Vorname__c, name, Anrede__c, Titel__c, eMail_Adresse_Vorgesetzter__c, Nachgeordnete_Firma__c, Abteilung__c, Telefon__c From FA_Personen__r ORDER BY CreatedDate DESC) From Firma__c f WHERE f.id IN :FAReportingHelper.getPossibleCompanyIds() ORDER BY name];
	}
	
	
	//Seminar bestellungen nach Wochen
	
	
	public List<Touple> getSeminarBereichCounter()
	{
		List<Touple> result = new List<Touple>();
		List<AggregateResult> seminareForBereich = [Select COUNT(w.id) counter, w.Portfolio__r.Bereich__r.name name From Warenkorb_Element__c w WHERE CreatedDate>:DateTime.now().addDays(-30)  AND Warenkorb__r.Person__r.Firma__c IN :FAReportingHelper.getPossibleCompanyIds() GROUP BY w.Portfolio__r.Bereich__r.name ];
		
		for(AggregateResult a : seminareForBereich)
		{
				result.add(new Touple(String.valueOf(a.get('name')), String.valueOf(a.get('counter'))));
		}
		
		return result;
	}

	
	class Touple{
		public String text {get; set;}
		public String counter {get; set;}
		
		public Touple(String text, String counter)
		{
			this.text = text;
			this.counter = counter;
		}
	}
	
	public List<Warenkorb_Element__c> getWarenkorbElemente()
	{
		return [Select w.CreatedDate,  w.Warenkorb__r.Status__c, w.Warenkorb__r.Person__c, w.Warenkorb__r.Person__r.name, w.Warenkorb__r.Person__r.vorname__c, w.Warenkorb__r.Person__r.Nachgeordnete_Firma__c, w.Warenkorb__r.Person__r.Nachgeordnete_Firma__r.name, w.Warenkorb__c, w.Status_Text__c, w.Status_Code__c, w.Seminarende__c, w.Seminarbeginn__c, w.Portfolio__r.URL__c, w.Portfolio__r.Web_Preis__c, w.Portfolio__r.Seminartitel__c, w.Portfolio__r.Name, w.Portfolio__c, w.Entscheidung_Vorgesetzter__c, w.EZ_Preis__c, w.Doppelzimmer__c, w.Bestelltermin__c, w.Anreise__c, w.Abreise__c, w.Einzelzimmer__c, w.Stornogrund__c, w.Anderer_Stornogrund__c From Warenkorb_Element__c w WHERE w.Warenkorb__r.Person__r.Nachgeordnete_Firma__c IN :FAReportingHelper.getPossibleCompanyIds() ORDER BY w.CreatedDate DESC LIMIT 1000 ];
	}
	
	static testMethod void test() 
    {
    	User u = [SELECT id, benutzer__c, benutzer__r.id FROM Person__c WHERE Personaler_Firma__c!= null LIMIT 1].Benutzer__r;
    	System.runAs(u)
    	{
    		FAReporting controller = new FAReporting();
    		controller.getWarenkorbElemente();
    		controller.getSeminarBereichCounter();
    		controller.getUserPerBusinessUnit();
    	}
    	
    }
	
}