/**
*WebURLEncoder
*This class helps to decode or encode Parameter for the URL.
*
*@author Christian Deckert, Parx
*@version 1.0
*/
public // TODO: Auto-generated Javadoc

 /**
  * The Class WebURLEncoder.
  */
 class WebURLEncoder {
	
	/** The page list. */
	public static List<Page__c> pageList = new List<Page__c>();
	
	/** The flag. */
	public static boolean flag = false;
	
	/**
	 * Instantiates a new web url encoder.
	 */
	public WebURLEncoder(){
	//if(!flag){
	    pageList = [Select  p.Oberseite__c, p.Name__c, p.Name,  p.LastModifiedById, p.LastActivityDate, p.IsDeleted, p.Id, p.Home_Page__c, p.CreatedDate, p.CreatedById, p.Cache_expires__c, p.Anordnung__c From Page__c p];
	//} 
	}

 
	//Decode String
	/**
	 * Decode.
	 *
	 * @param s the s
	 * @return the string
	 */
	public static String decode(String s){
	    if(s==null) return '';
	    s = s.replace('_', '%');
	    s = EncodingUtil.urlDecode(s, 'IBM-850');
	    System.debug(s+'decoded');
	    return s;
	}
	
	//Decode Parameter
	/**
	 * Decode param.
	 *
	 * @param param the param
	 * @return the string
	 */
	public static String decodeParam(String param){
	    String s = ApexPages.currentPage().getParameters().get(param);
	    if(s==null){
	        return '';
	    }
	    s = s.replace('_', '%');
	    s = EncodingUtil.urlDecode(s, 'IBM-850');
	    
	    return s;
	}
	//Encode Paramter
	/**
	 * Encode param.
	 *
	 * @param s the s
	 * @return the string
	 */
	public static String encodeParam(String s){
	    if(s==null) return '';
	    s = EncodingUtil.urlEncode(s, 'IBM-850');
	    s = s.replace('%', '_');
	    System.debug(s+'encoded');
	    return s;
	}
	
	/**
	 * Gets the page id by id.
	 *
	 * @param id the id
	 * @return the page id by id
	 */
	public static String getPageIdById(String id){
		Page__c p = [Select p.Oberseite__c,  p.Name__c, p.Name, p.Anordnung__c From Page__c p WHERE p.name=:id];
		if(p.id != null)
		return p.id;
		return getPageIdById('p-00001');
		
	}

}