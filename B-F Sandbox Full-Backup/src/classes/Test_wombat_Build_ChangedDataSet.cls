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
private class Test_wombat_Build_ChangedDataSet {
	public final static Integer twoBillion = 2000000000;

    static testMethod void myUnitTest() {
              
        
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
		User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = p.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='wombatTestUser@b-f.com');
		System.debug('USER ID'+u1.Id);

		DateTime lastSyncDate = Datetime.now();
		String sLastSyncDate = lastSyncDate.format();
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
        

		String di_wombatMobileConfig = 'Wombat_Mobile_Config__c, Wombat_Mobile_Config__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,CreateOrder__c,Create_SOQL__c,IsActive__c,Object_API_Name__c,Object_Name__c,ReceiveDataFromClient__c,Select_SOQL__c,SendDataToClient__c,IsGraveyardable__c,Select_SOQL_for_Sync_Update__c';
		String di_salesforcePicklickControllingValues = 'Salesforce_Picklist_Controlling_Values__c, Salesforce_Picklist_Controlling_Values__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Object_Name__c,Field_Name__c,Value__c,Controller__c,Controller_Value__c,Is_Active__c';
		String di_account = 'Account,Id,IsDeleted,MasterRecordId,Name,RecordTypeId,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Phone,Fax,AccountNumber,Website,Industry,AnnualRevenue,NumberOfEmployees,CurrencyIsoCode,OwnerId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Jigsaw,JigsawCompanyId,AccountSource,SicDesc,Channel__c,Market__c,Region__c,Status__c,FN__Find_Nearby__c,FN__Lat__c,FN__Lon__c,SAP_Customer_Number__c,E_Mail_Address__c,Lead_Independent_Director__c,Expected_Monthly_Visits__c,Account_Licence_Type__c,Account_Type__c,Banner_Group__c,Banner_Sub_Group__c,Is_Active__c,Is_Main__c,LMAA_Number__c,Last_Visit_Date__c,Legal_Entity__c,Licence__c,Off_Segment__c,On_Segment__c,Order_Type__c,Sales_Region__c,Account_Licence_Number__c';
		String di_asset = 'Asset__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Account__c,Active__c,Agreement__c,Asset_Model__c,Asset_Type__c,Asset_Tag__c,Comments__c,Fridge_Details_Incorrect__c,Fridge_Sighted__c,Is_Active__c,Last_Sighted__c,Legacy_Code__c,Placement_Date__c,SAP_Asset__c,Serial__c,Supplier__c,Venue__c,AssetNumber__c,AccountNumber__c,Fridge_In_Fill__c,External_Branding__c,Internal_Branding__c';
		String di_contact = 'Contact,Id,IsDeleted,MasterRecordId,AccountId,LastName,FirstName,Salutation,Name,RecordTypeId,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone,Fax,MobilePhone,HomePhone,OtherPhone,AssistantPhone,ReportsToId,Email,Title,Department,AssistantName,LeadSource,Birthdate,Description,CurrencyIsoCode,OwnerId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,LastCURequestDate,LastCUUpdateDate,EmailBouncedReason,EmailBouncedDate,Jigsaw,JigsawContactId,FN__Find_Nearby__c,FN__Lat__c,FN__Lon__c,FN__Mapping_Address__c,FN__Mapping_Status__c,Data_Quality_Score__c,Nickname__c,Primary_Contact__c,Is_Fridge_Contact__c,Preferred_Contact_Method__c,Venue__c,AccountNumber__c,Legacy_Code__c';
		String di_accountWholesaler = 'Account_Wholesaler__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,AccountNumber__c,Account__c,Allow_Order__c,Delivery_Day_1__c,Delivery_Day_2__c,Is_Active__c,Legacy_Code__c,Notes__c,Wholesaler_Account_Name__c,Wholesaler_Account_Number__c,Wholesaler_Name__c,Wholesaler__c,Banner_Partner__c';
		String di_venue = 'Venue__c,Id,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Account__c,Area_Type__c,Channel__c,Is_Active__c,Legacy_Code__c,Notes__c,Segment__c,Venue_Name__c,AccountNumber__c';
		String di_brand = 'Brand__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Spirit_Type__c,Supplier__c,Brand_Code__c';
		String di_product = 'Product__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Brand__c,Description__c,Mark_for_Deletion__c,Market__c,ProductCode__c,Status__c,Supplier__c,Unit_Cost__c,Case_Multiplier__c,Channel__c,Family__c,IsActive__c,Legacy_ID__c,Sort_Order__c,Carton_Qty__c,SAP_Material_Number__c,Bar_Code__c,Classification__c,Is_Wombat_Product__c,Legacy_Brand_Code__c,Product_Category__c,Wholesale_Price__c,Wholesaler_Number__c,Unit_Size__c,Pack_Quantity__c,Pallet_Quantity__c,Layer_Qty__c,Layer_Per_Pallet__c,Pricing_Reference_Material__c,Price_Material_Group__c,Market_Name__c,Category__c';
		String di_order = 'Order__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Account_Name__c,Account__c,Contact__c,CreatedBy_Name__c,Legacy_Code__c,Notes__c,Order_Date__c,Order_Type__c,Postal_Code__c,State__c,Status__c,Street_del__c,Suburb__c,Wholesaler_Code__c,Wholesaler_Customer_Number__c,Wholesaler_Name__c,Wholesaler_Number__c,Wholesaler_State_Code__c,Wholesalers__c,Banner_Partner__c,Wholesaler_Account_Name__c,Material_Errors__c,City__c,AccountNumber__c';
		String di_order_item = 'Order_Item__c,Id,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Order__c,Brand__c,Carton_Bonus__c,Carton__c,Discount__c,Legacy_Code__c,Product__c,SAP_Material_Number__c,Total_Bonus_Units__c,Total_Units__c,Unit_Bonus__c,Unit__c,Wholesaler_Product_Number__c,Wholesaler_Product__c,Wholesaler__c,Banner_Partner__c,Price_Ref_Material__c,Max_PA_Per_Case__c,Account_id__c,PRM_Units_Per_Case__c,Missing_Material__c,Banner_PA__c,Outlet_PA__c';
		String di_outletVisit = 'Outlet_Visit__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Account__c,Competitor_Activity__c,Met_With__c,Visit_Comments__c,Visit_Date__c,Venue__c,AccountNumber__c,Visit_Counts__c,Status__c,Create_Offline_OVIs__c,Legacy_Code__c,AccountName__c';
		String di_outletVisitItem = 'Outlet_Visit_Item__c, Outlet_Visit_Item__c,Id,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Outlet_Visit__c,Bottle_Price_Special__c,Bottle_Price__c,Drink_Price_Special__c,Drink_Price__c,Outlet_Visit_Item_Key__c,Available__c,Facing__c,Double_Price_Special__c,Double_Price__c,Channel__c,Brand__c,Placement__c,Custom_Product__c,Position__c,Location_Off__c,Location_On__c,Location_Reporting__c,BackBarVisit__c,PriceTypeFlag__c,CocktailCount__c,Shelf_Category_Item__c,Legacy_Code__c';
		/*
[INFO] describe info for Promotion_Activity__c, Promotion_Activity__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Market__c,Brand__c,Active__c,Description__c,Activity_Budget__c,Begin_Date__c,End_Date__c,Promotion_Code__c,Promotion_Type__c,Target_Depletion__c,Target_Outlets__c,Promotion_Subtype__c,Channel__c,Promotion_Category__c,Project_Team__c,Budget_Cost_Center__c,Customer_Management_Group__c,Trade_Presenter__c,Evaluation_Rating__c,Evaluation_Comments__c,Status__c,Wombat_Active__c,QLD__c,NSW__c,VIC_TAS__c,SA_NT__c,WA__c,Total_Allocations__c,Field_Resource__c,Target_Demographic__c,Mechanics__c,Activity__c,Sub_Type__c
[INFO] describe info for Promotion__c, Promotion__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Sales_Manager__c,Brand_Manager__c,Finance_Manager__c,Promotion_Activity__c,Brand__c,Account__c,Account_Capacity_f__c,Approval_Status__c,Crew_Support__c,End_Time__c,Mechanism__c,Promotion_End_Date__c,Promotion_Start_Date__c,Special_Event__c,Start_Time__c,Support_and_Backup__c,Target_Age_Group__c,Target_Attendance__c,Total_Brand_Profit__c,Total_Margin__c,Total_Promotion_Cost__c,Promotion_Number__c,Account_Market__c,Estimated_Cost__c,status_of_Secondary_placement__c,Number_of_Bottles__c,Comments__c,Promotion_Start_Date_BFA__c,English_Name__c,Outlet_Class__c,Promotion_Sub_Type__c,Market__c,Particular_Agreement__c,Total_Pouring_Amount2__c,Total_Sales_Volume__c,Banner_Group__c,Buy_Period_End_Date__c,Buy_Period_Start_Date__c,Channel__c,Material_Product_Group__c,PA_Type__c,Promotion_Mechanics__c,Promotion_Type__c,State__c,TA_Type__c,Promotion_End_Date_BFA__c,Additional_Mechanics__c,Draw_Date__c,Winner_Name__c,Suburb__c,Post_Code__c,Telephone__c,Is_Active__c,Contact__c,Venue__c,Sales_Region__c,Promotion_Category__c,Remind_Me_Date__c,Promotion_Activity_AUD__c,Sub_Type__c,AUD_Channel__c,Shipping_City__c,Shipping_Country__c,Shipping_State__c,Shipping_Street__c,Shipping_Zip__c,Contact_Email__c,Contact_Phone__c,Contact_MobilePhone__c,AccountNumber__c,AccountName__c,Legacy_Code__c,Market_Manager__c
[INFO] describe info for Asset_Type__c, Asset_Type__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp
[INFO] describe info for Asset_Models__c, Asset_Models__c,Id,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Asset_Type__c
[INFO] describe info for Asset_Sub_Type__c, Asset_Sub_Type__c,Id,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Asset_Model__c
[INFO] describe info for Fridge_In_Fills__c, Fridge_In_Fills__c,Id,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Asset_Model__c,Fridge_In_Fill_Type__c
[INFO] describe info for Banner_Groups__c, Banner_Groups__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Banner_Group_Description__c,Customer_Number__c,State__c,Country__c,Sales_Organization__c,Ownership_Group__c
[INFO] describe info for Shelf_Category__c, Shelf_Category__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp
[INFO] describe info for Shelf_Category_Items__c, Shelf_Category_Items__c,Id,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Shelf_Category__c,Channel__c
[INFO] describe info for Wholesaler__c, Wholesaler__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Account__c,Is_Active__c,Legacy_Code__c,SAP_Number__c,State_Code__c,Wholesaler_Name__c,AccountNumber__c,Email__c,Sales_Organization__c
[INFO] describe info for Event, Event,Id,RecordTypeId,WhoId,WhatId,Subject,Location,IsAllDayEvent,ActivityDateTime,ActivityDate,DurationInMinutes,StartDateTime,EndDateTime,Description,AccountId,OwnerId,CurrencyIsoCode,IsPrivate,ShowAs,IsDeleted,IsChild,IsGroupEvent,GroupEventType,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,IsArchived,RecurrenceActivityId,IsRecurrence,RecurrenceStartDateTime,RecurrenceEndDateOnly,RecurrenceTimeZoneSidKey,RecurrenceType,RecurrenceInterval,RecurrenceDayOfWeekMask,RecurrenceDayOfMonth,RecurrenceInstance,RecurrenceMonthOfYear,ReminderDateTime,IsReminderSet,DB_Activity_Type__c,Legacy_Code__c
[INFO] describe info for Group_Promotions__c, Group_Promotions__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Activity_Code__c,Activity_Comment__c,Application__c,Approx_LUC_exc_GST__c,Banner_Group__c,Brand__c,Buy_Period_End_Date__c,Buy_Period_Start_Date__c,Co_Op_Type__c,Comments__c,Customer_Level__c,Deal_Channel__c,Deal_Method__c,Extra_Co_Op_per_Case__c,Extra_Unit_PA__c,Id__c,LUC_GST_INC__c,Lump_Sum_Co_OP__c,Lump_Sum__c,Margin__c,Material_Product_Group__c,Note_to_Approver__c,Objective__c,Ongoing_PA__c,PA_Type__c,Price_Type__c,Product_Class__c,Promotion_Group__c,Promotion_Mechanics__c,Customer_Promotion_ID__c,Promotion_Period_End_Date__c,Promotion_Period_Start_Date__c,Promotion_Type__c,Rate_Per_Case__c,Region__c,Sell_Price__c,State__c,Status__c,Tatic__c,Unit__c,Vistex_Agreement_Type__c,Volume_Source__c,Wholesaler__c,Account__c,Vistex_Agreement_Number__c,AccountNumber__c,AccountName__c,Account_Wholesaler__c,Legacy_Code__c
[INFO] describe info for Group_Promotion_Item__c, Group_Promotion_Item__c,Id,IsDeleted,Name,CurrencyIsoCode,RecordTypeId,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,LastActivityDate,Group_Promotion__c,Account__c,Banner__c,Brand_Major__c,Brand_Minor__c,Condition_Types__c,Discount_Amount__c,Discount_Percent__c,Distributor__c,FE__c,Manufacturing_Brand__c,Ongoing__c,Reference_Material_Group__c,Price_Unit__c,Price_Vision__c,Product__c,Value_Type__c,Price_Vision_Type__c,Item_Number__c,Reference_Material_Group_Number__c,Legacy_Code__c
[INFO] describe info for Reference_Material_Group__c, Reference_Material_Group__c,Id,OwnerId,IsDeleted,Name,CurrencyIsoCode,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,Reference_Material_Group_Number__c
[INFO] describe info for User, User,Id,Username,LastName,FirstName,Name,CompanyName,Division,Department,Title,Street,City,State,PostalCode,Country,Email,Phone,Fax,MobilePhone,Alias,CommunityNickname,IsActive,TimeZoneSidKey,UserRoleId,LocaleSidKey,ReceivesInfoEmails,ReceivesAdminInfoEmails,EmailEncodingKey,DefaultCurrencyIsoCode,CurrencyIsoCode,UserType,LanguageLocaleKey,EmployeeNumber,DelegatedApproverId,ManagerId,LastLoginDate,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,OfflineTrialExpirationDate,OfflinePdaTrialExpirationDate,UserPermissionsMarketingUser,UserPermissionsOfflineUser,UserPermissionsAvantgoUser,UserPermissionsCallCenterAutoLogin,UserPermissionsMobileUser,UserPermissionsSFContentUser,UserPermissionsInteractionUser,ForecastEnabled,UserPreferencesActivityRemindersPopup,UserPreferencesEventRemindersCheckboxDefault,UserPreferencesTaskRemindersCheckboxDefault,UserPreferencesReminderSoundOff,UserPreferencesDisableAllFeedsEmail,UserPreferencesDisableFollowersEmail,UserPreferencesDisableProfilePostEmail,UserPreferencesDisableChangeCommentEmail,UserPreferencesDisableLaterCommentEmail,UserPreferencesDisProfPostCommentEmail,UserPreferencesContentNoEmail,UserPreferencesDisableAutoSubForFeeds,UserPreferencesContentEmailAsAndWhen,UserPreferencesDisableMentionsPostEmail,UserPreferencesDisMentionsCommentEmail,UserPreferencesDisCommentAfterLikeEmail,UserPreferencesDisableLikeEmail,UserPreferencesDisableMessageEmail,UserPreferencesDisableBookmarkEmail,UserPreferencesDisableSharePostEmail,ContactId,AccountId,CallCenterId,Extension,FederationIdentifier,AboutMe,CurrentStatus,FullPhotoUrl,SmallPhotoUrl,DigestFrequency,DefaultGroupNotificationFrequency,Brand_Manager__c,Finance_Manager__c,Sales_Manager__c,Market__c,Create_Offline_Outlet_Visit_Records__c,TSID__c,Owner_Name__c,Wombat_Sync_Session_ID__c,LastTransactionStatus__c,DB_Region__c,Comments__c,Manger_Email__c,Market_Manager__c
[INFO] filterinfo for Promotion_Activity__c, Promotion_Activity__c,,false, WHERE Wombat_Active__c = true
[INFO] filterinfo for User, User,,false, WHERE Username = ?,brandon_ward@b-f.com.config01
*/
		String fi_product = 'Product__c,,false, WHERE Market_Name__c = ?,Australia';

		List<List<String>> objectDescribeInfo = new List<List<String>>();
		List<List<String>> filterInfo = new List<List<String>>();
		objectDescribeInfo.add(di_product.split(','));
		filterInfo.add(fi_product.split(','));
		      	
       	System.runAs(u1){
       		wombat_Sync_Object wso = wombat_Build_Changed_DataSet.buildChangeDataSet(sessionId, ownerId, '2012-01-01 00:00:00', objectDescribeInfo, filterInfo);	
       	}
    }
}