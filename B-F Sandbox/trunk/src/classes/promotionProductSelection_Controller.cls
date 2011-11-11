public with sharing class promotionProductSelection_Controller {


/* Class Name : promotionProductSelection_Controller
* Description: --
* Created By : --
* Created On : --

* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer       Date              Description
* ----------------------------------------------------------------------------------------------------------------------------
* VARUN           06-13-2011        Code for Product Remediation Check.
*                                   
*/ 

    
    //Product Remediation Product2 changed to Product__c
    public List<Product__c> ProdSelection {get;set;}
    public string RecordTypeValue {get;set;}
    public string bfBrandValue {get;set;}
    Public ID  MyId {get;set;}

    
    public string ProductNameTextValue {get;set;}
    /*public string ProductCodeTextValue {get;set;}      
    public string bfBrandTextValue {get;set;}
    public string DescriptionTextValue {get;set;}*/
    
    public string productID {get;set;}
    public string productName {get;set;}
        
    ID marketID;
    
    promotionProductHelperClass helper;
    Promotion__c pm;
    public string pageType {get;set;}
    public promotionProductSelection_Controller (ApexPages.StandardController controller)
    {
        this.pm = (Promotion__c)controller.getRecord();
        try{
            Promotion__c myP = [Select Name, Brand__c, Promotion_Activity__r.Brand__c, Account__r.Market__c, Recordtype.name from Promotion__c where Id =: pm.Id];
            bfBrandValue = myP.Promotion_Activity__r.Brand__c;
            marketID = myP.Account__r.Market__c;
            map<string, Schema.recordtypeinfo> maprecordtypenames = Schema.SObjectType.Promotion_Goal__c.getRecordTypeInfosByName();

            MyID = maprecordtypenames.get(myP.recordtype.name).RecordTypeid;
        }catch(exception e){}
        pageType = ApexPages.currentPage().getParameters().get('type');
        helper = new promotionProductHelperClass();         
        buildProdSelection();
    }
    public List<SelectOption> getrecordTypeList() {

        return helper.getrecordTypeList();     
    }     
    public List<SelectOption> getBFBrandsList() 
    {
        return helper.getBFBrandsList();
    }       
    public PageReference filterAction(){
        buildProdSelection();
        return null;
    }     
    public PageReference addProducts(){
        //Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ''));

        return null;
    }           
    void buildProdSelection()
    {    
        //code modified for the Product Remediation. Custom setting is used to enable and disable custom product code.
        string myQueryString = '';
        
        //product remediation code start
            myQueryString = 'Select p.VAT__c, p.Unit_Cost__c, p.Supplier__c, p.Sort_Order__c, p.RecordTypeId, p.ProductCode__c, p.Name, p.Market__c, p.IsActive__c, p.Id, p.Family__c, p.Description__c, p.CurrencyIsoCode, p.Competes_On_Brand__c, p.Case_Multiplier__c, p.Brand__c, p.Brand__r.Name, p.Brand_Code__c From Product__c p where p.IsActive__c=true';
        //product remediation code end
        myQueryString = myQueryString + (marketID!=null?' and p.Market__c=\''+marketID+'\'':'');
        /*if(RecordTypeValue!=null && RecordTypeValue!='ALL')
        {
            myQueryString+=' and p.RecordTypeId=\''+String.escapeSingleQuotes(RecordTypeValue.trim())+'\'';
        }*/
        
        myQueryString+=' and p.RecordType.Name=\'Wet Goods\'';        
        
        
        if(bfBrandValue!=null && bfBrandValue!='ALL')
        {
            myQueryString+=' and p.Brand__c=\''+String.escapeSingleQuotes(bfBrandValue.trim())+'\'';
        }        
        if(ProductNameTextValue!=null && ProductNameTextValue!='')
        {
            myQueryString+=' and (p.Name like \'%'+String.escapeSingleQuotes(ProductNameTextValue.trim())+'%\'';
           //Product Remediation code starts
            myQueryString+=' or p.ProductCode__c like \'%'+String.escapeSingleQuotes(ProductNameTextValue.trim())+'%\'';
            myQueryString+=' or p.Brand__r.Name like \'%'+String.escapeSingleQuotes(ProductNameTextValue.trim())+'%\'';
            myQueryString+=' or p.Description__c like \'%'+String.escapeSingleQuotes(ProductNameTextValue.trim())+'%\')';            
        }
        /*if(ProductCodeTextValue!=null && ProductCodeTextValue!='')
        {
            myQueryString+=' and p.ProductCode like \'%'+String.escapeSingleQuotes(ProductCodeTextValue.trim())+'%\'';
        }    
        if(bfBrandTextValue!=null && bfBrandTextValue!='')
        {
            myQueryString+=' and p.Brand__r.Name like \'%'+String.escapeSingleQuotes(bfBrandTextValue.trim())+'%\'';
        }    
        if(DescriptionTextValue!=null && DescriptionTextValue!='')
        {
            myQueryString+=' and p.Description like \'%'+String.escapeSingleQuotes(DescriptionTextValue.trim())+'%\'';
        }     */
        myQueryString+=' and p.Brand__r.Supplier__r.Is_B_F_Brand__c = true';
        myQueryString+=' ORDER BY p.Sort_Order__c';                                  
        system.debug(myQueryString);
        ProdSelection = new List<Product__c>();
        for(Product__c productList : Database.query(myQueryString))
            {
            ProdSelection.add(productList);
            }

    }
}