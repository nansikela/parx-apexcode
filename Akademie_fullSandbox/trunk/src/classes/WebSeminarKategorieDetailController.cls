public class WebSeminarKategorieDetailController {


    public static List<Portfolio__c> getRegisterWithPortfolio(){
        String parameterName = ApexPages.currentPage().getParameters().get('name');
        parameterName = WebURLEncoder.decodeParam('category');
                String pyear = WebConfig.getPortfolioYear();
        return [Select p.Unterregister__c,
        		p.Englisch__c, 
        		p.Seminartitel__c, 
        		p.Register__c, 
        		p.Name,
        		p.NEU__c,
        		p.Intensiv_Seminar_URL__c,
        		p.Sprechende_URL__c
        		From 
        			Portfolio__c p 
        		WHERE 
        			p.Portfolio_Jahr__c = :pyear
        			AND p.Anzeige_auf_Website__c = true  
        			AND p.Register__c = :parameterName 
        		ORDER BY    
        			/*Unterregister__c ASC,*/  
        			Ausgabenummer__c ASC];
        
    }
    
    public static String getRegisterTitel(){
        //return ApexPages.currentPage().getParameters().get('name');
        return WebURLEncoder.decodeParam('category');
    }
    
    public static String getSeminarURL(){
      return '?pageid='+WebURLEncoder.getPageIdById('p-00017')+'&category='+ApexPages.currentPage().getParameters().get('category')+'&seminarCode=';
    }

}