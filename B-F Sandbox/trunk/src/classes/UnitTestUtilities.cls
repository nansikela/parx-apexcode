/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class UnitTestUtilities {
	
	public Account account1 {get;set;}
    public Account account2 {get;set;}
    public Account account3 {get;set;}
    	
    public Contact contact1 {get;set;}
    public Contact contact2 {get;set;}
    public Contact contact3 {get;set;}
        
   	public Promotion__c promotion1 {get;set;}
   	public Promotion__c promotion2 {get;set;}
    public Promotion__c promotion3 {get;set;}
    	
    public Promotion_Material_Item__c material_item1 {get;set;}
    public Promotion_Material_Item__c material_item2 {get;set;}
    public Promotion_Material_Item__c material_item3 {get;set;}
    	
    public Market__c market {get;set;}
    
    public Brand__c brand1 {get;set;}
    public Brand__c brand2 {get;set;}
       
    public Product__c product1 {get;set;}
    public Product__c product2 {get;set;}
    
        
    public void init() {
    	
    	market = new Market__c(Market_Code__c = 'GER', Name = 'Germany', Off_Channel__c = '1', On_Channel__c = '1');
    	
    	insert market;
    	
    	account1 = new Account(Name = 'Test Account 1', Market__c = market.Id, Channel__c = 'Off', BillingCountry = 'DE');
    	account2 = new Account(Name = 'Test Account 2', Market__c = market.Id, Channel__c = 'Off', BillingCountry = 'DE');
    	account3 = new Account(Name = 'Test Account 3');
    	
    	insert account1;
    	insert account2;
    	insert account3;
    	
    	contact1 = new Contact(LastName = 'Roger', AccountId = account1.Id);
    	contact2 = new Contact(LastName = 'Alex', AccountId = account2.Id);
    	contact3 = new Contact(LastName = 'Tim', AccountId = account3.Id);
    	 
    	insert contact1;
    	insert contact2;
    	insert contact3;
    	
    	promotion1 = new Promotion__c(Name = 'Test Promotion 1', Account__c = account1.ID); //No material item children
   		promotion2 = new Promotion__c(Name = 'Test Promotion 2', Account__c = account2.ID); //One material item children
   		promotion3 = new Promotion__c(Name = 'Test Promotion 3', Account__c = account3.ID); //Two material item children
    	
    	insert promotion1;
    	insert promotion2;
    	insert promotion3;
    	
    	material_item1 = new Promotion_Material_Item__c(Promotion__c = promotion2.Id);
    	material_item2 = new Promotion_Material_Item__c(Promotion__c = promotion3.Id);
    	material_item3 = new Promotion_Material_Item__c(Promotion__c = promotion3.Id); 

    	insert material_item1; 
    	insert material_item2;
    	insert material_item3;
    	 
    	brand1 = new Brand__c(Name = 'Jack Daniel\'s');
    	brand2 = new Brand__c(Name = 'Herradura');
    	
    	insert brand1;
    	insert brand2;
    	
    	product1 = new Product__c(Brand__c = brand1.ID);
        product2 = new Product__c(Brand__c = brand2.ID);
    	
    	insert product1;
    	insert product2; 
    }
    
}