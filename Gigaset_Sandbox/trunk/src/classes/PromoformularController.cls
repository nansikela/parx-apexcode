public class PromoformularController {

    public boolean display {get;set;}
    public Lead l {get;set;}
    public Campaign camp{get;set;}
    public Contact con{get;set;}
    public String Param_ContactId {get;set;}
    public String Param_Pro {get;set;}
    public String Param_SecurityContactId {get;set;}
    public String Param_CampaignId {get;set;}
    public String Param_LeadRecordType {get;set;}
    public String Param_Portal {get;set;}

    public Boolean showPhoneErr {get;set;}
    public Boolean showProdErr {get;set;}
    public String errorText {get;set;}
    public String errorBase='<strong>' + System.Label.site.Error2 + ':</strong> ';
    public boolean firstPage{get;set;}
    public list<String> selectedProducts {get;set;}
    public list<selectOption> Products {get;set;}
    public String selectedDistributor {get;set;}
    public list<selectOption> Distributors {get;set;}
    public boolean showProduct {get;set;}
    
    public static String getBrowserName()
    {
        String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        if (userAgent != null && userAgent.contains('MSIE'))
            return 'IE';    
            
        return userAgent;
    }
    
    // constructor
    public PromoformularController() {
        firstPage = true;
        display = true;
        
        if(ApexPages.currentPage().getParameters().get('ConId') != null && ApexPages.currentPage().getParameters().get('ConId') != '')
            Param_ContactId =  ApexPages.currentPage().getParameters().get('ConId');
        if(ApexPages.currentPage().getParameters().get('pro') != null && ApexPages.currentPage().getParameters().get('pro') != '')
            Param_Pro =  ApexPages.currentPage().getParameters().get('pro');
        if(ApexPages.currentPage().getParameters().get('SCId') != null && ApexPages.currentPage().getParameters().get('SCId') != '')
            Param_SecurityContactId =  ApexPages.currentPage().getParameters().get('SCId');
        if(ApexPages.currentPage().getParameters().get('CId') != null && ApexPages.currentPage().getParameters().get('CId') != '')
            Param_CampaignId =  ApexPages.currentPage().getParameters().get('CId');
        if(ApexPages.currentPage().getParameters().get('LRT') != null && ApexPages.currentPage().getParameters().get('LRT') != '')
            Param_LeadRecordType =  ApexPages.currentPage().getParameters().get('LRT');
        if(ApexPages.currentPage().getParameters().get('Ptal') != null && ApexPages.currentPage().getParameters().get('Ptal') != '')
            Param_Portal =  ApexPages.currentPage().getParameters().get('Ptal');
           
        if(Param_ContactId != null) {
            try {
                //we first check that the security contact id is the same as the contact id:
                String algorithmName = 'hmacSHA512';
                String key = '';
                key = FN__FindNearby__c.getOrgDefaults().KontaktformularKey__c;
                Blob privateKey = EncodingUtil.base64Decode(key);
                Blob input = Blob.valueOf(Param_ContactId);
                system.debug('test:' + EncodingUtil.urlEncode(EncodingUtil.base64Encode( Crypto.generateMac(algorithmName, input, privateKey )), 'UTF-8'));
                system.debug('test2:' + EncodingUtil.urlEncode(Param_SecurityContactId, 'UTF-8'));
                if(EncodingUtil.urlEncode(Param_SecurityContactId, 'UTF-8') == EncodingUtil.urlEncode(EncodingUtil.base64Encode( Crypto.generateMac(algorithmName, input, privateKey )), 'UTF-8'))
                    con = [select Salutation, FirstName, LastName, Funktion__c, Email, Phone, MailingStreet, MailingPostalCode, MailingCity, MailingCountry, Account.Name, Land_Auswahl__c from Contact where Id =: Param_ContactId];
            }
            catch(exception e) {}
        }
        camp = new Campaign();
        if(Param_CampaignId != null) {
            try {
                camp = [select ReturnText__c, Header__c, Produktinformation__c, Produkt__c, Distributor__c from Campaign where Id =: Param_CampaignId];
            }
            catch(exception e) {
                display = false;
            }
        }
         
        l = new lead();
        l.Portal__c=Param_Portal;
        l.Gigaset_Pro__c = Param_Pro=='true'?true:false;
        
        selectedProducts = new list<String>();
        Products = new list<SelectOption>();
        
        Distributors = new list<SelectOption>();
       // for(Schema.Picklistentry SP:Campaign.Produkt__c.getDescribe().getPicklistValues()) {
     //       Products.add(new SelectOption(SP.getValue(), SP.getValue()));
       // }
        if(camp != null) {
            if(camp.Produkt__c != null && camp.Produkt__c.length() > 0) {
            	list<String> Prods = new list<String>(camp.Produkt__c.split(';'));
                Prods.sort();
                for(String s:Prods) {
                    Products.add(new SelectOption(s, s));
                }
                if(camp.Produkt__c.split(';').size() == 1)
                    selectedProducts = camp.Produkt__c.split(';');
            }
            if(camp.Distributor__c != null && camp.Distributor__c.length() > 0) {
            	list<String> Distribs = new list<String>(camp.Distributor__c.split(';'));
            	Distribs.sort();
                for(String s:Distribs) {
                    Distributors.add(new SelectOption(s, s));
                }
            }
            if(Distributors.isEmpty())
                Distributors = null;
        }
        
        if(!Products.isEmpty())
            showProduct = false;
        else
            showProduct = true;
    }
    
    public PageReference insertIt() {
        system.debug('lead l ' + l);
        if(selectedProducts == null || selectedProducts.isEmpty()) {
            showProdErr = true;
            return null;
        }
        else 
            showProdErr = false;
        if (con!=null) { //we make a contact.
            try {
                if(con.Id != null) {
                    CampaignMember CM;
                    try {
                        CM = [select id from CampaignMember where ContactId =: con.Id AND CampaignId =: Param_CampaignId];
                        
                    }
                    catch(exception e) {
                        //Campaign Member still does not exist.
                        CM = new CampaignMember();
                        CM.CampaignId = Param_CampaignId;
                        CM.ContactId = con.Id;
                    }
                    CM.Produkt__c = '';
                    CM.Distributor__c = selectedDistributor;
                    if(selectedProducts != null) {
                        for(String s:selectedProducts) {
                           CM.Produkt__c += s + ';';
                        }
                    }
                    upsert CM;
                    firstPage = false;
                }
            } catch (Exception e) { }
        }
        else { //we make a lead.
            try {
                if(checkingPhoneNumber()) {
                    firstPage = false;
                    try {
                        id test = Param_LeadRecordType;
                        if(test != null)
                            l.RecordTypeId = test;
                    }
                    catch(exception e) {}
                    l.Gigaset_Pro__c = true;
                    insert l;
                }
            }
            catch(exception e) {}
            
            if(l.Id != null) {
                CampaignMember CM = new CampaignMember();
                CM.CampaignId = Param_CampaignId;
                CM.LeadId = l.Id;
                CM.Produkt__c = '';
                CM.Distributor__c = selectedDistributor;
                if(selectedProducts != null) {
                    for(String s:selectedProducts) {
                       CM.Produkt__c += s + ';';
                    }
                }
                insert CM;
            }
        }
        
        return null;
    }

    
    public Boolean checkingPhoneNumber () {
        // Company Phone / Fax
        Request__c rq = new Request__c();
        if (l.Phone!=null && l.Phone!='') {
            rq.Telefon__c=l.Phone;
            try {
                upsert rq;
            } catch (System.DmlException e) {
                errorText=errorBase + returnErrorMsg(e.getMessage());
                showPhoneErr=true;
                return false;
            }
        }
        
        if (rq!=null && rq.id!=null) try {
            delete rq;
        } catch (Exception e) {}
        return true;
    }
    
    private String returnErrorMsg(String error) {
        String errmsg=error;
        String validationerr='FIELD_CUSTOM_VALIDATION_EXCEPTION';
        Integer startindex=error.indexOf(validationerr);
        // custom validation errror found?
        if (startindex!=-1) {
            startindex=startindex+validationerr.length()+2;
            Integer lastindex=error.lastIndexOf(': [');
            errmsg=error.substring(startindex,lastindex);
        }
        return errmsg;
    }
    
    public lead getl() {
        return l;
    }
    
    @isTest
    public static void testit() {
        PromoformularController KFC = new PromoformularController();
        
        getBrowserName();
        KFC.getl();
        KFC.returnErrorMsg('test');
        KFC.l.Phone = '123456';
        KFC.checkingPhoneNumber();
        KFC.insertIt();        
    }
}