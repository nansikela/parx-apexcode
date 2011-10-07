public class WebStartseiteFacade{

    
 
	public static String AUSBILDUNGEN {get; set;}


    public static String categoryURL;
    //public WebSearchFacade search = new WebSearchFacade();
    public static String input{get; set;}
    
    public WebStartseiteFacade(){
        categoryURL = '?pageid='+WebURLEncoder.getPageIdById('p-00007');       
    }
    public static String getFuehrungLink(){
        return categoryURL + '&category='+ WebURLEncoder.encodeParam('Führung');
    }
    public static String getStrategieLink(){
        return categoryURL + '&category='+ WebURLEncoder.encodeParam('Strategie und Organisationsentwicklung');
    }
    public static String getPersoenlichkeitLink(){
        return categoryURL + '&category='+ WebURLEncoder.encodeParam('Persönlichkeitsentwicklung');
    }
    public static String getFachkompetenzLink(){
        return categoryURL + '&category='+ WebURLEncoder.encodeParam('Fachkompetenz');
    }
    public static String getCoachingLink(){
        return categoryURL + '&category='+ WebURLEncoder.encodeParam('Coaching');
    }
    
    public List<AkademieBlog__c> getBlogArticle()
    {
    	return AkademieBlog__c.getAll().values();
    }
    
    static {
    	AUSBILDUNGEN = WebConfig.AUSBILDUNGEN;    	
    }
    
}