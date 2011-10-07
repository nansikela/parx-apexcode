public class WebSeminarDiplom {

    public String anzahlmodule { get; set; }

    public Portfolio__c portfolio { get; set; }
    public String seminarCode {get; set;}
    public List<Portfolio__c> seminarList {get; set;}
    
    //Getting Seminars Info
    public WebSeminarDiplom(){
    	String protfolioYear = WebConfig.getPortfolioYear();
        seminarCode = WebURLEncoder.decodeParam('seminarCode');
        try{
        System.debug('***********seminarCode:'+seminarCode);
        }catch(Exception e)
        {
        	System.debug(e);
        }
        portfolio = [	Select 
        					p.Anzeige_auf_website__c,
        					p.Dauer_in_Tagen__c, p.Code_Titel__c, 
        					p.Max_Teilnehmer__c, p.Zielgruppe__c, 
        					p.Untertitel__c,
        					p.Intro__c,
        					p.Inhalte__c,
        					p.Methode__c,
        					p.Teilnehmerhinweis__c, 
        					p.Name, 
        					p.NEU__c, 
        					p.Register__c, 
        					p.Seminartitel__c, 
        					p.Unterregister__c ,
        					p.ist_pr_fungsgeb_hr__c,
        					p.Hinweis_bei_Preis__c,
        					p.auf_website_buchbar__c,
        					p.Anzahl_der_Module__c,
        					p.Dauer_der_Ausbildung__c
        				from Portfolio__c p
        				WHERE p.anzeige_auf_website__c = true 
        				AND p.name = :seminarCode 
        				AND p.ist_Intensivprogramm__c =true 
        				AND p.portfolio_jahr__c = :protfolioYear Limit 1];
        //Korrektur alter <b> Tags zu h3				
        portfolio.Zielgruppe__c = portfolio.Zielgruppe__c.replace('<b>','<h3>').replace('</b>', '</h3>');
        try{
        	portfolio.Inhalte__c = portfolio.Inhalte__c.replace('<b>','<h3>').replace('</b>', '</h3>');
        }catch(Exception e){
        	System.debug('******************Exception: Inhalt: '+e);
        }
        try{
        	portfolio.Intro__c = portfolio.Intro__c.replace('<b>', '<h3>');
        	portfolio.Intro__c = portfolio.Intro__c.replace('</b>', '</h3>');
        }catch(Exception e){
        	System.debug('**********Exception:'+e);
        }
        
        //IF Teilnehmerhinweis is not empty
        if(portfolio.Teilnehmerhinweis__c != null){
        	portfolio.Teilnehmerhinweis__c = portfolio.Teilnehmerhinweis__c.replace('<b>','<h3>').replace('</b>', '</h3>');
        }				
        
        
        anzahlmodule = String.valueOf(portfolio.Anzahl_der_Module__c);
        seminarList = new List<Portfolio__c>();
        seminarList = [Select p.Anzeige_auf_website__c, p.Name, p.Register__c, p.Ist_optionaler_Teil__c, p.Seminartitel__c from Portfolio__c p WHERE (p.Teil_des_Intensivprogramms__r.Name =:seminarCode OR p.Teil_des_Intensivprogramms2__r.Name =:seminarCode) AND p.Anzeige_auf_website__c = true AND p.portfolio_jahr__c = :protfolioYear ORDER BY p.Anordung_im_Intensivprogramm__c];
        
        
    }
    
    public static String getLinkForSeminars(){
        return 'page?pageid='+WebURLEncoder.getPageIdById('p-00017');
    }
    
}