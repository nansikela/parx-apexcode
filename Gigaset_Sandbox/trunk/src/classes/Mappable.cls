public class Mappable{

    Static Final Double PI = 3.14159265;
    String ID = '';
    String ObjectType = ''; 
    String Phone ='';
    Double Lat =0;
    Double Lon =0; 
    String Name ='';
    String Status = ''; 
    String Street='';
    String City='';
    String State ='';
    String Country ='';
    String Tp = '';
    String Zip = '';
    Double Distance = 0;
   
    Boolean Mappable = true; 

    public Mappable(Account A){
    	  system.debug('debugging Account: ' + A);
        Id = A.Id;
        ObjectType = 'Account';
        
        if(A.Phone == null){
            Phone = '';
        }
        else{  
            Phone = A.Phone;
        }         
        Lat = A.FN__Lat__c;
        Lon = A.FN__Lon__c;
        Name = A.Name;
        Status = A.FN__Mapping_Status__c;
        Tp = A.Type;
        Distance = A.Distance__c;
        if(A.FN__Which_Address__c == 'Shipping')
        {    
            Street = A.ShippingStreet;
            City = A.ShippingCity;
            State = A.ShippingState; 
            Country = A.ShippingCountry;
            Zip = A.ShippingPostalCode; 
        }
        else if(A.FN__Which_Address__c == 'Billing' || A.FN__Which_Address__c != null)
        {    
            Street = A.BillingStreet;
            City = A.BillingCity;
            State = A.BillingState; 
            Country = A.BillingCountry;
            Zip = A.BillingPostalCode; 
        }
            
    }

       public String getCleanAddress(){
        String theAddress='';
        
        if(zip == null){ zip = '';}
        if(street == null){ street = '';}
        if(Country == null){ Country = '';}
        if(city == null){ city = '';}
        
     //   if(street != null && city != null && Country != null){
            theAddress += street+',' + zip + ',' + city + ',' + Country; 
   //     }
    //    else{ 
    //        mappable = false; 
    ////        Status = 'Problem with Address'; 
    //        theAddress='';
    //        return Status;
    //    }
         
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
   /*Create request*/
   public HttpRequest buildWebServiceRequest(){
        String url = 'http://maps.google.com/maps/geo?q='+getCleanAddress()+'&output=csv&oe=utf8&sensor=false';//&key='+Label.GeoApiKey;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        return req; 
    }
    /*make the call out*/
 
    public static String invokeWebService(Http h, HttpRequest req){
         HttpResponse res = h.send(req);
        return  res.getBody();
    }
    
    /*Go through the respone*/ 
    public void handleWebServiceResponse(String answer){
        String[] parts; 
   
        parts = answer.split(',');

        if(parts[0] == '200')
        {
            Integer accuracy = Integer.ValueOf(parts[1]);
            
            if(accuracy < 6){
                Status = 'Problem with Address';
                mappable = false; 
            }
            else{
                Lat = Double.ValueOf(parts[2]);
                Lon = Double.ValueOf(parts[3]);
                Status = 'Located';
                mappable = true;
            }
        }
        else if(parts[0] == '500' || parts[0]== '601' ){
            Status = 'Problem with Address';
            mappable =false;
        }
        else if( parts[0] == '620'){
            Status = 'Google Exhausted';
            mappable = false; 
        }
        else if(parts[0] == '602' || parts[0] == '603'){
            Status = 'Problem with Address';
            mappable =false;
        }
        else if(parts[0] == '610'){
            Status = 'Bad Google Key';
            mappable =false;
        } 
        else{
            Status = 'Problem with Address';
            mappable= false; 
        }
    }

    public String geoTag(){
        if(mappable)
        {
            try{
                Http h = new Http();
                HttpRequest req= buildWebServiceRequest(); 
                String res = invokeWebService(h,req); 
                handleWebServiceResponse(res); 
            }catch(Exception e){
              mappable = false; 
              Status = 'Problem with Address'; 
           }
        }
        return Status; 
    }
    
    public String getStreet(){return Street;}
    public Double getDistance(){return Distance;}
    public String getState(){return State;}
    public String getCity(){return City;}
    public String getZip(){return Zip;}

    public Double getLat(){return Lat;}
    public Double getLon(){return Lon;}
    
    public String getID(){return Id;}
    public String getObjType(){ return ObjectType;} 
    public String getPhone(){return phone;}
    
    public String getStatus(){ return Status;} 
    
    public String getName() {return name;}
    public String getType() {return Tp;}

    public Boolean getMappable(){
        getCleanAddress();
        return mappable;
    }
    
    public String getURLCleanAddress(){
        return getCleanAddress().replace('+',' '); 
    }
    
    static testMethod void myUnitTest() {
    	 	Account a =new Account(Name = 'test', BillingPostalCode='80331', BillingStreet='Waltherstrasse 1', BillingCity = 'Munich', BillingCountry = 'DE');
    	 	insert a;
    	 	Mappable ctrl=new Mappable(a);
    	 	ctrl.geoTag();
    	 	ctrl.getCity();
    	 	ctrl.getCleanAddress();
    	 	ctrl.getDistance();
    	 	ctrl.getID();
    	 	ctrl.getLat();
    	 	ctrl.getLon();
    	 	ctrl.getMappable();
    	 	ctrl.getName();
    	 	ctrl.getObjType();
    	 	ctrl.getPhone();
    	 	ctrl.getState();
    	 	ctrl.getStatus();
    	 	ctrl.getStatus();
    	 	ctrl.getStreet();
    	 	ctrl.getType();
    	 	ctrl.getURLCleanAddress();
    	 	ctrl.getZip();
    	 	ctrl.handleWebServiceResponse('200,7,50,40');
    	 	ctrl.handleWebServiceResponse('200,5,50,40');
    	 	ctrl.handleWebServiceResponse('500,5,50,40');
    	 	ctrl.handleWebServiceResponse('620,5,50,40');
    	 	ctrl.handleWebServiceResponse('602,5,50,40');
    	 	ctrl.handleWebServiceResponse('610,5,50,40');
    	 	ctrl.handleWebServiceResponse('111,5,50,40');
    	 }
    
}