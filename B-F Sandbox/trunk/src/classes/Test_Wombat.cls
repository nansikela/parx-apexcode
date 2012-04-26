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
private class Test_Wombat {
	public final static Integer twoBillion = 2000000000;

    static testMethod void myUnitTest() {
              
        
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
		User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='wombatTestUser@b-f.com');
		System.debug('USER ID'+u1.Id);

		List<RecordType> rt_Banner = [SELECT Id FROM RecordType WHERE SObjectType = 'Banner_Groups__c' AND Name = 'AUD - Banner Groups'];
		List<RecordType> rt_AssetMove = [SELECT Id FROM RecordType WHERE SObjectType = 'Asset_Move__c'];
		List<RecordType> rt_PromoActivity = [SELECT Id FROM RecordType WHERE SObjectType = 'Promotion_Activity__c'];
		
		DateTime lastSyncDate = Datetime.now();
       	String ownerId = String.valueOf(u1.Id);
        //string sessionId = 'a20Q0000000DTbY';
		wombat_Sync_Session__c wss = new wombat_Sync_Session__c();
		wss.InProgress__c = true;
		wss.App_Version__c = '1.1';
		wss.IP_Address__c = '1.1.1.1';
		wss.Model__c = 'TestMethod';
		wss.User__c = u1.Id;
		insert wss;
		
