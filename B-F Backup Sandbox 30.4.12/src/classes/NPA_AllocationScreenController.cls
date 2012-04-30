/******************************************************************************
Name			: NPA_AllocationScreenController
Description		: This is the controller class for the Allocation Workbook screen
				  and Allocation Workbook

Modification Log:
-------------------------------------------------------------------------------
Developer			Date		Description
-------------------------------------------------------------------------------
Jishad P A (DC)		23-Jul-2011 Added code to provide roll-ups and fine tuning 
								the core logic
Jishad P A (DC)		16-Aug-2011 Modified to change the name of custom setting 
								Allocation Visibility Setting
Jishad P A (DC)		09-Sep-2011 Modified to re-instantiate promotion material 
								item map inside BrandInfo method
******************************************************************************/
public class NPA_AllocationScreenController{
    /* Start of ship-to selection */
    // Instance variables for shipto selection
    private Set<String> userMarkets;
    public List<SelectOption> markets {get; set;}
    public String selectedMarket {get; set;}

    private Map<Id, Account> accountsMap;
    public List<Account> accs;
    public List<Account> dummyAccs = new List<Account>();
    public List<Id> selectedValues {get; set;}
    public List<Id> unselectedValues {get; set;}
    private Set<Id> selectedAccs = new Set<Id>();
    private Set<Id> unselectedAccs = new Set<Id>();
    public boolean displayAll {get; set;}
    Map<String, List<Account>> marketAccMap = new Map<String, List<Account>>();
    Map<String, List<Account>> userMarketAccMap = new Map<String, List<Account>>();
    /* End of ship-to selection */
    
    //Using Task object to show Date fields in editable mode to Allocations users
    public Task taskOne {set; get;}
    public Task taskTwo {set; get;}
    
    //Variable Declaration for Allocations Screen
    public List<Allocations__c> allocs = new List<Allocations__c>();
    public String brandname = '';
    List<NPA_PromotionWrapper> promo_wrapper = new List<NPA_PromotionWrapper>();
    List<NPA_PromotionWrapper.InnerWrapper> inner_wc = new List<NPA_PromotionWrapper.InnerWrapper>();
    List<SelectOption> brandOptions = new List<SelectOption>();
    Id promotionRecTypeId;
    String userRole = '';
    
    //Fetching custom setting for promotion visibility with freeze date in past    
    MAP<String,Allocation_Visibility_Setting__c> avsMap = Allocation_Visibility_Setting__c.getAll();
	Set<Id> avsSet = new Set<Id>();
    
    //Setting static variables
    final String promStatus = 'Active';
    final String pliStatus = '0';
    final String pliStatusText = 'Active';
    final String allocPromoStatus = 'E0002';
    final String allocPMIStatus = '0';
    
    //Defining Getters and Setters
    public decimal subMarketCost {get; set;}
    public String PromoId{get;set;}
    public String fiscalYear {set; get;}
    public String tertile {set; get;}
    public String io {set; get;}
    public boolean hasSearched {set; get;}
    public boolean searchError {set; get;}    
    public String premise {get; set;}
    
    Map<Id, List<Promotion_Material_Item__c>> pmiMap;
    List<Promotion__c> promotionList;

