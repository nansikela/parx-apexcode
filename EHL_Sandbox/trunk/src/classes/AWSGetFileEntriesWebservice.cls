global class AWSGetFileEntriesWebservice {
	
	webService static Boolean createApplicationDocument(String aemmId, String applicationId) {
		Boolean isSuccessfull = true;
		try{
			List<Application__c> appList = [Select id from Application__c where id = :applicationId];
			if(appList.size() == 1){
				AWSFileHelper helper = new AWSFileHelper(aemmId, applicationId);
				helper.writeToSalesforce();
			}else{
				isSuccessfull = false;
			}
		}catch(System.Exception e){
			System.debug('**** Exception occured: ' +e);
			isSuccessfull = false;
		}
		
		return isSuccessfull;
		
	}
}