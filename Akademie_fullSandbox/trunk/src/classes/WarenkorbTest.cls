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
private class WarenkorbTest {

    static testMethod void myUnitTest() {
    	Person__c p = [SELECT id, Benutzer__r.id FROM Person__c WHERE Benutzer__c <>'' LIMIT 1];
		
		System.runAs(p.Benutzer__r){
        Seminar_to_Portfolio__c portfolio = [SELECT ID, portfolio__c FROM Seminar_to_Portfolio__c  LIMIT 1];
    	ApexPages.currentPage().getParameters().put('portfolioId', portfolio.portfolio__c);
        /*SIM STEP 1*/
        WarenkorbFacade controller = new WarenkorbFacade();
        controller.getPortfolioInformation();
        List<SelectOption> selectOptionList = controller.getTerminOptionList();
        SelectOption selectOption = selectOptionList.get(0);
        controller.terminString = selectOption.getValue();
        controller.toStep2();
        
        /*SIM STEP 2*/
        
        ApexPages.currentPage().getParameters().put('seminar', controller.terminString);
        controller = new WarenkorbFacade();
        controller.getcurrentWarenkorbElement();
        controller.putItemToWarenkorb();
        
        /*SIM Delete ELEMENT */
        List<FASeminar> seminarList = controller.getWarenkorbInhalt();
        FASeminar seminar = seminarList.get(0);
        ApexPages.currentPage().getParameters().put('id', seminar.id);
        
        
        /*Sim Step 3 */
         controller = new WarenkorbFacade();
         controller.getWarenkorbInhalt();
         controller.finishWarenkorb();
		}
		
    }
}