    /***************************************************************************
    Method Name : NPA_AllocationScreenController
    Description : This is the constructor
    Arguments   : ApexPages.StandardController
    Return Type : void
    ***************************************************************************/
    public NPA_AllocationScreenController(ApexPages.StandardController controller) {
		// Populate the avsSet with role id values to be excluded for freeze date check
		for(Allocation_Visibility_Setting__c avs: avsMap.values()){
			avsSet.add(avs.Allocation_Visibility__c);
		}
        
        // Get the user role
        if(userinfo.getUserRoleId()!=null){
            userRole = userinfo.getUserRoleId().subString(0,15);
        }
        
        //Fetching record types for Ship-To and Promotion objects
        Map<String,Schema.RecordTypeInfo> rtMapByName  = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id shiptoRecType;
        Map<String,Schema.RecordTypeInfo> promoRTMap = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName();
        if(rtMapByName.containsKey('POS Ship-To')){
            shiptoRecType = rtMapByName.get('POS Ship-To').getRecordTypeId();
        } else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot find the record type specified.'));
            return;
        }
        if(promoRTMap.containsKey('National Promotion - US')){
            promotionRecTypeId = promoRTMap.get('National Promotion - US').getRecordTypeId();
        } else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot find the Promotion record type specified.'));
            return;
        }
		
		//Set sub market cost as zero
        subMarketCost = 0.0;
        
        //Adding Brand options with Supplier as B-F
        brandOptions.add(new selectOption('','--None--'));
        for (Brand__c b: [Select Name,Id from Brand__c where Supplier__r.name='B-F' order By Name]){
            brandOptions.add(new selectOption(b.id,b.name));
        }

        /* Start of ship-to selection */
        // Set the display all checkbox to false
        displayAll = true;
        // Get the markets allocated to the user from the user object
        String allottedMarkets = [Select Market__c from User where Id=:UserInfo.getUserId()].Market__c;

        //Populating the Market list from the market allocation at the user object
        List<String> tempSortList = new List<String>();
        userMarkets = new Set<String>();
        if(allottedMarkets!=null){
            tempSortList = allottedMarkets.split(';', 0);
            tempSortList.sort();
            userMarkets.addAll(tempSortList);
        }
        markets = new List<SelectOption>();
        markets.add(new selectOption('','--None--'));
        for(String str: tempSortList){
            markets.add(new selectOption(str, str));
        }
        
        //Fetching the Ship-To's per the markets fetched from user object
        accountsMap = new Map<Id, Account>([SELECT Id,Legacy_ID__c,Name,ShippingStreet,
            ShippingCity,ShippingState,Market__r.Name,(Select Id from B_F_Contacts__r 
            where User__c=:UserInfo.getUserId()) from Account Where PAS_Relevant__c 
            = 'Yes' AND RecordTypeId =:shiptoRecType and Market__r.Name IN :userMarkets limit 10000]);

        //Populating Accounts Map checking Markets/User allocations
        for(Account acct: accountsMap.values()){
            if(marketAccMap.containsKey(acct.Market__r.Name)){
                (marketAccMap.get(acct.Market__r.Name)).add(acct);
            } else{
                marketAccMap.put(acct.Market__r.Name, new List<Account>{acct});
            }
            if(acct.B_F_Contacts__r.size()>0){
                if(userMarketAccMap.containsKey(acct.Market__r.Name)){
                    (userMarketAccMap.get(acct.Market__r.Name)).add(acct);
                } else{
                    userMarketAccMap.put(acct.Market__r.Name, new List<Account>{acct});
                }
            }
        }
        unselectedAccs = new Set<Id>();
        taskOne = new Task();
        taskTwo = new Task();
        /* End of ship-to selection */
    }
    
    //Getter for selected Ship-To's
    public List<SelectOption> selectedOptions { 
        get {
            List<SelectOption> options = new List<SelectOption>();
            Account acct;
            String tempStr;
            for (Id thisId: selectedAccs) {
                acct = accountsMap.get(thisId);
                tempStr = '';
                if(acct.Legacy_ID__c!=null){
                    tempStr = tempStr+acct.Legacy_ID__c;
                }
                if(acct.Name!=null){
                    tempStr = tempStr+' - '+acct.Name;
                }
                if(acct.ShippingStreet!=null){
                    tempStr = tempStr+' - '+acct.ShippingStreet;
                }
                if(acct.ShippingCity!=null){
                    tempStr = tempStr+' - '+acct.ShippingCity;
                }
                if(acct.ShippingState!=null){
                    tempStr = tempStr+' - '+acct.ShippingState;
                }
                options.add(new SelectOption(thisId, tempStr));
            }
            //Call to SelectOption sort method
            if(!options.isEmpty())
                selectSort(options);
            return options;
        }
    }

    //Getter for de-selected Ship-To's
    public List<SelectOption> unselectedOptions { 
        get {
            List<SelectOption> options = new List<SelectOption>();
            Account acct;
            String tempStr;
            for (Id thisId: unselectedAccs) {
                acct = accountsMap.get(thisId);
                tempStr = '';
                if(acct.Legacy_ID__c!=null){
                    tempStr = tempStr+acct.Legacy_ID__c;
                }
                if(acct.Name!=null){
                    tempStr = tempStr+' - '+acct.Name;
                }
                if(acct.ShippingStreet!=null){
                    tempStr = tempStr+' - '+acct.ShippingStreet;
                }
                if(acct.ShippingCity!=null){
                    tempStr = tempStr+' - '+acct.ShippingCity;
                }
                if(acct.ShippingState!=null){
                    tempStr = tempStr+' - '+acct.ShippingState;
                }
                options.add(new SelectOption(thisId, tempStr));
            }
            //Call to SelectOption sort method
            if(!options.isEmpty()){
                selectSort(options);
            }
            return options;
        }
    }

    /***************************************************************************
    Method Name : selectSort
    Description : This method sorts the values displayed for shipto selection
    Arguments   : List<SelectOption>
    Return Type : void
    ***************************************************************************/
    private void selectSort(List<SelectOption> selectOptionList){
        List<SelectOption> returnList = new List<SelectOption>();
        SelectOption tempSelectOption;
        Integer compValue;

        for(Integer i=0; i<selectOptionList.size(); i++){
            for(Integer j=i+1; j<selectOptionList.size(); j++){
                // Compare the labels(Account names)
                compValue = (selectOptionList[i].getLabel()).compareTo(selectOptionList[j].getLabel());
                if(compValue>0){
                    tempSelectOption = selectOptionList[i];
                    selectOptionList[i] = selectOptionList[j];
                    selectOptionList[j] = tempSelectOption;
                }
            }
        }
    }

    /***************************************************************************
    Method Name : doSelect
    Description : Action method to select Ship-To's for Allocations
    Arguments   : void
    Return Type : void
    ***************************************************************************/
    public void doSelect() {
        if((selectedAccs.size()+selectedValues.size())>5){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                'Cannot select more than 5 accounts.'));
        } else{
            for (Id thisId: selectedValues) {
                selectedAccs.add(thisId);
                unselectedAccs.remove(thisId);
            }
        }
    }
	
	/***************************************************************************
    Method Name : doUnSelect
    Description : Action method to de select Ship-To's for Allocations
    Arguments   : void
    Return Type : void
    ***************************************************************************/
    public void doUnSelect(){
        for (Id thisId: unselectedValues) {
            unselectedAccs.add(thisId);
            selectedAccs.remove(thisId);
        }
    }

    /***************************************************************************
    Method Name : showAllShiptos
    Description : Method to show all ship to's for all markets
    Arguments   : void
    Return Type : void
    ***************************************************************************/
    public void showAllShiptos(){
        unselectedAccs.clear();
        //Check to see if display all checkbox is checked
        if(displayAll){
            if(marketAccMap.containsKey(selectedMarket)){
                for (Account acct : marketAccMap.get(selectedMarket)) {
                    if(!selectedAccs.contains(acct.Id)){
                        unselectedAccs.add(acct.Id);
                    }
                }
            }
            else{
                // Show error
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 
                    'No accounts are available in the Market selected.'));
            }
        } else {
            if(userMarketAccMap.containsKey(selectedMarket)){
                for (Account acct : userMarketAccMap.get(selectedMarket)) {
                    unselectedAccs.add(acct.Id);
                }
            } else{
                // Show error
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 
                    'You are not assigned to any accounts in the Market selected.'));
            }
        }
    }

    /***************************************************************************
    Method Name : next
    Description : Method to navigate user from Ship-To selection screen to 
    			  allocation workbook with the selected ship-tos
    Arguments   : void
    Return Type : PageReference
    ***************************************************************************/
    public PageReference next() {
        if(selectedMarket==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                'Please select a Market and at least one Ship-to to proceed.'));
            return null;
        } else if(selectedOptions.size()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                'Please select at least one Account to proceed.'));
            return null;
        } else{
            accs = [Select Name, ShippingStreet,ShippingCity,ShippingState,Legacy_Id__c 
                from Account where Id in :selectedAccs order by Name];
            dummyAccs.addAll(accs);
            for(integer i=0;i<5-selectedAccs.size();i++){
                dummyAccs.add(new Account());
            }
            // Clear all variables
            userMarkets = null;
            markets = null;
            accountsMap = null;
            selectedValues = null;
            unselectedValues = null;
            selectedAccs = null;
            unselectedAccs = null;
            displayAll = null;
            marketAccMap = null;
            userMarketAccMap = null;

            return Page.NPA_AllocationWorkbook;
        }
    }

    /***************************************************************************
    Method Name : getShiptos
    Description : Getter method to return fetched ship-tos
    Arguments   : void
    Return Type : void
    ***************************************************************************/
    public void getShiptos(){
        unselectedAccs.clear();
        if(displayAll){
            if(marketAccMap.containsKey(selectedMarket)){
                for (Account acct : marketAccMap.get(selectedMarket)) {
                    unselectedAccs.add(acct.Id);
                }
            } else{
                // Show error
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,
                    'No accounts available in the Market selected.'));
            }
        } else {
            if(userMarketAccMap.containsKey(selectedMarket)){
                for (Account acct : userMarketAccMap.get(selectedMarket)) {
                    unselectedAccs.add(acct.Id);
                }
            } else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,
                    'You are not assigned to any accounts in the Market selected.'));
            }
        }
    }
    /* End of ship-to selection */
    
    //Getter for Premise to build drop down list
    public List<SelectOption> premiseList{
        get{
            List<SelectOption> selList = new List<Selectoption>();
            selList.add(new selectOption('','--None--'));
            for(Schema.PicklistEntry s: Promotion__c.Promotion_Premise__c.getDescribe().getPicklistValues()){
                selList.add(new Selectoption(s.getValue(), s.getLabel()));
            }
            return selList;
        }
    }
    
    /***************************************************************************
    Method Name : BrandInfo
    Description : Method which invokes the Query Builder and builds the Wrapper List
    Arguments   : void
    Return Type : void
    ***************************************************************************/
    public void BrandInfo() {
        //Defining local variables
        promo_wrapper = new List<NPA_PromotionWrapper>();
        
        // Fix 09/07/2011
        // Re-instantiated to fix problem of multiple line items after repeated search
        pmiMap = new Map<Id, List<Promotion_Material_Item__c>>();
        
        List<Allocations__c> tempAllocs = new List<Allocations__c>();
        Set<ID> accIds = new Set<ID>();
        List<Promotion__c> promos = new list<Promotion__c>();
        Decimal LineItems = 0;
        hasSearched = true;
        searchError = false;
        Integer count = 0;
        String Query = '';
        decimal marketCost = 0.0;
        decimal shiptoTotCost = 0.0;

        //Checking if required values are selected or not
        if((fiscalYear == null || fiscalYear == '') || (brandName == null || brandName == '')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                'Please add filters to the search criteria - Brand & Fiscal Year');
            ApexPages.addMessage(myMsg);
            searchError = true;
            hasSearched = false;
        } else{
            System.debug('### Start makeQueryString');
            String promoQuery;
            
            //Checking the custom setting per the roles of the logged in user. If role is 'Global Admin', then 
            //all the promotions with Freeze Date in past are also selected and displayed, else not
            if(avsSet.contains(userRole)){
                 promoQuery = 'Select Name,Has_Line_Items__c,Promotion_Premise__c,Internal_Order__r.Name,'+
                'Promotion_Start_Date__c From Promotion__c WHERE Has_Line_Items__c > 0 AND RecordTypeId=' + '\'' +
                 PromotionRecTypeId + '\'' + ' AND Brand_NPA__c=' + '\'' + brandname + '\'' + ' AND Fiscal_Year__c=' +
                  '\'' + fiscalYear + '\'' + ' AND Promotion_Status__c=' + '\'' + promStatus + '\'';
            } else{
                promoQuery = 'Select Name,Has_Line_Items__c,Promotion_Premise__c,Internal_Order__r.Name,'+
                'Promotion_Start_Date__c From Promotion__c WHERE Has_Line_Items__c > 0 AND RecordTypeId=' + '\'' +
                 PromotionRecTypeId + '\'' + ' AND Brand_NPA__c=' + '\'' + brandname + '\'' +
                 ' And Freeze_Date__c > today AND Fiscal_Year__c=' +'\'' + fiscalYear + '\'' + 
                 ' AND Promotion_Status__c=' + '\'' + promStatus + '\'';
            }
                        
            //Building the promotion query based on other filter criteria
            if(tertile != '' && tertile != null){ 
                promoQuery = promoQuery + ' AND Tertile__c = ' + '\'' + tertile + '\'' ;
            }
            if(io != '' && io != null){
                promoQuery = promoQuery + ' AND Internal_Order__r.Internal_Order_Number__c = ' + '\'' + io + '\'' ;
            }
            if(taskOne.ActivityDate != null){
                promoQuery = promoQuery + ' AND Promotion_Start_Date__c = ' + String.valueOf(taskOne.ActivityDate) ;
            }
            if(taskTwo.ActivityDate != null){
                promoQuery = promoQuery + ' AND Promotion_End_Date__c = ' + String.valueOf(taskTwo.ActivityDate);
            }
            if(premise != null){
                promoQuery = promoQuery + ' AND Promotion_Premise__c = ' + '\'' + premise + '\'' ;
            }
            System.debug('### promoQuery: '+promoQuery);
            promotionList = database.query(promoQuery+' limit 10000');
            
            //Building the PMI query based on Promotions fectched above
            String pmiQuery = 'Select Promotion__c,Item__c,Product_Custom__r.ProductCode__c,'+
                'Product_Custom__r.Name,Planned_Cost__c,Unit_of_Measure__c,Product_Description__c,'+
                '(Select Promotion_Material_Item__c,Ship_To__c,Ship_To_Qty__c,Total_Spend__c,'+
                'Unique_Key__c from Allocations__r WHERE Ship_To__c in :accs) '+
                'from Promotion_Material_Item__c WHERE Promotion__c in :promotionList AND Status__c=' +
                 '\'' + pliStatus + '\'' + ' order by Promotion__c,Item__c';
            System.debug('### pmiQuery: '+pmiQuery);
            
            //Building the Promotion-PMI map
            for(Promotion_Material_Item__c pmi: database.query(pmiQuery+' limit 10000')){
                if(pmiMap.containsKey(pmi.Promotion__c)){
                    pmiMap.get(pmi.Promotion__c).add(pmi);
                } else{
                    pmiMap.put(pmi.Promotion__c, new List<Promotion_Material_Item__c>{pmi});
                }
            }
            
            //Fetching the aggregate total across the selected market/brand
            AggregateResult result = [Select SUM(Total_Spend__c) cost FROM Allocations__c 
                WHERE Market_Name__c=:selectedMarket AND Brand_Id__c=:brandname.substring(0,15) 
                AND Fiscal_Year__c=:fiscalYear];
            system.debug('### marketCost: '+result.get('cost'));
            //Populate the market cost if the result is not null
            if(result.get('Cost')!=null){
                marketCost = decimal.valueOf(String.valueOf(result.get('Cost')));
            }
            List<Allocations__c> tempAllocsList = new List<Allocations__c>();
            Map<Id, Allocations__c> tempAllocsMap = new Map<Id, Allocations__c>();
            for(Promotion__c pr : promotionList){
                lineItems = lineItems + pr.has_line_items__c;
                
                //Adding error message if the PMI goes beyond 600 to avoid governance limitations
                if(lineItems > 600){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
                        'Please narrow down your search to get better results');
                    ApexPages.addMessage(myMsg);
                    searchError = true;
                    hasSearched = false;
                    return;
                } else{
                    //Preparing the Wrapper List
                    for(Promotion_Material_Item__c pli : pmiMap.get(pr.Id)){
                        for(Allocations__c all: pli.Allocations__r){
                            if(all.Total_Spend__c!=null){
                                shiptoTotCost = shiptoTotCost+all.Total_Spend__c;
                            }
                            tempAllocsMap.put(all.Ship_To__c, all);
                        }
                        //Looping over Dummy accounts to add allocations for upto 5 SHip-To's
                        for(account acc : dummyAccs){
                            if(tempAllocsMap.containsKey(acc.Id)){
                                tempAllocsList.add(tempAllocsMap.get(acc.Id));
                            } else{
                                if(acc.Id==null){
                                    tempAllocsList.add(new Allocations__c());
                                }else{
                                    tempAllocsList.add(new Allocations__c(Promotion__c = pr.Id,
                                        Promotion_Material_Item__c = pli.Id,Ship_To__c=acc.Id,
                                        Unique_Key__c = String.valueOf(pli.Id)+String.valueOf(acc.Id)));
                                }
                            }
                        }
                        inner_wc.add(new NPA_PromotionWrapper.InnerWrapper(pli,tempAllocsList));
                        tempAllocsList = new List<Allocations__c>();
                        tempAllocsMap = new Map<Id, Allocations__c>();
                    }
                    promo_wrapper.add(new NPA_PromotionWrapper(pr,inner_wc));
                    inner_wc = new list<NPA_PromotionWrapper.InnerWrapper>();
                }
            }
            subMarketCost = marketCost - shiptoTotCost;
        }
    }
    
    //Getter method returning the main wrapper list
    public List<NPA_PromotionWrapper> getwrapper(){
        return promo_wrapper;
    }

    //Getter for Brands drop down values
    public List<SelectOption> getBrands(){
        return brandOptions;
    }

    //Getter for Ship-To's
    public List<Account> getAccounts(){
        return accs;
    }

    //Getter for dummy Ship-To's for fixing number of columns
    public List<Account> getDummyAccounts(){
        return dummyAccs;
    }

    //Getter for selected Brand Name
    public String getselectedbrand(){
        return brandname;
    }

    //Setter for selected Brand name
    public void setselectedbrand(String brandname){
        this.brandname = brandname;
    }

    //Getter method to return Tertile drop down values
    public List<SelectOption> getTertileValues(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('','--None--'));
        options.add(new selectOption('1st Tertile','1st Tertile'));
        options.add(new selectOption('2nd Tertile','2nd Tertile')); 
        options.add(new selectOption('3rd Tertile','3rd Tertile'));
        return options;
    }  

    //Getter method to fetch the fiscal year values from previous year to 2 years hence
    public List<SelectOption> getFiscalValues() {
        List<SelectOption> options = new List<SelectOption>();
        Integer Yr = system.today().year();
        options.add(new selectOption('','--None--'));
        options.add(new selectOption(String.valueOf(Yr-1),String.valueOf(Yr-1)));
        options.add(new selectOption(String.valueOf(Yr),String.valueOf(Yr)));
        options.add(new selectOption(String.valueOf(Yr+1),String.valueOf(Yr+1)));
        options.add(new selectOption(String.valueOf(Yr+2),String.valueOf(Yr+2)));
        return options;
    }

    /***************************************************************************
    Method Name : saveAllocs
    Description : Primary save method to save allocations across promotions
    Arguments   : void
    Return Type : void
    ***************************************************************************/
    public void saveAllocs() {
        List<Allocations__c> allocs = new List<Allocations__c>();
        for(NPA_PromotionWrapper pw : promo_wrapper){
            for(NPA_PromotionWrapper.InnerWrapper iw : pw.allocList) {
                for(Allocations__c all : iw.allocs) {
                    if(all.Id!=null || all.Ship_To__c != null && all.Ship_To_Qty__c != null){
                        if(all.Ship_To_Qty__c<0){
                            all.Ship_To_Qty__c.addError('Only positive numbers allowed');
                            return;
                        } else{
	                        if(all.Unique_Key__c==null){
	                            all.Unique_Key__c = String.valueOf(all.Promotion_Material_Item__c)+String.valueOf(all.Ship_To__c);
	                        }
	                        allocs.add(all);
                        }
                    }
                }
            }
        }
        if(!allocs.isEmpty()){
        	upsert allocs Unique_Key__c;
        }        
    }
	
	/***************************************************************************
    Method Name : cancel
    Description : Method to navigate the user back to ship-to selection screen
    Arguments   : void
    Return Type : void
    ***************************************************************************/
    public pageReference cancel(){
        PageReference page = System.Page.NPA_AllocationScreen;
        Page.setRedirect(true);
        return page;
    }
    
    /***************************************************************************
    Method Name : hideAllocations
    Description : Method to save allocations whenever user collapses any allocation
    Arguments   : void
    Return Type : void
    ***************************************************************************/
    public void hideAllocations(){
        List<Allocations__c> allocs = new List<Allocations__c>();
        system.debug('### PromoId: '+PromoId);
        for(NPA_PromotionWrapper pw : promo_wrapper) {
            if(PromoId == pw.Promotions.Id){
                for(NPA_PromotionWrapper.InnerWrapper iw : pw.allocList){
                    for(Allocations__c all : iw.allocs) {
                        if(all.Id!=null || all.Ship_To__c != null && all.Ship_To_Qty__c != null){
	                        if(all.Ship_To_Qty__c<0){
	                            all.Ship_To_Qty__c.addError('Only positive numbers allowed');
	                            return;
	                        } else{
		                        if(all.Unique_Key__c==null){
		                            all.Unique_Key__c = String.valueOf(all.Promotion_Material_Item__c)+String.valueOf(all.Ship_To__c);
		                        }
		                        allocs.add(all);
	                        }
                    	}
                    }
                }
                break;
            }
        }
        if(!allocs.isEmpty()){
        	upsert allocs Unique_Key__c;
        }
    }
}