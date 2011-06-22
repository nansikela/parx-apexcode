public class SpecialPage {
	public String Param_Lang {get;set;}
    	public String Param_Portal {get;set;}
    	
    	public Boolean ShowKontaktFormular {get;set;}
    	public Boolean ShowPartnerFinder {get;set;}
    	
    	// constructor
	public SpecialPage() {
		ShowPartnerFinder = ShowKontaktFormular = false;
		if(ApexPages.currentPage().getParameters().get('Lang') != null && ApexPages.currentPage().getParameters().get('Lang') != '')
      		Param_Lang =  ApexPages.currentPage().getParameters().get('Lang');
      	if(ApexPages.currentPage().getParameters().get('Portal') != null && ApexPages.currentPage().getParameters().get('Portal') != '')
      		Param_Portal =  ApexPages.currentPage().getParameters().get('Portal');
		
		if(ApexPages.currentPage().getUrl().contains('KontaktFormular'))
			ShowKontaktFormular = true;
		else if(ApexPages.currentPage().getUrl().contains('PartnerFinder'))
			ShowPartnerFinder = true;
		system.debug('PARAM!!! ' + ApexPages.currentPage().getParameters());
	}
}