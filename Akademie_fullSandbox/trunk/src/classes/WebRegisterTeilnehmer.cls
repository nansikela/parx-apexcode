public class WebRegisterTeilnehmer 
{
	public Person__c currentPerson {get; set;}
	public Firma__c firma {get; set;}
	public Anschrift__c anschrift {get; set;}
	public Warenkorb__c warenkorbObject {get; set;}
	
	private static List<FASeminar> warenkorbInhalt {get; set;}
	WarenkorbFacade warenkorbFacade {get; set;}
	public WebRegisterTeilnehmer()
	{
		currentPerson = FAHelper.getCurrentPerson();
		if(currentPerson.Name == 'WebSiteUser')
		{
			currentPerson.vorname__c = '';
			currentPerson.name = '';
			currentPerson.Email__c = '';
		}
		
		List<Anschrift__c> anschriften = [Select a.eMail__c, Land__c, a.Warenkorb__c, a.Telefon__c, Ihr_Weg_zu_uns__c, Nachricht__c, a.Telefax__c, a.Strasse__c, a.Person__c, a.PLZ__c, a.Ort__c, a.Name, a.Id, a.Firma__c, a.Ansprechpartner__c, a.Abteilung__c From Anschrift__c a WHERE Warenkorb__c =  :Warenkorb.getInstance().warenkorb.id];
		if(anschriften.size()>0)
		{
			anschrift = anschriften.get(0);
		}
		else
		{
			anschrift = new Anschrift__c(Person__c = currentPerson.id, Warenkorb__c = Warenkorb.getInstance().warenkorb.id);
		}
		
		
		warenkorbFacade = new WarenkorbFacade();
		warenkorbObject = new Warenkorb__c(id = warenkorb.getInstance().warenkorb.id);
	}
	
	public PageReference goToRechnungsanschrift()
	{
		upsert currentPerson;
		
		ApexPages.currentPage().getParameters().remove('step');
		ApexPages.currentPage().getParameters().put('step', 'rechnungsanschrift');
		return ApexPages.currentPage();
	}
	
	public boolean getisWarenkorbElement()
	{
		
		return warenkorbFacade.getisWarenkorbElement();
	}
	public List<FASeminar>getWarenkorbInhalt()
	{
		if(warenkorbInhalt == null)
		{
			System.debug('******warenkorbInhalt:'+warenkorbInhalt);
			warenkorbInhalt = warenkorbFacade.getWarenkorbInhalt();
		}
		
		return warenkorbInhalt;
	}
	
	
	public Double getPreis()
	{
		Double preis = 0;
		for(FASeminar seminar : getWarenkorbInhalt())
		{
			preis+= Double.valueOf(seminar.Preis.replace(',-', '').replace(' Reservierung', '').trim());
		}
		
		return preis;
	}
	
	public String getPreisString()
	{
		return String.valueOf(getPreis()).replace('.0',',-');
	}
	public String getPreisMWST()
	{
		if(getPreis()== 0)
		{
			return '0,-';
		}
		return numberToPreis(String.valueOf(Math.round(getPreis()*0.19*100)/100.0));
	}
	
	public String numberToPreis(String input)
	{
		
		input = input.replace('.', ',');
		if(input.contains(','))
		{
			List<String> numbers = input.split(',');
			if(numbers.get(1).length()==1)
			{
				input = input+'0';
			}
		}
		else
		{
			input+=',00';
		}
		
		return input;
	}
	
	public String getPreisGesamt()
	{
		if(getPreis()== 0)
		{
			return '0,-';
		}
		return numberToPreis(String.valueOf(Math.round(getPreis()*1.19*100)/100.0));
	}
	
	
	
	public PageReference goToUebersicht()
	{
		upsert anschrift;
		ApexPages.currentPage().getParameters().remove('step');
		ApexPages.currentPage().getParameters().put('step', 'uebersicht');
		return ApexPages.currentPage();
	}
	
	public PageReference goToAbschluss()
	{
		try
		{
			warenkorbObject.Status__c = 'Abgeschlossen';
			Messaging.sendEmail(WebeMailToTeilnehmer.geteMail(getWarenkorbInhalt(), anschrift, currentPerson));
			update warenkorbObject;
		
		}catch(Exception e){
			System.debug('***AbschlussException'+e);
		}
		return new PageReference ('/bestellungdanke');
	}
	
	static testMethod void test(){
		WebRegisterTeilnehmer controller = new WebRegisterTeilnehmer();
		controller.currentPerson.Name = 'test';
		controller.currentPerson.Vorname__c = 'assgrfe';
		controller.currentPerson.Email__c = 'efrgt@dghfd.de';
		controller.getisWarenkorbElement();
		controller.getWarenkorbInhalt();
		controller.goToRechnungsanschrift();
		controller.goToUebersicht();
		//controller.goToAbschluss();
	}
}