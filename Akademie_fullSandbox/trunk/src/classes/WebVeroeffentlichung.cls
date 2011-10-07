public class WebVeroeffentlichung {

	public List<Veroeffentlichung> getVeroeffentlichungen(){
		List<Veroeffentlichung> result = new List<Veroeffentlichung>();
		String trainerId = WebURLEncoder.decodeParam('trainerId');
		Veroeffentlichung item = new Veroeffentlichung();
		if(trainerId != '' || trainerId != null){
			List<Ver_ffentlichung__c> veroeffentlichungen = [	Select 
																	v.Name, 
																	v.Autor_Trainer__c, 
																	v.Amazon_HTML_Code__c, 
																	v.Amazon_HTML_Code_Kurztext__c, 
																	v.Amazon_Bild__c 
																From 
																	Ver_ffentlichung__c v 
																WHERE 
																	v.Autor_Trainer__c = :trainerId];
			for(Ver_ffentlichung__c v: veroeffentlichungen){
				item = new Veroeffentlichung();
				item.bild = v.Amazon_Bild__c;
				item.text = v.Amazon_HTML_Code__c;
				item.kurztext = v.Amazon_HTML_Code_Kurztext__c;
				result.add(item);
			}
		
		
		}
		String seminarCode = WebURLEncoder.decodeParam('seminarCode');
		if(seminarCode != '' || seminarCode != null){
			String year = WebConfig.getPortfolioYear();
			List<Portfolio__c> portfolios = [	Select 
													p.Ver_ffentlichung__r.Amazon_Bild__c, 
													p.Ver_ffentlichung__r.Amazon_HTML_Code_Kurztext__c, 
													p.Ver_ffentlichung__r.Amazon_HTML_Code__c, 
													p.Ver_ffentlichung__r.Autoren__c, 
													p.Ver_ffentlichung__r.Autor_Trainer__c, 
													p.Ver_ffentlichung__c 
												From 
													Portfolio__c p 
												WHERE 
													p.name = :seminarCode 
												AND 
													p.portfolio_jahr__c = :year
												AND
													p.Ver_ffentlichung__r.name<> ''];
			for(Portfolio__c p: portfolios){
				item.bild = p.Ver_ffentlichung__r.Amazon_Bild__c;
				item.text = p.Ver_ffentlichung__r.Amazon_HTML_Code__c;
				item.kurztext = p.Ver_ffentlichung__r.Amazon_HTML_Code_Kurztext__c;
				result.add(item);
			}
		}
		
		
		
		
		return result;
	}
	
	public boolean getTrainerVeroeffentlichung(){
		if(this.getVeroeffentlichungen().size() == 0) return false; else return true;
	}
	
	public class Veroeffentlichung{
		public String bild {get; set;}
		public String text {get; set;}
		public String kurztext {get; set;}
	}

}