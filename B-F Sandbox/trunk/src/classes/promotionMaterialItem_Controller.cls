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
*                                   
*/ 

public with sharing class promotionMaterialItem_Controller {
    public Promotion__c pm;
    Account a;
    ID marketID;
    string promoType;
    promotionProductHelperClass helper;
    public integer myLimit = 1000;
    public promotionMaterialItem_Controller (ApexPages.StandardController controller)
    {
        this.pm = (Promotion__c)controller.getRecord();
        marketID = pm.Account__r.Market__c; 
        promoType = pm.RecordType.Name;
        helper = new promotionProductHelperClass();
        system.debug(Limits.getLimitQueryRows());
        if(Limits.getLimitQueryRows()<1000){ //unit test limit...
            myLimit = 100;
        }
        buildOvi();
            buildProdSelection();
        
        
    }
    
    public List<SelectOption> getrecordTypeList() {

        return helper.getrecordTypeList();     
    }     
    public List<SelectOption> getBFBrandsList() 
    {
        return helper.getBFBrandsList();
    }     
    public string RecordTypeValue {get;set;}
    public string bfBrandValue {get;set;}
        
    public string ProductNameTextValue {get;set;}
    public string ProductCodeTextValue {get;set;}      
    public string bfBrandTextValue {get;set;}
    public string DescriptionTextValue {get;set;}
       
    public PageReference saveAction(){
        //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ''));
        List<Promotion_Material_Item__c> myInserts = new List<Promotion_Material_Item__c>();
        List<Promotion_Material_Item__c> myUpdates = new List<Promotion_Material_Item__c>();
        Savepoint sp = Database.setSavepoint();
        try{    
            for(wrapper wp : myPromMatItems)
            {
                if (promoType=='Agreement') {
                wp.PromMatItem.Plan_Payment__c = wp.PromMatItem.Plan_Qty__c*wp.PromMatItem.Plan_Rebate__c;
                }
                if(wp.PromMatItem.Id!=null)
                {
                    myUpdates.add(wp.PromMatItem);
                }else{
                    myInserts.add(wp.PromMatItem);
                }
            }
                insert myInserts;
                update myUpdates;
         }catch(System.DmlException insertDmlexp){
                Database.rollback(sp);
                for (Integer i = 0; i < insertDmlexp.getNumDml(); i++) {
                    pm.addError(insertDmlexp.getDmlMessage(i));
                }
            return null;
         }           
        buildOvi();
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ''));
        return null;
    }     
    public PageReference filterAction(){
        
            buildProdSelection();
        return null;
    }
    public PageReference close(){
        return new PageReference('/'+pm.Id);
    }    
    public List<wrapperP> ProdSelection {get;set;}       

    void buildProdSelection()
    {    
        ProdSelection = new List<wrapperP>();
        System.debug('The value of conditions'+ProductNameTextValue+ProductCodeTextValue+bfBrandTextValue);
        
        string myQueryString = 'Select p.VAT__c, p.Unit_Cost__c, p.Supplier__c, p.Sort_Order__c, p.RecordType.Name, p.RecordTypeId, p.ProductCode__c, p.Name, p.Market__c, p.IsActive__c, p.Id, p.Family__c, p.Description__c, p.CurrencyIsoCode, p.Competes_On_Brand__c, p.Case_Multiplier__c, p.Brand__c, p.Brand__r.Name, p.Brand_Code__c From Product__c p'
        + ' where p.IsActive__c=true'
        + ' and p.Brand__r.Supplier__r.Is_B_F_Brand__c = true'
        + (marketID!=null?' and p.Market__c=\''+marketID+'\'':'');
        if(RecordTypeValue!=null && RecordTypeValue!='ALL')
        {
            myQueryString+=' and p.RecordTypeId=\''+RecordTypeValue+'\'';
        }
        if(bfBrandValue!=null && bfBrandValue!='ALL')
        {
            myQueryString+=' and p.Brand__c=\''+bfBrandValue+'\'';
        }        
        if(ProductNameTextValue!=null && ProductNameTextValue!='')
        {
            myQueryString+=' and p.Name like \'%'+ProductNameTextValue+'%\'';
        }
        if(ProductCodeTextValue!=null && ProductCodeTextValue!='')
        {
            myQueryString+=' and p.ProductCode__c like \'%'+ProductCodeTextValue+'%\'';
        }    
        if(bfBrandTextValue!=null && bfBrandTextValue!='')
        {
            myQueryString+=' and p.Brand__r.Name like \'%'+bfBrandTextValue+'%\'';
        }    
        if(DescriptionTextValue!=null && DescriptionTextValue!='')
        {
            myQueryString+=' and p.Description__c like \'%'+DescriptionTextValue+'%\'';
        }     
        myQueryString+=' ORDER BY p.Sort_Order__c';                                  
        system.debug(myQueryString);
            for(Product__c pr :Database.query(myQueryString))
            {
                ProdSelection.add( new wrapperP(pr));
            }
     
               
    }
    
    
    public PageReference addProducts(){
        //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ''));
        for(wrapperP wp : ProdSelection)
        {
            if(wp.selected || wp.brandQTY > 0)
            {
                for (Integer i=0;i<wp.brandQTY;i++){
                    //myPromMatItems.add(new wrapper(wp.prod,null,pm));
                        myPromMatItems.add(new wrapper(wp.prod,null,pm,wp.planBottle,wp.planRebate,wp.planBottle*wp.planRebate));                    
                }              
                wp.selected=false;
                wp.brandQTY = 0;
                wp.planRebate = 0;
                wp.planBottle = 0;
                
            }
        }
        saveAction();
        return null;
    }     
       //Add Products for Non-Agreement Record Types
      public PageReference addProducts2(){
        //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ''));
        for(wrapperP wp : ProdSelection)
        {
            if(wp.selected)
            {
                        myPromMatItems.add(new wrapper(wp.prod,null,pm));               
                           
                wp.selected=false;
                
            }
        }
        return null;
    }         
    //this wrapper is used for each Product__c selection record .
    // Remediated for custom product as well
    public class wrapperP {
    public Product__c prod {get; set;}
    // part of remediation
    public boolean selected {get; set;}
    public integer brandQTY {get;set;}    
    public integer planBottle {get;set;}
    public double planRebate {get;set;}             
        // part of remediation

    public wrapperP(Product__c a)
        {
            prod = a;
            selected=false;
        }
    }    
    
    public List<wrapper> myPromMatItems {get;set;}
    
    void buildOvi()
    { 
        myPromMatItems = new List<wrapper>();
        //grab all products in case they were since inactivated or in different markets
        system.debug(myLimit);
        Set<ID> myProducts = new Set<ID>();
        Map<ID,Promotion_Material_Item__c> mapPMIs = new Map<ID,Promotion_Material_Item__c>();  
        for(Promotion_Material_Item__c[] pmi : [Select p.Wet_Good_Use__c, p.Unit_Cost__c, p.Shipped_Date__c, p.Shipped_Amount__c, p.Request_Time__c, p.Request_Date__c, p.Remarks__c, p.Quantity__c, p.Promotion__c, p.Promotion_Cost_w_o_VAT__c, p.Product_Custom__c, p.Product_Custom__r.Name, p.Product_Custom__r.ProductCode__c, p.Product_Custom__r.Brand__c, p.Product_Custom__r.Brand__r.Name, p.Name, p.Id, p.Extended_Cost__c, p.Delivery_From__c, p.CurrencyIsoCode, p.Plan_Qty__c, p.Plan_Payment__c, p.Plan_Date__c, p.Act_Qty__c, p.Act_Date__c, p.Approval_Status__c, p.Actual_Payment__c,p.plan_rebate__c,p.Actual_Rebate__c,p.Act_Payment2__c
        ,p.Payment_Date__c 
         
         
         
         From Promotion_Material_Item__c p where p.Promotion__c =: pm.id order by p.Plan_Date__c])
        {
            for (Integer x=0;x<pmi.size();x++)
            {           
                    myProducts.add(pmi[x].Product_Custom__c);
                //mapPMIs.put(pmi[x].Id,pmi[x]);
            }
            Map<ID,Product__c> pr = new Map<ID,Product__c>([Select p.VAT__c, p.Unit_Cost__c, p.Supplier__c, p.Sort_Order__c, p.RecordType.Name, p.RecordTypeId, p.ProductCode__c, p.Name, p.Market__c, p.IsActive__c, p.Id, p.Family__c, p.Description__c, p.CurrencyIsoCode, p.Competes_On_Brand__c, p.Case_Multiplier__c, p.Brand__c, p.Brand__r.Name, p.Brand_Code__c From Product__c p where p.Id in: myProducts LIMIT :myLimit]);
            for (Integer x=0;x<pmi.size();x++)
            {      
                    myPromMatItems.add(new wrapper(pr.get(pmi[x].Product_Custom__c),pmi[x],pm));
            }           
        }
        
        //nds 09/20/10 - this loop was causing sorting issues.        
        /*for(Promotion_Material_Item__c pmi : mapPMIs.values())
        {
            myPromMatItems.add(new wrapper(pr.get(pmi.Product__c),pmi,pm));
        }*/
    }    
    public PageReference delPromMatItems(){
        //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ''));
        List<Promotion_Material_Item__c> myDels = new List<Promotion_Material_Item__c>();
        integer counter=0;
        List<integer> myset = new List<integer>();
        try{
            for(wrapper wp : myPromMatItems)
            {
                if(wp.selected)
                {
                    if(wp.PromMatItem.Id!=null)
                    {
                        myDels.add(wp.PromMatItem);
                    }
                    myset.add(counter);
                }else{
                    counter++;
                }
            }
            for(integer y : myset){
                myPromMatItems.remove(y);    
            }      
            delete myDels;
         }catch(exception e){
            pm.addError(e.getMessage());
            return null;
         }         
        return null;
    }           
    //this wrapper is used for each Promotion_Material_Item__c record .
    public class wrapper {
    //public Product2 prod {get; set;}
    public Product__c prod {get; set;}
    public Promotion_Material_Item__c PromMatItem {get; set;}
    public boolean selected {get; set;}
         
    public wrapper(Product__c pr, Promotion_Material_Item__c pmi, Promotion__c pm)
        {
            prod = pr==null?(new Product__c(id=pmi.Product_Custom__c,Name=pmi.product_custom__r.Name)):(pr);
            PromMatItem = pmi!=null?pmi:(new Promotion_Material_Item__c(Promotion__c=pm.Id,Product_Custom__c=prod.id));            
        }
    public wrapper(Product__c pr, Promotion_Material_Item__c pmi, Promotion__c pm, Integer planBottle, double planRebate, double planPayment)
        {
            prod = pr==null?(new Product__c(id=pmi.Product_Custom__c,Name=pmi.product_custom__r.Name)):(pr);
            PromMatItem = pmi!=null?pmi:(new Promotion_Material_Item__c(Promotion__c=pm.Id,Product_Custom__c=prod.id,plan_qty__c=planBottle,plan_rebate__c=planRebate,plan_payment__c=planPayment));            
        }        
    }
}