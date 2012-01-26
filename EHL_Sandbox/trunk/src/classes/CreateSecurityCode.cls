public class CreateSecurityCode {

	private String secret = '34hf3%h.129x19P2'; //16 chars
	private String objectIdLeft;
	private String objectIdRight;
	private integer objectIdLength;
	private String stringId;
	private String plainCode;
	private String securityCode;
	private String url = 'http://preferences.ehl.edu/?securityCode=';
	
	/*
	
	Calculates a security login link for a given object ID
	
	*/
	
	public String calculateSecurityCode(String stringId){
		
		//stringId = String.valueOf(l.id);
		
		objectIdLeft = stringId.substring(0, 5);
		objectIdRight = stringId.substring(5, 18);
	
		plainCode = objectIdLeft + secret + objectIdRight;
		
		// Complete security code
		securityCode = stringId.substring(8, 18) + EncodingUtil.convertToHex(crypto.generateDigest('SHA1', Blob.valueOf(plainCode))) + stringId.substring(0, 8);
		
		// append code to url
		securityCode = url + securityCode;

		return securityCode;		

	}




}