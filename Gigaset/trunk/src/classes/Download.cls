public class Download{
	List<myterm> Terms = new List<myterm>();
	public boolean showUpdatePage{get;set;}
	public boolean showThirdPage{get;set;}
	public boolean acceptConditions{get;set;}
//	public string portalUser{get;set;}
	public string GeneralConditionId{get;set;}
	
	public class myterm {   //our help class
  		public Integer Iteration {get; set;}
  		public Attachment term {get; set;}
  		public boolean showDescription {get; set;}
  		
  		public myterm() {
  			Iteration=0;
  			term=new Attachment();
  			showDescription = false;
  		}
  	}
  	
  	public List<myterm> getTerms() {    //we retrieve the datas from salesforce which have to be displayed in the webshop
      	List<myterm> Terms = new List<myterm>();
		if (Terms.isEmpty()) {
			Integer i = 1;
	      	for (Attachment Doc : [select id, name, description from Attachment where OwnerId =: UserInfo.getUserId()]) {
					myterm t=new myterm();
	        		t.term=Doc;
	        		t.Iteration=i;
	        		if(Doc.description != null && Doc.description != '')
	        			t.showDescription = true;
	        		else
	        			t.showDescription = false;
	        		terms.add(t); 
	        		i++;
	        }
		}
       	return Terms;
    }   
      
	public Download(){
		showUpdatePage = false;
		showThirdPage = false;
		try{
				String name = 'GeneralCondition';
		//		String pid='';
				for (Pages__c p: Pages__c.getAll().values()) {
					if (p.IsActive__c && p.Portal__c==systemSettings.Portal && p.Label__c==name && p.isPro__c==SystemSettings.isPro) GeneralConditionId=p.PageId__c;
				}

		
		//	GeneralConditionId = [select id From Page__c p where Name='General Condition'].Id;
		}
		catch(exception e){}
		
//		portalUser= [select Contact.Portal__c from User where Id=:UserInfo.getUserId() limit 1].Contact.Portal__c;
		Docs = new list<Attachment>([select id, name, description from Attachment where OwnerId =: UserInfo.getUserId()]);
		system.debug('come here 5');
		if(Art== null) {
			system.debug('come here 3');
			try{
				system.debug('come here 4');
				Art = [select Art__c from NextTopShop__c where Benutzer__c=:UserInfo.getUserId() limit 1];
				
			}
			catch(exception e){}
		}
			

		if(Docs.size() > 2) 
			ShowButtons = False;
		else	
			ShowButtons = True;
			
		NextTopShop__c NTS;
 		try{
			NTS = [select id, Art__c, URL_1__c, URL_2__c, URL_3__c, Status_der_Teilnahme__c from NextTopShop__c where Benutzer__c=:UserInfo.getUserId() limit 1];
		}
		catch(exception e){}
		getTerms();
	}
	
	public list<Attachment> Docs {
	      get {
			Docs = [select id, name, description from Attachment where OwnerId =: UserInfo.getUserId()];
			return Docs;
		} 
		set;
	}
	
	
	public NextTopShop__c Art {
		get;set;
	}

	public boolean Table{
		get {
			Docs = [select id from Attachment where OwnerId =: UserInfo.getUserId()];
			if(Docs.isEmpty())
				return false;
			else
				return true;
		}
		set;
	}
	
	public boolean ShowButtons{
		get {
			Docs = new list<Attachment>([select id, name, description from Attachment where OwnerId =: UserInfo.getUserId()]);
			if(Docs.size() > 2) 
				return False;
			else	
				return True;		
		}
		set;
	}
/*	
	public boolean ShowButtonsAndLinks{
		get {
			NextTopShop__c NTS;
			try{
				NTS = [select Status_der_Teilnahme__c from NextTopShop__c where Benutzer__c=:UserInfo.getUserId() limit 1];
			}
			catch(exception e){
				return true;
			}
			if(NTS.Status_der_Teilnahme__c == 'Abgesendet')
				return false;
			else
				return true;		
		}
		set;
	}*/
	
	public Attachment document {
      	get {
            	if (document == null)
        			document = new Attachment();
      		return document;
    		}
    		set;
  	}
  	
  	public PageReference toUpdatePage() {
  		showUpdatePage = true;
  		return null;
  	}
  	
  	public PageReference goHome() {
  		
  		Cookie TopShop = new Cookie('HideTopShop', UserInfo.getSessionId(),null,-1,false);
  		ApexPages.currentPage().setCookies(new Cookie[]{TopShop});
  		return SystemSettings.goHome();
  	} 
  	
  	public PageReference lockGame() {
  		
  		NextTopShop__c NTS = new NextTopShop__c();
		try{
			NTS = [select id, Name, Status_der_Teilnahme__c, Benutzer__c from NextTopShop__c where Benutzer__c=:UserInfo.getUserId() limit 1];
		}
		catch(exception e){
			//NTS null, we need to create a new one.
		//	NTS.Name = UserInfo.getName();
			NTS.Benutzer__c = UserInfo.getUserId();
			insert NTS;
		}
		NTS.Status_der_Teilnahme__c = 'Keine Teilnahme';
		update NTS;
		
		return SystemSettings.goHome();
  	}
  	 
 	public PageReference updateStatus() {
 		NextTopShop__c NTS;
 		try{
			NTS = [select id, URL_1__c, URL_2__c, URL_3__c, Status_der_Teilnahme__c, kampagne__c, Kampagne__r.EndDate from NextTopShop__c where Benutzer__c=:UserInfo.getUserId() limit 1];
		}
		catch(exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.label.NTS_no_picture));
	  		return null;
		}
		if(NTS.Kampagne__c == null || (NTS.Kampagne__c != null && NTS.Kampagne__r.EndDate < system.TODAY())) {	
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.label.NTS_campaign_over));
			return null;
		}
		if((NTS.URL_1__c == null || NTS.URL_1__c == '') && (NTS.URL_2__c == null || NTS.URL_2__c == '') && (NTS.URL_3__c == null || NTS.URL_3__c == '')) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.label.NTS_no_picture));
	  		return null;
		}
		NTS.Status_der_Teilnahme__c = 'Abgesendet';
		update NTS;
		showThirdPage = True;
		
