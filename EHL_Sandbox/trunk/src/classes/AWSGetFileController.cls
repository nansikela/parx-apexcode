public class AWSGetFileController {
	
	public String url {get;set;}
	public String appDocId {get;set;}
	
	private String errorMsg;
	private String URL_START = 'https://apply.ehl.ch/awsFileView.php';
	private String ALGORITHM = 'SHA1';
	private String SECRET = 'KT^6mGo2x7';

	
	public AWSGetFileController(){
		try{
			//Blob keySHA1;
			String keySHA1;
			Datetime dt = Datetime.now();
			String timestamp = dt.format('yyyyMMddHHmmssZ');
			errorMsg = '';
			if(ApexPages.currentPage().getParameters().get('adId') != null){
			        appDocId = ApexPages.currentPage().getParameters().get('adId');
			        List<Application_Document__c> adList = [Select a.Path__c From Application_Document__c a where a.Id = :appDocId];
			        if(adList.isEmpty()){
			        	errorMsg = 'Application Document Id is not valid';
			        }else{
			        	String path = adList[0].Path__c;
				        keySHA1 = EncodingUtil.convertToHex(Crypto.generateDigest(ALGORITHM, Blob.valueOf(path+timestamp+SECRET)));
		       			url = URL_START + '?path='+EncodingUtil.base64Encode(Blob.valueOf(path))+'&date='+EncodingUtil.base64Encode(Blob.valueOf(timestamp))+'&key='+keySHA1;
			        }
			}else{
			        appDocId = '-1';
			        errorMsg = 'Application Document Id must be provided in URL';
			}
	
			
	   
	       	if(errorMsg.length() > 0){
	            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMsg));
	       	}
        }catch(System.Exception e){
            System.debug('**** Exception: ' +e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }      
    }
}