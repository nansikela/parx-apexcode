trigger beforeInsertUpdateVendor on Vendor__c (before insert, before update) {
  for (Vendor__c vendor: trigger.new) {
    //Copy the Business address fields to the Payment address fields
    if (vendor.Copy_Business_Address_to_Payment_Address__c == true) {    
      vendor.Payment_Address_STRAS__c = vendor.Business_Address_STRAS__c;
      vendor.Payment_City_ORT01__c = vendor.Business_City_ORT01__c;
      vendor.Payment_Region__c = vendor.Business_Region__c;
      vendor.NON_US_Payment_Address_STRAS__c = vendor.NON_US_Business_Address_STRAS__c;
      vendor.NON_US_Payment_Region_Picklist__c = vendor.NON_US_Business_Region_Picklist__c;   
      vendor.NON_US_Payment_Region__c = vendor.NON_US_Business_Region__c;
      vendor.Payment_Postal_Code_PSTLZ__c = vendor.Business_Postal_Code_PSTLZ__c;     
    }
    
    //Copy the Business name field to the Business/Legal name field
    if (vendor.Copy_Business_Name_to_Business_Legal__c == true) {        
      vendor.X1099_Business_Legal_Name__c = vendor.Business_Name_NAME1__c;
    }   
      
    //Validation if Copy Business Address to Tax Address checkbox and Copy
    //Payment Address to Tax Address checkbox are checked at the same time
    if (vendor.Copy_Business_Address_to_Tax_Address__c == true 
        && vendor.Copy_Payment_Address_to_Tax_Address__c == true) {
      vendor.Copy_Business_Address_to_Tax_Address__c = false;
      vendor.Copy_Payment_Address_to_Tax_Address__c = false;
      vendor.Copy_Business_Address_to_Tax_Address__c.addError('Both copy address checkboxes cannot be checked'); 
      vendor.Copy_Payment_Address_to_Tax_Address__c.addError('Both copy address checkboxes cannot be checked');
    }  
    
    //Copy the Business address fields to the Tax address fields  
    if (vendor.Copy_Business_Address_to_Tax_Address__c == true) {                
      vendor.Tax_Address_STRAS__c = vendor.Business_Address_STRAS__c;
      vendor.Tax_City_ORT01__c = vendor.Business_City_ORT01__c;
      vendor.Tax_Region__c = vendor.Business_Region__c;
      vendor.Tax_Postal_Code_PSTLZ__c = vendor.Business_Postal_Code_PSTLZ__c;     
    }
    
    //Copy the Payment address fields to the Tax address fields
    if (vendor.Copy_Payment_Address_to_Tax_Address__c == true) {                 
      vendor.Tax_Address_STRAS__c = vendor.Payment_Address_STRAS__c;
      vendor.Tax_City_ORT01__c = vendor.Payment_City_ORT01__c;
      vendor.Tax_Region__c = vendor.Payment_Region__c;
      vendor.Tax_Postal_Code_PSTLZ__c = vendor.Payment_Postal_Code_PSTLZ__c;      
    }
    
    //Reset checkbox
    if (vendor.Copy_Business_Address_to_Payment_Address__c == true) {
      vendor.Copy_Business_Address_to_Payment_Address__c = false;       
    }
    
    //Reset checkbox
    if (vendor.Copy_Business_Name_to_Business_Legal__c == true) {        
      vendor.Copy_Business_Name_to_Business_Legal__c = false;
    }   
  
    //Reset checkbox
    if (vendor.Copy_Business_Address_to_Tax_Address__c == true) {        
      vendor.Copy_Business_Address_to_Tax_Address__c = false;
    }

    //Reset checkbox
    if (vendor.Copy_Payment_Address_to_Tax_Address__c == true) {         
      vendor.Copy_Payment_Address_to_Tax_Address__c = false;
    }           
  } 
}