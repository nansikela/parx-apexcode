public without sharing class AccountFactsheet {

    /** Button on Account should present a Factsheet.
    * Visual Force Page to show the most relevant information for one Account on max. 2 DIN A4 pages
    * Relevant objects are:
    * - Account (Address, Contact Names...)
    * - last visit comments 
    * - Account Brand
    * - Mandatory Products 
    * - Promotions (Sum of Promotion Totals: Total Promotion Cost (r)
    * - Promotion Activities with the same Subgroup (active and included between start and end date.)
    *
    * @author Christophe Vidal
    * @author Michael Mickiewicz
    **/
    
    public class Mandatory_Product {
    	public Mandatory_Products__c record {get;set;}
    	public String brand {get;set;}
    	
    	public Mandatory_Product(Mandatory_Products__c record, String brand) {
    		this.record = record;
    		this.brand = brand;
    	}	
    } 
    
    public class Promotion_Helper {
    	public Promotion__c record {get; set;}
    	public Boolean showStatus {get;set;}
    	
    	public Promotion_Helper(Promotion__c record, Boolean showStatus) {
    		this.record = record;
    		this.showStatus = showStatus;
    	}	
    }
    
    public Account account{get;set;} 
    public list<Contact> contact{get;set;}
    public list<Outlet_Visit__c> Outlet_Visit{get;set;}
    public list<Account_Product__c> Account_Product {get;set;}
    public list<Mandatory_Product> Mandatory_Products{get;set;}
    public String Currenc {get;set;} 
    public Double Total_Margin{get;set;}
    public Double Total_Promotion_Cost{get;set;}
    public Double Total_Brand_Profit{get;set;}
    public list<Promotion_Activity__c> Promotion_Activity{get;set;}
    public list<Key_Task__c> Key_Task{get;set;}
    public Boolean isChannelOn {get;set;}
    public Boolean isChannelOff {get;set;}
    public list<Promotion_Helper> Promotions {get;set;}
    public list<Promotion__c> pouring_contracts {get;set;}
    public String mode {get;set;}
    
    public AccountFactsheet () {
    	mode = '';
        String AccountId = ApexPages.currentPage().getParameters().get('AccountId');
        if(AccountId != null && AccountId.length() >=15 && AccountId.substring(0,3) == '001') {
            Promotions = new list<Promotion_Helper>();
            account = [select Name, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, Phone, Fax, Outlet_Class__r.Name, Channel__c, Group__c, Subgroup__c, Store_Type_TD__c  from Account where Id =:AccountId];
            contact = new list<Contact>([select salutation, LastName, FirstName, Email, Title__c from Contact where AccountId =: account.Id]);
            Outlet_Visit = new list<Outlet_Visit__c>([select Visit_Comments__c, Last_Visit_Date__c from Outlet_Visit__c where Status__c = 'Complete' AND Account__c =: AccountId order by Last_Visit_Date__c desc limit 4]);
            Account_Product = new list<Account_Product__c>([select Brand__c, Product__c from Account_Product__c where Account__c =: AccountId order by Brand__c asc]);
            list<Mandatory_Products__c> mps = new list<Mandatory_Products__c>([select Custom_Product__r.Name, Custom_Product__r.Brand__r.Name, Product_Status__c from Mandatory_Products__c where Account__c =: AccountId order by Custom_Product__r.Brand__r.Name asc]);
            list<Id> PromotionActivityIds = new list<Id>();
            
            //To query all promotions it is necessary to define the timeslot of every outlet visit, 
            //because only promotions within this timeslot have to be queried.
            Total_Margin = Total_Promotion_Cost = Total_Brand_Profit = 0;
            /*
            for(Promotion__c promo:[select CurrencyIsoCode, Total_Margin__c, Total_Promotion_Cost__c, Total_Brand_Profit__c, Promotion_Activity__c  from Promotion__c where Account__c =: AccountId]) {
                Total_Margin += promo.Total_Margin__c;
                Total_Promotion_Cost += promo.Total_Promotion_Cost__c;
                Total_Brand_Profit += promo.Total_Brand_Profit__c;
                Currenc = promo.CurrencyIsoCode;
                PromotionActivityIds.add(promo.Promotion_Activity__c);
            }
            */
            Date firstVisitDate = null;
            Date lastVisitDate = null;
            //Iterate over all outlet visits and set the date borders for first and last visit date correctly.
            for(Outlet_Visit__c ov : Outlet_Visit) {
            	if(firstVisitDate == null || firstVisitDate > ov.Last_Visit_Date__c)
            		firstVisitDate = ov.Last_Visit_Date__c;
            		
            	if(lastVisitDate == null || lastVisitDate < ov.Last_Visit_Date__c)
            		lastVisitDate = ov.Last_Visit_Date__c;	
            }
            	
            //Now the promotions with the correct visit date can be queried.
            //WARNING: If the promotion activity name contains the label "secoundary placement",
            //its status has to be shown.
            for(Promotion__c promo:[select Name, Promotion_Activity__c, Promotion_Activity__r.Name, Total_Promotion_Cost__c, Promotion_Start_Date__c, Promotion_End_Date__c, Approval_Status__c, status_of_Secondary_placement__c from Promotion__c where Account__c =: AccountId AND Promotion_Start_Date__c >= :firstVisitDate AND Promotion_Start_Date__c <= :lastVisitDate]) {
               	Boolean showStatus = false;
               	if(promo.Promotion_Activity__r.Name.contains('Secondary Placement'))
               		showStatus = true;
                Promotions.add(new Promotion_Helper(promo,showStatus));
                PromotionActivityIds.add(promo.Promotion_Activity__c);
            }
            //Query all promotion activities that happening still today, are active and targets a special germany subgroup
            Promotion_Activity = new list<Promotion_Activity__c>([select Name, Description__c from Promotion_Activity__c where Id NOT IN: PromotionActivityIds AND Begin_Date__c <=: system.today() AND End_Date__c >=: system.today() and Active__c = true AND Subgroup_Germany__c =: account.Subgroup__c ]);
            
            //Query the last 4 key tasks from the given outlet visit.
        	Key_Task = new list<Key_Task__c>([select Name, Outlet_Visit__r.Visit_Date__c from Key_Task__c where Outlet_Visit__c IN: Outlet_Visit order by Outlet_Visit__r.Visit_Date__c desc  limit 4]);
        	
        	//Query all pouring contracts. These are promotions with a special recordtype
        	pouring_contracts = new list<Promotion__c>([select Name, Promotion_Start_Date__c, Promotion_End_Date__c From Promotion__c Where RecordType.Name = 'Pouring_Contract']);
    	
        	if(account.Channel__c == 'On')
        		isChannelOn = true;
        	else if(account.Channel__c == 'Off')
        		isChannelOff = true;
        	
        	groupAccountProducts();
        	groupMandatoryProducts(mps);
        }
    }
    
    
    /*
     *	This refactored helper function clears temporarily all brands that are 
     *	grouped in the table. It iterates over all AccountPoroducts and checks 
     *	if the actual brand name is the same as the previous one.
     */
    private void groupAccountProducts() {
    	Account_Product__c lastRecord = null;
    	
    	for(Account_Product__c ap : Account_Product) {
    		if(lastRecord != null && lastRecord.Brand__c == ap.Brand__c)
    			ap.Brand__c = '';
    		else
    			lastRecord = ap;
    	}
    }
    
    
    /*
     * The same functionality as groupAccountProducts function.
     * All Mandatory Products are iterated and checked if the actual brand name
     * is the same as the previous one.
     */
    private void groupMandatoryProducts(list<Mandatory_Products__c> records) {
    	Mandatory_Products = new list<Mandatory_Product>();
    	Mandatory_Products__c lastRecord = null;
    	
    	for(Mandatory_Products__c mp : records) {
    		if(lastRecord != null && lastRecord.Custom_Product__r.Brand__r.Name == mp.Custom_Product__r.Brand__r.Name)
    			Mandatory_Products.add(new Mandatory_Product(mp, ''));
    		else
    			Mandatory_Products.add(new Mandatory_Product(mp, mp.Custom_Product__r.Brand__r.Name));
    		lastRecord = mp;
    	}
    }
	
	public PageReference renderAsPDF() {
		mode = 'pdf';
		return null;
	}
	public PageReference dummy() {
		return null;
	}
}