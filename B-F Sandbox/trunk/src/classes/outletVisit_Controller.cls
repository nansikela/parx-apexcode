public with sharing class outletVisit_Controller {
     
/* Class Name : outletVisit_Controller 
* Description: 
* Created By : --
* Created On : --

* Modification Log :  
 * ----------------------------------------------------------------------------------------------------------------------------
* Developer       Date              Description
* ----------------------------------------------------------------------------------------------------------------------------
* VARUN           06-13-2011        Code for Product Remediation Check.
*                                   
 */ 

         
    
    
    public String AlertMessage {get;set;}
    Public List<Product__c> myProds = new List<Product__c>();
    Public List<Depletion__c> myDeps = new List<Depletion__c>();
    Public Map<Id, Outlet_Visit_Item__c> myOVI = new Map<Id, Outlet_Visit_Item__c>();
    


    public Outlet_Visit__c ov;
    public string gridLayout {get;set;}
    public string retURL;
    //Map<ID,Outlet_Visit_Item__c> mapOvi = new Map<ID,Outlet_Visit_Item__c>{};
    Account a;
       
    public outletVisit_Controller(ApexPages.StandardController controller)
    {
        this.ov = (Outlet_Visit__c)controller.getRecord();
        this.retURL = System.currentPageReference().getParameters().get('retURL');
        if(ov.id!=null)
        { //load the details since its an existing record
            showDetails=true;
            setAccountInfo();
            //this.ov.CurrencyIsoCode = a.CurrencyIsoCode;      
            buildOvi(); 
            buildKT();
            if(this.retURL==null || this.retURL=='')
                this.retURL = '/'+ov.Account__c;

        }else{
            this.ov.Visit_Date__c = system.today();
        }   
    }
     /*
    public PageReference redirect(){
        system.debug(ov.Status__c);
        if(ov.Status__c=='New'){
            system.debug('inside');
            PageReference p1 = Page.outletVisit;
            p1.getParameters().put('CF00N30000005PvLY',ov.Account__r.Name);
            p1.getParameters().put('CF00N30000005PvLY_lkid',ov.Account__c);         
            p1.getParameters().put('scontrolCaching','1');
            p1.getParameters().put('sfdc.override','1');
            p1.getParameters().put('retURL',retURL);
            p1.setRedirect(true);
            return p1;
        }
        return null;
    }
    */
    void setAccountInfo()
    {
        Schema.DescribeSObjectResult deOV = Schema.SObjectType.Outlet_Visit__c;
        Transient Map<String,Schema.RecordTypeInfo> rtMapByNameOV = deOV.getRecordTypeInfosByName();
                        
        a = [Select Id, Name, Last_Master_Data_Review__c, Market__c, Market__r.Name, Market__r.On_Channel__c, Market__r.Off_Channel__c, Channel__c, Outlet_Class__c, CurrencyIsoCode, RecordType.developerName from Account where Id =:ov.Account__c];
        gridLayout='1';
        if(a.Channel__c!=null && a.Channel__c!='')
            try{
                if(a.Market__r.get(a.Channel__c+'_Channel__c')!=null && a.Market__r.get(a.Channel__c+'_Channel__c')!='')
                    gridLayout=(string)a.Market__r.get(a.Channel__c+'_Channel__c');
            }catch(exception e){}
        ov.RecordTypeID = rtMapByNameOV.get(gridLayout).RecordTypeID;       
        /*if(a.Channel__c=='Off' && a.Market__r.Off_Channel__c=='2')
        {
            gridLayout='2';
        }
        if(a.Channel__c=='On' && a.Market__r.On_Channel__c=='2')
        {
            gridLayout='2';
        }
        if(a.Channel__c=='Off' && a.Market__r.Off_Channel__c=='3')
        {
            gridLayout='3';
        }
        if(a.Channel__c=='On' && a.Market__r.On_Channel__c=='3')
        {
            gridLayout='3';
        }     */   
    }
    
    public List<SelectOption> getContacts() 
    {
        List<SelectOption> optionList = new List<SelectOption>();
        // Add a null option to force the user to make a selection. //
        //optionList.add(new SelectOption('None','--Please Choose--'));
        if(ov.Account__c!=null)
        {
            for(Contact y :[Select r.Name, r.Id From Contact r where AccountId =: ov.Account__c order by r.Name]) {
                    optionList.add(new SelectOption(y.Id,y.Name));
            }
        }
        return optionList;
    }     

    public List<SelectOption> getspiritTypeList() {
        List<SelectOption> spiritTypeList = new List<SelectOption>();
        Schema.DescribeFieldResult f = Schema.sObjectType.Brand__c.fields.Spirit_Type__c;
        // Get the field describe result from the token
        f = f.getSObjectField().getDescribe();
        List <Schema.PicklistEntry> picklistValues = f.getPicklistValues();  
        spiritTypeList.add(new SelectOption('ALL','ALL'));
        for (Integer x=0;x<picklistValues.size();x++)
        {
            spiritTypeList.add(new SelectOption(picklistValues[x].getLabel(),picklistValues[x].getValue()));
        }
        return spiritTypeList;     
    }  

    public List<SelectOption> getBFBrandsList() 
    {
        List<SelectOption> optionList = new List<SelectOption>();
        // Add a null option to force the user to make a selection. //
        optionList.add(new SelectOption('ALL','ALL'));
        if(ov.Account__c!=null)
        {
            for(Brand__c y :[Select r.Name, r.Id From Brand__c r where Supplier__r.Is_B_F_Brand__c = true ORDER BY r.Name]) {
                optionList.add(new SelectOption(y.Id,y.Name));
            }
        }
        return optionList;
    }     

    public List<SelectOption> getCompBrandsList() 
    {
        List<SelectOption> optionList = new List<SelectOption>();
        // Add a null option to force the user to make a selection. //
        optionList.add(new SelectOption('ALL','ALL'));
        if(ov.Account__c!=null)
        {
            for(Brand__c y :[Select r.Name, r.Id From Brand__c r where Supplier__r.Is_B_F_Brand__c = false ORDER BY r.Name]) {
                optionList.add(new SelectOption(y.Id,y.Name));
            }
        }
        return optionList;
    }     
    
    public PageReference nullAction(){
        return null;
    } 
    public PageReference cancelKT(){
        buildKT();  
        return null;
    }            
    public PageReference redirect(){
        system.debug(ov.Status__c);
        if(ov.Status__c=='New'){
            system.debug('inside');
            PageReference p1 = Page.outletVisit;
            p1.getParameters().put('CF00N30000005PvLY',ov.Account__r.Name);
            p1.getParameters().put('CF00N30000005PvLY_lkid',ov.Account__c);         
            p1.getParameters().put('scontrolCaching','1');
            p1.getParameters().put('sfdc.override','1');
            p1.getParameters().put('retURL',retURL);
            p1.setRedirect(true);
            return p1;
        }
        return null;
    }
      
    public PageReference next(){
        //insert ov;
        
        //a = [Select Id, Market__c, Name, Outlet_Class__c, CurrencyIsoCode, Channel__c from Account where Id =:ov.Account__c];   
        setAccountInfo();
        
        
        /* P00004 
        *VF Outlet Visit has to be updated. When the "Next" Button is pressed then the Visit Date is validated:
        *- The rule has to prevent Outlet Visits in the future and
        *- has to hint the user that the data lays in the past
        *
        *This should be done by using a div layer and the user has to press "OK" to proceed to "Next" or to return 
        * to the Visit.
        *
        *This change should be only available for Accounts with Record Type "EUR_Outlets" or DEU_Outlets.
        *
        *
        * P00050
        * Popup (div layer) occurs on every run of outletVisit VF if Account is a german account (recordtype) 
        * and the timestamp "Last Master Data Review" is null or older than 4 weeks.
        * The 4 weeks are configureable!
        * The Popup does not has any other effect it just has to be confirmed by clicking OK and does not prevent 
        * preceeding with the visit or does not prevent saving the visit.
        */
        
        if(a.RecordType.developerName == 'EUR_Outlets' || a.RecordType.developerName == 'DEU_Outlets' ) {
            if(a.Last_Master_Data_Review__c == null || OutletVisit__c.getOrgDefaults().Number_of_days_for_the_review_time__c != null && a.Last_Master_Data_Review__c.addDays(Integer.valueOf(OutletVisit__c.getOrgDefaults().Number_of_days_for_the_review_time__c))<system.today()) {
                AlertMessage = System.Label.You_did_not_review_the_account + ' ' + String.valueOf(Integer.valueOf(OutletVisit__c.getOrgDefaults().Number_of_days_for_the_review_time__c)) + ' ' + System.Label.days;
            }
            else {
                AlertMessage = '';
            }
            /*if(ov.Visit_Date__c > system.today()) {
                if(AlertMessage != '')
                   AlertMessage += '\r\n.';
                 AlertMessage += System.Label.You_cannot_have_a_visit_date;
                 return null;
            }
            else if(ov.Visit_Date__c < system.today()) {
                if(AlertMessage != '')
                   AlertMessage += '\r\n.';
                 AlertMessage += System.Label.Please_notice_that_the_visit_date_is_not_from_today;
            }*/
        }
        
        /*
        * P00004 - extension
        *
        * Shows AlertMessages based on the availibility of a record in customsettings. If there 
        * is any record available, the AlertMessage won't be cleared. If not, set AlertMessage = ''.
        * Additionally, the custom setting record controls the visit dates in the future.
        *
        * @author: Michael Mickiewicz
        */
        Boolean isRecordTypeFound = false;
        Boolean isCheckboxFlagged = false;
        for(Alert_Settings__c alertSetting : Alert_Settings__c.getAll().values()) 
        	if(alertSetting.Market_RecordType__c == a.RecordType.developerName) { 
        		isRecordTypeFound = true;
        		isCheckboxFlagged = alertSetting.No_Visit_Dates_in_the_Future__c;
        	}
        
        if(!isRecordTypeFound) {
        	AlertMessage = '';
        } else {
        	if(ov.Visit_Date__c > system.today() && isCheckboxFlagged) {
                 AlertMessage = System.Label.You_cannot_have_a_visit_date;
                 return null;
            }
            else if(ov.Visit_Date__c > system.today() && !isCheckboxFlagged) {
                 AlertMessage = System.Label.Please_notice_that_the_visit_date_is_not_from_today;
            }
        }
        /* P00004 - extension END */
        
        showDetails=true;
        ov.CurrencyIsoCode = a.CurrencyIsoCode;     
        buildOvi();
        buildKT();
        return null;
    }     
    public PageReference cancel(){
        return new PageReference(retURL);
    }
    public PageReference saveCommitClose(){
        saveOvi();
        buildOvi();
        buildKT();
        return new PageReference(retURL);
    }
    public PageReference saveCommit(){
        saveOvi();
        buildOvi();
        buildKT();
        return null;
    }  
    public PageReference refresh(){
        buildOvi();
        buildKT();
        return null;
    } 
    
    public boolean showDetails {get;set;}
    public string spiritType {get;set;}
    public string bfBrand {get;set;}
    public string compBrand {get;set;}

    public List<wrapper> myBFOvi {get;set;}
    public List<wrapper> myBFOvi_header {get;set;}
    public List<wrapper> myCompOvi {get;set;}
    public List<wrapper> myCompOvi_header {get;set;}
    public Map<ID,Account_Brand__c> mapBrandAccountBrands;//  {get;set;}
    public Map<ID,Mandatory_Products__c> mapProductsAccount;
    
    void buildAccountBrandMap()
    { 
        mapBrandAccountBrands = new Map<ID,Account_Brand__c>();
        for(Account_Brand__c ab : [Select a.Key_Brand__c, a.Brand__c, a.Required_Brand__c, a.Account__c From Account_Brand__c a where a.Account__c =: a.Id])
        {
            mapBrandAccountBrands.put(ab.Brand__c,ab);
            system.debug('adding keyBrand: ' + ab.Brand__c);
        }
        mapProductsAccount = new Map<ID,Mandatory_Products__c>();
        for(Mandatory_Products__c ab : [Select m.Custom_Product__c, m.Product_Status__c, m.Account__c From Mandatory_Products__c m where m.Account__c =: a.Id])
        {
            mapProductsAccount.put(ab.Custom_Product__c,ab);
        }        
    }    

        //Start Code Change
    void buildOvi()
    { 
        //Account a;
        string myQueryString;
        string depletionQry;
        string outletVisitItemQry;
        date startdate;
        date enddate;
        Map<ID,Outlet_Visit__c> myOldOV;
        Map<ID,Outlet_Visit_Item__c> myExistingOVI;    
        buildAccountBrandMap();        
        //a = [Select Id, Market__c, Outlet_Class__c from Account where Id =:ov.Account__c];
        if(a.Market__c==null)
        {
            ov.adderror(System.Label.OutletVisitPage_missingAccountMarket);
            return;
        }
        //system.debug(spiritType);
        //system.debug(bfBrand);
        //system.debug(compBrand);
    
        //set the range of dates for depletion query
        startdate=ov.Visit_Date__c.addmonths(-1).tostartofmonth();
        enddate=ov.Visit_Date__c.addmonths(1).tostartofmonth().adddays(date.daysInMonth(ov.Visit_Date__c.addmonths(1).year(),ov.Visit_Date__c.addmonths(1).month()));
        //check for any existing OVIs, if not then we need to query old and deepclone 
        myExistingOVI = new Map<ID,Outlet_Visit_Item__c>();
        if(ov.Id!=null) {
            myExistingOVI = new Map<ID,Outlet_Visit_Item__c>([Select id from Outlet_Visit_Item__c where Outlet_Visit__c =: ov.Id]);
        }
        
        //system.debug(myExistingOVI);
        //system.debug(ov.Id);
        if(myExistingOVI.keyset().isempty())
        {
            //try and get an old OV to pull previous entries
            myOldOV = new Map<ID,Outlet_Visit__c>([Select id from Outlet_Visit__c where Status__c != 'New' and Account__c =: ov.Account__c and id!=: ov.Id ORDER BY Visit_Date__c desc, Name desc LIMIT 1]);
        } 
        //system.debug(myOldOV);
        myQueryString = 'Select p.Supplier__c, p.Name, p.Market__c, p.Id, p.Brand__c, p.IsActive__c From Product__c p where '
        //End Code Change
        //10/12/10 - nds added logic for Channel
        + (a.Channel__c!=null?
            '(p.Channel__c = null OR p.Channel__c = \'Both\' OR p.Channel__c = \'' + string.escapeSingleQuotes(a.Channel__c) + '\') AND '  
        :
            '(p.Channel__c = null OR p.Channel__c = \'Both\') AND '
            )
        //        
        + 'p.Market__c = \'' + a.Market__c + '\' and p.RecordType.Name = \'Wet Goods\'';
        system.debug(((myOldOV!=null && !myOldOV.keyset().isempty())?myOldOV.values()[0].Id:ov.id));
        if(spiritType!=null && spiritType!='ALL')
        {
            myQueryString +=' and p.Brand__r.Spirit_Type__c = \'' + string.escapeSingleQuotes(spiritType) + '\'';
        }
//      system.debug(myQueryString);
       // string myBFQueryString;
       // string myCompQueryString;
       // myBFQueryString = myQueryString + ' and p.Brand__r.Supplier__r.Is_B_F_Brand__c = true';
        myQueryString += ' and p.Brand__c IN (';        
        if(bfBrand!=null && bfBrand!='ALL')
        {
            myQueryString += '\'' + string.escapeSingleQuotes(bfBrand) + '\',';
        } else {
            for(Brand__c y :[Select r.Name, r.Id From Brand__c r where Supplier__r.Is_B_F_Brand__c = true ORDER BY r.Name]) {
                myQueryString += '\'' + y.Id + '\',';
        }   
        }
       // myCompQueryString = myQueryString + ' and p.Brand__r.Supplier__r.Is_B_F_Brand__c = false';
        if(compBrand!=null && compBrand!='ALL')
        {
            myQueryString += '\'' + string.escapeSingleQuotes(compBrand) + '\',';
        } else {
            // loop thru all competitor brands
            for(Brand__c y :[Select r.Name, r.Id From Brand__c r where Supplier__r.Is_B_F_Brand__c = false ORDER BY r.Name]) {
                myQueryString += '\'' + y.Id + '\',';
        }           
        }         
        //remove final ,
        myQueryString = myQueryString.substring(0,myQueryString.length() -1);
        myQueryString += ')';
        myQueryString +=' ORDER BY p.Sort_Order__c';
        system.debug(myQueryString);
        
        myBFOvi = new List<wrapper>();
        myBFOvi_header = new List<wrapper>();
        myCompOvi = new List<wrapper>();    
        myCompOvi_header = new List<wrapper>();    
         
        myProds.clear();
        
        for(Product__c p :Database.query(myQueryString))
        {
            //&& p.Outlet_Visit_Items__r.size()==0
            if(p.IsActive__c==false)
            {
                continue;
            }else{
                myProds.add(p);
                }
                
             }
        depletionQry = 'Select Id, Name, Bottles__c, Month_Of_Date__c, Account__c, Custom_Product__c From Depletion__c where Account__c = \'' + a.Id + '\' and Month_Of_Date__c >= ' + startdate.year() +'-'+ (startdate.month()<10?('0'+startdate.month().format()):startdate.month().format()) + '-' + (startdate.day()<10?('0'+startdate.day().format()):startdate.day().format())+ ' and Month_Of_Date__c <= ' + enddate.year() +'-'+ (enddate.month()<10?('0'+enddate.month().format()):enddate.month().format()) + '-' + (enddate.day()<10?('0'+enddate.day().format()):enddate.day().format())+ ' ORDER BY Month_Of_Date__c';
        //String depletionQry = 'Select Id, Name, Bottles__c, Month_Of_Date__c, Account__c, Custom_Product__c From Depletion__c where Account__c = \'0013000000niZRZAA2\'';
        for (Depletion__c d :Database.query(depletionQry))
        {
            myDeps.add(d);
        }       
        outletVisitItemQry = 'Select Id, Name, Outlet_Visit__c, Custom_Product__c, Bottle_Price__c, Bottle_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Double_Price__c, Double_Price_Special__c, Space_Placement__c, Shelf__c, Facing__c, Available__c From Outlet_Visit_Item__c ' + (((myOldOV!=null && !myOldOV.keyset().isempty())?myOldOV.values()[0].Id:ov.id)!=null?(' where Outlet_Visit__c = \'' + ((myOldOV!=null && !myOldOV.keyset().isempty()) ? myOldOV.values()[0].Id:ov.id)+ '\''):' where Outlet_Visit__r.Account__c = \'' + a.Id + '\'');
        //String outletVisitItemQry = 'Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Outlet_Visit__c, Product__c, Bottle_Price__c, Bottle_Price_Special__c, Drink_Price__c, Drink_Price_Special__c, Double_Price__c, Double_Price_Special__c, Space_Placement__c, Shelf__c, Facing__c, Available__c From Outlet_Visit_Item__c  where Outlet_Visit__c = \'a0MS00000045QrdMAE\'';
        for (Outlet_Visit_Item__c i :Database.query(outletVisitItemQry))
        {
            myOVI.put(i.Custom_Product__c,i);
        }
        for(Product__c prod : myProds)
            {
                string requiredBrand = mapProductsAccount.get(prod.Id)!=null?mapProductsAccount.get(prod.Id).Product_Status__c:null;
                boolean keyBrand = mapBrandAccountBrands.get(prod.Brand__c)!=null?mapBrandAccountBrands.get(prod.Brand__c).Key_Brand__c:null;                        
            system.debug('prodId = ' + prod.Id);
            system.debug('prodBrand = ' + prod.Brand__c);           
            system.debug('requiredBrand = ' + requiredBrand);            
            system.debug('keyBrand = ' + keyBrand);
            system.debug('Supplier__c = ' + prod.Supplier__c);
            if (prod.Supplier__c == 'B-F') {
                myBFOvi.add(new wrapper(prod,ov,myOVI,myDeps,(myOldOV!=null && !myOldOV.keyset().isempty())?true:false,(requiredBrand!=null?requiredBrand:null),keyBrand));             
            } else {
                myCompOvi.add(new wrapper(prod,ov,myOVI,myDeps,(myOldOV!=null && !myOldOV.keyset().isempty())?true:false,(requiredBrand!=null?requiredBrand:null),keyBrand));
            }
        }
        /* P00005a */
        myBFOvi = sortOVI(myBFOvi);
  		/* P00005a */
  
    //    myCompQueryString +=' ORDER BY p.Sort_Order__c';
    //    system.debug(myCompQueryString);
    //    for(Product2 prod :Database.query(myCompQueryString))
     //   {
     //       if(prod.IsActive==false && prod.Outlet_Visit_Items__r.size()==0)
     //       {
     //           continue;
      //      }else{
      //          string requiredBrand = mapProductsAccount.get(prod.Id)!=null?mapProductsAccount.get(prod.Id).Product_Status__c:null;
      //          boolean keyBrand = mapBrandAccountBrands.get(prod.Brand__c)!=null?mapBrandAccountBrands.get(prod.Brand__c).Key_Brand__c:null;                        
                //myCompOvi.add(new wrapper(prod,ov,(myOldOV!=null && !myOldOV.keyset().isempty())?true:false,(requiredBrand!=null?requiredBrand:null),keyBrand));          
      //      }
     //   }
        system.debug(myBFOvi);
        //End Code Change   
    }
    
        /*
    *SOW: P00005a 
    *
    *Changes VF outletVisit
    *
    * For all markets:
    * Change the order of the drinks to present the account related drinks on top of the list.
    * Criteria are:
    * Mandatory Product
    * Account Brands (actual listings/facings)
    */
    public list<wrapper> sortOVI(list<wrapper> OVI) {
        list<wrapper> TempOVIs = new list<wrapper>();
        
        //first available ovi.
        for(wrapper temp:OVI) {
            if(temp != null && temp.ovi != null && temp.ovi.Available__c)
              TempOVIs.add(temp);
        }
        
        //then required Brand by taking care that we don't add again the available.
        for(wrapper temp:OVI) {
            if(temp != null && temp.ovi != null && !temp.ovi.Available__c && temp.requiredBrand != null)
              TempOVIs.add(temp);
        }
        
        //then key Brand by taking care that we don't add again the others
        for(wrapper temp:OVI) {
            if(temp != null && temp.ovi != null && !temp.ovi.Available__c && temp.requiredBrand == null && temp.keyBrand != null && temp.keyBrand)
              TempOVIs.add(temp);
        }
        
        //we add all others items.
        for(wrapper temp:OVI) {
            if(temp != null && temp.ovi != null && !temp.ovi.Available__c && temp.requiredBrand == null && (temp.keyBrand == null || !temp.keyBrand))
              TempOVIs.add(temp);
        }
        
        return TempOVIs;
    }
    
    void saveOvi()
    { 
    Savepoint sp = Database.setSavepoint();  
        INFW_Stateful.setAlreadyCreated();
        ov.Status__c = 'Complete';
        try{  
            upsert ov;
        }catch (System.DmlException insertDmlexp) {
            ov.adderror(insertDmlexp);
            //Rollback Transaction
            Database.rollback(sp);
            return;
        }
             
        List<Outlet_Visit_Item__c> myOVIUpdates = new List<Outlet_Visit_Item__c>();
        List<Outlet_Visit_Item__c> myOVIInserts = new List<Outlet_Visit_Item__c>();
        List<Depletion__c> myDEPUpdates = new List<Depletion__c>();
        List<Depletion__c> myDEPInserts = new List<Depletion__c>();     
        if(myBFOvi!=null)
        {
            for(wrapper y :myBFOvi)
            {
                if(y.ovi.Id==null)
                {
                    if((y.ovi.Bottle_Price__c!=null && y.ovi.Bottle_Price__c!=0) || 
                    (y.ovi.Drink_Price__c!=null && y.ovi.Drink_Price__c!=0) ||
                    y.ovi.Double_Price__c!=null ||
                    y.ovi.Space_Placement__c!=null ||
                    y.ovi.Shelf__c!=null ||
                    y.ovi.Facing__c!=null ||
                    y.ovi.Available__c!=null
                    )
                    {
                        y.ovi.Outlet_Visit__c=ov.Id;
                        myOVIInserts.add(y.ovi);
                    }
                }else{ //we need to update regardless...don't know if values were changed
                    myOVIUpdates.add(y.ovi);
                }   
                if(y.dep1.Id!=null)
                {
                    myDEPUpdates.add(y.dep1);               
                }else{
                    if(y.dep1.Bottles__c!=null && y.dep1.Bottles__c!=0)
                    {
                        myDEPInserts.add(y.dep1);
                    }               
                }
                if(y.dep2.Id!=null)
                {
                    myDEPUpdates.add(y.dep2);               
                }else{
                    if(y.dep2.Bottles__c!=null && y.dep2.Bottles__c!=0)
                    {
                        myDEPInserts.add(y.dep2);
                    }               
                }
                if(y.dep3.Id!=null)
                {
                    myDEPUpdates.add(y.dep3);               
                }else{
                    if(y.dep3.Bottles__c!=null && y.dep3.Bottles__c!=0)
                    {
                        myDEPInserts.add(y.dep3);
                    }               
                }                       
            }
        }
        if(myCompOvi!=null)
        {
            for(wrapper y :myCompOvi)
            {
                if(y.ovi.Id==null)
                {
                    if((y.ovi.Bottle_Price__c!=null && y.ovi.Bottle_Price__c!=0) || 
                    (y.ovi.Drink_Price__c!=null && y.ovi.Drink_Price__c!=0) ||
                    y.ovi.Double_Price__c!=null ||
                    y.ovi.Space_Placement__c!=null ||
                    y.ovi.Shelf__c!=null ||
                    y.ovi.Facing__c!=null ||
                    y.ovi.Available__c!=null
                    )
                    {
                        y.ovi.Outlet_Visit__c=ov.Id;
                        myOVIInserts.add(y.ovi);
                    }
                }else{ //we need to update regardless...don't know if values were changed
                    myOVIUpdates.add(y.ovi);
                }   
                if(y.dep1.Id!=null)
                {
                    myDEPUpdates.add(y.dep1);               
                }else{
                    if(y.dep1.Bottles__c!=null && y.dep1.Bottles__c!=0)
                    {
                        myDEPInserts.add(y.dep1);
                    }               
                }
                if(y.dep2.Id!=null)
                {
                    myDEPUpdates.add(y.dep2);               
                }else{
                    if(y.dep2.Bottles__c!=null && y.dep2.Bottles__c!=0)
                    {
                        myDEPInserts.add(y.dep2);
                    }               
                }
                if(y.dep3.Id!=null)
                {
                    myDEPUpdates.add(y.dep3);               
                }else{
                    if(y.dep3.Bottles__c!=null && y.dep3.Bottles__c!=0)
                    {
                        myDEPInserts.add(y.dep3);
                    }               
                }                       
            } 
        }  
        List<Key_Task__c> myKTUpdates = new List<Key_Task__c>();
        List<Key_Task__c> myKTInserts = new List<Key_Task__c>();
        List<Key_Task__c> myKTDeletes = new List<Key_Task__c>();                    
        if(myKTs!=null)
        {
            for(wrapperKT y : myKTs)
            {
                if(y.kt.id==null)
                {
                    if(y.selected)
                    {
                        y.kt.Outlet_Visit__c=ov.Id;
                        myKTInserts.add(y.kt);
                    }
                }else{
                    //already saved, but did they uncheck? ie. delete?
                    if(y.selected)
                    {
                        myKTUpdates.add(y.kt);
                    }else{//delete
                        myKTDeletes.add(y.kt);
                    }
                }
            }
        }
        try{                
            update myOVIUpdates;
            insert myOVIInserts;
            update myDEPUpdates;
            insert myDEPInserts;
            update myKTUpdates;
            insert myKTInserts;
            delete myKTDeletes;             
        }catch (System.DmlException insertDmlexp) {
            ov.adderror(insertDmlexp);
            //Rollback Transaction
            Database.rollback(sp);
            return;//refresh page to show error
        }   
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ''));                
    }

    //this wrapper is used for each Key_Task__c record .
    public class wrapperKT {
    public Key_Task__c kt {get; set;}
    public Key_Task_Template__c ktt {get; set;}
    public boolean selected {get; set;}
    public wrapperKT(Key_Task_Template__c a)
        {
            ktt = a;
            selected=false;
        }
    }

    public List<wrapperKT> myKTs {get;set;}
    public List<Key_Task__c> myCompletedKTs {get;set;}
    
    void buildKT()
    {
        myKTs = new List<wrapperKT>();
        myCompletedKTs = new List<Key_Task__c>();
        for(Key_Task_Template__c y : [Select k.Outlet_Class__c, k.Name, k.Market__c, k.Id, k.Channel__c, (Select Id, Name, Key_Task_Template__c, Outlet_Visit__c, Met_With__c, Comments__c From Key_Tasks__r where Outlet_Visit__c=:ov.Id and Outlet_Visit__c!=null) From Key_Task_Template__c k where k.Outlet_Class__c =: a.Outlet_Class__c and k.Market__c =: a.Market__c and (k.Channel__c = 'Both' or k.Channel__c =:a.Channel__c) ])
        {
            wrapperKT temp = new wrapperKT(y);
            if(ov.id!=null && !y.Key_Tasks__r.isempty())
            {
                temp.kt = y.Key_Tasks__r[0];
                temp.selected = true;
                myCompletedKTs.add(temp.kt);
            }else{
                temp.kt = new Key_Task__c();
                temp.kt.Key_Task_Template__c = temp.ktt.Id;
                temp.kt.Met_With__c = (string.valueof(ov.Met_With__c)!='None'&&ov.Met_With__c!=null)?ov.Met_With__c:null;
            }
            myKTs.add(temp);
        }
        
    }

    public List<Key_Task__c> getmyKTHistory() 
    {
        return [Select k.SystemModstamp, k.Outlet_Visit__r.Visit_Date__c, k.Name, k.Met_With__c, k.LastModifiedDate, k.LastModifiedById, k.Key_Task_Template__c, k.IsDeleted, k.Id, k.CreatedDate, k.CreatedById, k.Comments__c From Key_Task__c k where k.Outlet_Visit__r.Account__c =: ov.Account__c order by k.Outlet_Visit__r.Visit_Date__c DESC LIMIT 10];
    }      
    
    public ID productLookup {get;set;}
    public string productLookupName {get;set;}
    
    public List<Outlet_Visit_Item__c> getmyPHs()
    {
        List<Outlet_Visit_Item__c> temp = new List<Outlet_Visit_Item__c>();
        if(productLookup!=null)
        {       
            List<Outlet_Visit_Item__c> y = [Select o.SystemModstamp, o.Custom_Product__c, o.Custom_Product__r.Name, o.Outlet_Visit__r.Account__c, o.Outlet_Visit__r.Visit_Date__c, o.Outlet_Visit_Item_Key__c, o.Name, o.LastModifiedDate, o.LastModifiedById, o.IsDeleted, o.Id, o.Drink_Price__c, o.Drink_Price_Special__c, o.CreatedDate, o.CreatedById, o.Bottle_Price__c, o.Bottle_Price_Special__c, Double_Price__c, Double_Price_Special__c From Outlet_Visit_Item__c o where o.Custom_Product__c =: productLookup and o.Outlet_Visit__r.Account__c =: ov.Account__c order by o.Outlet_Visit__r.Visit_Date__c desc LIMIT 6];
            Integer x = y.size();
            while (x > 0) {
                temp.add(y.get(x-1));
                productLookupName=y.get(x-1).Custom_Product__r.Name;
                x--;
            } 
            return temp;
        }
        return null;
    }

    public wrapperDPHeader getmyDPs()
    {
        wrapperDPHeader myvalues = new wrapperDPHeader();
        //List<wrapperDP> myMonthsvalues = new List<wrapperDP>();
        wrapperDP Months = new wrapperDP();
        List<wrapperDP> myBFvalues = new List<wrapperDP>();
        List<wrapperDP> myCompvalues = new List<wrapperDP>();
        List<sObject> Totals;
        Map<string,List<sObject>> TotalList = new Map<string,List<sObject>> ();
        List<wrapperDPMonths> tempMonths = new List<wrapperDPMonths>();
        if(productLookup!=null)
        {       
            Totals = [Select d.Custom_Product__c Name, d.Month_Of_Date__c MonthOfDate, CALENDAR_QUARTER(d.Month_Of_Date__c) QuarterOfDate, SUM(d.Bottles__c) Bottles From Depletion__c d where d.Custom_Product__c IN (Select Id from Product__c where Competes_On_Brand__c =:[Select Competes_On_Brand__c from Product__c where Id =: productLookup].Competes_On_Brand__c) and d.Account__c =: ov.Account__c and d.Month_Of_Date__c = LAST_N_DAYS:365 GROUP BY CUBE(d.Custom_Product__c, d.Month_Of_Date__c, CALENDAR_QUARTER(d.Month_Of_Date__c)) order by d.Month_Of_Date__c ];
            system.debug(Totals);
            for(sObject y : Totals)
            {               
                system.debug(y);
                if(
                    ((string)y.get('Name')==null && (date)y.get('MonthOfDate')!=null && (integer)y.get('QuarterOfDate')==null) //need distinct list of months
                    //|| ((string)y.get('Name')==null && (date)y.get('MonthOfDate')==null && (integer)y.get('QuarterOfDate')!=null && (integer)y.get('YearOfDate')!=null) 
                )
                {
                        wrapperDPMonths b = new wrapperDPMonths();
                        //b.Bottles = (decimal)y.get('Bottles');
                        b.MonthOfDate = (date)y.get('MonthOfDate'); 
                        tempMonths.add(b);                                      
                }           
                if((string)y.get('Name')!=null && (date)y.get('MonthOfDate')!=null && (integer)y.get('QuarterOfDate')==null) //no subtotals, just the details
                {               
                    List<sObject> temp = TotalList.get((string)y.get('Name'));
                    if(temp==null)
                    {
                        temp = new List<sObject>(); 
                    }
                    temp.add(y);
                    TotalList.put((string)y.get('Name'),temp);
                }   
            }
            Months.months=tempMonths;           
            myvalues.monthsDPs = Months;
            //now we need to clone the monthsDPs so we have a place holder for each month
            Map<date,integer> mapOfMonths = new Map<date,integer>();
            integer counter = 0; 
            for(wrapperDPMonths t : tempMonths)
            {
                mapOfMonths.put(t.MonthOfDate,counter);
                counter++;
            }
    
            wrapperDPHeader myHeader = new wrapperDPHeader();
            for(Product__c z : [Select p.Id, p.Name, p.Sort_Order__c, p.Brand__r.Supplier__r.Is_B_F_Brand__c from Product__c p where p.Id in: TotalList.keyset() order by p.Sort_Order__c])
            {
                //for(Product2 z : pMap.values())
                //{     
                    wrapperDP a = new wrapperDP();
                    List<wrapperDPMonths> temp = new List<wrapperDPMonths>();
                    temp.addall(tempMonths);                
                    a.ProductName = z.Name;//pMap.get((string)y.get('Name')).Name;  
                    for(sObject y : TotalList.get(z.Id))
                    {                       
                        wrapperDPMonths b = new wrapperDPMonths();
                        b.Bottles = (decimal)y.get('Bottles');
                        b.MonthOfDate = (date)y.get('MonthOfDate');
                        temp.set(mapOfMonths.get((date)y.get('MonthOfDate')), b);               
                    }
                    a.months=temp;
                    if(z.Brand__r.Supplier__r.Is_B_F_Brand__c)
                    {
                        myBFvalues.add(a);
                    }else{
                        myCompvalues.add(a);
                    }   
                //} 
            }       
            myvalues.bfDPs = myBFvalues.isempty()?null:myBFvalues;      
            myvalues.compDPs = myCompvalues.isempty()?null:myCompvalues;
            return myvalues;
        }
        return null;
    }    

    public class wrapperDPHeader {
        public List<wrapperDP> bfDPs {get; set;}
        public List<wrapperDP> compDPs {get; set;}
        public wrapperDP monthsDPs {get; set;}
    }       
    
    public class wrapperDP {
    public string ProductName {get; set;}
    public List<wrapperDPMonths> months {get; set;}
    }   

    public class wrapperDPMonths {
    public decimal Bottles {get; set;}
    public date MonthOfDate {get; set;}
    }   
              
    public date getdate1() 
    {
        return ov.Visit_Date__c.addmonths(-1);
    }
    public date getdate2() 
    {
        return ov.Visit_Date__c;
    }
    public date getdate3() 
    {
        return ov.Visit_Date__c.addmonths(1);
    }                    
    //this wrapper is used for each Outlet_Visit_Item__c record to join Depletion__c record.
    public class wrapper {
    public Product__c prod {get; set;}
    public Outlet_Visit_Item__c ovi {get; set;}
    //public List<Depletion__c> dep {get; set;}
    public Depletion__c dep1 {get; set;}
    public Depletion__c dep2 {get; set;}
    public Depletion__c dep3 {get; set;}
    public boolean selected {get; set;}
    public string requiredBrand {get; set;}
    public boolean keyBrand {get; set;}
        public wrapper(Product__c p, Outlet_Visit__c ov, Map<Id,Outlet_Visit_Item__c> OVMap,List<Depletion__c> DepList, boolean isNew, string rb, boolean kb)   
        {
            prod = p;
                //Start Code Change
               if(OVMap.containsKey(prod.Id))
            {
                    Outlet_Visit_Item__c newOvi = OVMap.get(prod.Id);
                    //system.debug(p.Outlet_Visit_Items__r);
                if(isNew)
                {
                    ovi = new Outlet_Visit_Item__c();
                    ovi.CurrencyIsoCode = ov.CurrencyIsoCode;
                    ovi.Custom_Product__c=p.id;
                    //ovi.Outlet_Visit__c=ov.Id;    
                    ovi.Drink_Price__c=newOvi.Drink_Price__c;
                    ovi.Drink_Price_Special__c=newOvi.Drink_Price_Special__c;
                    ovi.Bottle_Price__c=newOvi.Bottle_Price__c;
                    ovi.Bottle_Price_Special__c=newOvi.Bottle_Price_Special__c;
                    ovi.Double_Price__c=newOvi.Double_Price__c;
                    ovi.Double_Price_Special__c=newOvi.Double_Price_Special__c;
                
                    ovi.Space_Placement__c=newOvi.Space_Placement__c;
                    ovi.Shelf__c=newOvi.Shelf__c;
                    ovi.Facing__c=newOvi.Facing__c;
                    ovi.Available__c=newOvi.Available__c;
                }else{
                    ovi = newOvi;//should be just one row
                    ovi.CurrencyIsoCode = ov.CurrencyIsoCode;   
                }            
            }else{
                ovi = new Outlet_Visit_Item__c();
                ovi.Custom_Product__c=p.id;
                ovi.CurrencyIsoCode = ov.CurrencyIsoCode;
                //ovi.Outlet_Visit__c=ov.Id;
            }
            requiredBrand = rb;
            keyBrand = kb;                        
                for(Depletion__c y : DepList) {
                    system.debug('y.custom_product__c = ' + y.Custom_product__c);
                    system.debug('prod.id = ' + prod.id);                   
                    if(y.Custom_product__c == prod.id) {
                if(y.Month_Of_Date__c.month()==ov.Visit_Date__c.addmonths(-1).month()){dep1=y;}
                if(y.Month_Of_Date__c.month()==ov.Visit_Date__c.month()){dep2=y;}
                if(y.Month_Of_Date__c.month()==ov.Visit_Date__c.addmonths(1).month()){dep3=y;}
                    }
            }
            if(dep1==null)
            {
                dep1 = new Depletion__c();
                dep1.CurrencyIsoCode = ov.CurrencyIsoCode;
                dep1.Custom_Product__c=p.Id;
                dep1.Account__c=ov.Account__c;
                dep1.Month_Of_Date__c=ov.Visit_Date__c.addmonths(-1).tostartofmonth();
            }
            if(dep2==null)          
            {
                dep2 = new Depletion__c();
                dep2.CurrencyIsoCode = ov.CurrencyIsoCode;
                dep2.Custom_Product__c=p.Id;
                dep2.Account__c=ov.Account__c;
                dep2.Month_Of_Date__c=ov.Visit_Date__c.tostartofmonth();
            }
            if(dep3==null)
            {
                dep3 = new Depletion__c();
                dep3.CurrencyIsoCode = ov.CurrencyIsoCode;
                dep3.Custom_Product__c=p.Id;
                dep3.Account__c=ov.Account__c;
                dep3.Month_Of_Date__c=ov.Visit_Date__c.addmonths(1).tostartofmonth();
            }
            selected = false;
        }
    }

    public List<Outlet_Visit__c> getRecentOVs() 
    {
        List<Outlet_Visit__c> optionList = new List<Outlet_Visit__c>();
        // Add a null option to force the user to make a selection. //
        //optionList.add(new SelectOption('None','--Please Choose--'));
        return [Select o.Visit_Date__c, o.Visit_Comments__c, o.SystemModstamp, o.OwnerId, o.Name, o.Met_With__c, o.LastModifiedDate, o.LastModifiedById, o.IsDeleted, o.Id, o.CurrencyIsoCode, o.CreatedDate, o.CreatedById, o.Competitor_Activity__c, o.Account__c, o.Account__r.Name From Outlet_Visit__c o where o.CreatedById =: userinfo.getUserId() and 
        (
            (o.CreatedDate >=: date.today().adddays(-1) and o.CreatedDate <=: date.today().adddays(1)) 
            or 
            (
                o.LastModifiedById  =: userinfo.getUserId() and 
                (o.LastModifiedDate >=: date.today().adddays(-1) and o.LastModifiedDate <=: date.today().adddays(1))
            )
        )];
    }  
  
  
   public List<SelectOption> getLocationData() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('--None--','--None--'));
        
        //Add values to list of Select Options  
        for (OV_Location_Data__c location : [select Name__c, Market__c, Sort_Order__c, Channel__c From OV_Location_Data__c order by Sort_Order__c]) {
            if (location.Market__c == a.Market__r.Name && location.Channel__c == a.Channel__c) {
                options.add(new SelectOption(location.Name__c,location.Name__c));
            }
        }
                
        return options;
    }
    
   public List<SelectOption> getShelfData() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('--None--','--None--'));
        
        //Add values to list of Select Options  
        for (Outlet_Visit_Shelf_Data__c shelf : [select Name__c, Market__c, Sort_Order__c From Outlet_Visit_Shelf_Data__c order by Sort_Order__c]) {
            if (shelf.Market__c == a.Market__r.Name) {
                options.add(new SelectOption(shelf.Name__c,shelf.Name__c));
            }
        }
                
        return options;
    }    
}