//		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Thank you for your participation!'));
		return null;
 	}
 	
  	public PageReference upload() {
  		system.debug('come here 1 ' + art );
  		if(art != null && (art.Art__c == null || art.Art__c == '')){
  			system.debug('come here 2');
  			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.label.NTS_Art_required));
  			document = new Attachment();
  			return null;
  		}
  				
		document.OwnerId = UserInfo.getUserId(); // put it in running user's folder
    		document.contenttype = 'image/jpeg';
	    	 
		NextTopShop__c NTS = new NextTopShop__c();
		try{
			NTS = [select id, Name, Art__c, URL_1__c, URL_2__c, URL_3__c, Status_der_Teilnahme__c, Benutzer__c, Kampagne__c, Kampagne__r.EndDate from NextTopShop__c where Benutzer__c=:UserInfo.getUserId() limit 1];
		}
		catch(exception e){
			//NTS null, we need to create a new one.
		//	NTS.Name = UserInfo.getName();
			NTS.Status_der_Teilnahme__c = 'Offen';
			NTS.Benutzer__c = UserInfo.getUserId();
			if(art != null)
		    		NTS.Art__c = art.Art__c;
			
			User u = [select AccountId__c, ContactId from User where Id =: UserInfo.getUserId() limit 1];
			NTS.Account__c = u.AccountId__c;
			
			//String Portal = [Select Name from profile where Id=: UserInfo.getProfileId()].Name;
			//Portal = portal.substring(Portal.length() -2, Portal.length());
			Boolean isPro = [select Gigaset_Pro__c From Contact where Id =: u.ContactId limit 1].Gigaset_Pro__c;
			try{
			//	system.debug('debuggingg.... ' + Portal + ' ' + isPro);
				NTS.Kampagne__c = [select Id from Campaign where RecordType.Name = 'Top Shop' AND Portal__c =: systemSettings.Portal AND isPro__c =: isPro AND EndDate >= TODAY AND StartDate <= TODAY AND isActive = True limit 1].Id;
			}
			catch(exception f){}
			if(NTS.Kampagne__c != null)
				insert NTS;
		}
		if(NTS.Kampagne__c == null || (NTS.Kampagne__c != null && NTS.Kampagne__r.EndDate < system.TODAY())) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.label.NTS_campaign_over));
			document = new Attachment();
			
		}else{	
			document.ParentId = NTS.Id;
			Docs = new list<Attachment>([select id, name, description from Attachment where OwnerId =: UserInfo.getUserId()]);
			
			if(Docs.size() > 2) {
				ShowButtons = False;
			}
			else
				ShowButtons = True;
				
	   		if(document.body == null) {
	   			if(ApexPages.getMessages().size() == 0)
	      			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.label.NTS_error_uploading));
	     			return null;
	      	}
	      
	    		try {
		    		document.name = 'bild';
		    		insert document;
	    		} catch (DMLException e) {
	    			if(ApexPages.getMessages().size() == 0)
	      			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.label.NTS_error_uploading2));
	      		return null;
	    		} finally {
	    			if((NTS.URL_1__c == null || NTS.URL_1__c == '') &&  document.Id != null)
	    				NTS.URL_1__c = '/servlet/servlet.FileDownload?file=' + document.Id;
	    			else if((NTS.URL_2__c == null || NTS.URL_2__c == '') &&  document.Id != null)
	    				NTS.URL_2__c = '/servlet/servlet.FileDownload?file=' + document.Id;
	    			else if((NTS.URL_3__c == null || NTS.URL_3__c == '') &&  document.Id != null)
	    				NTS.URL_3__c = '/servlet/servlet.FileDownload?file=' + document.Id;
	    			if(art != null)
		    			NTS.Art__c = art.Art__c;
		    		update NTS;
	      		document = new Attachment();
	    		}
		}
