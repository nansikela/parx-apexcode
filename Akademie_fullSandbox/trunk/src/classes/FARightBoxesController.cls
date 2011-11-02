/**
 * Firmenakademie RightBoxesController
 * @author Christian Deckert
 * @version 1.0
 */
public class FARightBoxesController 
{
    List<Ansprechpartner> ansprechpartner;
    List<FASeminarTermine.Seminar>seminareList;
    List<Weiterfuehrendes_Portfolio__c>weiterfuehrendeSeminarList;
    List<ShortInfoElemet> priceInfoList;
    List<ShortInfoElemet> priceIntensivInfoList;
    
    public Integer show {get; set;}
    
    public FARightBoxesController()
    {
        if(show == null || show == 0)
        {
            show = 10;
        }
    }
    
    
    static Portfolio2__c currentPortfolio;
    public List<Ansprechpartner>getAnsprechpartner()
    {
        if(ansprechpartner == null)
        {
            Map<String, Ansprechpartner> ansprechpartnerMap = new Map<String, Ansprechpartner>();
            ansprechpartner = new List<Ansprechpartner>();
            String bereichId = WebURLEncoder.decodeParam('bereich');
            List<Bereich__c> bereichList = [SELECT ID, name, verantwortlicher__c, verantwortlicher__r.anrede__c, verantwortlicher__r.titel__c, verantwortlicher__r.name, verantwortlicher__r.Foto__c, verantwortlicher__r.vorname__c, verantwortlicher__r.eMail__c, verantwortlicher__r.Telefon__c FROM Bereich__c WHERE Hauptbereich__c = :bereichId OR id = :bereichId ORDER BY Anordnung__c];
            for(Bereich__c b:bereichList)
            {
                //Ansprechpartner und Themen
                if(b.verantwortlicher__c!= null)
                {
                    if(ansprechpartnerMap.containsKey(String.valueOf(b.verantwortlicher__c)))
                    {
                        ansprechpartnerMap.get(String.valueOf(b.verantwortlicher__c)).add(b);
                    }else
                    {
                        ansprechpartnerMap.put(String.valueOf(b.verantwortlicher__c), new Ansprechpartner(b));
                    }
                }
            }
            ansprechpartner = ansprechpartnerMap.values();
        }
        return ansprechpartner;
    }
    
    class Ansprechpartner
    {
        public String name {get; set;}
        public List<String> verantwortlichBereich {get; set;}
        public String telefon {get; set;}
        public String eMail  {get; set;}
        public String foto {get; set;}
        public String anrede {get; set;}
        /** 
         * Ertsellt einen Bereichsansprechpartner und fügt den bereich an
         *
         * @param Bereich
         */
        public Ansprechpartner(Bereich__c bereich)
        {
            name= '';
            if(bereich.verantwortlicher__r.titel__c != null)
            {
                name += bereich.verantwortlicher__r.titel__c+' ';
            }
            name += bereich.verantwortlicher__r.Vorname__c+' '+bereich.verantwortlicher__r.name;
            telefon = bereich.verantwortlicher__r.telefon__c;
            email = bereich.verantwortlicher__r.eMail__c;
            foto = bereich.verantwortlicher__r.foto__c;
            anrede = bereich.verantwortlicher__r.anrede__c;
            add(bereich);
        }
        /** 
         * Fügt den Bereich zu einer Person hinzu
         *
         * @param Bereich
         */
        public void add(Bereich__c bereich)
        {
            if(verantwortlichBereich== null)
            {
                verantwortlichBereich = new List<String>();
            }
            verantwortlichBereich.add(bereich.name);
        }
    }
    
    /** 
     * Liefert eine Liste von zukünfigen Seminaren zurück / Interpreter je nach Kontext (Bereich / Portfolio)
     *
     * @return Liste von Seminar terminen
     */
    public List<FASeminarTermine.Seminar> getNextSeminars()
    {
        if(show == null || show == 0)
        {
            show = 10;
        }
        if(WebURLEncoder.decodeparam('bereich')!=''){
            getNextSeminarsFromBereich();
        } else if(WebURLEncoder.decodeparam('portfolioId')!='')
        {
            getNextSeminarsFromPortfolio();
        }
        return getNextSeminarsFromAny();
        
        return null;
    }
    
