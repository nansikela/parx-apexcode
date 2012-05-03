/* Class Name : DealItem_Controller
* Description: --
* Created By : --
* Created On : --
*
* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer          Date              Description
* ----------------------------------------------------------------------------------------------------------------------------
* Tass Tsakiridis    1st May 2012      Initial Coding
*
*/ 
public with sharing class DealItem_Controller {
	private String sortDirection = 'ASC';
	private String sortExp = 'name';
	
	public Group_Promotions__c myDeal { get; set; }
	public string bfBrandValue {get;set;} 
	public string ProductNameTextValue {get;set;}
	public string ProductCodeTextValue {get;set;}      
	public string bfBrandTextValue {get;set;}
	public string DescriptionTextValue {get;set;}   
 	public List<lineItemWrapper> myDealItems {get;set;}
	//Intial ProdSelection with Strucure <wrapper>  
    //public List<materialGroupWrapper> MaterialGroupSelection {get;set;}  
    public String sortExpression {
    	get { 
    		return sortExp;
    	}
    	set {
    		if (value == sortExp) {
    			sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';
    		} else {
    			sortDirection = 'ASC';
    		}
    		sortExp = value;
    	}
    }
    
	public Group_Promotion_Item__c  myDealItem;
		
	//Custom Wrapper class for LineItem    
    public class lineItemWrapper {
        public Group_Promotion_Item__c dealItem {get; set;}
    	public boolean selected {get; set;}
    	public Id materialGroup {
    		get {
    			if (dealItem == null) { 
    				return null; 
    			} else {
    				return dealItem.Reference_Material_Group__c;
    			}
    		}
    	}
    	public double discountAmount { 
    		get {
    			if (dealItem == null) { 
    				return 0;
    			} else {
    				return dealItem.Discount_Amount__c;
    			}
    		}
    	}
    	public double priceVision {
    		get {
    			if (dealItem == null) {
    				return 0;
    			} else {
    				return dealItem.Price_Vision__c;
    			}
    		}
    	}
    	public string priceVisionType {
    		get {
    			if (dealItem == null) {
    				return '';
    			} else {
    				return dealItem.Price_Vision_Type__c;
    			}
    		}
    	}
    	public double ongoingDiscount {
    		get {
    			if (dealItem == null) {
    				return 0;
    			} else {
    				return dealItem.OnGoing__c;
    			}
    		}
    	}
    	public string conditionTypes {
    		get {
    			if (dealItem == null) {
    				return '';
    			} else {
    				return dealItem.Condition_Types__c;
    			}
    		}
    	}
      
      	void Init() {
			selected = false;
			dealItem = new Group_Promotion_Item__c();
      	}
//I need to exstend this....    
		public lineItemWrapper () {
			Init();
		}
    	public lineItemWrapper (Group_Promotions__c o, Group_Promotion_Item__c oi, Reference_Material_Group__c a){
    		Init();
    		
    		dealItem = oi;
    		if (oi == null) {
    			dealItem = new Group_Promotion_Item__c();
    			List<RecordType> recordTypes = [SELECT Name FROM RecordType WHERE Id =:o.RecordTypeId];
  				dealItem.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Group_Promotion_Item__c' AND Name =:(recordTypes[0].Name + ' Item')][0].Id;
    			dealItem.Group_Promotion__c = o.Id;
    			if (a != null) {
    				dealItem.Reference_Material_Group__c = a.Id;
    			}
    		}
    	}
    }  
	//End lineItemWrapper
	
	/*
	//Custom Wrapper class for the Product List    
    public class materialGroupWrapper {
	    public Reference_Material_Group__c materialGroup {get; set;}
    	public boolean selected {get; set;}
    	public List<lineItemWrapper> myDealItems { get; set; } 
               
		//Tass - What is the code below doing?
    	public materialGroupWrapper(Reference_Material_Group__c a) {
    		// This code is acting as the constructor for the wrapperP class.
            materialGroup = a;
            selected=false;
        }
    }    
	//End productWrapper
	*/
	
   	public DealItem_Controller (ApexPages.StandardController controller) {
        this.myDeal = (Group_Promotions__c)controller.getRecord();
        this.myDeal = [SELECT Name, RecordTypeId, RecordTypeName__c, Deal_Type__c, Deal_Method__c, Deal_Display_Helper_Type__c, Buy_Period_Start_Date__c, Account__c, AccountName__c, AccountNumber__c, Banner_Group__c, Banner_Group_Name__c, Status__c, Account_Wholesaler__c, Wholesaler__c, Wholesaler_Name__c FROM Group_Promotions__c WHERE Id =:this.myDeal.Id];
	    
      
      	//Building my list of items
      	buildDealItems();
    }   
	//End of Declaration Stuff    
    
 	//For Closing the Page link back to Order Item   
    public PageReference close(){
        return new PageReference('/'+myDeal.id);
    }      
	public PageReference saveAndClose() {
		saveAction();
		return close();
	}
	public PageReference addLine() {
		myDealItems.add(new lineItemWrapper(this.myDeal, null, null));
		return null;
	}
	
	public PageReference saveAction(){  
        Savepoint sp = Database.setSavepoint();     
        
		// Not Sure why they use a Try Block - Ask Shroyer
		// Answer: A try block is to catch any exceptions that may occur and cater for them without breaking the page        
        try{
        	if (myDealItems.size() > 0) {
        		Group_Promotion_Item__c di;
        		List<Group_Promotion_Item__c> items = new List<Group_Promotion_Item__c>();
        		for(lineItemWrapper item: myDealItems) {
        			if (item.dealItem.Reference_Material_Group__c != null) {
        				items.add(item.dealItem);        				
        			}
        		}
        		
        		if (items.size() > 0) {
        			insert items;    
        		}        		
	
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'number of items to insert: ' + items.size()));
        	}
            
            
        }catch(System.DmlException insertDmlexp){
        	Database.rollback(sp);
            for (Integer i = 0; i < insertDmlexp.getNumDml(); i++) {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, insertDmlexp.getDmlMessage(i)));
            }
        }  
        
        return null;
    }    
    
    public PageReference BuildLineItems() {
    	// Use this function only for test method as buildOrderItems is private. Will remove after test method completes
    	buildDealItems();
    	return null;
    }

	//Get Deal Items
	void buildDealItems() {
	
	 	if (myDealItems == null) {
	 		myDealItems = new List<lineItemWrapper>();
	 	}
	 	
		for(Group_Promotion_Item__c oi: [SELECT p.Reference_Material_Group__c, Reference_Material_Group_Number__c, p.Ongoing__c, p.Discount_Amount__c, p.Price_Vision__c, p.Price_Vision_Type__c, p.RecordTypeId FROM Group_Promotion_Item__c p WHERE p.Group_Promotion__c =: this.myDeal.Id]) {
			this.myDealItems.add(new lineItemWrapper(this.myDeal, oi, null));							
		}
	}


	public PageReference removeDealItems(){
		if (this.myDealItems == null) { return null; }
		
		integer numberOfItems = this.myDealItems.size();

		try {
			for(integer i = numberOfItems - 1; i >= 0; i--) {
				lineItemWrapper wr = this.myDealItems.get(i);
				if (wr.selected == true) {
					if (wr.dealItem.Id != null) { delete wr.dealItem; }
						
					this.myDealItems.remove(i);					
				}
			}  
			
		} catch(System.DMLException ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}		

        return null;
    }        

}