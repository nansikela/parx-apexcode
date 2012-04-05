/**
  * Controller for MadatoryVisitPage
  * Conditions: 
  *  + none
  *
  * Firstly, the actual month and year are determined to set the timeframe for the
  * calculation. Secondly, the user is determined to query only time tracking records
  * that are visible respecting the role management. At the end the max days and current
  * days values are calculated.
  * 
  * OPTIONAL #1: 	The user can change the timeframe via two url parameter named 
  *					start and end in US dateformat MM-DD-YYYY.
  *       
  *	OPTIONAL #2:	Admins can define custom settings to customize colors and regions
  *
  * @date  01.01.2012
  * @author   Michael Mickiewicz
  **/
public with sharing class MandatoryVisitController {
    
    private final ID userID;
    private final String VISITSTATUS='Complete';
    public Outlet_Visit__c record {get;set;}
    
    Set<ID> accountIDs {get;set;}
    list<Time_Tracking__c> timecards {get;set;} 
    public Integer outletVisitAmount {get;set;}
    
    public Double maxDays {get;set;}
    public Date startingDate {get;set;}
    public Date endingDate {get;set;}

    public Boolean isRedConfigured {get;set;}
    public Boolean isGreenConfigured {get;set;}
    
    public Boolean isRedRegionConfigured {get;set;}
    public Boolean isGreenRegionConfigured {get;set;}
    
    public String greenColor {get;set;}
    public String redColor {get;set;}
    
    public double breakPoint {get;set;}
    
    public String reportURL {get;set;}
    
    public MandatoryVisitController() {
    	
    	//Default values
    	isGreenConfigured = false;
    	isRedConfigured = false;
    	breakPoint = 0.8;
    	reportURL = '#';
    	
    	userID = System.Userinfo.getUserId();
        maxDays = 0;
        Integer actualMonth = Date.today().month();
        Integer actualYear = Date.today().year();
        
        
    	//Check if customizing is definied for actual profile
    	User u = [Select Market__c From User Where ID = :userID limit 1];
    	Diagram_Settings__c mc = Diagram_Settings__c.getInstance(u.Market__c);
    	
    	if(mc != null) {
    		redColor = mc.inacceptableColor__c;
    		isRedConfigured = true;
    		greenColor = mc.acceptableColor__c;
    		isGreenConfigured = true;
    		
    		breakPoint = mc.Breakpoint__c / 100;
    		
    		if(mc.reportID__c != null) {
    			PageReference ref = new PageReference('/'+mc.reportID__c);
    			reportURL = ref.getUrl();
    		}
    	}
    	
    	//Check if user wants to change the timeframe via parameter
    	//Dateformat: MM-TT-JJJJ
        String start = ApexPages.currentPage().getParameters().get('start');
        String finish = ApexPages.currentPage().getParameters().get('end');
        
        if(start == null || finish == null) {
        	//If params not spcified, calculate the actual month.
        	startingDate = Date.newInstance(actualYear, actualMonth, 1);
        	endingDate = Date.newInstance(actualYear, actualMonth+1, 1).addDays(-1);
        } else {
        	//Else use the specified dates to target only this timeframe.
        	try {
        		Integer sMonth = Integer.valueOf(start.substring(0,2));
        		Integer sDay = Integer.valueOf(start.substring(3,5));
        		Integer sYear = Integer.valueOf(start.substring(6,start.length()));
        	
        		Integer fMonth = Integer.valueOf(finish.substring(0,2));
        		Integer fDay = Integer.valueOf(finish.substring(3,5));
        		Integer fYear = Integer.valueOf(finish.substring(6,start.length()));
        		
        		startingDate = Date.newInstance(sYear, sMonth, sDay);
        		endingDate = Date.newInstance(fYear, fMonth, fDay);
        	}catch(Exception e) {
        		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MandatoryVisits_DateformatError));
        	}
        }
        
        system.debug('Startdate: '+startingDate);
        system.debug('Enddate: '+endingDate);
        
        // After calculating the target timeframe we want to request all time tracking record respecting the role hirarchy
        // a user should only be able to see his outlet visits and the visits of his fellows in the role hierachy below him!
        set<ID> timeTrackingIDs = new set<ID>();
        
        // hope to get the right time tracking informations with this
        for(Time_Tracking__c tt : [Select Id, Number_of_possible_Visits__c, Staff_Account__c From Time_Tracking__c Where StartDate__c >=: startingDate AND StartDate__c <=: endingDate]){
            system.debug(tt);
            maxDays += tt.Number_of_possible_Visits__c;
        		
        	if(!timeTrackingIDs.contains(tt.ID))
        		timeTrackingIDs.add(tt.ID);
        }
        list<Outlet_Visit__c> ovlist = new list<Outlet_Visit__c>([Select Id, OwnerId From Outlet_Visit__c Where Time_Tracking__c IN :timeTrackingIDs AND Status__c=:VISITSTATUS]);
        outletVisitAmount = ovlist.size();
    }
    
    public static testMethod void MainTest() {
        MandatoryVisitController ctrl = new MandatoryVisitController(); 
        
       	ApexPages.currentPage().getParameters().put('start', '01-01-2012');
        ApexPages.currentPage().getParameters().put('end', '02-01-2012');
        
        ctrl = new MandatoryVisitController();
    }
}