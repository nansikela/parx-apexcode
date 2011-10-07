public class SeminarDetailviewController {
    
    // Current portfolio
    public Portfolio__c pf;
    public List<Nutzerbewertung__c> bewertungsList {get; set;}
    public Integer bewertungsAnzahl {get; set;}
    public Decimal bewertungsDurchschnitt {get; set;}
    public String bewertungsDurchschnittString {get; set;} 
    public String bewertungsAnzahlString {get; set;}
     
    // related portfolios    
    public List<Portfolio__c> additionalSeminars;
    public String trainerURL = '';
    public String seminarURL = '';
    // Events (products) of a specific portfolio
    public List<product2> seminarEvents;


    // Helper class 
    public static WebSeminarHelper semHelper;

    //Constructor
    public SeminarDetailviewController (ApexPages.StandardController stdController)
    {
    	
        try
        {          
        } 
        catch(System.Exception e)
        {
            System.debug('** Exception : ' + e.getMessage());
            ApexPages.addMessages(e);   
        }
    }
    
    //StandardConstructor
    public SeminarDetailviewController ()
    {
    	//WeiterführendeSeminare
        try
        {   
            
            String seminarCode = WebURLEncoder.decodeParam('seminarCode');
            seminarCode.replaceAll(' ', '');
            
            semHelper = new WebSeminarHelper();
            
            this.pf                 = semHelper.getPortfolioBySeminarcode(seminarCode, null);
            this.additionalSeminars = semHelper.getAdditionalSeminars(this.pf);
            this.seminarEvents      = semHelper.getSeminarEvents(this.pf.id);
            
            
            /*
            // TODO: error handling 
            if(ApexPages.currentPage().getParameters().get('pfid') != null) {
                String pfid = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('pfid'), 'UTF-8');
                String queryString = 'Select p.Id, p.Name, p.Dauer_in_Tagen__c, p.Max_Teilnehmer__c, p.Intro__c, p.Untertitel__c, p.Seminartitel__c, p.Inhalte__c, p.Methode__c, p.Zielgruppe__c, p.NEU__c, p.Preis__c, p.Hinweis_bei_Preis__c, p.Sonderpreis__c, p.Sonderpreisinfo__c, p.Weiterf_hrende_Seminare__c  From Portfolio__c p where p.Id = \'' + pfid + '\'';
                System.debug('*** Query' + queryString);
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, queryString));
                List<sObject> res = Database.query(queryString);
                pf = (Portfolio__c) res.get(0);
                weiterfuehrendeSeminare = new List<Portfolio__c>();
                if(pf.Weiterf_hrende_Seminare__c != null) {
                    String [] wfSem = pf.Weiterf_hrende_Seminare__c.split(',');
                    for(String wfseminar : wfSem) {
                        Portfolio__c pwf = webPortfolioUtil.getPortfolioByCode(wfSeminar.replaceAll(' ', ''), null);
                        weiterfuehrendeSeminare.add(pwf);
                    }
                }
                products = Database.query('Select p.Id, p.Seminarort__r.Id, p.Seminarort__r.Name, p.Co_Trainer__c, p.Co_Trainer__r.FirstName, p.Co_Trainer__r.Id, p.Co_Trainer__r.LastName, p.Trainer__c, p.Trainer__r.FirstName, p.Trainer__r.Id, p.Trainer__r.LastName,  p.Seminarort_Stadt__c, p.Seminarende__c, p.FM_Dozent__c, p.Seminarbeginn__c From Product2 p where Portfolio__r.Id = \'' + pf.Id + '\' AND p.Status_durchfuehrung__c = true AND p.Anzeige_auf_website__c = true ORDER BY Seminarbeginn__c ASC LIMIT 6');
            } else {
               System.debug('*** pfid missing');
            }
            */
            
            
        }
        catch(System.Exception e)
        {
            System.debug('** Exception : ' + e.getMessage());
            ApexPages.addMessages(e);   
        }
        
        //Bewertungen
        String seminarCode = WebURLEncoder.decodeParam('seminarCode');
        bewertungsList = [Select n.Teilnehmer__r.name, n.Sterne__c, n.Bewertungstext__c, n.Fazit__c From Nutzerbewertung__c n WHERE n.Status__c = 'Anzeigen auf Website' AND n.seminar__r.seminarcode__c = :seminarCode];
        bewertungsAnzahl = 0;
        
        bewertungsDurchschnitt = 0;
        for(Nutzerbewertung__c n : bewertungsList){
        	try{
        	n.Bewertungstext__c = n.Bewertungstext__c.replace('\n', '<br/>');
        	}catch(Exception e){
        		System.debug('************Exception'+e);
        	}
        	bewertungsAnzahl++;
        	bewertungsDurchschnitt+= Double.valueOf(n.Sterne__c);
        	
        }
        bewertungsAnzahlString = String.valueOf(bewertungsAnzahl);
        bewertungsDurchschnittString = '0';
        if(bewertungsAnzahl != 0){
        	bewertungsDurchschnittString = String.valueOf((bewertungsDurchschnitt/bewertungsAnzahl).round());
        }
    }
    

    //PortfolioInfoGetter
    public Portfolio__c getPortfolio()
    {
        return this.pf;
    }
    
    //Getting Seminar Events
    public List<Product2> getSeminarEvents()
    {
        return this.seminarEvents;
    }
    
    //Weiterführende Seminare
    public List<Portfolio__c> getAdditionalSeminars()
    {
        return this.additionalSeminars;
    }
    //Generating a list of Trainer
    public List<trainerA> getTrainer(){
    	
    	String seminarCode = WebURLEncoder.decodeParam('seminarCode');
    	List<AggregateResult> trainer = [Select 
											p.Trainer__r.id, 
											p.Trainer__r.name, 
											p.Trainer__r.titel_anrede__c, 
											p.Trainer__r.bildURL__c,
											p.Trainer__r.Sprechende_URL__c
										
											
										From Product2 p 
										WHERE 
											p.Seminarbeginn__c >=today AND p.Seminarcode__c = :seminarCode AND p.Trainer__c <> '' AND p.Trainer__r.Anzeige_auf_Website__c = true
											
										GROUP BY 
											p.Trainer__r.id, 
											p.Trainer__r.name, 
											p.Trainer__r.titel_anrede__c, 
											p.Trainer__r.Sprechende_URL__c,
											p.Trainer__r.bildURL__c];
    	
    	List<AggregateResult> cotrainer = [Select 
											p.Co_Trainer__r.id, 
											p.Co_Trainer__r.name, 
											p.Co_Trainer__r.titel_anrede__c, 
											p.Co_Trainer__r.bildURL__c,
											p.Co_Trainer__r.Sprechende_URL__c
										
											
										From Product2 p 
										WHERE 
											p.Seminarbeginn__c >=today AND p.Seminarcode__c = :seminarCode AND p.Co_Trainer__c <> '' AND p.Co_Trainer__r.Anzeige_auf_Website__c = true
											
										GROUP BY 
											p.Co_Trainer__r.id, 
											p.Co_Trainer__r.name, 
											p.Co_Trainer__r.titel_anrede__c, 
											p.Co_Trainer__r.Sprechende_URL__c,
											p.Co_Trainer__r.bildURL__c];
    	
		
		List<trainerA> result = new List<trainerA>();
		trainerA item;
		//Generating Trainer
		for(AggregateResult t : trainer){
			item = new trainerA();
			item.id = String.valueOf(t.get('Id'));
			item.name = t.get('titel_anrede__c')+ ' '+t.get('name');
			if(item.name.contains('null')) item.name = String.valueOf(t.get('name'));
			item.bildURL = String.valueOf(t.get('BildURL__c'));
			item.sprechendeURL = String.valueOf(t.get('Sprechende_URL__c'));
			result.add(item);
		}
		//Generating Cotrainer
		for(AggregateResult t : cotrainer){
			item = new trainerA();
			item.id = String.valueOf(t.get('Id'));
			item.name = t.get('titel_anrede__c')+ ' '+t.get('name');
			if(item.name.contains('null')) item.name = String.valueOf(t.get('name'));
			item.bildURL = String.valueOf(t.get('BildURL__c'));
			item.sprechendeURL = String.valueOf(t.get('Sprechende_URL__c'));
			result.add(item);
		}
		
		
		
		return result;
    }
    
    //Innerclass trainer
    public class trainerA{
    	public String id {get; set;}
    	public String name {get; set;}
    	public String bildURL {get; set;}
    	public String sprechendeURL {get; set;}
    }
    
    //Generating Trainer URL
    public String getTrainerURL(){
    	if(trainerURL=='') trainerURL = '/page?pageid='+ WebURLEncoder.getPageIdById('p-00016')+'&trainerId=';
    	return trainerURL;
    }
    
    //Generating Right Boxes Price Information
    public RightBox getPriceInformation(){
    	RightBox box = new RightBox();
    	String year = WebConfig.getPortfolioYear();
    	String code = WebURLEncoder.decodeParam('seminarCode');
    	Portfolio__c p = [	SELECT 
    							p.Weiterf_hrende_Seminare__c, 
    							p.Teil_des_Intensivprogramms__r.Intensiv_Seminar_URL__c, 
    							p.Teil_des_Intensivprogramms2__r.Intensiv_Seminar_URL__c, 
    							p.Teil_des_Intensivprogramms__r.seminartitel__c, 
    							p.Teil_des_Intensivprogramms2__r.seminartitel__c, 
    							p.Teil_des_Intensivprogramms__r.name, 
    							p.Teil_des_Intensivprogramms2__r.name, 
    							p.preis__c, p.Sonderpreisinfo__c,
    							p.Hinweis_bei_Preis__c,
    							p.Ist_Pr_fungsgeb_hr__c,
    							p.Auf_Website_buchbar__c
    						FROM Portfolio__c p 
    						WHERE p.Portfolio_Jahr__c = :year 
    							AND p.name = :code 
    							AND Anzeige_auf_website__c = true];
		
		box.price = String.valueOf(p.preis__c).replace('.',',').replace(',00',',-');
		box.priceHinweis = String.valueOf(p.Hinweis_bei_Preis__c);
		box.isPruefungegebuehr = p.Ist_Pr_fungsgeb_hr__c;
		box.aufWebsiteBuchbar = p.Auf_Website_buchbar__c;
		
		//If there is a Sonderpreis
		if(p.Sonderpreisinfo__c ==null) box.isSonderpreis = false; else box.isSonderpreis = true;
		if(box.isSonderpreis){
			String wCode = '';
			//Try to replace Links
			try{
				wCode = p.Sonderpreisinfo__c.subString(p.Sonderpreisinfo__c.indexOf(' „<se "')+7, p.Sonderpreisinfo__c.indexOf('">“'));
				box.sonderpreis = p.Sonderpreisinfo__c;
				String replaceText = '„<se "'+wCode+'">“ ('+wCode+')';
				String Link = '<a href="/page?pageid='+WebURLEncoder.getPageIdById('p-00017')+'&seminarCode='+wCode.replace(' ', '')+'">'+wCode.replace(' ', '')+'</a>';
				box.sonderpreis = box.sonderpreis.replace(replaceText, link);
				}catch(Exception e){
					box.sonderpreis = p.Sonderpreisinfo__c;
				System.debug('**************Ex'+e);
			}
		}
		//Intensivseminarinfo
		if(p.Teil_des_Intensivprogramms__r.name != null || p.Teil_des_Intensivprogramms2__r.name != null){
			box.isIntensivSeminar = true;
			box.intensivSeminar = 'Dieses Seminar ist Bestandteil des Intensivprogramms ';
			if(p.Teil_des_Intensivprogramms__r.name != null){
				box.intensivSeminar += ' <a href="/'+p.Teil_des_Intensivprogramms__r.Intensiv_Seminar_URL__c+'">'+p.Teil_des_Intensivprogramms__r.name+'</a> '+p.Teil_des_Intensivprogramms__r.seminartitel__c;
			}
			
			if(p.Teil_des_Intensivprogramms2__r.name != null){
				box.intensivSeminar += ' <a href="/'+p.Teil_des_Intensivprogramms2__r.Intensiv_Seminar_URL__c+'">'+p.Teil_des_Intensivprogramms2__r.name+'</a> '+p.Teil_des_Intensivprogramms2__r.seminartitel__c;
			}
			}else{
			box.isIntensivSeminar = false;
		}
		
		//Weiterführende Seminare
		if(p.Weiterf_hrende_Seminare__c != null){
			box.isFolgeSeminar = true;
			p.Weiterf_hrende_Seminare__c = p.Weiterf_hrende_Seminare__c.replace(' ', '');
			String query = 'Select p.name, p.Register__c, p.Seminartitel__c, p.Intensiv_Seminar_URL__c FROM Portfolio__c p WHERE (p.name = "';
			query += p.Weiterf_hrende_Seminare__c.replace(',', '" OR p.name = "');
			query += '") AND p.Portfolio_Jahr__c = "'+WebConfig.getPortfolioYear()+'"';
			query = query.replace('"', '\'');
			box.p = Database.query(query);
			List<Portfolio__c> portfolios = new List<Portfolio__c>();
			seminarURL = 'page?pageid='+WebURLEncoder.getPageIdById('p-00017')+'&seminarCode=';
			for(Portfolio__c pd : box.p){
				if(pd.Intensiv_Seminar_URL__c == '' ||pd.Intensiv_Seminar_URL__c == null){
					pd.Intensiv_Seminar_URL__c = seminarURL + pd.Name +'&category='+WebURLEncoder.encodeParam(pd.Register__c);
				}
				
				portfolios.add(pd);
			}
			
			box.p = portfolios;
			box.folgeSeminar = query;
			
			
			
		}else{
			box.isFolgeSeminar = false;
		}
		
		Portfolio__c portfolio = [SELECT p.register__c, p.Unterregister__c  From Portfolio__c p WHERE p.Name = :code LIMIT 1];
		String unterregister = portfolio.Unterregister__c;
		//Ansprechpartner for Register
		box.aTitel = 'KUNDENBERATUNG';
		box.aName = '';
		box.aTelefon = '+49.7551.9368-185';
		box.aEMail = 'info@die-akademie.de';
		
		/*if(unterregister == 'Selbstmanagement' || unterregister == 'Erfahrene Führungskräfte' || unterregister == 'Führungskräfte aller Ebenen'  || unterregister == 'Organisationsentwicklung'){
			box.aTitel = 'IHRE ANSPRECHPARTNERIN';
			box.aName = 'Birgit Schoierer';
			box.aTelefon = '+49.7551.9368-124';
			box.aEmail = 'bschoierer@die-akademie.de';
		}
		
		if(unterregister == 'Neu in Führung' || unterregister == 'Kommunikation' || unterregister == 'Tools und Techniken'){
			
			box.aTitel = 'IHR ANSPRECHPARTNER';
			box.aName = 'Martin Sens';
			box.aTelefon = '+49.7551.9368-122';
			box.aEmail = 'msens@die-akademie.de';
		}
		
		if(unterregister == 'Neu in Führung' || unterregister == 'Kommunikation' || unterregister == 'Tools und Techniken' || code == 'GMP'){
			
			box.aTitel = 'IHR ANSPRECHPARTNER';
			box.aName = 'Martin Sens';
			box.aTelefon = '+49.7551.9368-122';
			box.aEmail = 'msens@die-akademie.de';
		}
		if( unterregister == 'Strategie' || unterregister == 'Marketing und Produktmanagement' || unterregister == 'Vertrieb' || unterregister == 'Office Management' || unterregister == 'Projektmanagement' || unterregister == 'Finanzen und Controlling'){
			
			box.aTitel = 'IHR ANSPRECHPARTNER';
			box.aName = 'Stephan Kopietz';
			box.aTelefon = '+49.7551.9368-127';
			box.aEmail = 'skopietz@die-akademie.de';
		}*/
		
		if(code == 'CO')
		{
			box.aTitel = 'IHRE ANSPRECHPARTNERIN';
			box.aName = 'Silvia Ufer';
			box.aTelefon = '+49.7551.9368-180';
			box.aEmail = 'sufer@die-akademie.de';
		}
		if(code == 'FN253' || code == 'CM253' || code == 'MO253' || code=='FO118' || code=='GMP')
		{
			box.aTitel = 'IHR ANSPRECHPARTNER';
			box.aName = 'Martin Sens';
			box.aTelefon = '+49.7551.9368-122';
			box.aEmail = 'msens@die-akademie.de';
		}
		if(code=='FO253' || code == 'MV253' || code =='MAIK' || code =='MBS200')
		{
			box.aTitel = 'IHR ANSPRECHPARTNER';
			box.aName = 'Stephan Kopietz';
			box.aTelefon = '+49.7551.9368-127';
			box.aEmail = 'skopietz@die-akademie.de';
		}
		if(code=='ATA')
		{
			box.aTitel = 'IHR ANSPRECHPARTNER';
			box.aName = 'Thorsten Wulf';
			box.aTelefon = '+49.7551.9368-182';
			box.aEmail = 'twulf@die-akademie.de';
		}
		
		return box;
    }
    public class RightBox{
    	public String price {get;set;}
    	public String priceHinweis {get; set;}
    	public boolean isPruefungegebuehr {get; set;}
    	
    	public boolean aufWebsiteBuchbar{get;set;}
    	
    	public boolean IsIntensiv {get; set;}
    	
    	public String sonderpreis {get;set;}
    	public boolean isSonderpreis {get; set;}
    	
    	public boolean isIntensivSeminar {get; set;}
    	public String intensivSeminar {get; set;}
    	
    	public boolean isFolgeSeminar{get; set;}
    	public String folgeSeminar{get; set;}
    	
    	public List<Portfolio__c> p {get; set;}
    	
    	
    	
    	public String aTitel {get; set;}
		public String aName {get; set;}
		public String bereich {get; set;}
		public String aTelefon {get; set;}
		public String aEMail {get; set;}
		public String aBildURL {get; set;}
	
    }
    
    
    
    
}