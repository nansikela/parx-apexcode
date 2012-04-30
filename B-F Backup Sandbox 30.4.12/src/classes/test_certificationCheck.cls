/**********************************************************************************
* Class Name  : test_certificationCheck
* Description : This test class is to cover certificationCheck class
*
*    
* Modification Log :  
* ----------------------------------------------------------------------------------
* Developer                                 Date             Description
* ----------------------------------------------------------------------------------
* Fayas Mansoor(Deloitte Consulting)      28/05/2011          Created
************************************************************************************/

@isTest
Private class test_certificationCheck
{
    static testMethod void classTest(){
        // test data preparation
        SOD__c testData=new SOD__c();
        testData.Certified_Complete__c='No';
        testData.Compliance_Method__c='Included';
        testData.UniqueID__c='asdasdqwe123123';
        //inserting testdata 
        Database.insert(testData);
        
        Test.starttest();
        certificationCheck.checkCertification(testData.id);
        Test.stoptest();
        
    }
}