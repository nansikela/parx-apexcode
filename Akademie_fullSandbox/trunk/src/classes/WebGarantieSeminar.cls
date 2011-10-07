public class WebGarantieSeminar {
	
	public static List<seminarList> seminarObject {get; set;}
	

	
	public WebGarantieSeminar(){
		
		Map<Integer, String> monthList = new Map<Integer, String>();
		monthList.put(1, 'Januar');
		monthList.put(2, 'Februar');
		monthList.put(3, 'März');
		monthList.put(4, 'April');
		monthList.put(5, 'Mai');
		monthList.put(6, 'Juni');
		monthList.put(7, 'Juli');
		monthList.put(8, 'August');
		monthList.put(9, 'September');
		monthList.put(10, 'Oktober');
		monthList.put(11, 'November');
		monthList.put(12, 'Dezember');
		
		seminarObject = new List<seminarList>();
		List<Product2> productList = [	Select 
											p.Veranstaltungsort2__r.Name, 
											p.Veranstaltungsort2__r.Account__r.billingCity, 
											p.Veranstaltungsort2__c, 
											p.Seminarende__c, 
											p.Seminarbeginn__c, 
											p.Portfolio__r.Intensiv_Seminar_URL__c,
											p.Portfolio__r.NEU__c,
											p.Portfolio__r.Seminartitel__c, 
											p.Portfolio__r.Register__c,
											p.Portfolio__r.Englisch__c, 
											p.Portfolio__r.Name, 
											p.Portfolio__c 
										From Product2 p 
										WHERE p.Garantie_Termin__c = true 
											AND p.Anzeige_auf_Website__c = true 
											AND p.Seminarbeginn__c > today 
											AND p.Portfolio__r.name <> ''
											AND p.Restpl_tze__c <> 0
										ORDER BY p.Seminarbeginn__c];
											
		Integer monthInt = 0;
		Integer oldMonthInt = 0;
		seminarList oneMonth = new seminarList();									
		Seminar oneSeminar = new Seminar();
		String seminarURL = WebURLEncoder.getPageIdById('p-00017');
		for(Product2 p : productList){
			oneSeminar.code = p.Portfolio__r.name;
			oneSeminar.titel = p.Portfolio__r.Seminartitel__c;
			oneSeminar.datePlace = p.Seminarbeginn__c.format();
			oneSeminar.datePlace += ' - '+ p.Seminarende__c.format();
			oneSeminar.datePlace += ', '+p.Veranstaltungsort2__r.Account__r.billingCity;
			oneSeminar.isEnglish = p.Portfolio__r.name.contains('-E');
			oneSeminar.isNew = (p.Portfolio__r.NEU__c != null);
			
			
			if(p.Portfolio__r.Intensiv_Seminar_URL__c == null){
				oneSeminar.url = '/page?pageid='+seminarURL+'&seminarCode='+p.Portfolio__r.name+'&category='+p.Portfolio__r.register__c;
			}else{
				oneSeminar.url = p.Portfolio__r.Intensiv_Seminar_URL__c;
			}
			monthInt = p.seminarbeginn__c.month();
			
			if(monthInt != oldMonthInt && oldMonthInt != 0){
				seminarObject.add(oneMonth);
				oneMonth = new seminarList();
			}
			
			
			oneMonth.seminare.add(oneSeminar);
			oneMonth.month = monthList.get(monthInt);
			
			oneSeminar = new Seminar();
			
			
			oldmonthInt = monthInt;
		}
		seminarObject.add(oneMonth);
	}
	
	
	
	
	public class Seminar{
		public String titel {get; set;}
		public String code {get; set;}
		public String url {get; set;}
		public String month {get; set;}
		public String datePlace {get; set;}
		public boolean isEnglish {get; set;}
		public boolean isNew {get; set;}
	}
	
	public class seminarList{
		public List<Seminar> seminare {get; set;}
		public String month {get; set;}
		
		public seminarList(){
			seminare = new List<Seminar>();
		}
		
	}
}