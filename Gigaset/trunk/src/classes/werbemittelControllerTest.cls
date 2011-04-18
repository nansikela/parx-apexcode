@isTest
private class werbemittelControllerTest {

    static testMethod void myUnitTest1() {
    	testData.initData mytestData = new testData.initData('de',false);
    	testData.werbemittelData wmData = new testData.werbemittelData('de',false);
    	
        werbemittelController ctrl = new werbemittelController();
        
        userdataController uCtrl = ctrl.getctrl();
        uCtrl = new userdataController();
        System.debug(uCtrl.u.Id);
        
        for(Contact c : [SELECT Id, AccountId FROM Contact WHERE  id =: uCtrl.u.ContactId])
        	uCtrl.c = c;
        	
        ctrl.firstPage();
        ctrl.secondPage(); //For else Case
        
        werbemittelController.myterm t = new werbemittelController.myterm();
        t.quantity = '011';
        insert t.term;
        ctrl.setTerms(t);
        ctrl.setTerms2(t);
        
        ctrl.secondPage(); //For if Case
        ctrl.thirdPage();
        
        ctrl.setbestellungTemp();
        ctrl.getbestellungTemp();
        
        ctrl.getTerms();
        ctrl.getTerms2();
    }
    
    static testMethod void myUnitTest2() {
    	testData.initData mytestData = new testData.initData('de',false);
        testData.werbemittelData wmData = new testData.werbemittelData('de',false);
        
        System.runAs(mytestData.testuser) {
        werbemittelController ctrl = new werbemittelController();
        
        userdataController uCtrl = ctrl.getctrl();
        uCtrl = new userdataController();
        System.debug(uCtrl.u.Id);
        
        for(Contact c : [SELECT Id, AccountId FROM Contact WHERE  id =: uCtrl.u.ContactId])
        	uCtrl.c = c;
        	
        ctrl.firstPage();
        ctrl.secondPage(); //For else Case
        
        werbemittelController.myterm t = new werbemittelController.myterm();
        t.quantity = '011';
        insert t.term;
        ctrl.setTerms(t);
        ctrl.setTerms2(t);
        
        ctrl.secondPage(); //For if Case
        ctrl.thirdPage();
        
        ctrl.setbestellungTemp();
        ctrl.getbestellungTemp();
        
        ctrl.getTerms();
        ctrl.getTerms2();
        }
    }
}