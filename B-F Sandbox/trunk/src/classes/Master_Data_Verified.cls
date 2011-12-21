global class Master_Data_Verified {

    webservice static String init(String AccId) {
        Account account = [select id, Last_Master_Data_Review__c from Account where Id =: AccId ];
        account.Last_Master_Data_Review__c = system.today();
        update account;
        return 'Your account has been updated'; 
    }
}