public without sharing class AccountFactsheet {

    /** Button on Account should present a Factsheet.
    * Visual Force Page to show the most relevant information for one Account on max. 2 DIN A4 pages
    * Relevant objects are:
    * - Account (Address, Contact Names...)
    * - last visit comments 
    * - Account Brand
    * - Mandatory Products 
    * - Promotions (Sum of Promotion Totals: Total Gross Profit, Total Promotion Cost (r), Total Brand Profit (f)
    * - Promotion Activities with the same Subgroup (active and included between start and end date.)
    **/
    
    public Account account{get;set;} 
    public list<Contact> contact{get;set;}
    public list<Outlet_Visit__c> Outlet_Visit{get;set;}
    public list<Account_Brand__c> Account_Brand{get;set;}
    public list<Mandatory_Products__c> Mandatory_Products{get;set;}
    public String Currenc {get;set;} 
    public Double Total_Margin{get;set;}
    public Double Total_Promotion_Cost{get;set;}
    public Double Total_Brand_Profit{get;set;}
    public list<Promotion_Activity__c> Promotion_Activity{get;set;}
    public list<Key_Task__c> Key_Task{get;set;}
     
    public AccountFactsheet () {
        String AccountId = ApexPages.currentPage().getParameters().get('AccountId');
        if(AccountId != null && AccountId.length() >=15 && AccountId.substring(0,3) == '001') {
            account = [select Name, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, Subgroup__c, Phone, Fax  from Account where Id =:AccountId];
            contact = new list<Contact>([select salutation, LastName, FirstName, Email from Contact where AccountId =: account.Id]);
            Outlet_Visit = new list<Outlet_Visit__c>([select Visit_Comments__c, LastModifiedDate from Outlet_Visit__c where Status__c = 'Complete' AND Account__c =: AccountId order by LastModifiedDate desc]);
            Account_Brand = new list<Account_Brand__c>([select of_Forecast__c, of_Goal__c, Goal__c, Brand__r.Name, Supplier__c, Goal_Gauge__c from Account_Brand__c where Account__c =: AccountId order by Brand__r.Name asc]);
            Mandatory_Products = new list<Mandatory_Products__c>([select Custom_Product__r.Name, Product_Status__c from Mandatory_Products__c where Account__c =: AccountId]);
            Total_Margin = Total_Promotion_Cost = Total_Brand_Profit = 0;
            list<Id> PromotionActivityIds = new list<Id>();
            for(Promotion__c promo:[select CurrencyIsoCode, Total_Margin__c, Total_Promotion_Cost__c, Total_Brand_Profit__c, Promotion_Activity__c  from Promotion__c where Account__c =: AccountId]) {
                Total_Margin += promo.Total_Margin__c;
                Total_Promotion_Cost += promo.Total_Promotion_Cost__c;
                Total_Brand_Profit += promo.Total_Brand_Profit__c;
                Currenc = promo.CurrencyIsoCode;
                PromotionActivityIds.add(promo.Promotion_Activity__c);
            }
            Promotion_Activity = new list<Promotion_Activity__c>([select Name, Description__c from Promotion_Activity__c where Id NOT IN: PromotionActivityIds AND Begin_Date__c <=: system.today() AND End_Date__c >=: system.today() and Active__c = true AND Subgroup_Germany__c =: account.Subgroup__c ]);
            Key_Task = new list<Key_Task__c>([select Name, Outlet_Visit__r.Visit_Date__c from Key_Task__c where Outlet_Visit__c IN: Outlet_Visit limit 3]);
        }
    }
}