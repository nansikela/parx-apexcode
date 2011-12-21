/* Class Name : promotionMaterialItem_Controller_Remed
* Description: --
* Created By : --
* Created On : -- 
*
* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer       Date              Description
* ----------------------------------------------------------------------------------------------------------------------------
* Fayas Mansoor  06-27-2011        Code for Product Remediation Check.
* Mike Shroyer  11/22/2011         Added logic to set approval status to Submit if submit is checked.  
* Christophe Vidal 12/14/2011      Revamped the whole controller and page to improve drastically the performance of the slow wrapper 
*                                  classes. Please be aware that moving elements, changing id of elements or removing elements can
*                                  break javascript functions. Most of logic has now be moved to the VF Page in order to improve
*                                  the performance. 
*                                  Please also be aware by adding columns to existing tables. You should not forget
*                                  to add the right id to the column and to add it also to the wrapperRemote wrapper class. If you expect
*                                  to save this new column, this should be also implemented in the remoteaction function addNewProduct
*/ 

public with sharing class promotionMaterialItem_Controller {

    private list<RecordType> RecordTypes =  [select name from RecordType where SobjectType='Product__c'];
    private list<Brand__c> Brands = [Select Name From Brand__c where Supplier__r.Is_B_F_Brand__c = true order BY Name];
    
    public integer myLimit = 1000;
    
    public static Promotion__c pm {get;set;}
       
    public String promoType {get;set;}
    public String IdDataTableHidden {get;set;}
    public string RecordTypeValue {get;set;}
    public string bfBrandValue {get;set;}
    public string ProductNameTextValue {get;set;}     
    public List<wrapper> myPromMatItems {get;set;}
    
    //this wrapper is used for each Promotion_Material_Item__c record .
    public  class wrapper {
        public Product__c prod {get; set;}
        public Promotion_Material_Item__c PromMatItem {get; set;}
         
        public wrapper(Product__c pr, Promotion_Material_Item__c pmi) {
            prod = pr==null?(new Product__c(id=pmi.Product_Custom__c,Name=pmi.product_custom__r.Name)):(pr);
            PromMatItem = pmi!=null?pmi:(new Promotion_Material_Item__c(Promotion__c=pm.Id,Product_Custom__c=prod.id));            
        }    
    }
      
    public class wrapperRemote {
        public String productid;
        public String promoid;
        public String Act_Date;
        public String Plan_Qty;
        public String Remarks;
        public String Act_Qty;
        public String Selected;
        public String Plan_Date;
        public Boolean Submit;
        public String Actual_Rebate;
        public String Plan_Rebate;
        public String Approval_Status;
        
        //other fields for non agreement RT
        public String Promotion_Cost_w_o_VAT;
        public String Extended_Cost;
        public String Delivery_From;
        public String Wet_Good_Use;
        public String Shipped_Date;
        public String Request_Date;
        public String Quantity;
        public String Unit_Cost;
        public String Brand;
        public String ProductCode;

        public wrapperRemote() {
        }
    }    

    public void buildOvi(){ 
    	//we still use this function in order to load for the first time the existing products.
        myPromMatItems = new List<wrapper>();
        //grab all products in case they were since inactivated or in different markets

        Set<ID> myProducts = new Set<ID>();
        
        list<Promotion_Material_Item__c> PMIList = new list<Promotion_Material_Item__c>([Select Wet_Good_Use__c, Unit_Cost__c, Shipped_Date__c, Shipped_Amount__c, Request_Time__c, Request_Date__c, Remarks__c, Quantity__c, Promotion__c, Promotion_Cost_w_o_VAT__c, Product_Custom__c, Product_Custom__r.Name, Product_Custom__r.ProductCode__c, Product_Custom__r.Brand__c, Product_Custom__r.Brand__r.Name, Name, Extended_Cost__c, Delivery_From__c, CurrencyIsoCode, Plan_Qty__c, Plan_Payment__c, Plan_Date__c, Act_Qty__c, Act_Date__c, Approval_Status__c, Actual_Payment__c,plan_rebate__c,Actual_Rebate__c,
        Act_Payment2__c, Payment_Date__c, Submit__c from Promotion_Material_Item__c where Promotion__c =: pm.id order by Product_Custom__r.Name,Plan_Date__c]);
        
        for(Promotion_Material_Item__c pmi : PMIList) {
        	 myProducts.add(pmi.Product_Custom__c);
        }
        Map<ID,Product__c> pr = new Map<ID,Product__c>([Select p.VAT__c, p.Unit_Cost__c, p.Supplier__c, p.Sort_Order__c, p.RecordType.Name, p.RecordTypeId, p.ProductCode__c, p.Name, p.Market__c, p.IsActive__c, p.Id, p.Family__c, p.Description__c, p.CurrencyIsoCode, p.Competes_On_Brand__c, p.Case_Multiplier__c, p.Brand__c, p.Brand__r.Name, p.Brand_Code__c From Product__c p where p.Id in: myProducts LIMIT :myLimit]);
        
        //we add a dummy hidden product for the row duplication in the html table.
        //this is used to be able to clone easily the row.
        Promotion_Material_Item__c helper = [Select Wet_Good_Use__c, Unit_Cost__c, Shipped_Date__c, Shipped_Amount__c, Request_Time__c, Request_Date__c, Remarks__c, Quantity__c, Promotion__c, Promotion_Cost_w_o_VAT__c, Product_Custom__c, Product_Custom__r.Name, Product_Custom__r.ProductCode__c, Product_Custom__r.Brand__c, Product_Custom__r.Brand__r.Name, Name, Extended_Cost__c, Delivery_From__c, CurrencyIsoCode, Plan_Qty__c, Plan_Payment__c, Plan_Date__c, Act_Qty__c, Act_Date__c, Approval_Status__c, Actual_Payment__c,plan_rebate__c,Actual_Rebate__c,
        Act_Payment2__c, Payment_Date__c, Submit__c from Promotion_Material_Item__c where Submit__c = false AND Extended_Cost__c = 0 limit 1];
        //we just reset all field of our helper row. we don't make any update on this row but we use it as a template for our cloning.
        helper.Plan_Qty__c = helper.Plan_Rebate__c = helper.Plan_Payment__c = helper.Act_Qty__c = helper.Actual_Rebate__c = helper.Quantity__c = helper.Unit_Cost__c = null ;
        helper.Plan_Date__c = helper.Act_Date__c = helper.Request_Date__c = helper.Shipped_Date__c = null;
        helper.Remarks__c = null;
        helper.Submit__c = false;
        helper.Approval_Status__c = 'New';
        helper.Delivery_From__c = null;
        
        myPromMatItems.add(new wrapper(null,  helper));
        IdDataTableHidden = 'none ';
        for(Promotion_Material_Item__c pmi : PMIList) {
             myPromMatItems.add(new wrapper(pr.get(pmi.Product_Custom__c),pmi/*,pm*/));
             IdDataTableHidden += pmi.Id + ' ';
        }
    }   
    
    public promotionMaterialItem_Controller (){
        pm = [select Account__r.Market__c, RecordTypeId, RecordType.Name, Approval_Status__c, Promotion_Start_Date__c from Promotion__c where Id =: ApexPages.currentPage().getParameters().get('Id')];
        promoType = pm.RecordType.Name;
        buildOvi();
    }
    
    public List<SelectOption> getrecordTypeList() {
        //same old function
        List<SelectOption> recordTypeList = new List<SelectOption>();
        recordTypeList.add(new SelectOption('ALL','ALL'));

        for(RecordType rt :  RecordTypes) {
            recordTypeList.add(new SelectOption(rt.Id,rt.Name));            
        }         
        //end of product remediation code 

        return recordTypeList;   
    }  
       
    public List<SelectOption> getBFBrandsList() {
    	//same old function
        List<SelectOption> optionList = new List<SelectOption>();

        optionList.add(new SelectOption('ALL','ALL'));
        for(Brand__c y :Brands) {
            optionList.add(new SelectOption(y.Id,y.Name));
        }
        return optionList;
    }     
	
	@RemoteAction
	public static void RemoveLine(String RowId) {
		//called when the X is clicked.
		if(RowId != null && RowId != ''){
			try {
				Database.delete(RowId);
			}
			catch(Exception e) {
				if(!e.getMessage().contains('ENTITY_IS_DELETED')) //if the user clicks very fast on the same X, it will produce this error. We don't need to confuse the user so we ignore this error.
				    throw e;
			}
		}
	}
	
    @RemoteAction
    public static list<Product__c> buildProdSelection2(String ProductNameTextValue, String bfBrandValue, String RecordTypeValue, String marketID) {  
        //this is the old search function, adapted to js remoting.
        string myQueryString = 'Select Name, ProductCode__c, Unit_Cost__c,  Brand__r.Name From Product__c '
        + ' where IsActive__c=true'
        + ' and Brand__r.Supplier__r.Is_B_F_Brand__c = true'
        + (marketID!=null?' and Market__c=\''+marketID+'\'':'');
        if(RecordTypeValue!=null && RecordTypeValue!='ALL')   {
            myQueryString+=' and RecordTypeId=\''+RecordTypeValue+'\'';
        }
        if(bfBrandValue!=null && bfBrandValue!='ALL') {
            myQueryString+=' and Brand__c=\''+bfBrandValue+'\'';
        }        
        if(ProductNameTextValue!=null && ProductNameTextValue!='') {
            myQueryString+=' and Name like \'%'+ProductNameTextValue+'%\'';
        }
        myQueryString+=' ORDER BY Sort_Order__c limit 1000';                                  
        system.debug(myQueryString);

        return Database.query(myQueryString);
    }

    @RemoteAction
    public static list<wrapperRemote> AddNewProduct(list<wrapperRemote> NewProducts, String promoType, String PromoId) { 
    	system.debug('Test0:' + NewProducts);
    	list<Promotion_Material_Item__c> PMIList = new list<Promotion_Material_Item__c>();
    	Promotion_Material_Item__c PMI = new Promotion_Material_Item__c();
        //we have now to handle our data, to check of wrong input, and to save them.
        map<Id, Promotion_Material_Item__c> ExistingPromoMat;
        list<Id> ExistingPromoMatIds = new list<Id>();
        for(wrapperRemote wR:NewProducts) {
        	if(wR.promoid != null && wR.promoid != '')
        	   ExistingPromoMatIds.add(wR.promoid);
        }
        if(!ExistingPromoMatIds.isEmpty())
            ExistingPromoMat = new map<Id, Promotion_Material_Item__c>([select Product_Custom__c, Plan_Qty__c, Remarks__c, Act_Qty__c, Submit__c, Actual_Rebate__c, Plan_Rebate__c, Act_Date__c, Plan_Date__c, Plan_Payment__c, Approval_Status__c from Promotion_Material_Item__c where Id IN:ExistingPromoMatIds]);

        
        for(wrapperRemote wR:NewProducts) {
        	//we have to try catch every single element to produce a more consistent output error to the user.
        	if(wR.promoid != null && wR.promoid != '')  {
        		PMI = new Promotion_Material_Item__c();
        		PMI = ExistingPromoMat.get(Id.valueOf(wR.promoid));
        	}
        	else {
        	   PMI = new Promotion_Material_Item__c();
        	   try {PMI.Promotion__c = PromoId;}
               catch(exception e) { throw e;}
        	}

            try {PMI.Product_Custom__c = wr.productid!=null?wr.productid:PMI.Product_Custom__c; }
            catch(exception e) { throw e;}
            
            try {PMI.Plan_Qty__c = wR.Plan_Qty!=null&&wR.Plan_Qty!=''?Double.valueOf(wR.Plan_Qty):0; }
	        catch(exception e) { throw e;}
	        
	        try {PMI.Remarks__c = wR.Remarks; }
	        catch(exception e) { throw e;}
	        
	        try {PMI.Act_Qty__c = wR.Act_Qty!=null&&wR.Act_Qty!=''?Double.valueOf(wR.Act_Qty):0; }
	        catch(exception e) { throw e;} 
	        
	        try {PMI.Submit__c = wR.Submit!=null?wR.Submit:PMI.Submit__c;}
	        catch(exception e) { throw e;} 
	        
	        try {PMI.Actual_Rebate__c = wR.Actual_Rebate!=null&&wR.Actual_Rebate!=''?Double.valueOf(wR.Actual_Rebate):0;}
	        catch(exception e) { throw e;}
	        
	        try {PMI.Plan_Rebate__c = wR.Plan_Rebate!=null&&wR.Plan_Rebate!=''?Double.valueOf(wR.Plan_Rebate):0; }
	        catch(exception e) { throw e;}
	        
	        try {PMI.Act_Date__c = wR.Act_Date!=null&&wR.Act_Date!=''?Date.parse(wR.Act_Date):null;}
	        catch(exception e) { throw e;}
	        
	        try {PMI.Plan_Date__c = wR.Plan_Date!=null&&wR.Plan_Date!=''?Date.parse(wR.Plan_Date):null; }
	        catch(exception e) { throw e;}
	        
	        try {PMI.Approval_Status__c = wR.Approval_Status; }
            catch(exception e) { throw e;}
	        
	        try {PMI.Delivery_From__c = wR.Delivery_From; }
            catch(exception e) { throw e;}

            try {PMI.Wet_Good_Use__c = wR.Wet_Good_Use; }
            catch(exception e) { throw e;}
            
            try {PMI.Shipped_Date__c = wR.Shipped_Date!=null&&wR.Shipped_Date!=''?Date.parse(wR.Shipped_Date):null; }
            catch(exception e) { throw e;}
            
            try {PMI.Request_Date__c = wR.Request_Date!=null&&wR.Request_Date!=''?Date.parse(wR.Request_Date):null; }
            catch(exception e) { throw e;}
            
            try {PMI.Quantity__c = wR.Quantity!=null&&wR.Quantity!=''?Double.valueOf(wR.Quantity):0; }
            catch(exception e) { throw e;}
            
            try {PMI.Unit_Cost__c = wR.Unit_Cost!=null&&wR.Unit_Cost!=''?Double.valueOf(wR.Unit_Cost):0; }
            catch(exception e) { throw e;}
	        
	        
            if (promoType=='Agreement') {
            	PMI.Plan_Payment__c = PMI.Plan_Qty__c * PMI.Plan_Rebate__c;
            }
            if (wR.Approval_Status=='New' & wR.submit== true){
                PMI.Approval_Status__c ='Submit';
            }

            PMIList.add(PMI);
        }
        
        system.debug('PMIList:' + PMIList);
        upsert PMIList; 
        
        Integer i = 0;
        for(wrapperRemote wR:NewProducts) {
            wR.promoId = PMIList.get(i).Id;
            i++;
        }
        
        return NewProducts;
    }      
}