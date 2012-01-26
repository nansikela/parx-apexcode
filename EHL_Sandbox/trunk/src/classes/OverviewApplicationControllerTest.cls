public class OverviewApplicationControllerTest {
	public static Id idRTeducationSQ, idRTeducationLQ, idRTeducationTS, idRTAddress_CPA,
				idRTadditionalIE, idRTadditionalM, idRTpe_WE, idRTpe_ECK, idRTDiploma, idRToppDiplom;
				
	static testMethod void testController(){
		setRecordType();
		Account oSchool = new Account(Name='Erster Account');
		insert oSchool;
		Contact oStudent = new Contact(LastName='Gibt es nicht', AccountId=oSchool.Id);
		insert oStudent;
		Address__c oSchoolAddress = new Address__c(RecordTypeId=idRTAddress_CPA, Contact__c=oStudent.Id); 
		insert oSchoolAddress;
		Reference_Data__c oDiplom = new Reference_Data__c(RecordTypeId=idRTDiploma, Name='Parx Diploma Kaffee Kochen');
		insert oDiplom;
		Opportunity oOpportunity = new Opportunity(RecordTypeId=idRToppDiplom, Name='Ausweg XYZ', AccountId=oSchool.Id, Contact_Student__c=oStudent.Id,
													StageName='First Evaluation', CloseDate=date.today());
		insert oOpportunity;
		Application__c oApplication = new Application__c(Student__c=oStudent.Id, Opportunity__c=oOpportunity.Id);
		insert oApplication;
		Selection__c oSelection = new Selection__c(Application__c=oApplication.Id);
		insert oSelection;
		list<Selection__c> listSelection = new list<Selection__c>();
		listSelection.add(oSelection);
		
		Education__c oEd_one = new Education__c(RecordTypeId=idRTeducationLQ, Student__c=oStudent.Id, Language__c= 'English', Test_Score__c = '420', Qualification__c = 'TOEFL - paper based', Date_of_Test__c = Date.Today() - 100);
		Education__c oEd_two = new Education__c(RecordTypeId=idRTeducationLQ, Student__c=oStudent.Id, Language__c= 'French',Qualification__c = 'DELF Unité A1', Test_Score__c = '2',Date_of_Test__c = Date.Today() - 356);
		Education__C oEd_three = new Education__c(RecordTypeId=idRTeducationSQ, Student__c=oStudent.Id, Diploma_Name__c=oDiplom.Id, 
													School_Name__c=oSchool.Id, Education__c='Secondary School', Diploma_Date__c=date.today());
		Education__C oEd_five = new Education__c(RecordTypeId=idRTeducationSQ, Student__c=oStudent.Id, Diploma_Name__c=oDiplom.Id, 
													School_Name__c=oSchool.Id, Education__c='Secondary School');
		Education__C oEd_six = new Education__c(RecordTypeId=idRTeducationSQ, Student__c=oStudent.Id, Diploma_Name__c=oDiplom.Id, 
													School_Name__c=oSchool.Id, Education__c='Higher Education');
		Education__c oEd_for = new Education__c(RecordTypeId=idRTeducationTS, Student__c=oStudent.Id, Date_of_Test__c=date.today());
		list<Education__c> listEducation = new list<Education__c>();
		listEducation.add(oEd_one);
		listEducation.add(oEd_two);
		listEducation.add(oEd_three);
		listEducation.add(oEd_for);
		listEducation.add(oEd_five);
		listEducation.add(oEd_six);
		insert listEducation;
		
		Profile_Experience__c oPE_one = new Profile_Experience__c(Contact__c=oStudent.Id, RecordTypeId=idRTpe_WE);
		Profile_Experience__c oPE_two = new Profile_Experience__c(Contact__c=oStudent.Id, RecordTypeId=idRTpe_ECK);
		list<Profile_Experience__c> listPE = new list<Profile_Experience__c>();
		listPE.add(oPE_one);
		listPE.add(oPE_two);
		insert listPE;
	
		Test.setCurrentPageReference(new PageReference('/apex/OverviewApplicationController?id='+oApplication.Id));	
		OverviewApplicationController oTest = new OverviewApplicationController();
		oTest.init();
		oTest.doNothing();
		
		System.assert(oTest.getListAllEducation() != null);
		System.assertEquals(6, oTest.getListAllEducation().size());
		System.assert(oTest.getOAddress() != null);
		
		list<Education__c> listEdToTest = oTest.getListAllEducation();
		Education__c oEdToTest_one;
		Education__c oEdToTest_two;
		Education__c oEdToTest_three;
		Education__c oEdToTest_for;
		for(Education__c oTemp : oTest.getListAllEducation()){
			if(oTemp.Language__c != null){
					if(oTemp.Language__c == 'English')
						oEdToTest_one = oTemp;
					else if(oTemp.Language__c == 'French')
						oEdToTest_two = oTemp;
			}	
			else if(oTemp.Diploma_Name__c != null)
				oEdToTest_three = oTemp;
			else if(oTemp.Date_of_Test__c != null)
				oEdToTest_for = oTemp;
		}
		
		System.assert(oEdToTest_one != null);
		System.assert(oEdToTest_two != null);
		System.assert(oEdToTest_three != null);
		System.assert(oEdToTest_for != null);
		
		//Test only lists of Education
		oTest.setListEducationLQ(listEducation);
		System.assert(oTest.getListEducationLQ().size() == listEducation.size());
		oTest.setListEducationLQ_EN(listEducation);
		System.assert(oTest.getListEducationLQ_EN().size() == listEducation.size());
		oTest.setListEducationLQ_FR(listEducation);
		System.assert(oTest.getListEducationLQ_FR().size() == listEducation.size());
		oTest.setListEducationSQ(listEducation);
		System.assert(oTest.getListEducationSQ().size() == listEducation.size());
		oTest.setListEducationSQ_HE(listEducation);
		System.assert(oTest.getListEducationSQ_HE().size() == listEducation.size());
		oTest.setListEducationSQ_SecSchool(listEducation);
		System.assert(oTest.getListEducationSQ_SecSchool().size() == listEducation.size());
		oTest.setListEducationSQ_SecSchool_DDnull(listEducation);
		System.assert(oTest.getListEducationSQ_SecSchool_DDnull().size() == listEducation.size());
		oTest.setListEducationTS(listEducation);
		System.assert(oTest.getListEducationTS().size() == listEducation.size());
		
		//Test only list of Profile_Experience__c
		oTest.setListProfileExperience_ECK(listPE);
		System.assert(oTest.getListProfileExperience_ECK().size() == listPE.size());
		oTest.setListProfileExperience_WE(listPE);
		System.assert(oTest.getListProfileExperience_WE().size() == listPE.size());
		
		// Test only several Object
		oTest.setOApplication(oApplication);
		System.assert(oTest.getOApplication() == oApplication);
		oTest.setOOpportunity(oOpportunity);
		System.assert(oTest.getOOpportunity() == oOpportunity);
		oTest.setOContact(oStudent);
		System.assert(oTest.getOContact() == oStudent);
		oTest.setOAddress(oSchoolAddress);
		System.assert(oTest.getOAddress() == oSchoolAddress);
		oTest.setOEducationSATone(oEdToTest_one);
		System.assert(oTest.getOEducationSATone() == oEdToTest_one);
		oTest.setOSchool(oSchool);
		System.assert(oTest.getOSchool() == oSchool);
		oTest.setOSelection(oSelection);
		System.assert(oTest.getOSelection() == oSelection);
		oTest.setListSelection(listSelection);
		System.assert(oTest.getListSelection().size() == listSelection.size());
		
	}
	
static void setRecordType(){
	idRTeducationSQ = [select id, Name from RecordType where IsActive=true and SobjectType='Education__c' and Name= 'School Qualification' limit 1].id;
	idRTeducationLQ = [select id, Name from RecordType where IsActive=true and SobjectType='Education__c' and Name= 'Language Qualification' limit 1].id;
	idRTeducationTS = [select id, Name from RecordType where IsActive=true and SobjectType='Education__c' and Name= 'Test Scores' limit 1].id;
	idRTadditionalIE = [select id, Name from RecordType where IsActive=true and SobjectType='Additional__c' and Name= 'International Exposure' limit 1].id;
	idRTadditionalM = [select id, Name from RecordType where IsActive=true and SobjectType='Additional__c' and Name= 'Miscellaneous' limit 1].id;	
	idRTpe_WE = [select id, Name from RecordType where IsActive=true and SobjectType='Profile_Experience__c' and Name= 'Work Experience' limit 1].id; 
	idRTpe_ECK = [select id, Name from RecordType where IsActive=true and SobjectType='Profile_Experience__c' and Name= 'Extra Curricular Activities' limit 1].id;
	idRTAddress_CPA = [select id, Name from RecordType where IsActive=true and SobjectType='Address__c' and Name= 'Contact Permanent Address' limit 1].id;	
	idRTDiploma = [select Name from RecordType where IsActive=true and SobjectType='Reference_Data__c' and Name= 'Reference - Diploma' limit 1].id;	
	idRToppDiplom = [select id, Name from RecordType where IsActive=true and SobjectType='Opportunity' and Name= 'Bachelor' limit 1].id;
}
}