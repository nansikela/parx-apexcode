trigger Enrollment_beforeInsertUpdate on Enrollment__c (before insert, before update) {
//Select a.Student__r.Student_Name__c, a.Student__r.FirstName, a.Student__r.LastName, a.Student__c, a.Id From Application__c a



/*
Felder:
Contact --> Enrollment
Student_Name__c --> Student_First_Name__c
Last Name --> Student_Last_Name__c
First Name & Last Name --> Student_Name__c
*/


	Set<Id> applicationIds = new Set<Id>();
	  
    for (Enrollment__c new_Enrollment : Trigger.new) {
        applicationIds.add(new_Enrollment.Application__c);   
    }    

	Map<Id, Application__c> applicationMap = new Map<Id, Application__c>([Select a.Student__r.Student_Name__c, a.Student__r.FirstName, a.Student__r.LastName, a.Student__c, a.Id From Application__c a where a.Id IN :applicationIds ]);        
		
	Application__c application;
	for (Enrollment__c new_Enrollment : Trigger.new) {
		application = applicationMap.get(new_Enrollment.Application__c);
		if (application != null && application.Student__c != null) {
			new_Enrollment.Student_First_Name__c = application.Student__r.Student_Name__c; 
			new_Enrollment.Student_Last_Name__c = application.Student__r.LastName; 
			new_Enrollment.Student_Name__c = application.Student__r.FirstName + ' ' + application.Student__r.LastName; 
		}
    } 
}