/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class Selection_beforeInsertUpdateTEST
{

    static testMethod void myUnitTest()
    {
    	// create (or fetch) base objects used for testing
    	User owner = [Select Id, Name From User Where IsActive = true Limit 1];
    	
        Contact student1 = new Contact(Firstname = 'Test', Lastname = 'Moser',
        	OwnerId = owner.Id,
        	Gender__c = 'Male',
        	Preferred_Language__c = 'English',
        	Email_Private__c = 'test.moser@host.com'
        );
        insert student1;
        System.debug(student1);
        
        Contact student2 = new Contact(Firstname = 'Lucy', Lastname = 'Moser',
        	OwnerId = owner.Id,
        	Gender__c = 'Female',
        	Preferred_Language__c = 'English',
        	Email_Private__c = 'lucy.moser@host.com'
        );
        insert student2;
        
        Application__c app = new Application__c(
        	OwnerId = owner.Id
        );
        insert app;
        
        
        // TEST: plain selection shall not have any relation
        Selection__c sel1 = new Selection__c();
        insert sel1;
        
        Selection__c iSel1 = [Select Id, Student__c, Application__c From Selection__c Where Id = :sel1.Id Limit 1];
        System.assertEquals(iSel1.Student__c, null, 'Student not null allthough there is no application related');
        
        
        // TEST: upatte selection (link to an application w/o student)
        sel1.Application__c = app.Id;
        update sel1;
        
        iSel1 = [Select Id, Student__c, Application__c From Selection__c Where Id = :sel1.Id Limit 1];
        System.assertEquals(iSel1.Student__c, null, 'Student not null allthough the realted application has no student');
        
        
        // TEST: insert a selection with relation to an application w/o student
        Selection__c sel2 = new Selection__c(Application__c = app.Id);
        insert sel2;
        
        Selection__c iSel2 = [Select Id, Student__c, Application__c From Selection__c Where Id = :sel2.Id Limit 1];
        System.assertEquals(iSel2.Student__c, null, 'Student not null allthough the realted application has no student');
        
        
        // TEST: update application link to student (should update selection)
        app.Student__c = student1.Id;
        update app;
        
        iSel1 = [Select Id, Student__c, Application__c From Selection__c Where Id = :sel1.Id Limit 1];
        System.assertEquals(iSel1.Student__c, student1.Id, 'Student not equal to student on the related application after application update');
        
        
        // TEST: insert a seletion with realtion to an application with student
        Selection__c sel3 = new Selection__c(Application__c = app.Id);
        insert sel3;
        Selection__c iSel3 = [Select Id, Student__c, Application__c From Selection__c Where Id = :sel3.Id Limit 1];
        System.assertEquals(iSel3.Student__c, student1.Id, 'Student not equal to student on the related application after selection insert');
        
        
        // TEST: update application (change student), this should update the selection as well
        app.Student__c = student2.Id;
        update app;
        iSel1 = [Select Id, Student__c, Application__c From Selection__c Where Id = :sel1.Id Limit 1];
        System.assertEquals(iSel1.Student__c, student2.Id, 'Student not equal to student on the related application after application update');
        
    }
}