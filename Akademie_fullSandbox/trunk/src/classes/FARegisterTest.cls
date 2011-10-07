@isTest


private class FARegisterTest {
	static String token;	
    static testMethod void testStep1() 
    {
        FARegisterController controller = new FARegisterController();
        controller.person.Anrede__c = 'Herr';
        controller.person.Vorname__c = 'Vorname';
        controller.person.Name = 'NACHNAME';
        controller.person.Nachgeordnete_Firma__c = 'a0g20000000Hy2s';
        controller.person.Telefon__c = '0763486789';
        controller.person.Email__c = 'sfpiufgsdjijp@iroghhgrfhrfgf.de';
        String url = String.valueOf(controller.toStep2());
        //token = url.substring(url.length()-19, url.length());
        System.debug('*********TOKEN:'+token);
    }
    
     static testMethod void testStep2() 
     {
     	System.debug('*************TOKEN:'+token);
     	ApexPages.currentPage().getParameters().put('token', token);
     	FARegisterControllerStep2 controller = new FARegisterControllerStep2();
     	controller.password = 'Computer123';
     	controller.passwordConfirm = 'Computer123';
     	/*String url = String.valueOf(controller.toStep3());
     	token = url.substring(url.length()-19, url.length());*/
     }
}