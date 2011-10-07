public class WebMicroNext3SeminarsController 
{
	public List<Seminar>seminars {get; set;}
	
	
	public WebMicroNext3SeminarsController()
	{
		seminars = new List<Seminar>();
		Seminar s = new Seminar();
	}
	
	public List<Seminar> getProjektmanagement()
	{
		return getAnySeminarByCode('FO230');
	}
	public List<Seminar> getPersoenlichkeit()
	{
		return getAnySeminarByCode('PE200');
	}
	public List<Seminar> getFuehrung()
	{
		return getAnySeminarByCode('PE101');
	}
	
	
	public List<Seminar> getAnySeminarByCode(String code)
	{
		seminars = new List<Seminar>();
		for(Product2 p : [Select p.Veranstaltungsort2__r.Account__r.billingCity, p.Veranstaltungsort2__r.Id, p.Veranstaltungsort2__c, p.Trainer__r.Sprechende_URL__c, p.Trainer__r.Name, p.Trainer__c, p.Co_Trainer__r.Sprechende_URL__c, p.Co_Trainer__r.Name, p.Co_Trainer__c, p.Portfolio__r.Seminartitel__c, p.Portfolio__r.name, p.Portfolio__c, p.seminarbeginn__c, p.seminarende__c From Product2 p WHERE p.Portfolio__r.name = :code AND p.Anzeige_auf_website__c = true AND p.Seminarbeginn__c>=today LIMIT 3])
		{
			Seminar s = new Seminar();
			s.datum = p.seminarbeginn__c.format()+' - '+p.seminarende__c.format();
			s.ort = '<a href="/page?pageid=a0M20000003XGDwEAO&hotelId='+p.Veranstaltungsort2__r.id+'">'+p.Veranstaltungsort2__r.Account__r.billingCity+'</a>';
			s.titel = p.Portfolio__r.seminartitel__c;
			s.trainer = '<a href="'+p.Trainer__r.Sprechende_URL__c+'">'+p.trainer__r.name+'</a>';
			if(p.Co_Trainer__c!= null)
			{
				s.trainer+=' und <a href="'+p.Co_Trainer__r.sprechende_URL__c+'">'+p.Co_Trainer__r.name+'</a>';
			}
			
			seminars.add(s);
		}
		return seminars;
	}
	
	class Seminar{
		public String datum {get; set;}
		public String titel {get; set;}
		public String ort {get; set;}
		public String trainer {get; set;}
	}
	
	static testMethod void test() {
		WebMicroNext3SeminarsController controller = new WebMicroNext3SeminarsController();
		controller.getProjektmanagement();
	}
}