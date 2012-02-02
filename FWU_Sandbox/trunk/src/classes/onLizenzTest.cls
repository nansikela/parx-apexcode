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
private class onLizenzTest {

    static testMethod void myUnitTest() {
    	    Medienart__c medien = new Medienart__c(Name='55');
    	    insert medien;
    	    
    	    list<Product2> ProdList = new list<Product2>();
    	    Product2 product;
    	    for(Integer i=0;i<100;i++) {
    	    	   product = new Product2(TITL01__c='test', MEDA01__c=medien.Id, ProductCode='0',RECH01__c='0', Name='test');
    	    	   ProdList.add(product);
    	    }
    	    insert ProdList; 
    	    
    	    list<Lizenz__c> lizenzList = new list<Lizenz__c>();
    	    Lizenz__c lizenz;
    	    for(Integer i=0;i<10;i++) {
          	  lizenz = new Lizenz__c(MED017__c=medien.Id, VPR015__c=100);
          	  lizenzList.add(lizenz);
    	    }
          insert lizenzList;
          update lizenzlist;
    }
}