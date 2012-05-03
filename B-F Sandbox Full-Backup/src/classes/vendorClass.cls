public with sharing class vendorClass {
  private final Vendor__c vendor;
  public String countryID {get;set;} 
  public String reqTrueFalse {get;set;}
  public String selectedCountry {get;set;} 
  String defVal = 'US - USA';
        
  public vendorClass(ApexPages.StandardController vendorController) {
    this.vendor = (Vendor__c)vendorController.getRecord();
  }
  
  public List<SelectOption> getCountries() {
    List<SelectOption> options = new List<SelectOption>();
    Schema.DescribeFieldResult fieldResult = Vendor__c.Country_LAND1__c.getDescribe();
    List<Schema.PicklistEntry> countryList = fieldResult.getPicklistValues();
        
    for( Schema.PicklistEntry c : countryList) {
      options.add(new SelectOption(c.getLabel(), c.getValue()));
    }         
    return options;
  } 

  public PageReference autoRun() {
    countryID = defVal; //ApexPages.currentPage().getParameters().get('ddlCountry');
    RequiredFields();
    return null;
  }

  //public void returnCountry() {
  public PageReference returnCountry() {
  	countryID = selectedCountry; 
  	//countryID = ApexPages.currentPage().getParameters().put('country',selectedCountry);   
    RequiredFields();
    return null;
    
    //PageReference pageRef = Page.vendorRequestForm;
    //pageRef.getParameters().put('Country__c',selectedCountry);
    //pageRef.setRedirect(true);
    //return pageRef;
  }
  
  public void RequiredFields() {
    if (countryID == defVal) {
      this.reqTrueFalse = 'true';
    }   
    else {
      this.reqTrueFalse = 'false';
    }
  }      
}