    /** 
     * Liefert eine Liste von zukünfigen Seminaren zurück an hand des Bereichs
     *
     * @return Liste von Seminar terminen
     */
    public List<FASeminarTermine.Seminar> getNextSeminarsFromBereich()
    {
        if(seminareList== null)
        {
            String bereichid = WebURLEncoder.decodeparam('bereich');
            seminareList = getNextSeminarByBereichID(bereichid);
        }
        return seminareList;
    }
    /** 
     * Liefert eine Liste von zukünfigen Seminaren zurück an Hand eines Portfolios
     *
     * @return Liste von Seminar terminen
     */
    public List<FASeminarTermine.Seminar> getNextSeminarsFromPortfolio(){
        if(seminareList == null)
        {
            String portfolioId = WebURLEncoder.decodeparam('portfolioId');
            String bereichId;
            List<Portfolio2__c> portfolioList = [SELECT Bereich__r.Hauptbereich__c FROM Portfolio2__c WHERE ID = :portfolioId ];
            if(portfolioList.size()>0)
            {
                bereichId = portfolioList.get(0).Bereich__r.Hauptbereich__c;
                seminareList = getNextSeminarByBereichID(bereichid);
            }
            
        }
        return seminareList;
    }
    
    
    public List<FASeminarTermine.Seminar> getNextSeminarsFromAny(){
        if(seminareList == null || seminareList.size() == 0)
        {
            seminareList = new List<FASeminarTermine.Seminar>();
            
            for(Seminar_to_Portfolio__c s : [Select s.Seminar__r.Anzeige_auf_website__c, s.Seminar__r.Seminarende__c, Seminar__r.Trainer__c, Seminar__r.Co_Trainer__c, Seminar__r.Co_Trainer__r.Firstname, Seminar__r.Co_Trainer__r.Lastname, Seminar__r.Co_Trainer__r.Sprechende_URL__c,  Seminar__r.Trainer__r.Firstname, Seminar__r.Restpl_tze__c, Seminar__r.Trainer__r.Lastname, Seminar__r.Trainer__r.Sprechende_URL__c,s.Seminar__r.Seminarbeginn__c, s.Seminar__c, s.Portfolio__r.URL__c, s.Portfolio__r.Live__c, s.Portfolio__r.Seminartitel__c, s.Portfolio__r.Name, Ort__c, s.Portfolio__c, s.Firma_id__c From Seminar_to_Portfolio__c s WHERE s.Seminar__r.Anzeige_auf_website__c = true AND Firma_id__c = :String.valueOf(FAHelper.getCurrentFirma().id).subString(0,15) AND s.Seminar__r.Seminarbeginn__c>today  ORDER BY s.Seminar__r.Seminarbeginn__c LIMIT :show])
            {
                seminareList.add(new FASeminarTermine.Seminar(s));
            }
        }
        return seminareList;
    }
    
    
    
