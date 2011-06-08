public class FNA_MapCon {
    	public Account mainAccount;
 
    	List<Account> Locations = new List<Account>(); // The list of Accounts to be shared with the Page
    	public String Lands {get; set;} // How far do we want to search? (from UI)
 
    	public Boolean error = false; // Do we continue to load the Map
    	public String msg=''; // What is the error message to display to the user? 
     	public String msg2=''; 
    	public String City {get;set;} // What city does the user want us to search?
    	public Double latStart;
    	public Double lonStart;
    	public boolean showTable{get;set;}
    	//These will be set as the Bounding Box for the query
    	public Double LatMax =0;
    	public Double LatMin =0;
    	public Double LonMin =0;
    	public Double LonMax =0;
    	public Double Rmax ; // km
    	private Double Pi = 3.1415926535897932384626433832795;
    	
    	
    	public String Param_Lang {get;set;}
    	public String Param_Portal {get;set;}
	public boolean Param_Pro {get;set;}
		
	public static String getBrowserName()
	{
		String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
		if (userAgent != null && userAgent.contains('MSIE 7'))
			return 'IE7';	
			
		return userAgent;
	}
	
		public void getParams() {
			 //   error = !isSourceAccountGood();
     		if(ApexPages.currentPage().getParameters().get('Lang') != null && ApexPages.currentPage().getParameters().get('Lang') != '')
      		Param_Lang =  ApexPages.currentPage().getParameters().get('Lang');
      	if(ApexPages.currentPage().getParameters().get('Portal') != null && ApexPages.currentPage().getParameters().get('Portal') != '')
      		Param_Portal =  ApexPages.currentPage().getParameters().get('Portal');
      	Param_Pro = false;
      	if(ApexPages.currentPage().getParameters().get('Pro') != null  ) {
      		if(ApexPages.currentPage().getParameters().get('Pro') == 'true')
      			Param_Pro = true;
      	}

      	city = '';
      	Rmax= 0;
   //     	msg='The Account cannot be mapped, please look over the Account record for more information';//'The Account cannot be mapped, please look over the Account record for more information (Account:'+mainAccount.FN__Mapping_Status__c+')';

   //     	city = '';
		}
	
    	public void init(){
    		getParams();
        //If there is no error, let's populate the map. 
        	if(!error){Search();}
        	system.debug('debug param ' +  Param_Lang + ' ' + Param_portal);
        	Rmax= 50;
    	} 
   
    /*To do the search, I Find the Dimensions of my bounding box (serach area), Generate the list of accounts, and refresh the page. */ 
	public PageReference Search() {
		system.debug('debug param 2 ' +  Param_Lang + ' ' + Param_portal);
		Error = false;
		String Status;
		if(ApexPages.currentPage().getParameters().get('city1') != null && ApexPages.currentPage().getParameters().get('city1') != '')
			city = ApexPages.currentPage().getParameters().get('city1');
		
		if(city == null || city == '') {
	    		city = 'Deutschland';
	    		Status = googleRequest();
	    		city = '';
	    		Rmax= 0;
	    	}
	    	else {
	    		city = getCleanAddress(city);
      			Status = googleRequest();
	    	}
      	if(Status == 'OK') {
      		findMax();
        		makeList();
      	}
      	else {
	      	msg = System.Label.PartnerFinder_Error;
	        Error = true;
      	}
      	Rmax= 50;
      	return null;
	}

    	public Boolean isSourceAccountGood(){
    /*    Mappable m;
        string bla;
        try{
  //      system.debug('test ID retrieved ' + ApexPages.currentPage().getParameters().get('id'));
            mainAccount = [Select Id,Name,FN__Lat__c,FN__Lon__c, Type, BillingStreet,BillingCity,BillingPostalCode,BillingState, ShippingStreet,
                           ShippingCity,ShippingState,ShippingPostalCode, FN__Mapping_Status__c, Phone, FN__Which_Address__c 
                           from Account where/* Id  = :ApexPages.currentPage().getParameters().get('id')*//* BillingCity bla limit = 1 ]; 
            
            m = new Mappable(mainAccount); // Make a "Mappable" object off of the account 
            //If it hasn't been located it... TRY! If it has... we're already in business!
             
            if(mainAccount.FN__Mapping_Status__c != 'Located'){
                
                m.geoTag();
                
                mainAccount.FN__Lat__c = m.getLat();
                mainAccount.FN__Lon__c = m.getLon();
                mainAccount.FN__Mapping_Status__c = m.getStatus(); // The Status will tell us if it worked.  
                update mainAccount; 
            }
        }catch(Exception e){
                //something crazy went down. 
                error = true;  
                Msg = 'We encountered issues while attempting to locate the account, here is the system generated Error:' + e;
                return false;  // definately not mappable. 
        }
        return m.getMappable();  */
        	return true;     
    	}
	public String getCleanAddress(String theAddress){
	        
	        theAddress = theAddress.replace('#','');
	        theAddress = theAddress.replace('/','');
	        theAddress = theAddress.replace('&','');
	        theAddress = theAddress.replace('(','');
	        theAddress = theAddress.replace(')','');
	        theAddress = theAddress.replace(';','');
	        theAddress = theAddress.replace(':','');
	        theAddress = theAddress.replace('@','');
	        theAddress = theAddress.replace('!','');
	        theAddress = theAddress.replace('~','');
	        theAddress = theAddress.replace('`','');
	        theAddress = theAddress.replace('$','');
	        theAddress = theAddress.replace('%','');
	        theAddress = theAddress.replace('^','');
	        theAddress = theAddress.replace('*','');
	        theAddress = theAddress.replace('+','');
	        theAddress = theAddress.replace('=','');
	        theAddress = theAddress.replace('"','');
	    
	        String[] brokenUp = theAddress.split(' '); 
	        String makeIt='';
	
	            for(String s:brokenUp)
	            {
	               makeIt+=s+'+';
	            }
	            
	        return makeIt; 
    }
	public String googleRequest(){
      	String Status= 'OK';    	
  //    	if(city == null || city== '')
  //    		city = 'Deutschland';
	      String url = 'http://maps.google.com/maps/geo?q=' + city + /*',' + Lands +*/'&output=csv&oe=utf8&sensor=false&key=' + System.Label.GeoApiKey;
	      HttpRequest req = new HttpRequest();
	      req.setEndpoint(url);
	      req.setMethod('GET');
	      Http h = new Http();
	      HttpResponse res = h.send(req);
	      system.debug('res body ' + res.getBody() );
	      String answer = res.getBody();
	      String[] parts = answer.split(',');
	      if(parts[0] == '200'){
            	Integer accuracy = Integer.ValueOf(parts[1]);
                  latStart = Double.ValueOf(parts[2]);
                  lonStart = Double.ValueOf(parts[3]);

          	}
          	else if(parts[0] == '500' || parts[0]== '601' ){
                	Status = 'Problem with Address';
          	}
          	else if( parts[0] == '620'){
               	Status = 'Google Exhausted';
          	}
          	else if(parts[0] == '602' || parts[0] == '603'){
                	Status = 'Problem with Address';
          	}
          	else if(parts[0] == '610'){
                	Status = 'Bad Google Key';
          	} 
          	else{
                	Status = 'Problem with Address';
          	}
        	return Status;
    
    	}

    	public void makeList(){
        	Locations = new List<Account>(); //Clear the list. 
        	try{
            	boolean lookforaccounts = false;
            	for(GlobalSettings__c GS:GlobalSettings__c.getAll().values()) {
            		if(((GS.isPro__c == Param_Pro) /*&& Param_Pro || !Param_Pro*/) && GS.Portal__c == Param_Portal && GS.Located_in_PartnerFinder__c)
            			lookforaccounts = true;
            	}
            	if(lookforaccounts){
            		Locations = Database.query(makeQuery()); 
            		msg2 = String.valueOf( Locations.size());
            		Locations = OrderSource(Locations); // Make sure the Original Account is in the list and only at the top.  
            	}
        	}
        	catch(Exception e) {error= true; Msg=System.Label.PartnerFinder_Error2;}
    	}

    /*This method takes in the list of locations, and makes sure that the MainAccount is at the top of the list.
      That ensures that the Account the user clicked on is at the TOP of the dataTable on the UI*/
    	public List<Account> OrderSource(List<Account> locations){
       
		Boolean foundMain = false;
	      list<Integer> remove = new list<Integer>();
	      list<Double> Ordering = new list<Double>();
	      list<Double> OrderingHelper = new list<Double>();
	      map<Integer, Account> LocationsTemp = new map<Integer, Account>();
	      set<Integer> y = new set<Integer>();
	      Integer j = 0;
	      for(Integer k=0; k<Locations.size(); k++){  
            	Locations.get(k).Distance__c = Math.acos(Math.sin(latStart)*Math.sin(Locations.get(k).FN__Lat__c  * Pi/180) + 
                  Math.cos(latStart)*Math.cos(Locations.get(k).FN__Lat__c * Pi/180)  *
                  Math.cos(Locations.get(k).FN__Lon__c * Pi/180-lonStart)) * 6371;
                  
       // 		system.debug('distance accounts ' + Locations.get(k).Distance__c);
      		 system.debug('locationget(k) ' + Locations.get(k));
        		if(Locations.get(k).Distance__c < Rmax && Locations.get(k) != null) {
            		Ordering.add(Locations.get(k).Distance__c);
	  //          	OrderingHelper.add(Locations.get(k).Distance__c);
	            	LocationsTemp.put(j, Locations.get(k));
        			j++;
        		}
        	}
		system.debug('ordering1 ' + Ordering);
		system.debug('locationTemp  ' + LocationsTemp);
        	Ordering.sort();
        	system.debug('ordering2 ' + Ordering);
        	Locations = new list<Account>();

           	for(Integer k=0; k<Ordering.size(); k++){
            	for(Integer i=0; i<LocationsTemp.size(); i++) {
            		system.debug('ordering3 ' + LocationsTemp.get(i));
           			system.debug('ordering4 ' + k + ' ' + Ordering.get(k));
                		if(LocationsTemp.get(i) != null && LocationsTemp.get(i).Distance__c == Ordering.get(k)) {
                    		Locations.add(LocationsTemp.get(i));
                    		//LocationsTemp.remove(i);
                    		//k=0;
                    		break;
                		}
                		if(locations.size() == 7)
                			return Locations;
            	}   
       	}
        	return Locations;
    	}

    	public String makeQuery(){
        	String searchQ = 'Select Id,Name,FN__Lat__c,FN__Lon__c, Type, BillingStreet,BillingCity,BillingPostalCode,BillingState, ShippingStreet,';
            searchQ+='ShippingCity,ShippingState,ShippingPostalCode, FN__Mapping_Status__c, Phone, FN__Which_Address__c, BillingCountry, ShippingCountry from Account';

            searchQ+=' where (( FN__Lat__c <= :latMax and FN__Lat__c >=:latMin ';
            searchQ+=' and FN__Lon__c <= :lonMax and FN__Lon__c >=:lonMin and FN__Mapping_Status__c = \'Located\' and FN__Which_Address__c !=\'Do Not Map\''; 
          	searchQ+=' and Portal__c =: Param_Portal';
          	if(Param_Pro)
          		searchQ+=' and Gigaset_Pro__c =: Param_Pro';
          	searchQ+='))  limit 30';
      
    //   String searchQ = 'select id from account limit 31';
      
        	return searchQ; 
    	}
    
    
    
    
    	public void findMax(){
        	latStart *= Pi/180;
        	lonStart *= Pi/180;
        //Rmax = 50 ;
        //Double d = Math.acos(Math.sin(lat1)*Math.sin(lat2) + Math.cos(lat1)*Math.cos(lat2) * Math.cos(lon2-lon1)) * 6371;
            latMax = Math.asin( Math.sin(latStart)*Math.cos(Rmax/6371) + 
                      Math.cos(latStart)*Math.sin(Rmax/6371)*Math.cos(0) ) * 180 / Pi;
            latMin = latStart * 180 / Pi - (latMax - latStart * 180 / Pi);
            
            lonMax = (lonStart + Math.atan2(Math.sin(90 * Pi /180)*Math.sin(Rmax/6371)*Math.cos(latStart), 
                             Math.cos(Rmax/6371)-Math.sin(latStart)*Math.sin(latStart))) * 180 / Pi;
            lonMin = lonStart * 180 / Pi - (lonMax - lonStart * 180 / Pi);
            system.debug('latmin ' + latMin);
            system.debug('latMax ' + latMax);
            system.debug('lonMin ' + lonMin);
            system.debug('lonMax ' + lonMax);
            /*
     (latMin,lonMin)            (latMax,lonMin)
            |-----------------------------|
            |                   |
            |                   |
            |                   |
            |  Rmax (50Km)          |
            |<------------>         |
            |         x(latStart,   |
            |           lonStart)   |
            |       z           |
            |                   |
            |                   |
            | y                 |
            |-----------------------------|
        (latMin,lonMax)          (latMax,lonMax)
            
            x = start Point (latstart, lonstart)
            We can now make a selective query but we still have to elimate all the accounts 
            which are not in the circle of 50km (like for example y)
            y = not good
            z = good account
            */
     }    
 
    /*Returns the list of located accounts to the UI
      I've made them Mappable Objects, just incase we want to map 
      other objects in the future, the UI can be setup for that.*/
    	public List<Mappable> getLocations(){
        	List<Mappable> maps = new List<Mappable>(); 
        	for(Account a : locations){
                	Mappable m = new Mappable(a);
                	maps.add(m);
        	}
          	
        	if(maps.isEmpty())
        		showTable = false;
        	else
        		showTable = true;
            return maps; 
    	}
    

    
    /*To create Dynamic TYPE List on Accounts*/ 
    	public List<SelectOption> getItems(){
        	List<SelectOption> items = new List<SelectOption>();
        	Schema.DescribeFieldResult F = Account.Type.getDescribe();
        	List<Schema.PicklistEntry> P = F.getPicklistValues();
    
        	items.add(new SelectOption('All','All'));
    
        	for(integer k =0; k< P.size(); k++)
        	{
            	if(P[k].isActive()){
               		items.add(new SelectOption(P[k].getLabel(),P[k].getLabel()));
            	}
        	}
        
        	return items;
    	}

    
    /* Creates drop down of Distances */  
/*    	public List<SelectOption> getLand(){ 
        	List<SelectOption> lands = new List<SelectOption>{
        		new SelectOption('','Deutschland'),
                new SelectOption('Österreich','Österreich')
        	}; 
    
       	return lands;
    	}
  */
    	public PageReference goBack(){return new PageReference('/'+mainAccount.id);}
    	public PageReference goBackMap(){return new PageReference('/apex/FindNearbyAccountsMap?Id='+mainAccount.id);}
    //	public PageReference gotoIten(){return Page.FindNearbyAccountsIten;}
    	public String getMsg(){return msg;}
     	public String getMsg2(){return msg2;}
    	public Boolean getError() {return error;}  
    	public Account getmainAccount(){return mainAccount;}
    	
}