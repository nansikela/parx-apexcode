public class WebSearchingFacade{

    public static List<seminarList> seminarObject {get; set;}


    public  List<SelectOption> dayOptions {get; set;}
    public  List<SelectOption> monthOptions {get; set;}
    public  List<SelectOption> yearOptions {get; set;}
    public  List<SelectOption> locationOptions {get;set;}
    public  List<SelectOption> placeOptions {get;set;}
    
    public Integer day {get; set;}
    public Integer month {get; set;}
    public Integer year {get; set;}
    public String place {get;set;}
    public String region {get; set;}
    
    
    public boolean strategy {get; set;}
    public boolean leadership {get; set;}
    public boolean expertise{get; set;}
    public boolean personality{get; set;}
    public static String query {get; set;}
    public String dateURL {get; set;}
    
    
    public String textsearch{get;set;}
    
    
    public List<WebSearchResult> result;
    
    
    public WebSearchingFacade (){
        initSelectOptions();
        day = System.today().day();
        month = System.today().month();
        year = System.today().year();
    }
    
    public void init()
    {
    	// decode category from URL
        String category = WebURLEncoder.decodeParam('category');
        
        // set category keys
        if(category.contains('s')) strategy = true; else strategy = false;
        if(category.contains('l')) leadership = true; else leadership = false;
        if(category.contains('e')) expertise = true; else expertise = false;
        if(category.contains('p')) personality = true; else personality = false;
        
        // decode date from URL
        dateURL = WebURLEncoder.decodeParam('d');
        
        // generate query string and result
        buildquery();
        prepairResult();
    }
    
    
    private void initSelectOptions()
    {
    	 // init vars
    	 DateTime dT = System.now();
         Integer y = dt.year();
         dayOptions = new List<SelectOption>();
         SelectOption item;
         
         // generate options (day)
         for(Integer i=1; i<=31; i++)
         {
         	 item = new SelectOption(String.valueOf(i),String.valueOf(i));
             dayOptions.add(item);
         }
         
         // generate option (month)
         monthOptions = new List<SelectOption>();
         for(Integer i=1; i<=12; i++)
         {
             item = new SelectOption(String.valueOf(i),String.valueOf(i));
             monthOptions.add(item);
         }
         
         // generate option (year)
         yearOptions = new List<SelectOption>();
         for(Integer i=0; i<=2; i++)
         {
             item = new SelectOption(String.valueOf(y+i),String.valueOf(y+i));
             yearOptions.add(item);
         }
         
         // generate option (location)
         locationOptions = new List<SelectOption>();
         List<AggregateResult> hotels = [Select h.Region__c from Hotel__c h WHERE h.anzeige_auf_website__c = true GROUP BY h.Region__c];
         locationOptions.add(new SelectOption('','- alle anzeigen -'));
         for(SObject h:hotels)
         {	  
         	  //if first Re
         	  if(h.get('region__c' )!= null){
              item = new SelectOption(String.valueOf(h.get('region__c')),String.valueOf(h.get('region__c')));
              locationOptions.add(item);
         	  }
         }
         // generate option (City)
         placeOptions = new List<SelectOption>();
         List<AggregateResult> hotels2 = [Select h.account__r.BillingCity from Hotel__c h WHERE h.anzeige_auf_website__c = true GROUP BY h.account__r.BillingCity];
         placeOptions.add(new SelectOption('','- alle anzeigen -'));
         for(SObject h:hotels2){
         		if(h.get('billingcity' )!= null){
                	item = new SelectOption(String.valueOf(h.get('billingcity')),String.valueOf(h.get('billingcity')));
                	placeOptions.add(item);
         		}
         }
         
         
         
       
		
		seminarObject = new List<seminarList>();
         
         
         
    }
    
    //building search query for seminars
    public void buildquery (){
        query = 'SELECT p.name,p.Portfolio__r.Intensiv_Seminar_URL__c, p.portfolio__r.englisch__c, p.Portfolio__r.Register__c, p.Portfolio__r.name, p.Portfolio__r.seminartitel__c, p.portfolio__c, p.seminarbeginn__c, p.seminarende__c, p.portfolio__r.neu__c, p.veranstaltungsort2__r.account__r.billingcity  FROM Product2 p WHERE';
        
        query += ' ( ';
        
        //if no category is selected, all categories are selected
        if(!strategy && ! leadership && !expertise && !personality)
        {
        	strategy = leadership = expertise = personality = true;
        }
        
        // select strategy
        if(strategy )
        {
            query += 'p.Portfolio__r.Register__c  = \'Strategie und Organisationsentwicklung\'';
        }
        
        // adding OR if necessary
        if(strategy && leadership)
        {
            query += ' OR ';
        }
        
        //select leadership
        if(leadership )
        {
            query += 'p.Portfolio__r.Register__c  = \'Führung\'';
        }
        
        // adding OR if necessary
        if(leadership && expertise)
        {
            query += ' OR ';
        }
        
        //select expertise
        if(expertise)
        {
            query += 'p.Portfolio__r.Register__c  = \'Fachkompetenz\'';
        }
        
        //adding OR if necessary
        if(expertise && personality)
        {
            query += ' OR ';
        }
        
        //select personality
        if(personality)
        {
            query += 'p.Portfolio__r.Register__c  = \'Persönlichkeitsentwicklung\'';
        }
        
        //select Seminarbeginn
        query += ' ) AND p.anzeige_auf_Website__c = true AND p.Seminarbeginn__c>=';
        
        
        //Date FROM
        System.debug('*********************dateUrl:'+dateUrl);
        if(dateUrl== ''){
        	
            query += 'today AND p.Seminarbeginn__c < '+Datetime.now().addMonths(3).year()+'-';
            String solvProblems = '';
            if(Datetime.now().addMonths(3).month()<10)solvProblems = '0';
            query+= solvProblems+Datetime.now().addMonths(3).month();
            solvProblems = '';
            if(Datetime.now().addMonths(3).day()<10) solvProblems = '0';
            query+= '-'+solvProblems+Datetime.now().addMonths(3).day()+' ';
        }else{
            query += dateUrl;
        }
        
        //select English seminars
        String english  = WebURLEncoder.decodeParam('e');
        if(WebURLEncoder.decodeParam('pageid')=='a0M20000003XF7mEAG'){
        english = '1';
        }
        if(english == ''){
            
        }else{
            query += ' AND p.Portfolio__r.Englisch__c = \'true\'';
        }
        
        
        //adding searchString to query
        String q = WebURLEncoder.decodeParam('q');
        if(q!='')
        {
            query+=' AND (p.Portfolio__r.name like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.name like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Seminartitel__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Register__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Unterregister__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Seminus_Kategorie_1__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Seminus_Kategorie_2__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Seminus_Kategorie_3__c like \'%'+q+'%\')';
            
        }
        
        //select region
        String region = WebURLEncoder.decodeParam('r');
        String city= WebURLEncoder.decodeParam('o');
        if(region != '' || city != ''){
        	query += ' AND ';
        }
        
        if(region!='' && city!=''){
        	query+='(';
        }
        if(region!='')
        {
            query+= ' p.veranstaltungsort2__r.region__c = \''+region+'\'';
        }
        
        //select city
        if(region!='' && city!=''){
        	query+=' OR ';
        }else{
        	
        }
        
        if(city!='')
        {
            query+= ' p.veranstaltungsort2__r.account__r.BillingCity = \''+city+'\'';
        }
        
        if(region!='' && city!=''){
        	query+=')';
        }
        
        //select garantie
        String garantie= WebURLEncoder.decodeParam('g');
        if(garantie!='')
        {
            query+= ' AND p.garantie_termin__c = true';
        }
        query+= ' AND p.name<>\'\'';
        
        //order results for "Englische Seminare"
        if(WebURLEncoder.decodeParam('pageid')=='a0M20000003XF7mEAG')
        {
           query+= ' ORDER BY p.portfolio__r.name';
        }
        else
        {
            query+= ' ORDER BY p.seminarbeginn__c';
        }
        
    }
    
    //prepairs results for Visualforcepage
    private void prepairResult(){
        result = new List<WebSearchResult>();
        WebSearchResult item; 
        //results
        System.debug(query);
        List<Product2> qresult = Database.query(query);
        
        //pageid for seminardetail
        String detailpage = WebURLEncoder.getPageIdById('p-00017');
        
        //convert queryresults to class results
        
        
        
        
        
        
        
        
        /*for(Product2 p: qresult)
        {
            item = new WebSearchResult();
            item.seminarCode = p.Portfolio__r.name;
            item.seminarText = p.Portfolio__r.seminartitel__c;
            item.datum = p.seminarbeginn__c.format() + ' - '+p.seminarende__c.format();
            item.isEnglish = Boolean.valueOf(p.Portfolio__r.Englisch__c);
            
            if(p.portfolio__r.neu__c == 'N'){
                item.isNew = true;
            }else{
                item.isNew = false;
            }
            item.ort = p.veranstaltungsort2__r.account__r.billingcity;
            item.seminarLink ='page?pageid='+detailpage+'&seminarCode='+item.seminarCode+'&category='+WebURLEncoder.encodeParam(p.portfolio__r.register__c);
            result.add(item);
        }*/
        
        
          
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
        Integer monthInt = 0;
		Integer oldMonthInt = 0;
		seminarList oneMonth = new seminarList();									
		Seminar oneSeminar = new Seminar();
		String seminarURL = WebURLEncoder.getPageIdById('p-00017');
		System.debug('************qresult'+qresult);
		for(Product2 p : qresult){
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
    
    
    //getter for results
    public List<seminarList> getResult()
    {
        init();
        return seminarObject;
    }
    
    //isResultEmpty
    public boolean getIsResultEmpty()
    {
    	if(result == null || result.size()== 0)
    	{
    		return true;
    	}
    	return false;
    }
    
    //searchButton
    public PageReference searchStartpage() {
        String link;
        link = '/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00031');
        if(place == null) place = '';
        if(region == null) region = '';
        String daykorrektor;
        String monthkorrektor;
        
        //adding 0 to days <10 => 				8=>08
        if(day<10)daykorrektor='0';
        if(month<10)monthkorrektor='0';
        if(textsearch == null){
            textsearch = '';
        }
        
        link+= '&q='+textsearch+'&o='+place+'&r='+region+'&d='+year+'-'+monthkorrektor+month+'-'+daykorrektor+day;
        try{
        link+='&category=';
        if(strategy){
        	link+='s';
        }
        if(leadership){
        	link+='l';
        }
        if(expertise){
        	link+='e';
        }
        if(personality){
        	link+='p';
        }
        }catch(Exception e){
        	System.debug('***************'+e);
        }
        link = link.replace('null','');
        return new PageReference (link);
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