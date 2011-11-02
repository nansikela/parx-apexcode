public class WebEnhancedSearch {
    public List<SeminarContainer> seminarList {get; set;}
    public List<SeminarContainer> intensivSeminare {get; set;}
    
    
    public static boolean strategy {get; set;}
    public static boolean leadership {get; set;}
    public static boolean expertise{get; set;}
    public static boolean personality{get; set;}
    
    public WebEnhancedSearch()
    {
        
        // decode category from URL
        String category = WebURLEncoder.decodeParam('category');
        
        // set category keys
        
        if(category.contains('s')) strategy = true; else strategy = false;
        if(category.contains('l')) leadership = true; else leadership = false;
        if(category.contains('e')) expertise = true; else expertise = false;
        if(category.contains('p')) personality = true; else personality = false;
        
        
        seminarList = new List<SeminarContainer>();
        for(Product2 p: queryProduct())
        {
            seminarList.add(new SeminarContainer(p));
        }
        intensivSeminare = new List<SeminarContainer>();
        for(Portfolio__c p: queryPortfolio())
        {
            intensivSeminare.add(new SeminarContainer(p));
        }
    }
    
    public static List<Portfolio__c> queryPortfolio()
    {
        List<Portfolio__c> result;
        String query = 'SELECT p.name, p.seminartitel__c, p.Englisch__c, p.NEU__c, p.sprechende_Url__c FROM Portfolio__c p WHERE p.ist_Intensivprogramm__c = true  AND Portfolio_Jahr__c = \''+WebConfig.getPortfolioYear()+'\'';
        
        
        String q = WebURLEncoder.decodeParam('q');
        
        if(q!='')
        {
            /*Pattern Match */
            String exp= '([A-Z]{2})\\s(\\d{3})';
            String exp2= '$1$2';
            pattern myPattern = pattern.compile(exp);
            matcher myMatcher = myPattern.matcher('BI 200');
            q = myMatcher.replaceAll(exp2);
            q = 'PE120';
            
            q = q.replace('\'','');
            query+=' AND (p.name like \'%'+q+'%\'';
            query+=' OR p.name like \'%'+q+'%\'';
            query+=' OR p.Seminartitel__c like \'%'+q+'%\'';
            query+=' OR p.Register__c like \'%'+q+'%\'';
            query+=' OR p.Unterregister__c like \'%'+q+'%\'';
            query+=' OR p.Seminus_Kategorie_1__c like \'%'+q+'%\'';
            query+=' OR p.Seminus_Kategorie_2__c like \'%'+q+'%\'';
            query+=' OR p.Seminus_Kategorie_3__c like \'%'+q+'%\')';
            
        }
        /*query += ' AND ( ';
        
        //if no category is selected, all categories are selected
        if(!strategy && ! leadership && !expertise && !personality)
        {
            strategy = leadership = expertise = personality = true;
        }
        
        // select strategy
        if(strategy )
        {
            query += 'p.Register__c  = \'Strategie und Organisationsentwicklung\'';
        }
        
        // adding OR if necessary
        if(strategy && leadership)
        {
            query += ' OR ';
        }
        
        //select leadership
        if(leadership )
        {
            query += 'p.Register__c  = \'Führung\'';
        }
        
        // adding OR if necessary
        if(leadership && expertise)
        {
            query += ' OR ';
        }
        
        //select expertise
        if(expertise)
        {
            query += 'p.Register__c  = \'Fachkompetenz\'';
        }
        
        //adding OR if necessary
        if(expertise && personality)
        {
            query += ' OR ';
        }
        
        //select personality
        if(personality)
        {
            query += 'p.Register__c  = \'Persönlichkeitsentwicklung\'';
        }
        
        //select Seminarbeginn
        query += ' )';
        */
        
        
        
        
        
        query+= ' LIMIT 5';
        
        result = Database.query(query);
        
        
        return result;
    }
    
    
    public  boolean getIsResultEmpty()
    {
        if(seminarList.size()== 0 && intensivSeminare.size()==0)
        {
            return true;
        }
        return false;

    }
    
    
    public static List<Product2> queryProduct()
    {
        String query = 'SELECT p.name, p.portfolio__c, p.portfolio__r.Englisch__c, p.portfolio__r.NEU__c, p.portfolio__r.name, p.portfolio__r.seminartitel__c, p.seminarbeginn__c, p.portfolio__r.sprechende_URL__c, p.seminarende__c, p.veranstaltungsort2__c, p.veranstaltungsort2__r.account__r.BillingCity FROM Product2 p WHERE p.seminarbeginn__c>today AND p.Anzeige_auf_website__c = true AND p.Portfolio__r.Anzeige_auf_Website__c = true ';
        if(WebURLEncoder.decodeParam('d') != '')
        {
            query+=' AND p.seminarbeginn__c >='+WebURLEncoder.decodeParam('d');
        }
        
        String q = WebURLEncoder.decodeParam('q');
        if(q!='')
        {
            /*Pattern Match */
            String exp= '([A-Z]{2})\\s(\\d{3})';
            String exp2= '$1$2';
            pattern myPattern = pattern.compile(exp);
            matcher myMatcher = myPattern.matcher(q);
            q = myMatcher.replaceAll(exp2);
            //q = 'PE120';
            
            
            q = q.replace('\'','');
            query+=' AND (p.Portfolio__r.name like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.name like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Seminartitel__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Register__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Unterregister__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Seminus_Kategorie_1__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Seminus_Kategorie_2__c like \'%'+q+'%\'';
            query+=' OR p.Portfolio__r.Seminus_Kategorie_3__c like \'%'+q+'%\')';
            
        }
        
        
        query += ' AND ( ';
        
        //if no category is selected, all categories are selected
        if(!strategy && ! leadership && !expertise && !personality)
        {
            strategy = leadership = expertise = personality = true;
        }
        
        // select strategy
        if(strategy )
        {
            query += 'p.Portfolio__r.Register__c  = \'Strategie und Organisationsentwicklung\'';
        }
        
        // adding OR if necessary
        if(strategy && leadership)
        {
            query += ' OR ';
        }
        
        //select leadership
        if(leadership )
        {
            query += 'p.Portfolio__r.Register__c  = \'Führung\'';
        }
        
        // adding OR if necessary
        if(leadership && expertise)
        {
            query += ' OR ';
        }
        
        //select expertise
        if(expertise)
        {
            query += 'p.Portfolio__r.Register__c  = \'Fachkompetenz\'';
        }
        
        //adding OR if necessary
        if(expertise && personality)
        {
            query += ' OR ';
        }
        
        //select personality
        if(personality)
        {
            query += 'p.Portfolio__r.Register__c  = \'Persönlichkeitsentwicklung\'';
        }
        
        //select Seminarbeginn
        query += ' )';
        
        
        
        
        String region= WebURLEncoder.decodeParam('r');
        String city= WebURLEncoder.decodeParam('o');
        if(region != '' || city != ''){
            query += ' AND ';
        }
        
        if(region!='' && city!=''){
            query+='(';
        }
        if(region!='')
        {
            query+= ' p.veranstaltungsort2__r.region__c = \''+region+'\'';
        }
        
        //select city
        if(region!='' && city!=''){
            query+=' AND ';
        }
        
        if(city!='')
        {
            query+= ' p.veranstaltungsort2__r.account__r.BillingCity = \''+city+'\'';
        }
        
        if(region!='' && city!=''){
            query+=')';
        }
        query += ' ORDER BY p.seminarbeginn__c LIMIT 300';
        
        return Database.query(query);
    }
    
    
    public void sendMail()
    {
        String message;
        message = 'Die Suche ist \n';
        message += 'Datum:'+WebURLEncoder.decodeParam('d')+'\n';
        message += 'Query:'+WebURLEncoder.decodeParam('q')+'\n';
        message += 'Ort:'+WebURLEncoder.decodeParam('o')+'\n';
        message += 'Region:'+WebURLEncoder.decodeParam('r')+'\n';
        String[] toAddresses = new String[] {'support.customer+AnmeldungenDieAkademie@parx.com'}; 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject('Es wurde eine Suche ausgefuehrt');
        mail.setPlainTextBody(message);
        mail.setSenderDisplayName('Salesforce Support');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    class SeminarContainer{
        public String code {get; set;}
        public String seminarTitel {get; set;}
        public String seminarUntertitel {get; set;}
        public String seminarURL {get; set;}
        public String monat {get; set;}
        public boolean english{get; set;}
        public boolean neu {get; set;}
        public SeminarContainer(Product2 p)
        {
            if(p.portfolio__c != null)
            {
                this(p.portfolio__r);
            }
            
            if(p.Seminarende__c!= null && p.Seminarbeginn__c!= null)
            {
                seminarUntertitel = p.Seminarbeginn__c.format()+' - '+p.Seminarende__c.format()+', ';
                
                
                if(p.seminarbeginn__c.month() == 1)
                {
                    monat = 'Januar';
                }
                else if(p.seminarbeginn__c.month() == 2)
                {
                    monat = 'Februar';
                }
                else if(p.seminarbeginn__c.month() == 3)
                {
                    monat = 'März';
                }
                else if(p.seminarbeginn__c.month() == 4)
                {
                    monat = 'April';
                }
                else if(p.seminarbeginn__c.month() == 5)
                {
                    monat = 'Mai';
                }
                else if(p.seminarbeginn__c.month() == 6)
                {
                    monat = 'Juni';
                }
                else if(p.seminarbeginn__c.month() == 7)
                {
                    monat = 'Juli';
                }
                else if(p.seminarbeginn__c.month() == 8)
                {
                    monat = 'August';
                }
                else if(p.seminarbeginn__c.month() == 9)
                {
                    monat = 'September';
                }
                else if(p.seminarbeginn__c.month() == 10)
                {
                    monat = 'Oktober';
                }
                else if(p.seminarbeginn__c.month() == 11)
                {
                    monat = 'November';
                }
                else if(p.seminarbeginn__c.month() == 12)
                {
                    monat = 'Dezember';
                }
                
                
                
            }
            if(p.veranstaltungsort2__c != null && p.veranstaltungsort2__r.account__c != null)
            {
                seminarUntertitel += p.veranstaltungsort2__r.account__r.billingCity;
            }
            
        }
        
        public SeminarContainer(Portfolio__c p)
        {
            code = p.name;
            seminarTitel = p.seminarTitel__c;
            seminarURL = p.sprechende_URL__c;
            if(p.Neu__c != null)
            {
                neu =true;
            }
            else
            {
                neu = false;
            }
            
            if(p.Englisch__c == 'true')
            {
                english = true;
            }
            else
            {
                english = false;
            }
        }
    }
}