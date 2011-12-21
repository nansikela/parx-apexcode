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
    	
   	public Promotion__c promotion1 {get;set;}
   	public Promotion__c promotion2 {get;set;}
    public Promotion__c promotion3 {get;set;}
    	
    public Promotion_Material_Item__c material_item1 {get;set;}
    public Promotion_Material_Item__c material_item2 {get;set;}
    public Promotion_Material_Item__c material_item3 {get;set;}
    	
    	
    public UnitTestUtilities() {
    	//Account
    	account1 = new Account(Name = 'Test Account 1');
    	account2 = new Account(Name = 'Test Account 2');
    	account3 = new Account(Name = 'Test Account 3');
    	
    	insert account1;
    	insert account2;
    	insert account3;
    	
    	//Promotion__c
    	promotion1 = new Promotion__c(Name = 'Test Promotion 1', Account__c = account1.ID); //No material item children
   		promotion2 = new Promotion__c(Name = 'Test Promotion 2', Account__c = account2.ID); //One material item children
   		promotion3 = new Promotion__c(Name = 'Test Promotion 3', Account__c = account3.ID); //Two material item children
    	
    	insert promotion1;
    	insert promotion2;
    	insert promotion3;
    	
    	//Promotion_Material_Item__c
    	material_item1 = new Promotion_Material_Item__c(Promotion__c = promotion2.Id);
    	
    	material_item2 = new Promotion_Material_Item__c(Promotion__c = promotion3.Id);
    	material_item3 = new Promotion_Material_Item__c(Promotion__c = promotion3.Id); 

    	insert material_item1;
    	insert material_item2;
    	insert material_item3;
    }
    
}