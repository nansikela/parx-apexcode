/* Class Name : OrderItem_Controller
* Description: --
* Created By : --
* Created On : --
*
* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer       Date              Description
* ----------------------------------------------------------------------------------------------------------------------------
* Mike Levites  06-27-2011        Code for Product Remediation Check.      
* Stuff to Do:
* 1.Dynamic Look Up for Market
* 2.Fix the Product Select Statment to include the Market Value 
* 3.Select Market from current User's market
* 4. 
* 5. 
*/ 
public with sharing class OrderItem_Controller {
	private String sortDirection = 'ASC';
	private String sortExp = 'name';
	
	public Order__c myOrder { get; set; }
	public string bfBrandValue {get;set;} 
	public string ProductNameTextValue {get;set;}
	public string ProductCodeTextValue {get;set;}      
	public string bfBrandTextValue {get;set;}
	public string DescriptionTextValue {get;set;}   
 	public List<lineItemWrapper> myOrderItems {get;set;}
	//Intial ProdSelection with Strucure <wrapper>  
    public List<productWrapper> ProdSelection {get;set;}  
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
    
	public Order_Item__c  myOrderItem;
	
	public RecordType orderItemRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Order_Item__c' AND Name = 'New'];
	
	Account a;
	id OrderId;
    Id marketID = 'a06Q0000005nz0B';
    //integer myLimit = 2000;

	//Custom Wrapper class for LineItem    
    public class lineItemWrapper {
        public Order_Item__c orderItem {get; set;}
        public Product__c prod {get; set;}
    	public boolean selected {get; set;}
    	public brand__c brand {get; set;}
   	    public integer carton { 
   	    	get { return orderItem == null || orderItem.Carton__c == null ? 0 : (integer)orderItem.Carton__c; }
   	    }
		public integer unit { 
			get { return orderItem == null || orderItem.Unit__c == null ? 0 : (integer)orderItem.Unit__c; } 
		}
		public decimal discount { 
			get { return orderItem == null || orderItem.Discount__c == null ? 0 : orderItem.Discount__c; } 
		}
		public integer bonusCarton { 
			get { return orderItem == null || orderItem.Carton_Bonus__c == null ? 0 : (integer)orderItem.Carton_Bonus__c; } 
		}
		public integer bonusUnit { 
			get { return orderItem == null || orderItem.Unit_Bonus__c == null ? 0 : (integer)orderItem.Unit_Bonus__c; } 
		}
      
      	void Init() {
			selected = false;
			orderItem = new Order_Item__c();
			prod = null;
			brand = null;
      	}
//I need to exstend this....    
		public lineItemWrapper () {
			Init();
		}
    	public lineItemWrapper (Order__c o, Order_Item__c oi, Product__c a){
    		Init();
    		prod = a;
    		brand = a.Brand__r;
    		
    		orderItem = oi;
    		if (oi == null) {
    			orderItem = new Order_Item__c();
    			orderItem.RecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Order_Item__c' AND Name = 'New'][0];
    			orderItem.Order__c = o.Id;
    			orderItem.Product__c = a.Id;
    		}
    	}
    }  
	//End lineItemWrapper
	
	//Custom Wrapper class for the Product List    
    public class productWrapper {
	    public Product__c prod {get; set;}
    	public boolean selected {get; set;}
    	public integer brandQTY {get;set;}    
    	public integer planBottle {get;set;}
    	public double planRebate {get;set;}  
    	public List<lineItemWrapper> myOrderItems { get; set; } 
               
		//Tass - What is the code below doing?
    	public productWrapper(Product__c a) {
    		// This code is acting as the constructor for the wrapperP class.
            prod = a;
            selected=false;
        }
    }    
	//End productWrapper


	//Public Declaration Stuff
   	public OrderItem_Controller (ApexPages.StandardController controller) {
		List<Market__c> markets = [SELECT Id FROM Market__c WHERE Name = 'Australia'];
		if (markets != null && markets.size() > 0) {
			marketID = markets[0].Id;
		}
   		
        this.myOrder = (Order__c)controller.getRecord();
        this.myOrder = [SELECT Name, RecordTypeId, RecordTypeName__c,Account__c, Account_Name__c, AccountNumber__c, Banner_Partner__c, Contact__c, Order_Date__c, Status__c, Wholesaler_Code__c, Wholesaler_Name__c, Wholesalers__c, Wholesaler_Customer_Number__c, Wholesaler_Account_Name__c FROM Order__c WHERE Id =:myOrder.Id];
	    
	    //This Builds the intial List.
      	buildProdSelection(); 
      
      	//Building my list of items
      	buildOrderItems();
    }   
	//End of Declaration Stuff    
    
 	//For Closing the Page link back to Order Item   
    public PageReference close(){
        return new PageReference('/'+myOrder.id);
    }      
	public PageReference saveAndClose() {
		saveAction();
		return close();
	}


	//Brand & String Filters
	public List<SelectOption> getBFBrandsList() {
        List<SelectOption> optionList = new List<SelectOption>();
        // Add a null option to force the user to make a selection. //
        optionList.add(new SelectOption('ALL','ALL'));
        for(Brand__c y :[Select r.Name, r.Id From Brand__c r where Supplier__r.Is_B_F_Brand__c = true ORDER BY r.Name]) 
        {
            optionList.add(new SelectOption(y.Id,y.Name));
        }
        return optionList;
    }
	//Getting Brand List - End
 
  
	//Once Filters Come in it will then be passed to the Product Selection   
 	public PageReference filterAction() {  
        buildProdSelection();
        return null;
    }    

	//Product Selection - Used for the Product Section Part of the screen.
 	void buildProdSelection() {    
        if (ProdSelection == null) { 
        	ProdSelection = new List<productWrapper>(); 
        } else {
        	ProdSelection.clear();
        }
        
		//Product Selection String       
        string myQueryString = 'Select p.VAT__c, p.Unit_Cost__c, p.Supplier__c, p.Sort_Order__c, p.RecordType.Name, p.RecordTypeId, p.ProductCode__c, p.Name, p.Market__c, p.IsActive__c, p.Id, p.Family__c, p.Description__c, p.CurrencyIsoCode, p.Competes_On_Brand__c, p.Case_Multiplier__c, p.Brand__c, p.Brand__r.Name, p.Brand_Code__c From Product__c p ';
        myQueryString += ' WHERE p.IsActive__c=true';
//        + ' and p.Market__c= +marketID+
        myQueryString += ' AND p.Brand__r.Supplier__r.Is_B_F_Brand__c = true';
        myQueryString += (marketID != null ? ' AND p.Market__c=\''+marketID+'\'' : '');
 

        if(bfBrandValue != null && bfBrandValue != 'ALL') {
            myQueryString+=' and p.Brand__c=\'' + bfBrandValue + '\'';
        }        
        if(ProductNameTextValue != null && ProductNameTextValue != '') {
            myQueryString+=' and p.Name like \'%' + ProductNameTextValue + '%\'';
        }
        if(ProductCodeTextValue != null && ProductCodeTextValue != '') {
            myQueryString+=' and p.ProductCode__c like \'%' + ProductCodeTextValue + '%\'';
        }    
        if(bfBrandTextValue != null && bfBrandTextValue != '') {
            myQueryString+=' and p.Brand__r.Name like \'%' + bfBrandTextValue + '%\'';
        }    
        if(DescriptionTextValue != null && DescriptionTextValue != '') {
            myQueryString+=' and p.Description__c like \'%' + DescriptionTextValue + '%\'';
        }     
        
        myQueryString+=' ORDER BY p.Sort_Order__c';
        myQueryString += ',p.' + sortExpression + ' ' + sortDirection;
                        
        //system.debug(myQueryString);
        
        System.debug('queryString: ' + myQueryString);
        for(Product__c pr :Database.query(myQueryString)) {
        	ProdSelection.add( new productWrapper(pr));
        }
     
        System.debug('[orderitem_controller] prodSelection.size: ' + ProdSelection.size());
    }

	// End Product Selection String 


	public PageReference saveAction(){  
        Savepoint sp = Database.setSavepoint();     
        
		// Not Sure why they use a Try Block - Ask Shroyer
		// Answer: A try block is to catch any exceptions that may occur and cater for them without breaking the page        
        try{    
        	List<Order_Item__c> orderItems = new List<Order_Item__c>();
        	Order_Item__c item;
            for(lineItemWrapper wp : myOrderItems) {
            	System.debug('wp.product: ' + wp.orderItem.Product__c + ', carton: ' + wp.orderItem.Carton__c + ', carton(sc): ' + wp.carton);
            	if (wp.carton + wp.unit + wp.bonusCarton + wp.bonusUnit + wp.discount > 0) {
            		integer totalStock = wp.carton + wp.unit;
            		integer bonusStock = wp.bonusCarton + wp.bonusUnit;
            		if (bonusStock > 0 && (wp.orderItem.Discount__c > 0 || totalStock > 0)) {
		            	for (Order_Item__c tt: orderItems) {
        		    		System.debug('[splitting bonus stock]Order item id: ' + tt.Id);
            			}
            			
            			Order_Item__c bonusOI = wp.orderItem.clone(false, true);
						System.debug('[splitting bonus stock] bonusOI.id: ' + bonusOI.Id);
						System.debug('[splitting bonus stock] orderitem.id: ' + wp.orderItem.Id);
            			wp.orderItem.Carton_Bonus__c = 0;
            			wp.orderItem.Unit_Bonus__c = 0;
            			orderItems.add(wp.orderItem);            			

						
						bonusOI.Carton__c = 0;
						bonusOI.Unit__c = 0;
						bonusOI.Discount__c = 0;
						            			
						orderItems.add(bonusOI);            			
            		} else {
            			orderItems.add(wp.orderItem);
            		}
            	} else {
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No amounts enterred against line item ' + wp.prod.Name));
            	}
            }
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'number of items to insert: ' + orderItems.size()));
            
            if (orderItems.size() > 0) {
            	for (Order_Item__c tt: orderItems) {
            		System.debug('Order item id: ' + tt.Id);
            	}
				upsert orderItems;                   	
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
    	buildOrderItems();
    	return null;
    }

	//Get Order Items
	void buildOrderItems() {
	
	 	if (myOrderItems == null) {
	 		myOrderItems = new List<lineItemWrapper>();
	 	}
	 	
		//Shroyer What does this do?	 
	 	//Set<ID> myProducts = new Set<ID>();
		//Custom Structure for myOrderItems & ID Correct?	 
		//Map<ID,Order_Item__c> orderItems = new Map<ID,Order_Item__c>();
		// This SET AND MAP lists are not required, as we will build the line item on the fly.
		for(Order_Item__c oi: [SELECT p.Product__c, p.Carton__c, p.Unit__c, p.Discount__c, p.Carton_Bonus__c, p.Unit_Bonus__c, p.RecordTypeId, p.RecordTypeName__c FROM Order_Item__c p WHERE p.Order__c =: this.myOrder.Id]) {
			List<Product__c> p = [SELECT p.VAT__c, p.Unit_Cost__c, p.Supplier__c, p.Sort_Order__c, p.RecordType.Name, p.RecordTypeId, p.ProductCode__c, p.Name, p.Market__c, p.IsActive__c, p.Id, p.Family__c, p.Description__c, p.CurrencyIsoCode, p.Competes_On_Brand__c, p.Case_Multiplier__c, p.Brand__c, p.Brand__r.Name, p.Brand_Code__c FROM Product__c p WHERE p.Id =:oi.Product__c];
			if (p != null && p.size() > 0) {
				this.myOrderItems.add(new lineItemWrapper(this.myOrder, oi, p[0]));				
			}
		}
	}


	public PageReference removeOrderItems(){
		if (this.myOrderItems == null) { return null; }
		
		integer numberOfItems = this.myOrderItems.size();

		try {
			for(integer i = numberOfItems - 1; i >= 0; i--) {
				lineItemWrapper wr = this.myOrderItems.get(i);
				if (wr.selected == true && wr.orderItem.RecordTypeName__c == 'New') {
					if (wr.orderItem.Id != null) {
						delete wr.orderItem;
					}
						
					this.myOrderItems.remove(i);					
				}
			}  
			
		} catch(System.DMLException ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}		

        return null;
    }        

    public PageReference addProducts(){
        //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ''));
        
		//This Fixed my Error      
     	
     	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'number of products already selected: ' + myOrderItems.size()));
    	for(productWrapper wp : ProdSelection) {
        	        	
    		if(wp.selected == true) {
    			wp.selected = false;
        		myOrderItems.add(new lineItemWrapper(this.myOrder, null, wp.prod));
        	}
    	}

        return null;
    }

	// Validation Routines
	/*
	public void validateBonusStock(Order_Item__c oi) {
		if (oi == null) { return; }
		if (oi.Discount__c == 0) { return; }
		
		if (oi.Carton_Bonus__c + oi.Unit_Bonus__c > 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot enter a Discount with Bonus Stock'));
			oi.Discount__c = 0;
		}
	} 
	*/ 
}