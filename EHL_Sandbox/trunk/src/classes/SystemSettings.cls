public with sharing class SystemSettings {
    
   	//************************* CITY COUNTRY START
   	
	public static final Set<String> COUNTRYVALIDATIONLIST = new Set<String> {'SWITZERLAND'};	//must be all uppercase!
     	
   	public static final String STATUS_INACTIVE = 'Inactive';
   	public static final String LANGUAGE_FRENCH = 'Français';
   	public static final String LANGUAGE_ENGLISH = 'English';
    
    //API Profiles
    public static final Set<String> API_USERID = new Set<String>{'005200000014m96AAA', '005200000015uHCAAY'}; //EHL ESB, EHL
    
    
    public static final Id REFERENCEDATA_CITY_TYPE = '01220000000HhZQAA0';
    public static final Id REFERENCEDATA_COUNTRY_TYPE = '01220000000HFKmAAO';
    public static final String ERROR_MSG_PART1 = 'Please validate the ZIP/City information <a href="/_ui/common/search/client/ui/UnifiedSearchResults?searchType=2&sen=a11&str=';
    public static final String ERROR_MSG_PART2 = '&cache=ghdb6zas">Check</a>';
    
    //Batch Job
    public static final String TASK_STATUS = 'Completed';
    public static final String TASK_SUBJECT = 'Invalid ZIP/City combination';
    public static final String TASK_TOPIC_LEAD = 'Prospect with invalid address';    
    public static final String TASK_TOPIC_ACCOUNT = 'Account with invalid address';
    
    //ACCOUNT
    public static final String ACCOUNT_ADDRESS_BILLING_RECORDTYPE = '012200000004uUqAAI';
    public static final String ACCOUNT_ADDRESS_SHIPPING_RECORDTYPE = '012200000004w3NAAQ';
    
    public static final String ACCOUNT_SHIPPING_ADDRESS = 'Shipping Address'; //PICKLIST VALUE
   	public static final String ACCOUNT_BILLING_ADDRESS = 'Billing Address'; //PICKLIST VALUE  
   	
   	public static final String ERROR_MSG_ACCOUNT = 'There is already a preferred address for this account.';
   	
   	
   	//CONTACT
   	public static final String CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE = '012200000004uy6AAA';
    public static final String CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE = '012200000004uxrAAA';
    public static final String CONTACT_ADDRESS_BUSINESS_RECORDTYPE = '01220000000502DAAQ'; 
    public static final String CONTACT_ADDRESS_PRIVATE_RECORDTYPE = '01220000000542oAAA';
    public static final String CONTACT_ADDRESS_BILLING_RECORDTYPE = '0122000000059aaAAA';
    public static final String CONTACT_ADDRESS_PERMANENT_RECORDTYPE = '012200000005EDAAA2';
    
    public static final String CONTACT_TIME_OF_STUDY = 'Address at the time of Study'; //PICKLIST VALUE
    public static final String CONTACT_STUDENT_PERMANENT_ADDRESS = 'Student Permanent Address'; //PICKLIST VALUE
    public static final String CONTACT_BUSINESS_ADDRESS = 'Business Address'; //PICKLIST VALUE
    public static final String CONTACT_PRIVATE_ADDRESS = 'Private Address'; //PICKLIST VALUE
    public static final String CONTACT_BILLING_ADDRESS = 'Billing Address'; //PICKLIST VALUE
    public static final String CONTACT_PERMANENT_ADDRESS = 'Contact Permanent Address'; //PICKLIST VALUE

    
    public static final Map<String,String> CONTACT_ADDRESSTYPEMAP = new Map<String,String>{CONTACT_TIME_OF_STUDY => CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE,
    																			CONTACT_STUDENT_PERMANENT_ADDRESS => CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE,
    																			CONTACT_BUSINESS_ADDRESS => CONTACT_ADDRESS_BUSINESS_RECORDTYPE,
    																			CONTACT_PRIVATE_ADDRESS => CONTACT_ADDRESS_PRIVATE_RECORDTYPE,
    																			CONTACT_BILLING_ADDRESS => CONTACT_ADDRESS_BILLING_RECORDTYPE,
    																			CONTACT_PERMANENT_ADDRESS => CONTACT_ADDRESS_PERMANENT_RECORDTYPE};
    																			
   public static final Map<String,String> ADDRESS_CONTACTTYPEMAP = new Map<String,String>{  CONTACT_ADDRESS_TIME_OF_STUDY_RECORDTYPE => CONTACT_TIME_OF_STUDY,
    																			 CONTACT_ADDRESS_STUDENT_PERMANENT_RECORDTYPE => CONTACT_STUDENT_PERMANENT_ADDRESS,
    																			 CONTACT_ADDRESS_BUSINESS_RECORDTYPE => CONTACT_BUSINESS_ADDRESS,
    																			 CONTACT_ADDRESS_PRIVATE_RECORDTYPE => CONTACT_PRIVATE_ADDRESS,
    																			 CONTACT_ADDRESS_BILLING_RECORDTYPE => CONTACT_BILLING_ADDRESS,
    																			 CONTACT_ADDRESS_PERMANENT_RECORDTYPE => CONTACT_PERMANENT_ADDRESS};
    
    public static final String ERROR_MSG_CONTACT = 'There is already a preferred address for this contact.';
        
    
    //used for network creation if account has changed
    public static final String NEWTORK_RELATION_FROM_EMPLOYED = 'has employed:';
    public static final String NEWTOWRK_ACCOUNTCONTACT_RECORDTYPE = '0122000000050L6AAI';
    public static final String NEWTOWRK_CONTACTACCOUNT_RECORDTYPE = '0122000000057jLAAQ';
    
   	//************************* CITY COUNTRY END

}