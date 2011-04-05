@isTest
private class cloneWerbemittelBestellungTest {

    static testMethod void myUnitTest() {
    	Werbemittel_Bestellung__c wb = new Werbemittel_Bestellung__c();
    	
    	insert wb;
        cloneWerbemittelBestellung ctrl = new cloneWerbemittelBestellung(new ApexPages.Standardcontroller(wb));
  
        ctrl.redirect();
        ctrl.back();
    }
}