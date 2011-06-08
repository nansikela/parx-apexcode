public class KontaktFormularController {

	public Lead l {get;set;}
	public String Param_Lang {get;set;}
    	public String Param_Portal {get;set;}
    	public Boolean firstPage {get;set;}
    	public Boolean out1 {get;set;}
    	public Boolean out2 {get;set;}
    	public Boolean out3 {get;set;}
	public Boolean out4 {get;set;}
	public Boolean out5 {get;set;}
	public Boolean out6 {get;set;}
	public Boolean hideHelper {get;set;}
	public Boolean showPhoneErr {get;set;}
	public String errorText {get;set;}
	private String name;
	public String errorBase='<strong>' + System.Label.site.Error2 + ':</strong> ';
	public Boolean errorCompany {get;set;}
	
	public String DatenschutzLink { get; set; }
	
	public static String getBrowserName()
	{
		String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
		if (userAgent != null && userAgent.contains('MSIE'))
			return 'IE';	
			
		return userAgent;
	}
	
	// constructor
	public KontaktFormularController() {
		firstPage = true;
		hideHelper = true;
		//out1 = out2 = out3 = out4 = out5 = out6 = false;
            

	      out1 = out2 = out3 = out4 = true;
		out5 = out6 = false;

		if(ApexPages.currentPage().getParameters().get('Lang') != null && ApexPages.currentPage().getParameters().get('Lang') != '')
      		Param_Lang =  ApexPages.currentPage().getParameters().get('Lang');
      	if(ApexPages.currentPage().getParameters().get('Portal') != null && ApexPages.currentPage().getParameters().get('Portal') != '')
      		Param_Portal =  ApexPages.currentPage().getParameters().get('Portal');

		l = new lead();
		l.Ihre_Anfrage_bitte_w_hlen_Sie_aus__c = 'Ich möchte allgemeine Informationen zu Gigaset pro';
		l.Portal__c=Param_Portal;

		DatenschutzLink = Site.getCurrentSiteUrl()+'page' + '?pageid=' + getPageid('PrivacyProtection');
	}
	
	private String getPageid(String name) {
		String pid='';
		if(Param_Portal == null || Param_Portal == '')
			Param_Portal = 'de'; //standard value
			
		for (Pages__c p: Pages__c.getAll().values()) {
			if (p.IsActive__c && p.Portal__c==Param_Portal && p.Label__c==name ) pid=p.PageId__c;
		}

		return pid;
	}
	
	public PageReference ChangeDisplay() {
		String result = ApexPages.currentPage().getParameters().get('Kontaktregistration:step0form:Ihre_Anfrage_bitte_w_hlen_Sie_aus');
		
		//if(l!=null) {
			if(result == '' || result == null)
				out1 = out2 = out3 = out4 = out5 = out6 = false;
			else if(
			       result == 'Ich möchte allgemeine Informationen zu Gigaset pro' ||
			       result == 'Ich möchte Informationen zu den IP-Systemtelefonen' ||
			       result == 'Ich möchte ein Beratungsgespräch' ||
			       result == 'Ich suche einen Fachhandelspartner' ||
			       result == 'Ich bin Pressevertreter' ||
			       result == 'Ich benötige Technischen Support' 
			         ) {
				out1 = out2 = out3 = out4 = true;
				out5 = out6 = false;
			}
			else if( result == 'Ich möchte kaufen') {
				out1 = out3 = out4 = out5 = true;
				out2 = out6 = false;
			}
			else if( result == 'Ich möchte Partner werden') {
				out1 = out2 = out3 = out4 = out5 = false;
				out6 = true;
			}
		//}

		return null;
	}
	
	public PageReference insertLead() {
		system.debug('lead l ' + l);
		
		if (l!=null) {
			try {
				if(checkingPhoneNumber()) {
					firstPage = false;
					l.Zustimmung_Datenschutzerkl_rung_am__c = System.today();
					l.Datenschutzerkl_rung_zugestimmt__c = true;
					l.RecordTypeId = '012D0000000JEeU'; //Customer Datensatztyp
					l.Gigaset_Pro__c = true;
					insert l;
					l = new Lead();
				}
			} catch (Exception e) {	}
		}
		
		return null;
	}
	
	public void hideHelper() {
		hideHelper = false;	
	}
	
	public Boolean checkingPhoneNumber () {
		// Company Phone / Fax
	 	Request__c rq = new Request__c();
		if (l.Phone!=null && l.Phone!='') {
			rq.Telefon__c=l.Phone;
 			try {
 				upsert rq;
 			} catch (System.DmlException e) {
 				errorText=errorBase + returnErrorMsg(e.getMessage());
 				showPhoneErr=true;
 				return false;
 			}
		}
		
 		if (rq!=null && rq.id!=null) try {
	 		delete rq;
	 	} catch (Exception e) {}
		return true;
	}
	
	private String returnErrorMsg(String error) {
		String errmsg=error;
		String validationerr='FIELD_CUSTOM_VALIDATION_EXCEPTION';
		Integer startindex=error.indexOf(validationerr);
		// custom validation errror found?
		if (startindex!=-1) {
			startindex=startindex+validationerr.length()+2;
			Integer lastindex=error.lastIndexOf(': [');
			errmsg=error.substring(startindex,lastindex);
		}
		return errmsg;
	}
	
	public lead getl() {
		return l;
	}
	
	@isTest
	public static void testit() {
		
		KontaktFormularController KFC = new KontaktFormularController();
		
		getBrowserName();
		KFC.ChangeDisplay();
		KFC.getl();
		KFC.returnErrorMsg('test');
		KFC.l.Phone = '123456';
		KFC.checkingPhoneNumber();
		KFC.insertLead();
		KFC.hideHelper();
		
	}
}