public class FABestellungZyklus 
{
	//Step 1
	public List<SelectOption>zyklusSelect {get; set;}
	public String zyklusId {get; set;}
	public String preis {get; set;}
	public Gruppe__c gruppe {get; set;}
	public List<Seminar_to_Portfolio__c> seminare {get; set;}
	public List<Warenkorb_Element__c> warenkorbElement {get; set;}
	public List<SeminarWarenkorb>warenkorbElementSeminar {get; set;}
	public String buchungstyp {get; set;}
	public Warenkorb_Element__c standardWElement {get; set;}
	
	//Step 2
	public Terminblock__c currentTerminBlock {get; set;}
	
	public FABestellungZyklus()
	{
		standardWElement = new Warenkorb_Element__c();
		if(WebURLEncoder.decodeParam('step') == '')
		{
			zyklusSelect = new List<SelectOption>();
		
			List<Terminblock__c> terminbloecke = [Select t.Produktgruppe__c, t.Name, t.LIVE__c, t.Id, t.Anordnung__c From Terminblock__c t WHERE t.Produktgruppe__c = :WebURLEncoder.decodeParam('groupId') AND LIVE__c = true];
			for(Terminblock__c t : terminbloecke)
			{
				zyklusSelect.add(new SelectOption(t.id, t.name));
			}
			gruppe = [SELECT Web_Preis__c, url__c FROM Gruppe__c WHERE ID = :WebURLEncoder.decodeParam('groupId')];
			preis = String.valueOf(gruppe.Web_Preis__c).replace('.', ',').replace(',00', ',-')+' EUR zzgl. MwSt.';
		}
		else if(WebURLEncoder.decodeParam('zyklusId') <> '')
		{
			
			currentTerminBlock = [Select t.Produktgruppe__c, t.Produktgruppe__r.name, t.Produktgruppe__r.name__c, t.Name, t.LIVE__c, t.Id, t.Anordnung__c From Terminblock__c t WHERE t.id = :WebURLEncoder.decodeParam('zyklusId') AND LIVE__c = true LIMIT 1];
			seminare = [Select s.Seminar__r.Terminblock__c, s.Seminar__r.Veranstaltungsort__c, s.Seminar__r.Seminarende__c, s.Seminar__r.Seminarbeginn__c, s.Seminar__c, s.Portfolio__r.Seminartitel__c, s.Portfolio__c, s.Ort__c, s.Seminar__r.Seminarort__r.DZ_Preis_dieses_Jahr__c, s.Seminar__r.Seminarort__r.EZ_Preis_dieses_Jahr__c, s.Seminar__r.Seminarort__r.name From Seminar_to_Portfolio__c s WHERE Seminar__r.Terminblock__c = :WebURLEncoder.decodeParam('zyklusId')];
			
			warenkorbElementSeminar = new List<SeminarWarenkorb>();
			warenkorbElement = new List<Warenkorb_Element__c>();
			for(Seminar_to_Portfolio__c s : seminare)
			{
				Warenkorb_Element__c we = new Warenkorb_Element__c (Warenkorb__c = Warenkorb.getInstance().warenkorb.id, Seminar__c = s.Seminar__c, Portfolio__c = s.Portfolio__c, Terminblock__c = currentTerminBlock.id);
				warenkorbElementSeminar.add(new SeminarWarenkorb(we, s));
				warenkorbElement.add(we);
			}
			
		}
	}
	
	
	public class SeminarWarenkorb
	{
		public Warenkorb_Element__c we {get; set;}
		public Seminar_to_Portfolio__c s {get; set;}
		
		public SeminarWarenkorb(Warenkorb_Element__c we, Seminar_to_Portfolio__c s)
		{
			this.we = we;
			this.s = s;
		}
	}
	public PageReference goToTermin()
	{
		System.debug(gruppe.url__c);
		System.debug('?id='+zyklusId);
		return new PageReference(gruppe.url__c+'/order?zyklusId='+zyklusId+'&step=2');
	}
	
	public PageReference goToWarenkorb()
	{
		for(Warenkorb_Element__c we : warenkorbElement)
		{
			we.Buchungstyp__c = standardWElement.Buchungstyp__c;
		}
		Warenkorb.getInstance().warenkorbElementList.addAll(warenkorbElement);
		Warenkorb.getInstance().save();
		return new PageReference('/warenkorb');
	}
	
	
	
	static testMethod void testMain() {
		Gruppe__c g = [SELECT ID FROM Gruppe__c WHERE Buchungstyp__c = 'Zyklus' LIMIT 1];
		ApexPages.currentPage().getParameters().put('groupId', g.id);
		FABestellungZyklus controller = new FABestellungZyklus();
		
		
	}
	static testMethod void testMain2() {
		Warenkorb_Element__c w = [SELECT Id, warenkorb__r.person__r.Benutzer__c,warenkorb__r.person__r.Benutzer__r.id FROM Warenkorb_Element__c WHERE warenkorb__r.person__r.Benutzer__c != null LIMIT 1];
		User u = w.warenkorb__r.person__r.Benutzer__r;
		System.runAs(u){
			Gruppe__c g = [SELECT ID FROM Gruppe__c WHERE Buchungstyp__c = 'Zyklus' LIMIT 1];
			ApexPages.currentPage().getParameters().put('groupId', g.id);
			FABestellungZyklus controller = new FABestellungZyklus();
			ApexPages.currentPage().getParameters().put('zyklusId', controller.zyklusSelect.get(0).getValue());
			controller = new FABestellungZyklus();
			controller.seminare=[SELECT Id FROM Seminar_To_Portfolio__c limit 10];
			controller.warenkorbElement=[SELECT Id, warenkorb__r.person__r.Benutzer__c,warenkorb__r.person__r.Benutzer__r.id FROM Warenkorb_Element__c WHERE warenkorb__r.person__r.Benutzer__c != null LIMIT 10];
			controller.goToTermin();
			FABestellungZyklus.SeminarWarenkorb sw = new FABestellungZyklus.SeminarWarenkorb(controller.warenkorbElement.get(0), controller.seminare.get(0));
			Warenkorb.getInstance().warenkorbElementList.clear();
			controller.goToWarenkorb();
		}
	}
	
}