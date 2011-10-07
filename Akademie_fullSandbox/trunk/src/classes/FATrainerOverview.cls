public class FATrainerOverview {
	public List<TrainerContainer>trainer {get; set;}
	
	public FATrainerOverview()
	{
		trainer = new List<TrainerContainer>();
		for(Contact c: [Select c.BildURL__c, c.Title, c.Sprechende_url__c, c.Name, c.LastName, c.Id From Contact c  WHERE c.Dozent__c = true  AND c.Anzeige_auf_website__c = true  ORDER BY LastName])
		{
			trainer.add(new TrainerContainer(c));
		}
	}
	
	class TrainerContainer{
		public String firstCaracter {get; set;}
		public String name {get; set;}
		public String url {get; set;}
		public String titel {get; set;}
		public String bild {get; set;}
		
		public TrainerContainer(Contact c)
		{
			firstCaracter = c.lastname.subString(0,1);
			if(firstCaracter == 'X' || firstCaracter == 'Y' || firstCaracter == 'Z')
			{
				firstCaracter = 'XYZ';
			}
			name = c.name;
			titel = c.title;
			url = c.Sprechende_url__c;
			bild = c.BildURL__c;
		}
	}
	
	static testMethod void testFaHelper() {
		FATrainerOverview controller = new FATrainerOverview();
	}
}