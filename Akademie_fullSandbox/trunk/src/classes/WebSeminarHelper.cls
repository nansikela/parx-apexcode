public class WebSeminarHelper {

    public WebSeminarHelper()
    {
    
    }
    
    
    // Get events of a specific portfolio
    public List<Product2> getSeminarEvents(Id portFolioSfdcId)
    {
        List<Product2> seminarList = [Select 
                            p.Co_Trainer__c, p.Co_Trainer__r.FirstName, p.Co_Trainer__r.Id, p.Co_Trainer__r.LastName, p.Trainer__c, p.Trainer__r.FirstName, p.Trainer__r.Id, p.Trainer__r.LastName ,
                            
                            p.Id,
                            p.Veranstaltungsort__c, 
                            p.Seminartitel__c, 
                            p.Seminarort__c, 
                            p.Seminarort_Stadt__c,
                            p.Seminarort__r.Name,
                            p.seminarbeginn__c,
                            p.Seminarende__c, 
                            p.Seminarcode__c, 
                            p.ProductCode, 
                            p.FM_Dozent__c,
                            p.FM_Seminarort__c,
                            p.FM_Seminaradresse__c,
                            p.Portfolio__r.Anzeige_auf_website__c, 
                            p.Portfolio__r.Seminartitel__c, 
                            p.Portfolio__r.Seminarname__c, 
                            p.Portfolio__r.Portfolio_Jahr__c,
                            p.Portfolio__r.Untertitel__c,
                            p.Portfolio__r.Inhalte__c, 
                            p.Portfolio__r.Intro__c,
                            p.Portfolio__r.Methode__c,  
                            p.Portfolio__r.Zielgruppe__c,
                            p.Portfolio__r.Id, 
                            p.Portfolio__c 
                        From 
                            Product2 p
                        Where
                            /*seminarcode__c = :seminarCode*/
                            portfolio__c = :portFolioSfdcId
                        and
                            seminarbeginn__c >= today
                        and
                            status_durchfuehrung__c = true
                        Order by
                            seminarbeginn__c asc
                        ];
                        
        return seminarList;
    
    }
    
    
    public List<Portfolio__c> getAdditionalSeminars(Portfolio__c pf)
    {
        List<Portfolio__c> additionalSeminars = new List<Portfolio__c>();
        
        if(pf.Weiterf_hrende_Seminare__c != null) 
        {
            String [] wfSem = pf.Weiterf_hrende_Seminare__c.split(',');
            
            for(String wfseminar : wfSem) 
            {
                    Portfolio__c pwf = this.getPortfolioBySeminarcode(wfSeminar.replaceAll(' ', ''), null);
                    additionalSeminars.add(pwf);
            }
            
            
        }       
        
        return additionalSeminars;
    }
    
    
    public Portfolio__c getPortfolioBySeminarcode(String SeminarCode, String year)
    {
        
        if(year == null) {
            // use current year if nothing else provided
            year = WebConfig.getPortfolioYear();
        }
        
        List<Portfolio__c> pfl = [SELECT
                                    Anzeige_auf_website__c, 
                                    Seminartitel__c, 
                                    Seminarname__c, 
                                    Portfolio_Jahr__c,
                                    Untertitel__c,
                                    Inhalte__c, 
                                    Intro__c,
                                    Teilnehmerhinweis__c,
                                    Methode__c,  
                                    Zielgruppe__c,
                                    Id,
                                    Preis__c,
                                    Hinweis_bei_Preis__c,
                                    englisch__c,
                                    Sonderpreisinfo__c,
                                    NEU__c,
                                    Dauer_in_Tagen__c,
                                    Max_Teilnehmer__c,
                                    Name,
                                    Weiterf_hrende_Seminare__c
                                FROM
                                    Portfolio__c
                                WHERE
                                    Name = :seminarCode
                                AND
                                    Anzeige_auf_website__c = true
                                AND
                                    Portfolio_jahr__c = :year 
                                ];
                                
        // There should only be one                     
        return pfl.get(0);  
    
    }
        
    
    public void getPortfolioBySfdcId(Id portfolioId)
    {
    
    }
    

}