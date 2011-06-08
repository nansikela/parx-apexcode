public class IE9FixUtil {
	public static void fixIt(){
       	//IE9 Visualforce hack
       	String browserType = Apexpages.currentPage().getHeaders().get('USER-AGENT'); //gets the browser name 
       	
       	if(browserType != null && browserType.contains('MSIE')){
       	    Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=7');
       	}	
    }
}