		String sessionId = wss.Id;
        
       	
       	System.runAs(u1){
						
			//Testing Wombat_Exception
			wombat_Exception we = new wombat_Exception();
			we.isWombatException = true;
			
			//Testing Wombat_Describe_Object
			wombat_Descibe_Object wdo = new wombat_Descibe_Object();
			
			//Testing wombat_Describe_Object_Field
			wombat_Describe_Object_Field wdof = new wombat_Describe_Object_Field();
			
			//Testing Wombat_sync
			//Master List
			List<List<String>> clientData = new List<List<String>>();
			//Lists that will contain header info and data
			List <String> accountSetup = new List <String>();
			List <String> accountValues = new List <String>();
			List <String> orderItemSetup = new List <String>();
			List <String> orderItemValues = new List <String>();
			List <String> orderSetup = new List <String>();
			List <String> orderValues = new List <String>();
			List <String> outletVisitItemSetup = new List <String>();
			List <String> outletVisitItemValues = new List <String>();
			List <String> outletVisitSetup = new List <String>();
			List <String> outletVisitValues = new List <String>();
			List <String> venueSetup = new List <String>();
			List <String> venueValues = new List <String>();
			List <String> assetSetup = new List<String>();
			List<String> assetValues = new List<String>();
			List<String> accountWholesalerSetup = new List<String>();
			List<String> accountWholesalerValues = new List<String>();
			List<String> promotionSetup = new List<String>();
			List<String> promotionValues = new List<String>();
			List<String> groupPromotionSetup = new List<String>();
			List<String> groupPromotionValues = new List<String>();
			List<String> groupPromotionItemSetup = new List<String>();
			List<String> groupPromotionItemValues = new List<String>();
			List<String> contactSetup = new List<String>();
			List<String> contactValues = new List<String>();
			List<String> eventSetup = new List<String>();
			List<String> eventValues = new List<String>();
			List<String> assetMoveSetup = new List<String>();
			List<String> assetMoveValues = new List<String>();
			
			List<Market__c> markets = [SELECT Id FROM Market__c WHERE Name = 'Australia'];
			
			Account acct = new Account();
			acct.Name = 'Test Account';
			acct.Market__c = markets[0].Id;
			insert acct;
			
			Account pfmAccount = new Account();
			pfmAccount.Name = 'PFM Account';
			pfmAccount.Market__c = markets[0].Id;
			insert pfmAccount;
			
			Venue__c ven = new Venue__c();
			ven.Name = 'Test Venue';
			ven.Channel__c = 'Off';
			ven.Segment__c = 'T3';
			ven.Area_Type__c = 'T3 BARN BIG BOX';
			ven.Account__c = acct.Id;
			insert ven;
			
			Contact contact = new Contact();
			contact.FirstName = 'firstName';
			contact.LastName = 'lastName';
			contact.AccountId = acct.Id;
			contact.Venue__c = ven.Id;
			insert contact;
			
			Wholesaler__c wsaler = new Wholesaler__c();
			wsaler.Name = 'Test Wholesaler';
			wsaler.Account__c = acct.Id;
			wsaler.Market__c = markets[0].Id;
			wsaler.Wholesaler_Name__c = 'Test Wholesaler';
			wsaler.SAP_Number__c = 'ECC-1234';
			insert wsaler;
			
			Account_Wholesaler__c accwsaler = new Account_Wholesaler__c();
			accwsaler.Account__c = acct.Id;
			accwsaler.Wholesaler__c = wsaler.Id;
			accwsaler.Allow_Order__c = true;
			insert accwsaler;
			
			Asset_Type__c at1 = new Asset_Type__c();
			at1.Name = 'asset_Type1';
			insert at1;
			
			Asset_Models__c am1 = new Asset_Models__c();
			am1.Name = 'asset_Model1';
			am1.Asset_Type__c = at1.Id;
			insert am1;
			
			Asset_Sub_Type__c ast1 = new Asset_Sub_Type__c();
			ast1.Name = 'asset_sub_type1';
			ast1.Asset_Model__c = am1.Id;
			insert ast1;
			
			List<Fridge_In_Fills__c> fifList = new List<Fridge_In_Fills__c>();
			Fridge_In_Fills__c fif1 = new Fridge_In_Fills__c();
			fif1.Name = 'Fridge in Fill 1';
			fif1.Asset_Model__c = am1.Id;
			fif1.Fridge_In_Fill_Type__c = 'Fridge In Fill';
			fifList.add(fif1);
			
			Fridge_In_Fills__c fif2 = new Fridge_In_Fills__c();
			fif2.Name = 'External Branding 1';
			fif2.Asset_Model__c = am1.Id;
			fif2.Fridge_In_Fill_Type__c = 'Exernal Branding';
			fifList.add(fif2);
			
			Fridge_In_Fills__c fif3 = new Fridge_In_Fills__c();
			fif3.Name = 'Internal Branding 1';
			fif3.Asset_Model__c = am1.Id;
			fif3.Fridge_In_Fill_Type__c = 'Internal Branding';
			fifList.add(fif3);
			
			insert fifList;
			
			Asset__c asset = new Asset__c();
			asset.Account__c = acct.Id;
			asset.Venue__c = ven.Id;
			asset.Asset_Model__c = am1.Id;
			asset.Asset_Type__c = at1.Id;
			insert asset;
			
			Banner_Groups__c banner = new Banner_Groups__c();
			banner.Name = 'Test Banner';
			banner.RecordTypeID = rt_Banner[0].Id;
			insert banner;
			
			Order__c orderHeader = new Order__c();
			orderHeader.Account__c = acct.Id;
			orderHeader.Wholesalers__c = accwsaler.Id;
			insert orderHeader;
			
			Promotion_Activity__c promoActivity1 = new Promotion_Activity__c();
			promoActivity1.Name = 'promo Activity 1';
			promoActivity1.Active__c = true;
			promoActivity1.Activity__c = 'Agreements';
			promoActivity1.Channel__c = 'On';
			promoActivity1.Market__c = markets[0].Id;
			promoActivity1.Promotion_Category__c = 'Staffed';
			promoActivity1.Promotion_Type__c = 'Agreement';
			promoActivity1.Promotion_SubType__c = 'Drink Menu';
			promoActivity1.RecordTypeId = rt_PromoActivity[0].Id;
			insert promoActivity1;
			
			// Test Data from Tass
			String accountHeaders ='Account,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,IsDeleted,MasterRecordId,Name,RecordTypeId,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Phone,Fax,AccountNumber,Website,Industry,AnnualRevenue,NumberOfEmployees,CurrencyIsoCode,OwnerId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Jigsaw,JigsawCompanyId,AccountSource,SicDesc,Channel__c,Market__c,Region__c,Status__c,FN__Find_Nearby__c,FN__Lat__c,FN__Lon__c,SAP_Customer_Number__c,E_Mail_Address__c,Lead_Independent_Director__c,Expected_Monthly_Visits__c,Account_Licence_Type__c,Account_Type__c,Banner_Group__c,Banner_Sub_Group__c,Is_Active__c,Is_Main__c,LMAA_Number__c,Last_Visit_Date__c,Legal_Entity__c,Licence__c,Off_Segment__c,On_Segment__c,Order_Type__c,Sales_Region__c,Account_Licence_Number__c';
			String accountHeaderValues = 'Account,detail,474,null,null,null,null,2,' + acct.Id + ',null,null,1ST CHOICE FORESTVI 7019,01230000001KOFQAA4,null,null,null,null,null,682 WARRINGAH ROAD,null,NSW,null,Australia,9451 -6413,9975 6352,23818,,null,null,null,USD,005Q0000000vbtmIAA,null,00530000005n92iAAA,2012-04-18 10:24:21,00530000005n92iAAA,null,null,null,null,null,null,OFF PREMISE,a06Q0000005nz0BIAQ,NSW,Active,<a href=\'apex/FN__AGeoCode?id=001Q000000RAkoY\' target=\'_parent\'>Locate Account</a>,,,null,Test@test.com,null,null,LIQUOR STORES,Domestic,a1oQ0000000oPpFIAU,null,true,false,null,2012-04-18 10:24:00 ,1ST CHOICE FORESTVI 7019,null,UNC,NIL,null,NSW,351055';  
			
			String orderItemHeaders = 'Order_Item__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Order__c,Brand__c,Carton_Bonus__c,Carton__c,Discount__c,Legacy_Code__c,Product__c,SAP_Material_Number__c,Unit_Bonus__c,Unit__c,Wholesaler_Product_Number__c,Wholesaler__c,Banner_Partner__c,Price_Ref_Material__c,Max_PA_Per_Case__c,Account_id__c,PRM_Units_Per_Case__c,Missing_Material__c';
			String orderItemHeaderValues = 'Order_Item__c,detail,69,2000000001,null,null,null,1,2000000001.0,null,null,null,null,null,null,null,null,null,null,2000000001.0,null,0,2,0,null,' +orderHeader.Id+ ',null,null,null,0,0,null,null,null,null,null,null,null,null,null,null,null';

			String orderHeaders = 'Order__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Account_Name__c,Account__c,Contact__c,CreatedBy_Name__c,Legacy_Code__c,Notes__c,Order_Date__c,Order_Type__c,Postal_Code__c,State__c,Status__c,Street_del__c,Suburb__c,Wholesaler_Code__c,Wholesaler_Customer_Number__c,Wholesaler_Name__c,Wholesaler_Number__c,Wholesaler_State_Code__c,Wholesalers__c,Banner_Partner__c,Wholesaler_Account_Name__c,Material_Errors__c,City__c,AccountNumber__c';
			String orderHeaderValues = 'Order__c,detail,46,2000000001,null,null,null,1,2000000001.0,' + ownerId + ',null,null,null,012Q0000000CzGTIA0,2012-04-18 10:23:33,null,null,null,null,null,null,' + acct.Id + ',' + contact.Id + ',null,null,test note,2012-04-18 10:23:10,In-Direct,2122,NSW,New,682 WARRINGAH ROAD,Suburb,' + wsaler.Id + ',7019,PENNEYS NSW & ACT,null,null,' + accwsaler.Id + ',null,null,null,null,23818';
			
			String outletVisitItemHeaders = 'Outlet_Visit_Item__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Outlet_Visit__c,Bottle_Price_Special__c,Bottle_Price__c,Drink_Price_Special__c,Drink_Price__c,Outlet_Visit_Item_Key__c,Available__c,Facing__c,Double_Price_Special__c,Double_Price__c,Channel__c,Brand__c,Placement__c,Custom_Product__c,Position__c,Location_Off__c,Location_On__c,Location_Reporting__c,BackBarVisit__c,PriceTypeFlag__c,CocktailCount__c,Shelf_Category_Item__c,Legacy_Code__c';
			String outletVisitItemHeaderValues = 'Outlet_Visit_Item__c,detail,366,2000000001,null,null,null,1,2000000001.0,null,null,null,null,null,null,null,null,null,2000000001.0,null,0,null,null,null,1,null,null,null,null,null,null,null,0,null,null,null,0,0,0,a2UQ00000006NWdMAM,null';
			
			String outletVisitHeaders = 'Outlet_Visit__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Account__c,Competitor_Activity__c,Met_With__c,Visit_Comments__c,Visit_Date__c,Venue__c,AccountNumber__c,Visit_Counts__c,Status__c,Create_Offline_OVIs__c,Legacy_Code__c,AccountName__c';
			String outletVisitHeaderValues = 'Outlet_Visit__c,detail,23,2000000001,null,null,null,1,2000000001.0,' + ownerId + ',null,null,null,null,2012-04-18 10:23:53,null,2012-04-18 10:23:53,null,null,' + acct.Id + ',null,null,null,2012-04-18 10:23:53,' + ven.Id + ',23818,null,null,null,null,null';
			
			String venueHeaders = 'Venue__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Account__c,Area_Type__c,Channel__c,Is_Active__c,Legacy_Code__c,Notes__c,Segment__c,Venue_Name__c,AccountNumber__c';
			String venueHeaderValues = 'Venue__c,detail,123,null,null,null,null,2,' + ven.Id + ',null,T3  BARN BIG BOX,AUD,null,00530000005n92iAAA,2012-04-18 10:24:21,00530000005n92iAAA,null,null,' + acct.Id + ',T3  BARN BIG BOX,Off,true,57968,Testet,T3,T3  BARN BIG BOX,23818';
			
			String assetHeaders = 'Asset__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Account__c,Active__c,Agreement__c,Asset_Model__c,Asset_Type__c,Asset_Tag__c,Comments__c,Fridge_Details_Incorrect__c,Fridge_Sighted__c,Is_Active__c,Last_Sighted__c,Legacy_Code__c,Placement_Date__c,SAP_Asset__c,Serial__c,Supplier__c,Venue__c,AssetNumber__c,AccountNumber__c,Fridge_In_Fill__c,External_Branding__c,Internal_Branding__c';
			String assetHeaderValues = 'Asset__c,detail,45,null,null,null,a20Q0000000DXR4IAO,2,' + asset.Id + ',005Q0000000vbtmIAA,null,AN-347,AUD,null,00530000005n92iAAA,2012-04-18 09:20:47,00530000005n92iAAA,null,null,' + acct.Id +',Active,null,null,null,null,,0,1,true,2012-04-18 09:20:47,1254910,2011-05-05 00:00:00,null,100200074,null,' + ven.Id + ',AN-347,20612,a1eQ00000004yg5,null,null';
			
			String accountWholesalerHeaders = 'Account_Wholesaler__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,AccountNumber__c,Account__c,Allow_Order__c,Delivery_Day_1__c,Delivery_Day_2__c,Is_Active__c,Legacy_Code__c,Notes__c,Wholesaler_Account_Name__c,Wholesaler_Account_Number__c,Wholesaler_Name__c,Wholesaler__c,Banner_Partner__c';
			String accountWholesalerHeaderValues = 'Account_Wholesaler__c,detail,1273,null,null,null,null,2,' + accwsaler.Id + ',' + ownerId + ',null,WHSL-93485,AUD,null,00530000005n92iAAA,2012-04-18 09:27:55,00530000005n92iAAA,null,null,23818,' + acct.Id + ',true,null,null,true,434379,Test,null,7019,PENNEYS NSW & ACT,' + wsaler.Id + ',null';
			
			String promotionHeaders = 'Promotion__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Sales_Manager__c,Brand_Manager__c,Finance_Manager__c,Promotion_Activity__c,Brand__c,Account__c,Account_Capacity_f__c,Approval_Status__c,Crew_Support__c,End_Time__c,Mechanism__c,Promotion_End_Date__c,Promotion_Start_Date__c,Special_Event__c,Start_Time__c,Support_and_Backup__c,Target_Age_Group__c,Target_Attendance__c,Total_Brand_Profit__c,Total_Margin__c,Total_Promotion_Cost__c,Promotion_Number__c,Account_Market__c,Estimated_Cost__c,status_of_Secondary_placement__c,Number_of_Bottles__c,Comments__c,Promotion_Start_Date_BFA__c,English_Name__c,Outlet_Class__c,Promotion_Sub_Type__c,Market__c,Particular_Agreement__c,Total_Pouring_Amount2__c,Total_Sales_Volume__c,Banner_Group__c,Buy_Period_End_Date__c,Buy_Period_Start_Date__c,Channel__c,Material_Product_Group__c,PA_Type__c,Promotion_Mechanics__c,Promotion_Type__c,State__c,TA_Type__c,Promotion_End_Date_BFA__c,Additional_Mechanics__c,Draw_Date__c,Winner_Name__c,Suburb__c,Post_Code__c,Telephone__c,Is_Active__c,Contact__c,Venue__c,Sales_Region__c,Promotion_Category__c,Remind_Me_Date__c,Promotion_Activity_AUD__c,Sub_Type__c,AUD_Channel__c,Shipping_City__c,Shipping_Country__c,Shipping_State__c,Shipping_Street__c,Shipping_Zip__c,Contact_Email__c,Contact_Phone__c,Contact_MobilePhone__c,AccountNumber__c,AccountName__c,Legacy_Code__c,Market_Manager__c';
			String promotionHeaderValues = 'Promotion__c,detail,92,2000000001,null,null,null,1,2000000001.0,' + ownerId + ',null,12312312,null,01230000000dh6O,null,null,null,null,null,null,null,null,null,a0BQ0000005mxONMAY,null,' + acct.Id + ',null,null,null,null,null,2012-04-20 00:00:00,2012-04-18 00:00:00,null,null,null,,,null,null,null,null,null,null,null,null,Rrqwrrq,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,,null,,,,,true,003Q000000TmwydIAB,,null,null,2012-04-19 00:00:00,null,null,null,null,null,null,null,null,null,null,null,23818,null,null,null';
			
			String groupPromotionHeaders = 'Group_Promotions__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Activity_Code__c,Activity_Comment__c,Application__c,Approx_LUC_exc_GST__c,Banner_Group__c,Brand__c,Buy_Period_End_Date__c,Buy_Period_Start_Date__c,Co_Op_Type__c,Comments__c,Customer_Level__c,Deal_Channel__c,Deal_Method__c,Extra_Co_Op_per_Case__c,Extra_Unit_PA__c,Id__c,LUC_GST_INC__c,Lump_Sum_Co_OP__c,Lump_Sum__c,Margin__c,Material_Product_Group__c,Note_to_Approver__c,Objective__c,Ongoing_PA__c,PA_Type__c,Price_Type__c,Product_Class__c,Promotion_Group__c,Promotion_Mechanics__c,Customer_Promotion_ID__c,Promotion_Period_End_Date__c,Promotion_Period_Start_Date__c,Promotion_Type__c,Rate_Per_Case__c,Region__c,Sell_Price__c,State__c,Status__c,Tatic__c,Unit__c,Vistex_Agreement_Type__c,Volume_Source__c,Wholesaler__c,Account__c,Vistex_Agreement_Number__c,AccountNumber__c,AccountName__c,Account_Wholesaler__c,Legacy_Code__c';
			String groupPromotionHeaderValues = 'Group_Promotions__c,detail,4,2000000001,null,null,null,1,2000000001.0,' + ownerId + ',null,null,null,012Q0000000CzCtIAK,null,null,null,null,null,null,Price Support,Test,On Retailer\'s Invoice,null,null,null,2012-04-21,2012-04-18,null,null,null,OFF,Rate Per Case,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,Initial,null,null,null,null,' + acct.Id + ',null,null,23818,null,' + accwsaler.Id + ',null';
			
			String groupPromotionItemHeaders = 'Group_Promotion_Item__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Group_Promotion__c,Account__c,Banner__c,Brand_Major__c,Brand_Minor__c,Condition_Types__c,Discount_Amount__c,Discount_Percent__c,Distributor__c,FE__c,Manufacturing_Brand__c,Ongoing__c,Reference_Material_Group__c,Price_Unit__c,Price_Vision__c,Product__c,Value_Type__c,Price_Vision_Type__c,Item_Number__c,Reference_Material_Group_Number__c,Legacy_Code__c';
			String groupPromotionItemHeaderValues = 'Group_Promotion_Item__c,detail,4,2000000001,null,null,null,1,2000000001.0,null,null,null,012Q0000000Czf9IAC,null,null,null,null,null,null,2000000001.0,' + acct.Id + ',' + banner.Id + ',null,null,null,7,null,null,null,null,null,a1tQ0000000b4ZmIAI,null,14,null,null,Maximum,null,null,null';
			
			String contactHeaders = 'Contact,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,IsDeleted,MasterRecordId,AccountId,LastName,FirstName,Salutation,Name,RecordTypeId,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone,Fax,MobilePhone,HomePhone,OtherPhone,AssistantPhone,ReportsToId,Email,Title,Department,AssistantName,LeadSource,Birthdate,Description,CurrencyIsoCode,OwnerId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastCURequestDate,LastCUUpdateDate,EmailBouncedReason,EmailBouncedDate,Jigsaw,JigsawContactId,FN__Find_Nearby__c,FN__Lat__c,FN__Lon__c,FN__Mapping_Address__c,FN__Mapping_Status__c,Data_Quality_Score__c,Nickname__c,Primary_Contact__c,Is_Fridge_Contact__c,Preferred_Contact_Method__c,Venue__c,AccountNumber__c,Legacy_Code__c';
			String contactHeaderValues = 'Contact,detail,240,null,null,null,null,2,' + contact.Id + ',null,null,' + acct.Id + ',Somebody,Greg,Mr.,Greg .,01230000001KOFXAA4,null,null,null,null,null,null,null,null,null,null,,,0411222444,null,null,null,null,,Manager,null,null,null,null,null,AUD,005Q0000000vbtmIAA,null,00530000005n92iAAA,2012-04-18 09:58:24,00530000005n92iAAA,null,null,null,null,null,null,null,null,<a href=\'apex/FN__CGeoCode?id=003Q000000SvhN5\' target=\'_parent\'>Locate Contact</a>,null,null,Mailing,Not Located Yet,1,null,null,true,Mobile,' + ven.Id + ',23818,null';
			
			String eventHeaders = 'Event,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,RecordTypeId,WhoId,WhatId,Subject,Location,IsAllDayEvent,ActivityDateTime,ActivityDate,DurationInMinutes,StartDateTime,EndDateTime,Description,AccountId,OwnerId,CurrencyIsoCode,IsPrivate,ShowAs,IsDeleted,IsChild,IsGroupEvent,GroupEventType,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,IsArchived,RecurrenceActivityId,IsRecurrence,RecurrenceStartDateTime,RecurrenceEndDateOnly,RecurrenceTimeZoneSidKey,RecurrenceType,RecurrenceInterval,RecurrenceDayOfWeekMask,RecurrenceDayOfMonth,RecurrenceInstance,RecurrenceMonthOfYear,ReminderDateTime,IsReminderSet,DB_Activity_Type__c,Legacy_Code__c';
			String eventHeaderValues = 'Event,detail,1,2000000001,' + ownerId + ',null,null,1,2000000001.0,01230000001KOFY,' + contact.Id + ',' + acct.Id + ',' + ownerId + ',null,null,2012-04-18 10:02:13 ,2012-04-18 10:02:13 ,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null';
			
			String assetMoveHeaders = 'Asset_Move__c,header,sqlite_ID,Client_ID,Salesforce_Record_Url,DoNotSync,Transaction_ID,Flags,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Actual_Placement_Date__c,Asset_Serial__c,Asset_Sub_Type__c,Asset_Type__c,Asset__c,Comments__c,Contact__c,Enter_Serial__c,External_Branding__c,Fridge_In_Fill__c,Internal_Branding__c,Model__c,Move_Complete__c,New_Account__c,New_Address__c,New_City__c,New_State__c,New_Venue_Lookup__c,New_Venue_Name__c,New_Venue__c,New_Zip__c,Pick_Up_Date__c,Fridge_Depot__c,Address__c,City__c,State__c,Previous_Venue_Name__c,Previous_Venue__c,Zip__c,Reason__c,Requested_Placement_Date__c,Serial_Lookup__c,Type_Of_Placement__c,Terms_Conditions__c,PFM_Serial_Number__c,PFM_Asset_Tag__c,Account__c,Region__c,AccountNumber__c,Legacy_Code__c';
			String assetMoveHeaderValues = 'Asset_Move__c,detail,1,2000000001,null,null,null,1,2000000001.0,' + ownerId + ',null,null,null,01230000001KOFSAA4,null,null,null,null,null,null,null,null,a1bQ0000000wxPuIAI,a1cQ0000000AnosIAC,,Test,' + contact.Id + ',,a1eQ00000004yfgIAA,a1eQ00000004yd1IAA,a1eQ00000004yeeIAA,a1ZQ0000000BM6jMAG,false,' + acct.Id + ',null,null,null,' + ven.Id + ',null,null,null,null,' + pfmAccount.Id + ',null,null,null,null,null,null,,null,null,null,true,,,null,null,20612,null';

			
			// Split Test Data into Lists
			accountSetup = accountHeaders.split(',');
			accountValues = accountHeaderValues.split(',');
			orderItemSetup = orderItemHeaderValues.split(',');
			orderItemValues = orderHeaders.split(',');
			orderSetup = orderHeaderValues.split(',');
			orderValues = outletVisitItemHeaders.split(',');
			outletVisitItemSetup = outletVisitItemHeaderValues.split(',');
			outletVisitItemValues = outletVisitItemHeaderValues.split(',');
			outletVisitSetup = outletVisitHeaders.split(',');    
			outletVisitValues = outletVisitHeaderValues.split(',');
			venueSetup = venueHeaders.split(',');
			venueValues = venueHeaderValues.split(',');
			assetSetup = assetHeaders.split(',');
			assetValues = assetHeaderValues.split(',');
			accountWholesalerSetup = accountWholesalerHeaders.split(',');
			accountWholesalerValues = accountWholesalerHeaderValues.split(',');
			promotionSetup = promotionHeaders.split(',');
			promotionValues = promotionHeaderValues.split(',');
			groupPromotionSetup = groupPromotionHeaders.split(',');
			groupPromotionValues = groupPromotionHeaderValues.split(',');
			groupPromotionItemSetup = groupPromotionItemHeaders.split(',');
			groupPromotionItemValues = groupPromotionItemHeaderValues.split(',');
			contactSetup = contactHeaders.split(',');
			contactValues = contactHeaderValues.split(',');
			eventSetup = eventHeaders.split(',');
			eventValues = eventHeaderValues.split(',');
			assetMoveSetup = assetMoveHeaders.split(',');
			assetMoveValues = assetMoveHeaderValues.split(',');
			
			// Add Test data into Master List (clientData)
			// Accounts - for update
			clientData.add(accountSetup);
			clientData.add(accountValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {
      	 		System.debug('Exception with updating account data. ' + e.getMessage());
      	 	}

			// Accounts - for insert      	 	
      	 	for (integer i = 0; i < accountSetup.size(); i++) {
      	 		if (accountSetup[i] == 'Id') {
      	 			accountValues[i] = (twoBillion + 1).format();
      	 		}
      	 		if (accountSetup[i] == 'Flags') {
      	 			accountValues[i] = '1';
      	 		}
      	 		if (accountSetup[i] == 'Client_ID') {
      	 			accountValues[i] = (twoBillion + 1).format();
      	 		}
      	 	}
      	 	clientData.clear();
			clientData.add(accountSetup);
			clientData.add(accountValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {
      	 		System.debug('Exception with updating account data. ' + e.getMessage());
      	 	}
			
			// Assets
			clientData.clear();
			clientData.add(assetSetup);
			clientData.add(assetValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
			} catch(Exception e) {
			}

			// Assets - test for fridge in fill to select model and type			
			for (integer i = 0; i < assetSetup.size(); i++) {
				if (assetSetup[i] == 'Fridge_In_Fill__c') {
					assetValues[i] = fif1.Id;
				}
			}
			clientData.clear();
			clientData.add(assetSetup);
			clientData.add(assetValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
			} catch(Exception e) {
			}
			
			// Asset - for delete			
			for (integer i = 0; i < assetSetup.size(); i++) {
				if (assetSetup[i] == 'Flags') {
					assetValues[i] = '3';
				}
			}
			clientData.clear();
			clientData.add(assetSetup);
			clientData.add(assetValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
			} catch(Exception e) {
			}
			
			
      	 	// Asset Moves
      	 	clientData.clear();
      	 	clientData.add(assetMoveSetup);
      	 	clientData.add(assetMoveValues);
      	 	try {
      	 		wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}

			for(integer i = 0; i < assetMoveSetup.size(); i++) {
				if (assetMoveSetup[i] == 'Flags') {
					assetMoveValues[i] = '2';
					break;
				}
			}
      	 	clientData.clear();
      	 	clientData.add(assetMoveSetup);
      	 	clientData.add(assetMoveValues);
      	 	try {
      	 		wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}

			// Test deleting Asset Move
			Asset_Move__c move = new Asset_Move__c();
			move.RecordTypeId = rt_AssetMove[0].Id;
			move.Account__c = acct.Id;
			move.New_Account__c = acct.Id;
			move.New_Venue_Lookup__c = ven.Id;
			move.Contact__c = contact.Id;
			move.Asset_Type__c = at1.Id;
			move.Model__c = am1.Id;
			move.Asset_Sub_Type__c = ast1.Id;
			move.Fridge_Depot__c = pfmAccount.Id;
			insert move;
			for(integer i = 0; i < assetMoveSetup.size(); i++) {
				if (assetMoveSetup[i] == 'Flags') {
					assetMoveValues[i] = '3';
				}
				if (assetMoveSetup[i] == 'Id') {
					assetMoveValues[i] = move.Id;
				}
			}
      	 	clientData.clear();
      	 	clientData.add(assetMoveSetup);
      	 	clientData.add(assetMoveValues);
      	 	try {
      	 		wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}

			// Account Wholesalers
			clientData.clear();
			clientData.add(accountWholesalerSetup);
			clientData.add(accountWholesalerValues);
			clientData.add(orderSetup);
			clientData.add(orderValues);
			clientData.add(groupPromotionSetup);
			clientData.add(groupPromotionValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
			} catch(Exception e) {}

			// Contacts
			clientData.clear();
			clientData.add(contactSetup);
			clientData.add(contactValues);
      	 	clientData.add(assetMoveSetup);
      	 	clientData.add(assetMoveValues);
			clientData.add(eventSetup);
			clientData.add(eventValues);
			clientData.add(orderSetup);
			clientData.add(orderValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
			} catch(Exception e) {}

			List<String> assetMoveSetup1 = assetMoveHeaders.split(',');
			List<String> assetMoveSetup1Values = assetMoveHeaderValues.split(',');
			for (integer i = 0; i < contactSetup.size(); i++) {
				if (contactSetup[i] == 'Flags') {
					contactValues[i] = '1';
				}
				if (contactSetup[i] == 'Id') {
					contactValues[i] = (twoBillion + 1).format();
				}
				if (contactSetup[i] == 'Client_ID') {
					contactValues[i] = (twoBillion + 1).format();
				}
			}
			for (integer i = 0; i < assetMoveSetup1.size(); i++) {
				if (assetMoveSetup1[i] == 'Contact__c') {
					assetMoveSetup1Values[i] = (twoBillion + 1).format();
					break;
				}
			}
			List<String> orderSetup1 = orderHeaders.split(',');
			List<String> orderSetup1Values = orderHeaderValues.split(',');
			for(integer i = 0; i < orderSetup1.size(); i++) {
				if (orderSetup1[i] == 'Contact__c') {
					orderSetup1Values[i] = (twoBillion + 1).format();
					break;
				}
			}
			List<String> eventSetup1 = eventHeaders.split(',');
			List<String> eventSetup1Values = eventHeaderValues.split(',');
			for(integer i = 0; i < eventSetup1.size(); i++) {
				if (eventSetup1[i] == 'Contact__c') {
					eventSetup1Values[i] = (twoBillion + 1).format();
					break;
				}
			}
			clientData.clear();
			clientData.add(contactSetup);
			clientData.add(contactValues);
			clientData.add(assetMoveSetup1);
			clientData.add(assetMoveSetup1Values);
			clientData.add(orderSetup1);
			clientData.add(orderSetup1Values);
			clientData.add(eventSetup1);
			clientData.add(eventSetup1Values);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
			} catch(Exception e) {}
			


      	 	// Venues
			clientData.clear();  	     				  	 	
			clientData.add(venueSetup);
			clientData.add(venueValues);
      	 	clientData.add(assetMoveSetup);
      	 	clientData.add(assetMoveValues);
			clientData.add(contactSetup);
			clientData.add(contactValues);
			clientData.add(outletVisitSetup);
			clientData.add(outletVisitValues);
			try {
				wombat_sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(exception e) {}

			for(integer i = 0; i < venueSetup.size(); i++) {
				if (venueSetup[i] == 'Flags') {
					venueValues[i] = '1';
				}
				if (venueSetup[i] == 'Client_ID') {
					venueValues[i] = (twoBillion + 1).format();
				}
				if (venueSetup[i] == 'Id') {
					venueValues[i] = (twoBillion + 1).format();
				}
			}
			clientData.clear();  	     				  	 	
			clientData.add(venueSetup);
			clientData.add(venueValues);
			try {
				wombat_sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(exception e) {}

			// Events
			clientData.clear();  	     				  	 	
			clientData.add(eventSetup);
			clientData.add(eventValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}
      	 	
      	 	for(integer i = 0; i < eventSetup.size(); i++) {
      	 		if (eventSetup[i] == 'ActivityDate') {
      	 			eventValues[i] = null;
      	 		}
      	 		if (eventSetup[i] == 'ActivityDateTime') {
      	 			eventValues[i] = null;
      	 		}
      	 		if (eventSetup[i] == 'DurationInMinutes') {
      	 			eventValues[i] = '50';
      	 		}
      	 	}
			clientData.clear();  	     				  	 	
			clientData.add(eventSetup);
			clientData.add(eventValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}

			// Orders
			clientData.clear();  	     				
			clientData.add(orderItemSetup);
			clientData.add(orderItemValues);
			clientData.add(orderSetup);
			clientData.add(orderValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}
      	 	
      	 	// Order - for delete			
			for (integer i = 0; i < orderSetup.size(); i++) {
				if (orderSetup[i] == 'Flags') {
					orderValues[i] = '3';
				}
			}
			clientData.clear();
			clientData.add(orderSetup);
			clientData.add(orderValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
			} catch(Exception e) {	}
			
			
      	 	
			// Outlet Visit
			clientData.clear();  	     				      	 	
			clientData.add(outletVisitItemSetup);
			clientData.add(outletVisitItemValues);
			clientData.add(outletVisitSetup);
			clientData.add(outletVisitValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}

			// Promotion
			clientData.clear();
			clientData.add(promotionSetup);
			clientData.add(promotionValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}
      	 	
      	 	Promotion__c prom = new Promotion__c();
      	 	prom.Name = 'Test Promotion';
      	 	prom.Account__c = acct.Id;
      	 	prom.Contact__c = contact.Id;
      	 	prom.Is_Active__c = true;
      	 	prom.Promotion_Activity__c = promoActivity1.Id;
      	 	insert prom;
      	 	
      	 	// Test for delete of promotion
      	 	for(integer i = 0; i < promotionSetup.size(); i++) {
      	 		if (promotionSetup[i] == 'Flags') {
      	 			promotionValues[i] = '3';
      	 		}
      	 		if (promotionSetup[i] == 'Id') {
      	 			promotionValues[i] = prom.Id;
      	 		}
      	 	}
			clientData.clear();
			clientData.add(promotionSetup);
			clientData.add(promotionValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}

			// Test for update of promotion
			for(integer i = 0; i < promotionSetup.size(); i++) {
				if (promotionSetup[i] == 'Flags') {
					promotionValues[i] = '2';
				}
				if (promotionSetup[i] == 'Id') {
					promotionValues[i] = prom.Id;
				}
			}
			clientData.clear();
			clientData.add(promotionSetup);
			clientData.add(promotionValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}
			


			// GroupPromotion
			clientData.clear();
			clientData.add(groupPromotionSetup);
			clientData.add(groupPromotionValues);
			clientData.add(groupPromotionItemSetup);
			clientData.add(groupPromotionItemValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {}
				
			// Accounts - for delete      	 	
      	 	for (integer i = 0; i < accountSetup.size(); i++) {
      	 		if (accountSetup[i] == 'Id') {
      	 			accountValues[i] = acct.Id;
      	 		}
      	 		if (accountSetup[i] == 'Flags') {
      	 			accountValues[i] = '3';
      	 		}
      	 	}
      	 	clientData.clear();
			clientData.add(accountSetup);
			clientData.add(accountValues);
			try {
				wombat_Sync.updateServer(sessionId, ownerId, clientData);
      	 	} catch(Exception e) {
      	 		System.debug('Exception with updating account data. ' + e.getMessage());
      	 	}
						      	 	      	 				

			//Test wombat_Sync_Item
			wombat_Sync_Item wsi = new wombat_Sync_Item();
			wsi.Object_API_Name = 'Account';
			wsi.ColumnNames.add('Id');
			wsi.ColumnNames.add('Name');
			wsi.ColumnValues.add(acct.Id);
			wsi.ColumnValues.add('Test Account');
			wsi.records.add(u1);
			System.debug('Number of records in wsi: ' + wsi.totalSize);
		
			//Testing wombat_Sync_Object
			wombat_Sync_Object wso = new wombat_Sync_Object();	
			wso.Messages.add('Test message');
			wso.Items.add(wsi);
			System.debug('Number of messages in wso: ' + wso.totalSize);
			System.debug('Number of sync items in wso: ' + wso.totalItems);		

			// Test wombat_Build_ChangedDataSet			
			String di_product = 'Product__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Brand__c,Description__c,Mark_for_Deletion__c,Market__c,ProductCode__c,Status__c,Supplier__c,Unit_Cost__c,Case_Multiplier__c,Channel__c,Family__c,IsActive__c,Legacy_ID__c,Sort_Order__c,Carton_Qty__c,SAP_Material_Number__c,Bar_Code__c,Classification__c,Is_Wombat_Product__c,Legacy_Brand_Code__c,Product_Category__c,Wholesale_Price__c,Wholesaler_Number__c,Unit_Size__c,Pack_Quantity__c,Pallet_Quantity__c,Layer_Qty__c,Layer_Per_Pallet__c,Pricing_Reference_Material__c,Price_Material_Group__c,Market_Name__c,Category__c';
			String fi_product = 'Product__c,,false, WHERE Market_Name__c = ?,Australia';
			List<List<String>> objectDescribeInfo = new List<List<String>>();
			List<List<String>> filterInfo = new List<List<String>>();
			objectDescribeInfo.add(di_product.split(','));
			filterInfo.add(fi_product.split(','));
			
       		wso = wombat_Build_Changed_DataSet.buildChangeDataSet(sessionId, ownerId, '2012-01-01 00:00:00', objectDescribeInfo, filterInfo);	
			
			
			// Test wombat_UpdateSessionStatus
			//Id testUserId = [SELECT Id FROM User WHERE Alias = 'drood'][0].Id;
			wso = wombat_UpdateSessionStatus.updateSessionStatus(sessionID, u1.Id, 0);
			
			
			wss.Status__c = 'Success';
			wss.InProgress__c = false;
			update wss;
       }
       
       //SELECT Object_API_Name__c FROM wombat_Mobile_Config__c WHERE IsActive__c = true AND IsGraveyardable__c = true]
       	
    }
}