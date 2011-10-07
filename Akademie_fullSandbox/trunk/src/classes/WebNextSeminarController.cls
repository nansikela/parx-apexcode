public class WebNextSeminarController 
{
	public static Integer show{get; set;}
	
	
	//Getting Next 6 Seminars
	public static List<Product2> getNextSeminars()
	{
	    if(show ==null) show = 6;
	    return [SELECT p.Id, 
		    		p.Name, 
		    		p.portfolio__r.name, 
		    		p.Seminarbeginn__c, 
		    		p.portfolio__r.id, 
		    		p.portfolio__r.register__c,
		    		p.portfolio__r.sprechende_url__c 
	    		From 
	    			Product2 p 
	    		WHERE 
	    			p.Seminarbeginn__c > today 
	    			AND 
	    			p.Status_durchfuehrung__c = true
	    			AND
	    			Portfolio__r.Anzeige_auf_website__c = true
	    			/* 
	    			AND
	    			p.Anzeige_auf_website__c = true
	    			AND
	    			p.Ampel__c <> '%red%'
	    			AND
	    			*/
	    		ORDER BY 
	    			p.Seminarbeginn__c LIMIT :show];
	}

	//NextSeminarsLinks
	public static String getLink()
	{
	    return 'page?pageid='+WebURLEncoder.getPageIdById('p-00017');
	}
}