    /** 
     * Liefert eine Liste von zukünfigen Seminaren zurück an Hand einer bereich Id
     *
     * @param Bereich Id
     * @return Liste von Seminar terminen
     */
    private List<FASeminarTermine.Seminar> getNextSeminarByBereichID(String bereichid)
    {
        
        List<Portfolio2__c> portfoliosInBereich = [SELECT ID FROM Portfolio2__c WHERE Bereich__r.Hauptbereich__c = :bereichid];
        if(portfoliosInBereich.size()>0)
        {
            FASeminarTermine controller = new FASeminarTermine(portfoliosInBereich);
            return controller.seminarList;
        }
        return null;
    }
    /** 
     * Liefert eine Liste von weiterführenden Portfolios zurück im Kontext eines Portfolios
     *
     * @return Liste von Portfolio2
     */
    public List<Weiterfuehrendes_Portfolio__c> getWeiterfuehrendeSeminare()
    {
        
        if(weiterfuehrendeSeminarList == null)
        {
            if(WebURLEncoder.decodeParam('portfolioId')!= '')
            {
                weiterfuehrendeSeminarList = [SELECT End_Portfolio__c, End_Text__c, End_URL__c, End_Portfolio__r.name, End_Portfolio__r.seminartitel__c, End_Portfolio__r.url__c FROM Weiterfuehrendes_Portfolio__c WHERE Start_Portfolio__c = :WebURLEncoder.decodeParam('portfolioId')];
            }else if (WebURLEncoder.decodeParam('groupId')!= '')
            {
                weiterfuehrendeSeminarList = [SELECT End_Portfolio__c, End_Text__c, End_URL__c, End_Portfolio__r.name, End_Portfolio__r.seminartitel__c, End_Portfolio__r.url__c FROM Weiterfuehrendes_Portfolio__c WHERE Start_Produktgruppe__c = :WebURLEncoder.decodeParam('groupId')];
            }
        }
        return weiterfuehrendeSeminarList;
    }
    /** 
     * Prüft ob Weiterführende Portfolios vorhanden sind
     *
     * @return is Weiterführendes Seminar vorhanden
     */
    public boolean getisWeiterfuehrendeSeminare()
    {
        if(getWeiterfuehrendeSeminare().size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    /** 
     * Liefert "Short Info" für Portfolios zurück
     *
     * @return List of Short Info Elements
     */
    public List<ShortInfoElemet> getShortInfo()
    {
        List<ShortInfoElemet> result = new List<ShortInfoElemet>();
        Portfolio2__c portfolio = getCurrentPortfolio();
        
        //Dauer
        String dauer = String.valueOf(portfolio.Dauer_in_Tagen__c);
        if(dauer!=null)dauer = dauer.replace('.0','');
        if(dauer=='1')
        {
            dauer+= ' Tag';
        }else
        {
            dauer+=' Tage';
        }
        result.add(new ShortInfoElemet('Dauer', dauer));
        
        
        //Teilnehmer
        String teilnehmer ='';
        if(FAHelper.getCurrentFirma().id != 'a0g20000000If9L')
        {
            if(portfolio.Min_Teilnehmer__c != null)
            {
                teilnehmer = 'min. ';
                teilnehmer += String.valueOf(portfolio.Min_Teilnehmer__c);
                
                teilnehmer+='</br>';
            }
        }
        if(portfolio.Max_Teilnehmer__c != null)
        {
            teilnehmer+= 'max. '+String.valueOf(portfolio.Max_Teilnehmer__c);
            teilnehmer = teilnehmer.replace('.0','');
        }
        
        result.add(new ShortInfoElemet('Teilnehmer', teilnehmer));
        
        //beginn
        result.add(new ShortInfoElemet('Beginn', portfolio.beginn__c));
        //ende
        result.add(new ShortInfoElemet('Ende', portfolio.ende__c));
        return result;
    }
    
    public class ShortInfoElemet
    {
        public String label {get; set;}
        public String content {get; set;}
        public boolean isDisplayed {get; set;}
        
        public ShortInfoElemet(String label, String content)
        {
            this.label = label;
            this.content = content;
            if(content != null && content!= '')
            {
                this.isDisplayed = true;
            }
            else
            {
                this.isDisplayed = false;
            }
        }
    }
    /** 
     * Liefert booking URL zurück für Portfolios
     *
     * @return Booking URL
     */
    public String getBookingURL()
    {
        if(getIsBookingURL())
        
        {
            Portfolio2__c p = getCurrentPortfolio();
            return p.url__c+'/order';
        }
        else
        {
            return null;
        }
    }
    
    /** 
     * Prüft ob das aktuelle Portfolio im Web Buchbar ist
     *
     * @return is Booking URL
     */
    public boolean getIsBookingURL()
    {
        if(getCurrentPortfolio().Buchbar__c!= null && getCurrentPortfolio().Buchbar__c)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    /** 
     * Liefert Preis Informationen für Portfolios zurück im Kontext eines Portfolios
     *
     * @return Liste von Short Info Elements
     */
    public List<ShortInfoElemet> getPriceInfo()
    {
        if(priceInfoList== null)
        {
            priceInfoList = new List<ShortInfoElemet>();
            
            Portfolio2__c portfolio = getCurrentPortfolio();
            String preis;
            
            if(portfolio.Web_Preis__c != null && portfolio.Web_Preis__c!= 0)
            {
                preis= '<strong>'+String.valueOf(portfolio.Web_Preis__c).replace('.',',').replace(',00',',-')+' EUR</strong> zzgl. MwSt.';
            }
            
            
            priceInfoList.add(new ShortInfoElemet('PREIS', preis));
            priceIntensivInfoList = new List<ShortInfoElemet>();
            for(Produktgruppenmitglied__c pgm: [SELECT ID, Ueberschrift__c, Text__c, Box__c FROM Produktgruppenmitglied__c WHERE Portfolio2__c = :getCurrentPortfolio().id])
                {
                    if(pgm.Box__c == '1. Box')
                    {
                        priceInfoList.add(new ShortInfoElemet(pgm.Ueberschrift__c, pgm.Text__c));
                    }else if(pgm.Box__c == '2. Box')
                    {
                        priceIntensivInfoList.add(new ShortInfoElemet(pgm.Ueberschrift__c, pgm.Text__c));
                    }
                }
            
            
        }
        return priceInfoList;
    }
    
    
    
    public boolean getIsIntensivInfo()
    {
        if(getIntensivInfo().size()>0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public List<ShortInfoElemet> getIntensivInfo()
    {
        getPriceInfo();
        return priceIntensivInfoList;
    }
    
    
    
    /** 
     * Liefert aktuelles Portfolio zurück
     *
     * @return Portfolio2
     */
    private Portfolio2__c getCurrentPortfolio()
    {
        if(currentPortfolio== null)
        {
            String portfolioId = WebURLEncoder.decodeparam('portfolioId');
            List<Portfolio2__c> portfolioList = [SELECT id, url__c,Dauer_in_Tagen__c, Web_Preis__c, Min_Teilnehmer__c, beginn__c, ende__c, Max_Teilnehmer__c, seminartitel__c, Buchbar__c FROM Portfolio2__c WHERE ID = :portfolioId];
            if(portfolioList.size()>0)
            {
                currentPortfolio = portfolioList.get(0);
            }
        }
        return currentPortfolio;
    }
    
    /** 
     * Gibt die Kundenberatungs eMail für Portfolios zurück
     *
     * @return eMail String
     */
    public String getKundenberatungeMail()
    {
        if(FAHelper.getCurrentPerson().Firma__c != null && FAHelper.getCurrentPerson().Firma__r.name == 'Vossloh')
        {
            return 'rvochezer@die-akademie.de';
        }
        else
        {
            return 'beratung@die-akademie.de';
        }
    }
    
    /** 
     * Gibt die Kundenberatungs Phone für Portfolios zurück
     *
     * @return Phone String
     */
    public String getKundenberatungePhone()
    {
        if(FAHelper.getCurrentPerson().Firma__c != null && FAHelper.getCurrentPerson().Firma__r.name == 'Vossloh')
        {
            return '+49.7551.9368-133';
        }
        else
        {
            return '+49.7551.9368-185';
        }
    }
    
    
    public Veroeffentlichung getVeroeffentlichung()
    {
        Veroeffentlichung v = new Veroeffentlichung();
        String portfolioId = WebURLEncoder.decodeparam('portfolioId');
        String groupId = WebURLEncoder.decodeparam('groupId');
        if(portfolioId!= null && portfolioId!= '')
        {   
            List<Portfolio2__c> portfolioVeroeffentlichung = [SELECT ID, Ver_ffentlichung__c, Ver_ffentlichung__r.Amazon_HTML_Code__c, Ver_ffentlichung__r.Amazon_HTML_Code_Kurztext__c, Ver_ffentlichung__r.Amazon_Bild__c FROM Portfolio2__c WHERE id = :portfolioId AND Ver_ffentlichung__c != null];
            if(portfolioVeroeffentlichung.size()>0)
            {
                v.veroeffentlichung = portfolioVeroeffentlichung.get(0).Ver_ffentlichung__r;
                v.isVeroeffentlichung = true;
            }
        }
        
        if(groupId!= null && groupId!= '')
        {   
            List<Gruppe__c> portfolioVeroeffentlichung = [SELECT ID, Ver_ffentlichung__c, Ver_ffentlichung__r.Amazon_HTML_Code__c, Ver_ffentlichung__r.Amazon_HTML_Code_Kurztext__c, Ver_ffentlichung__r.Amazon_Bild__c FROM Gruppe__c WHERE id = :groupId AND Ver_ffentlichung__c != null];
            if(portfolioVeroeffentlichung.size()>0)
            {
                v.veroeffentlichung = portfolioVeroeffentlichung.get(0).Ver_ffentlichung__r;
                v.isVeroeffentlichung = true;
            }
        }
        
        
        return v;
    }
    
    public class Veroeffentlichung
    {
        public Ver_ffentlichung__c veroeffentlichung {get; set;}
        public boolean isVeroeffentlichung {get; set;}
        
        public Veroeffentlichung()
        {
            isVeroeffentlichung = false;
            
        }
    }
    
    
    
    /** 
     * Test methode
     */
    static testMethod void test(){
        Bereich__c b = [SELECT id FROM Bereich__c WHERE Hauptbereich__c = null LIMIT 1];
        ApexPages.currentPage().getParameters().put('bereich', b.id);
        
        Portfolio2__c p = [SELECT ID FROM Portfolio2__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('portfolioId', p.id);
        
        FARightBoxesController controller = new FARightBoxesController();
        controller.getAnsprechpartner();
        controller.getNextSeminarsFromBereich();
        controller.getisWeiterfuehrendeSeminare();
        controller.getBookingURL();
        controller.getShortInfo();
        controller.getPriceInfo();
        controller.getNextSeminars();
        controller.getKundenberatungePhone();
        controller.getKundenberatungeMail();
        controller.getVeroeffentlichung();
    }
}