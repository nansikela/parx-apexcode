public class Education_afterInsertUpdateTEST{

    static testMethod void educationTestMethodApplication(){
    	String RT_EDUCATION_LANGUAGE_QUALIFICATION = '01220000000HF0aAAG';
    	String RT_EDUCATION_SCHOOL_QUALIFICATION = '01220000000HEvBAAW';
    	String FRENCH = 'French';
		String ENGLISH = 'English';
    	try{
	    	Account a = new Account();
	    	a.Name = 'Test AG';
	    	insert a;
	    	
	    	List<Contact> cList = new List<Contact>();
	    	Contact c = new Contact();
	    	c.Firstname = 'parx';
	    	c.Lastname = 'Muster';
	    	c.AccountId = a.Id;
	    	cList.add(c);
	    	
	    	Contact c2 = new Contact();
	    	c2.Firstname = 'parx2';
	    	c2.Lastname = 'Muster2';
	    	c2.AccountId = a.Id;
	    	cList.add(c2);
	    	
	    	Contact c3 = new Contact();
	    	c3.Firstname = 'parx3';
	    	c3.Lastname = 'Muster3';
	    	c3.AccountId = a.Id;
	    	cList.add(c3);
	    	
	    	Contact c4 = new Contact();
	    	c4.Firstname = 'parx4';
	    	c4.Lastname = 'Muster4';
	    	c4.AccountId = a.Id;
	    	cList.add(c4);
	    
	    	
	    	insert cList;
	    	
	    	List<Application__c> aList = new List<Application__c>();
	    	
	    	Application__c app = new Application__c();
	    	app.Student__c = c.Id;
	    	aList.add(app);
	    	
	    	Application__c app2 = new Application__c();
	    	app2.Student__c = c2.Id;
	    	aList.add(app2);
	    	
	    	Application__c app3 = new Application__c();
	    	app3.Student__c = c3.Id;
	    	aList.add(app3);
	    	
	    	Application__c app4 = new Application__c();
	    	app4.Student__c = c4.Id;
	    	aList.add(app4);
	    	
	    	
			insert aList;
	    	
	    	List<Education__c> edList = new List<Education__c>();
	    	
	    	//*****************   nothing should happen, school qualifaction
	    	Education__c e1 = new Education__c();
	    	e1.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e1.Date_of_Test__c = Date.Today() - 100;
	    	e1.Student__c = c.Id;
	    	edList.add(e1);
	    	
	    	Education__c e2 = new Education__c();
	    	e2.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e2.Student__c = c.Id;
	    	e2.Date_of_Test__c = Date.Today() - 250;
	    	edList.add(e2);
	    	
	    	insert edList;
	    	
	    	//check
	    	List<Application__c> appList = [Select a.Score__c, a.English_Qualification__c, a.Student__c From Application__c a where a.Id = :app.Id];
	    	if(appList.isEmpty()){
	    		System.assert(false);
	    	}else{
	    		System.assertEquals(appList[0].Score__c, null);
	    		System.assertEquals(appList[0].English_Qualification__c, null);
	    	}
	    	
	    	//*****************   should update record
	    	Education__c e3 = new Education__c();
	    	e3.RecordTypeId = RT_EDUCATION_LANGUAGE_QUALIFICATION;
	    	e3.Student__c = c.Id;
	    	e3.Language__c = ENGLISH;
	    	e3.Qualification__c = 'TOEFL - paper based';
	    	e3.Date_of_Test__c = Date.Today() - 20;
	    	e3.Test_Score__c = '420';
	    	insert e3;
	    	
	    	//check
	    	appList = [Select a.Score__c, a.English_Qualification__c, a.Student__c From Application__c a where a.Id = :app.Id];
	    	if(appList.isEmpty()){
	    		System.assert(false);
	    	}else{
	    		System.assertEquals(appList[0].Score__c, '420');
	    		System.assertEquals(appList[0].English_Qualification__c, 'TOEFL - paper based');
	    	}
	    	
	    	//delete education, check if data in application also deleted
	    	delete e3;
	    	appList = [Select a.Score__c, a.English_Qualification__c, a.Student__c From Application__c a where a.Id = :app.Id];
	    	if(appList.isEmpty()){
	    		System.assert(false);
	    	}else{
	    		System.assertEquals(appList[0].Score__c, null);
	    		System.assertEquals(appList[0].English_Qualification__c, null);
	    	}
	    	
	    	//*****************   should not update record, language is french
	    	Education__c e5 = new Education__c();
	    	e5.RecordTypeId = RT_EDUCATION_LANGUAGE_QUALIFICATION;
	    	e5.Student__c = c3.Id;
	    	e5.Language__c = FRENCH;
	    	e5.Qualification__c = 'DELF Unité A1';
	    	e5.Date_of_Test__c = Date.Today() - 100;
	    	e5.Test_Score__c = '2';
	    	insert e5;
	    	
	    	//check
	    	appList = [Select a.Score__c, a.English_Qualification__c, a.Student__c From Application__c a where a.Id = :app3.Id];
	    	if(appList.isEmpty()){
	    		System.assert(false);
	    	}else{
	    		System.assertEquals(appList[0].Score__c, null);
	    		System.assertEquals(appList[0].English_Qualification__c, null);
	    	}
	    	
			//delete education
	    	delete e5;
	    	appList = [Select a.Score__c, a.English_Qualification__c, a.Student__c From Application__c a where a.Id = :app3.Id];
	    	if(appList.isEmpty()){
	    		System.assert(false);
	    	}else{
	    		System.assertEquals(appList[0].Score__c, null);
	    		System.assertEquals(appList[0].English_Qualification__c, null);
	    	}
    	}catch(System.Exception e){
			System.debug('**** Exception occured: ' + e);
			System.assertEquals(e.getMessage(), 'x');
			System.assert(false);
		}
    }
    
    
    static testMethod void educationTestMethodContact(){
    	String RT_EDUCATION_LANGUAGE_QUALIFICATION = '01220000000HF0aAAG';
    	String RT_EDUCATION_SCHOOL_QUALIFICATION = '01220000000HEvBAAW';
    	String FRENCH = 'French';
		String ENGLISH = 'English';
		String SECSCHOOL = 'Secondary School';
		
    	try{
	    	Account a = new Account();
	    	a.Name = 'Test AG';
	    	insert a;
	    	
	    	List<Contact> cList = new List<Contact>();
	    	Contact c = new Contact();
	    	c.Firstname = 'parx ag';
	    	c.Lastname = 'Muster';
	    	c.AccountId = a.Id;
	    	cList.add(c);
	    	
	    	Contact c2 = new Contact();
	    	c2.Firstname = 'parx2 ag';
	    	c2.Lastname = 'Muster2';
	    	c2.AccountId = a.Id;
	    	cList.add(c2);
	    	
	    	Contact c3 = new Contact();
	    	c3.Firstname = 'parx3 ag';
	    	c3.Lastname = 'Muster3';
	    	c3.AccountId = a.Id;
	    	cList.add(c3);
	    
	    	Contact c4 = new Contact();
	    	c4.Firstname = 'parx4 ag';
	    	c4.Lastname = 'Muster3';
	    	c4.AccountId = a.Id;
	    	cList.add(c4);
	    	
	    	insert cList;
	    	    	  
	    	
	    	List<Education__c> edList = new List<Education__c>();
	    	
	    	//*****************   nothing should happen, not secondary school
	    	Education__c e1 = new Education__c();
	    	e1.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e1.Student__c = c.Id;
	    	e1.Date_of_Test__c = Date.Today() - 100;
	    	insert e1;
	    	
	    	//check
	    	cList = [Select c.SIUS_Locality__c from Contact c where c.Id = :c.Id];
	    	if(cList.isEmpty()){
	    		System.assert(false);
	    	}else{
	    		System.assertEquals(cList[0].SIUS_Locality__c, null);
	    	}
	    	
	    	
	    	//*****************   should update contact
	    	Education__c e2 = new Education__c();
	    	e2.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e2.Education__c = SECSCHOOL;
	    	e2.Diploma_Date__c = Date.today();
	    	e2.Country_of_residence__c  = 'SWITZERLAND'; //used for sius
	    	e2.City_of_residence__c = 'xx'; //used for sius
	    	e2.State_Canton_of_residence__c = 'ee'; //used for sius --> xx (ee)
	    	e2.SIUS_Locality__c = 'xx (ee)';
	    	e2.Student__c = c2.Id;
	    	e2.Date_of_Test__c = Date.Today() - 256;
	    	insert e2;
	    	
	    	//check
	    	cList = [Select c.SIUS_Locality__c from Contact c where c.Id = :c2.Id];
	    	if(cList.isEmpty()){
	    		System.assert(false);
	    	}else{
	    		System.assertEquals(cList[0].SIUS_Locality__c, 'xx (ee)');
	    	}
	    	
	    	//delete education, check if data in contact also deleted
	    	delete e2;
	    	cList = [Select c.SIUS_Locality__c from Contact c where c.Id = :c2.Id];
	    	System.assertEquals(cList[0].SIUS_Locality__c, null);
	    	
	    	
	    	
	    	//*****************   should not update date is missing
	    	Education__c e3 = new Education__c();
	    	e3.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e3.Education__c = SECSCHOOL;
	    	e3.Country_of_residence__c  = 'SWITZERLAND';
	    	e3.Student__c = c3.Id;
	    	insert e3;
	    	
	    	//check
	    	cList = [Select c.SIUS_Locality__c from Contact c where c.Id = :c3.Id];
	    	if(cList.isEmpty()){
	    		System.assert(false);
	    	}else{
	    		System.assertEquals(cList[0].SIUS_Locality__c, null);
	    	}
	    	
	    	
	    	//*****************   should update
	    	Education__c e4 = new Education__c();
	    	e4.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e4.Education__c = SECSCHOOL;
	    	e4.Country_of_residence__c  = 'SWITZERLAND';
	    	e4.City_of_residence__c = 'tt'; //used for sius
	    	e4.State_Canton_of_residence__c = 'zz'; //used for sius --> xx (ee)
	    	e4.SIUS_Locality__c = 'tt (zz)';
	    	e4.Date_of_Test__c = Date.Today() - 256;
	    	e4.Diploma_Date__c = Date.today();
	    	e4.Student__c = c4.Id;
	    	insert e4;
	    	
	        	
	    	//check
	    	cList = [Select c.SIUS_Locality__c from Contact c where c.Id = :c4.Id];
	    	if(cList.isEmpty()){
	    		System.assert(false);
	    	}else{
	    		System.assertEquals(cList[0].SIUS_Locality__c, 'tt (zz)');
	    	}
	    	
	    	//delete Diploma_Date__c, should also delete sius on contact
	    	e4.Diploma_Date__c = null;
	    	update e4;
	    	cList = [Select c.SIUS_Locality__c from Contact c where c.Id = :c4.Id];
	    	System.assertEquals(cList[0].SIUS_Locality__c, null);
	    	
    	}catch(System.Exception e){
			System.debug('**** Exception occured: ' + e);
			System.assertEquals(e.getMessage(), 'x');
			System.assert(false);
		}
    }
    
    
    
    static testMethod void educationTestMethodApplicationDiploma(){
    	String RT_EDUCATION_LANGUAGE_QUALIFICATION = '01220000000HF0aAAG';
    	String RT_EDUCATION_SCHOOL_QUALIFICATION = '01220000000HEvBAAW';
    	String RT_DIPLOMA = '012200000005Es9AAE';
    	String FRENCH = 'French';
		String ENGLISH = 'English';
		String SECSCHOOL = 'Secondary School';
		
    	try{
    		Reference_Data__c diploma1 = new Reference_Data__c();
    		diploma1.RecordTypeId = RT_DIPLOMA;
    		diploma1.Diploma_Name_English__c = 'Dip Eng';
    		diploma1.Diploma_Name_Francais__c = 'Dip Fr';
    		diploma1.Country_Francais_Diploma_Bible__c = 'test';
    		diploma1.Country_English_Diploma_Bible__c = 'test en';
    		insert diploma1;
    		
	    	Account a = new Account();
	    	a.Name = 'Test AG 2';
	    	insert a;
	    	
	    	List<Contact> cList = new List<Contact>();
	    	Contact c = new Contact();
	    	c.Firstname = 'parx ag 2';
	    	c.Lastname = 'Muster 2';
	    	c.AccountId = a.Id;
	    	cList.add(c);
	    	
	    	Contact c2 = new Contact();
	    	c2.Firstname = 'parx2 ag 2';
	    	c2.Lastname = 'Muster2 2';
	    	c2.AccountId = a.Id;
	    	cList.add(c2);
	    	
	    	Contact c3 = new Contact();
	    	c3.Firstname = 'parx3 ag 2';
	    	c3.Lastname = 'Muster3 2';
	    	c3.AccountId = a.Id;
	    	cList.add(c3);
	    	
	    	insert cList;
	    	
	    	Account school = new Account();
	    	school.Name = 'School AG';
	    	insert school;
	    	
	    	List<Application__c> aList = new List<Application__c>();
	    	
	    	Application__c app = new Application__c();
	    	app.Student__c = c.Id;
	    	aList.add(app);
	    	
	    	Application__c app2 = new Application__c();
	    	app2.Student__c = c2.Id;
	    	aList.add(app2);
	    	
	    	Application__c app3 = new Application__c();
	    	app3.Student__c = c3.Id;
	    	aList.add(app3);

			insert aList;
	    	
	    	List<Education__c> edList = new List<Education__c>();
	    	
	    	//*****************   nothing should happen, not secondary school
	    	Education__c e1 = new Education__c();
	    	e1.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e1.Student__c = c.Id;
	    	e1.Diploma_Date__c = Date.today();
	    	e1.Diploma_Name__c = diploma1.Id;
	    	e1.Date_of_Test__c = Date.Today() - 100;
	    	e1.School_Name__c = school.Id;
	    	insert e1;
	    	
	    	//check
	    	List<Application__c> appList = [Select a.Secondary_School__c, a.Secondary_Diploma__c From Application__c a where a.Id = :app.Id];
	    	System.assertEquals(appList[0].Secondary_Diploma__c, null);
	    	System.assertEquals(appList[0].Secondary_School__c, null);
	    	
	    	//*****************   should update application diploma
	    	e1.Education__c = SECSCHOOL;
	    	update e1;
	    	appList = [Select a.Secondary_School__c, a.Secondary_Diploma__c From Application__c a where a.Id = :app.Id];
	    	System.assertEquals(appList[0].Secondary_Diploma__c, diploma1.Id);
	    	System.assertEquals(appList[0].Secondary_School__c, school.Id);
	    	
	    	//delete education, should also delete information in application
	    	delete e1;
	    	appList = [Select a.Secondary_School__c, a.Secondary_Diploma__c From Application__c a where a.Id = :app.Id];
	    	System.assertEquals(appList[0].Secondary_Diploma__c, null);
	    	System.assertEquals(appList[0].Secondary_School__c, null);
	    	
	    	//*****************   should update application diploma
	    	Education__c e2 = new Education__c();
	    	e2.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e2.Education__c = SECSCHOOL;
	    	e2.Diploma_Date__c = Date.today();
	    	e2.Diploma_Name__c = diploma1.Id;
	    	e2.Country_of_residence__c  = 'SWITZERLAND';
	    	e2.Student__c = c2.Id;
	    	e2.Date_of_Test__c = Date.Today() - 256;
	    	e2.School_Name__c = school.Id;
	    	insert e2;
	    	
	    	//check
	    	appList = [Select a.Secondary_School__c, a.Secondary_Diploma__c From Application__c a where a.Id = :app2.Id];
	    	System.assertEquals(appList[0].Secondary_Diploma__c, diploma1.Id);
	    	System.assertEquals(appList[0].Secondary_School__c, school.Id);
	    	
	    	//delete education, should also delete information in application
	    	delete e2;
	    	appList = [Select a.Secondary_School__c, a.Secondary_Diploma__c From Application__c a where a.Id = :app2.Id];
	    	System.assertEquals(appList[0].Secondary_Diploma__c, null);
	    	System.assertEquals(appList[0].Secondary_School__c, null);
	    	
	    	//*****************   should not update date is missing
	    	Education__c e3 = new Education__c();
	    	e3.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e3.Education__c = SECSCHOOL;
	    	e3.Country_of_residence__c  = 'SWITZERLAND';
	    	e2.Diploma_Name__c = diploma1.Id;
	    	e3.Student__c = c3.Id;
	    	e3.School_Name__c = school.Id;
	    	insert e3;
	    	
	    	//check
	    	appList = [Select a.Secondary_School__c,  a.Secondary_Diploma__c From Application__c a where a.Id = :app3.Id];
	    	System.assertEquals(appList[0].Secondary_Diploma__c, null);
	    	System.assertEquals(appList[0].Secondary_School__c, null);
	    	
	    	//delete education
	    	delete e3;
	    	appList = [Select a.Secondary_School__c, a.Secondary_Diploma__c From Application__c a where a.Id = :app3.Id];
	    	System.assertEquals(appList[0].Secondary_Diploma__c, null);
	    	System.assertEquals(appList[0].Secondary_School__c, null);
	    	
    	}catch(System.Exception e){
			System.debug('**** Exception occured: ' + e);
			System.assertEquals(e.getMessage(), 'x');
			System.assert(false);
		}
    }
    
    
    
    static testMethod void educationTestMethodApplicationOwnership(){
    	String RT_EDUCATION_LANGUAGE_QUALIFICATION = '01220000000HF0aAAG';
    	String RT_EDUCATION_SCHOOL_QUALIFICATION = '01220000000HEvBAAW';
    	String RT_DIPLOMA = '012200000005Es9AAE';
    	String FRENCH = 'French';
		String ENGLISH = 'English';
		String SECSCHOOL = 'Secondary School';
		
		
		String CANTON = 'AG';
		String OWNER1 = '005200000015Gim'; //Carvi Stucki-Wick
		
		
		String COUNTRY = 'INDIA';
		String OWNER2 = '005200000015Giw'; //Ikerne Azpilicueta
		
    	try{
    		Reference_Data__c diploma1 = new Reference_Data__c();
    		diploma1.RecordTypeId = RT_DIPLOMA;
    		diploma1.Diploma_Name_English__c = 'Dip Eng';
    		diploma1.Diploma_Name_Francais__c = 'Dip Fr';
    		diploma1.Country_Francais_Diploma_Bible__c = 'test';
    		diploma1.Country_English_Diploma_Bible__c = 'test en';
    		insert diploma1;
    		
	    	Account a = new Account();
	    	a.Name = 'Test AG 2';
	    	insert a;
	    	
	    	List<Contact> cList = new List<Contact>();
	    	Contact c = new Contact();
	    	c.Firstname = 'parx ag 2';
	    	c.Lastname = 'Muster 2';
	    	c.AccountId = a.Id;
	    	cList.add(c);
	    	
	    	Contact c2 = new Contact();
	    	c2.Firstname = 'parx2 ag 2';
	    	c2.Lastname = 'Muster2 2';
	    	c2.AccountId = a.Id;
	    	cList.add(c2);
	    	
	    	Contact c3 = new Contact();
	    	c3.Firstname = 'parx3 ag 2';
	    	c3.Lastname = 'Muster3 2';
	    	c3.AccountId = a.Id;
	    	cList.add(c3);
	    	
	    	insert cList;
	    	
	    	Account school = new Account();
	    	school.Name = 'School AG';
	    	insert school;
	    	
	    	List<Application__c> aList = new List<Application__c>();
	    	
	    	Application__c app = new Application__c();
	    	app.Student__c = c.Id;
	    	aList.add(app);
	    	
	    	Application__c app2 = new Application__c();
	    	app2.Student__c = c2.Id;
	    	aList.add(app2);
	    	
	    	Application__c app3 = new Application__c();
	    	app3.Student__c = c3.Id;
	    	aList.add(app3);

			insert aList;
	    	
	    	List<Education__c> edList = new List<Education__c>();
	    	
	    	//*****************  should update application owner based on canton
	    	Education__c e1 = new Education__c();
	    	e1.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e1.Education__c = SECSCHOOL;
	    	e1.Student__c = c.Id;
	    	e1.Diploma_Date__c = Date.today();
	    	e1.Diploma_Name__c = diploma1.Id;
	    	e1.Date_of_Test__c = Date.Today() - 100;
	    	e1.School_Name__c = school.Id;
	    	e1.Country_of_residence__c = 'SWITZERLAND';
	    	e1.City_of_residence__c = 'Aarau';
	    	e1.State_Canton_of_residence__c = CANTON;
	    	insert e1;
	    	
	    	//check that stucki is owner of application
	    	Application__c appToTest = [Select a.OwnerId, a.changedOwner__c From Application__c a where a.Id = :app.Id];
	    	System.assertEquals(appToTest.OwnerId, OWNER1);
	    	System.assert(appToTest.changedOwner__c);
	    	
	    	
	    	//*****************   should update application owner based on country
	    	Education__c e2 = new Education__c();
	    	e2.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e2.Education__c = SECSCHOOL;
	    	e2.Diploma_Date__c = Date.today();
	    	e2.Diploma_Name__c = diploma1.Id;
	    	e2.Country_of_residence__c  = COUNTRY;
	    	e2.Student__c = c2.Id;
	    	e2.Date_of_Test__c = Date.Today() - 256;
	    	e2.School_Name__c = school.Id;
	    	insert e2;
	    	
	    	//check
	    	appToTest = [Select a.OwnerId, a.changedOwner__c From Application__c a where a.Id = :app2.Id];
	    	System.assertEquals(appToTest.OwnerId, OWNER2);
	    	System.assert(appToTest.changedOwner__c);
	    	
	    	
	    	//*****************   no sius code, nothing should happen
	    	Education__c e3 = new Education__c();
	    	e3.RecordTypeId = RT_EDUCATION_SCHOOL_QUALIFICATION;
	    	e3.Education__c = SECSCHOOL;
	    	e3.Diploma_Date__c = Date.today();
	    	e3.Diploma_Name__c = diploma1.Id;
	    	e3.Student__c = c3.Id;
	    	e3.Date_of_Test__c = Date.Today() - 256;
	    	e3.School_Name__c = school.Id;
	    	insert e3;
	    	
	    	//check
	    	appToTest = [Select a.OwnerId, a.changedOwner__c From Application__c a where a.Id = :app3.Id];
	    	System.assertNotEquals(appToTest.OwnerId, OWNER2);
	    	System.assert(!appToTest.changedOwner__c);
	    	
	    	
	    	//*****************  update country, should update ownership    	
	    	e3.Country_of_residence__c  = COUNTRY;	    	
	    	update e3;
	    	
	    	//check
	    	appToTest = [Select a.OwnerId, a.changedOwner__c From Application__c a where a.Id = :app3.Id];
	    	System.assertEquals(appToTest.OwnerId, OWNER2);
	    	System.assert(appToTest.changedOwner__c);
	    	
    	}catch(System.Exception e){
			System.debug('**** Exception occured: ' + e);
			System.assertEquals(e.getMessage(), 'x');
			System.assert(false);
		}
    }
}