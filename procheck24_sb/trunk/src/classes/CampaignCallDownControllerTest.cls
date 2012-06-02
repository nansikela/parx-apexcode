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
private class CampaignCallDownControllerTest {

	static testMethod void testKeyCaseSensitive(){
		String lower='abc';
		String upper='ABC';
		map<String, String> testmap = new map<String, String>();
		testmap.put(lower,lower);
		testmap.put(upper,upper);
		System.assertEquals(2,testmap.size());
	}

     static testMethod void testNormalFlow(){
     	// get aliases for existing users
     	map<Id, User> usermap = new map<Id, User>();
     	
     	for (User u: [SELECT Email, Id, Name, Alias FROM USER WHERE Isactive=true limit 10]) {
     		usermap.put(u.id, u);
     	}
     	
	  	//campaign
	  	Campaign testCampaign 		= new Campaign();
	  	testCampaign.name 			= 'TestCampaign';
	  	insert testCampaign;
	  	
	  	//Lead
	  	Lead testLead1 			= new Lead();
	  	testLead1.FirstName 	= 'LeadFirstName1';
	  	testLead1.LastName 		= 'LeadLastName1';
	  	testLead1.Company 		= 'Test1';
	  	testLead1.Street		= '123 abc st';
	  	testLead1.City			= 'Munich';
	  	testLead1.Email			= 'test@test.test';
	  	testLead1.Country		= 'Testcountry';
	  	testLead1.State			= 'Bayern';
	  	testLead1.PostalCode	= '80337';
	  	insert testLead1;
	  	
	  	//Lead
	  	Lead testLead2			= new Lead();
	  	testLead2.FirstName 	= 'LeadFirstName2';
	  	testLead2.LastName 		= 'LeadLastName2';
	  	testLead2.Company 		= 'Test2';
	  	insert testLead2;
	  	
	  	// Account
	  	Account testAccount = new Account();
	  	testAccount.Name = 'Company';
	  	insert testAccount;
	  	
	  	//Contact
	  	Contact testContact 		= new Contact();
	  	testContact.AccountId		= testAccount.Id;
	  	testContact.FirstName 		= 'ContactFirstName';
	  	testContact.LastName 		='ContactLastName';
	    testContact.Email 			= 'Adress2@Adress.com';
	  	testContact.Title			= 'ContactTitile';
	  	testContact.MailingStreet	= '456 garrik st';
	  	testContact.MailingCity		= 'City';
	  	testContact.MailingCountry	= 'Country';
	  	testContact.MailingState	= 'State';
	  	testContact.MailingPostalCode = 'PLZ';
	    insert testContact;
	    
	    //Contact2
	    Contact testContact2 		= new Contact();
	    testContact2.FirstName 		= 'ContactFirstName2';
	    testContact2.Email 			= 'Adress@Adress.com';
	    testContact2.LastName 		='ContactLastName2';
	    testContact2.Title			= 'ContactTitile2';
	    insert testContact2;
	  	
	  	//make campaign members
	  	CampaignMember testCM 		= new CampaignMember();
	  	testCM.leadID 				= testLead1.Id;
	  	testCM.campaignID 			= testCampaign.Id;
	  	testCM.Status				='Responded';
	  	if (usermap.size()>0) {
	  		testCM.Bearbeiter__c	= usermap.values().get(0).Alias;
	  	}
	  	insert testCM;
	  	
	  	//make campaign members
	  	CampaignMember testCM1 		= new CampaignMember();
	  	testCM1.leadID 				= testLead2.Id;
	  	testCM1.campaignID 			= testCampaign.Id;
	  	testCM1.Status				= 'Responded';
	  	if (usermap.size()>1) {
	  		testCM1.Bearbeiter__c	= usermap.values().get(1).Alias;
	  	}
	  	insert testCM1;
	  	
	  	CampaignMember testCM2 		= new CampaignMember();
	  	testCM2.ContactId 			= testContact.Id;
	  	testCM2.CampaignId 			= testCampaign.Id;
	  	testCM2.Status				= 'Responded';
	  	if (usermap.size()>2) {
	  		testCM2.Bearbeiter__c	= usermap.values().get(2).Alias;
	  	}
	  	insert testCM2;
	  	
	  	CampaignMember testCM3 		= new CampaignMember();
	    testCM3.ContactId 			= testContact2.Id;
	    testCM3.CampaignId 			= testCampaign.Id;
	    testCM3.Status				= 'Responded';
	    if (usermap.size()>3) {
	  		testCM3.Bearbeiter__c	= usermap.values().get(3).Alias;
	  	}
	    insert testCM3;
	  	
	  	//begin tests
	  	CampaignCallDownController ccdc1 = new CampaignCallDownController();
	    ccdc1.ownerId = UserInfo.getUserId();
	    ccdc1.bearbeiterCheckbox=false;
	    List<CampaignMember> testCMList = [ SELECT id, ContactId, CampaignId, Status FROM CampaignMember WHERE id =: testCM.id OR id =: testCM1.id OR id =: testCM2.id OR id =: testCM3.id ];
	  	ccdc1.updateAll();
	    List<CampaignMember> testCMList2 = [ SELECT id, ContactId, CampaignId, Status FROM CampaignMember WHERE id =: testCM.id OR id =: testCM1.id OR id =: testCM2.id OR id =: testCM3.id ];
	    
	    // No changes
	    System.assertEquals( testCMList, testCMList2 );
	    
	    List<Selectoption>sO=ccdc1.getstatusItems();
	    
	  	ccdc1.camp = testCampaign.Id;
	    String s = ccdc1.getCampaignName();
	    
	    //Campaign name
	    System.assertEquals( s, 'Keine Kampagne ausgewählt' );
	    
	  	ccdc1.campaignRefresh();
	    s = ccdc1.getCampaignName();
	    sO=ccdc1.getstatusItems();
	    
	    List<Selectoption> options= new List<Selectoption>{ new Selectoption( '--ALL--', '--ALL--'), new Selectoption( 'Sent', 'Sent' ), new Selectoption( 'Responded', 'Responded')};
	   
	    // Options
	    System.assertEquals( sO[ 0 ].getLabel(), options[ 0 ].getLabel());
	    System.assertEquals( sO[ 1 ].getLabel(), options[ 1 ].getLabel());
	    System.assertEquals( sO[ 2 ].getLabel(), options[ 2 ].getLabel());
	    System.assertEquals( sO[ 0 ].getValue(), options[ 0 ].getValue());
	    System.assertEquals( sO[ 1 ].getValue(), options[ 1 ].getValue());
	    System.assertEquals( sO[ 2 ].getValue(), options[ 2 ].getValue());
	    //Campaign name
	    System.assertEquals( s, 'TestCampaign' );
	    
	    // JS, Bearbeiterliste
	    System.assert(!ccdc1.getbearbeiters().isEmpty());
	    //ccdc1.getLeadPlusTasks()[ 0 ].t.Description='test';
	    ccdc1.getLeadPlusTasks()[ 0 ].memo='test';
	    //ccdc1.getLeadPlusTasks()[ 1 ].t.Description='test';
	    ccdc1.getLeadPlusTasks()[ 1 ].memo='test';
	    ccdc1.getLeadPlusTasks()[ 1 ].followupdesc=true;
	    //ccdc1.getLeadPlusTasks()[ 1 ].followup.Subject='test';
	    ccdc1.getLeadPlusTasks()[ 1 ].followupTaskSubject='test';
	    //ccdc1.getLeadPlusTasks()[ 1 ].followup.ActivityDate=System.today()+30;
	    Date d = System.today()+30;
	    ccdc1.getLeadPlusTasks()[ 1 ].followupActivityDate=d.day() + '.' + d.month() + '.' + d.year();
	    //ccdc1.getLeadPlusTasks()[ 1 ].getfollowup();
	    ccdc1.getLeadPlusTasks()[ 1 ].getFollowupTaskSubject();
	    	    
	  	ccdc1.getLeadPlusTasks()[0].statusUpdate = 'Sent';
	  	System.debug('******' + ccdc1.getLeadPlusTasks().size());
	    ccdc1.updateAll();
	    System.debug('******' + ccdc1.getLeadPlusTasks().size());
	    List<CampaignMember> testCMList3 = [ SELECT id, ContactId, CampaignId, Status FROM CampaignMember WHERE id =: testCM.id OR id =: testCM2.id OR id =: testCM3.id ];
	    
	    String name1 = ccdc1.getLeadPlusTasks()[ 0 ].name;
	    String name2 = ccdc1.getLeadPlusTasks()[ 1 ].name;
	    ccdc1.sortByName();
	    System.assert( ccdc1.getLeadPlusTasks()[ 0 ].name <= ccdc1.getLeadPlusTasks()[ 1 ].name, 'Error in sort');
	  	ccdc1.sortByCompany();
	    System.assert( ccdc1.getLeadPlusTasks()[ 0 ].Company <= ccdc1.getLeadPlusTasks()[ 1 ].Company, 'Error in sort');
	  	ccdc1.sortByStatus();
	    System.assert( ccdc1.getLeadPlusTasks()[ 0 ].memStatus <= ccdc1.getLeadPlusTasks()[ 1 ].memStatus, 'Error in sort');
	  	ccdc1.sortByTitle();
	    System.assert( ccdc1.getLeadPlusTasks()[ 0 ].Title <= ccdc1.getLeadPlusTasks()[ 1 ].Title, 'Error in sort');
	    
	    // Changes
	    System.assert( testCMList != testCMList3, 'The collections not be equals.' );
	  	
	  	sO=ccdc1.getcampaignItems();
	  	
	  	List<Selectoption> auxCampList = new List<Selectoption>(); 
	  	auxCampList.add(new SelectOption( '1','SELECT' ));
	  	
	  	for(Campaign c : [Select Name, Id From Campaign Where isactive = true order by Name limit 100])
	  		auxCampList.add( new SelectOption( c.id, c.name ));
	  		
	  	Integer k = 0;
	  	for( SelectOption op: auxCampList )
			System.assertEquals( sO[ k++ ].getValue(), op.getValue(), 'Error list of campaigns must be equals');
	
		ccdc1.getLeadPlusTasks()[ 0 ].getmemStatusValue();
		//ccdc1.getLeadPlusTasks()[ 0 ].sett( ccdc1.getLeadPlusTasks()[ 0 ].gett());
		//ccdc1.getLeadPlusTasks()[ 0 ].setfollowup( ccdc1.getLeadPlusTasks()[ 0 ].getfollowup());
		ccdc1.getLeadPlusTasks()[ 0 ].setMemo( ccdc1.getLeadPlusTasks()[ 0 ].getMemo());
		ccdc1.getLeadPlusTasks()[ 0 ].setFollowupTaskSubject( ccdc1.getLeadPlusTasks()[ 0 ].getFollowupTaskSubject());
		ccdc1.getLeadPlusTasks()[ 0 ].setFollowupActivityDate( ccdc1.getLeadPlusTasks()[ 0 ].getFollowupActivityDate());
		ccdc1.getLeadPlusTasks()[ 0 ].getmemStatus();
	
	
	
		System.assert( ccdc1.gethasCampaignID());
	  	
	  	ccdc1.status='Responded';
	  	ccdc1.campaignRefresh();
	  	System.assert( ccdc1.status == 'Responded');
	  	
	  	ccdc1.status='All';
	    ccdc1.campaignRefresh();
	  	System.assert( ccdc1.status == 'All');
	  	
	  	sO=ccdc1.getcampaignItems();
	  	sO=ccdc1.getstatusItems();
	    
	    s = ccdc1.getCampaignName();
	    boolean b = ccdc1.getName();
	    
	    ccdc1.setowners(new List<SelectOption>());
	    System.assert( ccdc1.getowners().size() == 0);
	  	
	  }
  
}