//	 	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
	  	return null;
  	}
  	
  	public PageReference Del() {
  		String DocId = ApexPages.currentPage().getParameters().get('docId');
		Database.delete(DocId);
		
		NextTopShop__c NTS = new NextTopShop__c();
		try{
			NTS = [select id, Art__c, URL_1__c, URL_2__c, URL_3__c from NextTopShop__c where Benutzer__c=:UserInfo.getUserId() limit 1];
			
			if(NTS.URL_1__c != null && NTS.URL_1__c.endsWith(DocId))
				NTS.URL_1__c = '';
			else if(NTS.URL_2__c != null && NTS.URL_2__c.endsWith(DocId))
				NTS.URL_2__c = '';
			else if(NTS.URL_3__c != null && NTS.URL_3__c.endsWith(DocId))
				NTS.URL_3__c = '';
			update NTS;
		}
		catch (exception e){}
		
		return null;
	}
	
	static testMethod void testDownload() {
		User u=[SELECT Id, Pro_Partner_Typ__c, In_Freischaltung__c, ContactId FROM User WHERE ContactId!='' and isactive=true limit 1];
	 	System.runAs(u) {
			Download ctrl = new Download();
			//ctrl.Del();
			ctrl.toUpdatePage();
			ctrl.goHome();
			ctrl.lockGame();
			ctrl.UpdateStatus();
			ctrl.upload();
			
			NextTopShop__c nts = ctrl.Art;
			boolean x = ctrl.showUpdatePage;
			x = ctrl.showThirdPage;
			x = ctrl.Table;
			x = ctrl.ShowButtons;
	//		x = ctrl.ShowButtonsAndLinks;
			Attachment a = ctrl.document;
			
	 	}
	}
}