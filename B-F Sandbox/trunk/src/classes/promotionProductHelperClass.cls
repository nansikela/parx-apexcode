public with sharing class promotionProductHelperClass {

/* Class Name : promotionProductHelperClass 
* Description: --
* Created By : --
* Created On : --

* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer       Date              Description
* ----------------------------------------------------------------------------------------------------------------------------
* VARUN           06-24-2011        Code for Product Remediation Check.
*                                   
*/ 
    public List<SelectOption> getrecordTypeList() {
        List<SelectOption> recordTypeList = new List<SelectOption>();
        recordTypeList.add(new SelectOption('ALL','ALL'));
        //code updated for product remediation added custom setting to enable and disable custom product code.
        //start of product remediation code
        //for(RecordType rt : [select id, name from RecordType where SobjectType='Product2'])
        for(RecordType rt :  [select id, name from RecordType where SobjectType='Product__c'])
        {
            recordTypeList.add(new SelectOption(rt.Id,rt.Name));            
        }         //end of product remediation code 

        return recordTypeList;     
    }     
    public List<SelectOption> getBFBrandsList() 
    {
        List<SelectOption> optionList = new List<SelectOption>();
        // Add a null option to force the user to make a selection. //
        optionList.add(new SelectOption('ALL','ALL'));
        for(Brand__c y :[Select r.Name, r.Id From Brand__c r where Supplier__r.Is_B_F_Brand__c = true ORDER BY r.Name]) 
        {
            optionList.add(new SelectOption(y.Id,y.Name));
        }
        return optionList;
    }     
}