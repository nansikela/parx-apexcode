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
private class onProduktionsstandHelperTest {

    static testMethod void DatumNeuproduktionTest() {
    	Medienart__c ma=new Medienart__c(Name='00');
    	insert ma;
        Product2 p=new Product2(Name='test');
        p.PDKZ01__c=0;
        p.MEDA01__c=ma.id;
        p.IsActive=true;
        insert p;
        p.PDKZ01__c=2;
        p.Aenderung_Produktionsstufe__c=System.today()-5;
        update p;
        p.PDKZ01__c=4;
        p.Aenderung_Produktionsstufe__c=System.today();
        update p;
        Produktionsstand__c ps=new Produktionsstand__c(Status__c='05',Datum__c=System.today(),Artikel__c=p.id);
        insert ps;
        p=[SELECT Id, Datum_Neuproduktion__c FROM Product2 WHERE Id=:p.id];
        System.assertEquals(System.today(),p.Datum_Neuproduktion__c);
    }
}