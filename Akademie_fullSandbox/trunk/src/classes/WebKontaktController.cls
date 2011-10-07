public class WebKontaktController {
	public Lead websiteLead {get; set;}
	
	public WebKontaktController(){
		websiteLead = new Lead();
	}
	//save
	public PageReference saveRuf(){
		//No empty companyfield
		if(websiteLead.company == '' || websiteLead.Company == null){
			websiteLead.company = 'Privat';
		}
		websiteLead.LeadSource = 'Website Rückruf';
		
		
		String link = WebURLEncoder.getPageIdById('p-01335');
		insert websiteLead;
		return new PageReference('/page?pageid='+link);
	}
	
	public PageReference saveInteresse(){
		//No empty companyfield
		if(websiteLead.company == '' || websiteLead.Company == null){
			websiteLead.company = 'Privat';
		}
		websiteLead.LeadSource = 'Website Interesse';
		
		
		String link = WebURLEncoder.getPageIdById('p-01379');
		insert websiteLead;
		return new PageReference('/page?pageid='+link);
	}
	
		public PageReference saveInformationsmaterial(){
		//No empty companyfield
		if(websiteLead.company == '' || websiteLead.Company == null){
			websiteLead.company = 'Privat';
		}
		websiteLead.LeadSource = 'Website Informationsmaterial';
		
		
		String link = WebURLEncoder.getPageIdById('p-01379');
		insert websiteLead;
		return new PageReference('/page?pageid='+link);
	}
}