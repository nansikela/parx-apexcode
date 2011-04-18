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
private class DownloadTest {

    static testMethod void testDownload() {
    	testData.initData mytestData = new testData.initData('de',false);
    	Campaign campaign = new Campaign();
    	campaign.RecordTypeId=[SELECT id FROM RecordType WHERE Name='Top Shop' AND SObjectType='Campaign' limit 1].id;
    	campaign.Portal__c='de';
    	campaign.IsActive=true;
    	campaign.isPro__c=false;
    	campaign.Name='ParxTest';
    	insert campaign;
    	/*
    	Attachment att=new Attachment();
	 		att.Name='test';
	 		att.Description='test';
	 		att.Parentid=mytestData.Contacts.get(0).id;
	 		att.Body=Blob.valueOf('test');
	 		att.Ownerid=mytestData.testuser.id;
	 		insert att;
	 		*/
		
	 	System.runAs(mytestData.testuser) {
			Download ctrl = new Download();
			//ctrl.Del();
			ctrl.toUpdatePage();
			ctrl.goHome();
			ctrl.lockGame();
			ctrl.UpdateStatus();
			ctrl.upload();
			Download.myterm trm= new Download.myterm();
			
			NextTopShop__c nts = ctrl.Art;
			boolean x = ctrl.showUpdatePage;
			x = ctrl.showThirdPage;
			x = ctrl.Table;
			x = ctrl.ShowButtons;
	//		x = ctrl.ShowButtonsAndLinks;
			Attachment a = ctrl.document;
			
			a.Name='test';
			NextTopShop__c acc=new NextTopShop__c();
			insert acc;
			a.ParentId=acc.Id;
			a.Body=Blob.valueOf('XXX');
			insert a;
			ApexPages.currentPage().getParameters().put('docId',a.id);
			ctrl.Del();
			ctrl.toUpdatePage();
			ctrl.goHome();
			ctrl.lockGame();
			ctrl.UpdateStatus();
			ctrl.upload();
	 	}
	}
	
	 static testMethod void testDownload2() {
    	testData.initData mytestData = new testData.initData('de',false);
    	Attachment att=new Attachment();
	 		att.Name='test';
	 		att.Description='test';
	 		att.Parentid=mytestData.Contacts.get(0).id;
	 		att.Body=Blob.valueOf('test');
	 		att.Ownerid=mytestData.testuser.id;
	 		insert att;
		
	 	
			Download ctrl = new Download();
			//ctrl.Del();
			ctrl.toUpdatePage();
			ctrl.goHome();
			ctrl.lockGame();
			ctrl.UpdateStatus();
			ctrl.upload();
			Download.myterm trm= new Download.myterm();
			
			NextTopShop__c nts = ctrl.Art;
			boolean x = ctrl.showUpdatePage;
			x = ctrl.showThirdPage;
			x = ctrl.Table;
			x = ctrl.ShowButtons;
	//		x = ctrl.ShowButtonsAndLinks;
			Attachment a = ctrl.document;
			
			a.Name='test';
			NextTopShop__c acc=new NextTopShop__c();
			insert acc;
			a.ParentId=acc.Id;
			a.Body=Blob.valueOf('XXX');
			insert a;
			ApexPages.currentPage().getParameters().put('docId',a.id);
			ctrl.Del();
	 	
	}
}