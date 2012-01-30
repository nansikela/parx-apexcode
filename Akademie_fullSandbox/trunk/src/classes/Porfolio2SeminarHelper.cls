global class Porfolio2SeminarHelper {

    public webservice static String createSeminars(Id portfolioId){
        String message = '';
        if(portfolioId != null){
            Portfolio2__c p=getPortfolio(portfolioId);
            if (p!=null) {
                if (p.Termine_n_chstes_Jahr__c!=null) {
                    Integer anzahl = p.Termine_n_chstes_Jahr__c.intValue();
                    message=createSeminarsFromPortfolio(p, anzahl);
                } else 
                    message = 'Im Feld "Termine nächstes Jahr" wurde noch keine Seminaranzahl definiert.';
            } else{
                message = 'Es wurde kein Portfolio mit der ID \''+ portfolioId + '\' gefunden.';
            }
        }
        return message;
            
    }
    
    public webservice static String createOneSeminar(Id portfolioId){
        String message = '';
        if(portfolioId != null){
            Portfolio2__c p=getPortfolio(portfolioId);
            if (p!=null) {
                message=createSeminarsFromPortfolio(p, 1);
            } else{
                message = 'Es wurde kein Portfolio mit der ID \''+ portfolioId + '\' gefunden.';
            }
        }
        return message;
    }
    
    public webservice static String SeminarAktualisieren(Id portfolioId){
        if(portfolioId != null){
            Portfolio2__c p=getPortfolio(portfolioId);
            if (p!=null) {
                list<Product2> Prods = new list<Product2>([select Description from Product2 where Portfolio2__c =: portfolioId]);
                for(Product2 prod:Prods) {
                    prod.Description = p.Zertifikatsinhalte__c;
                }
                Database.DMLOptions dml = new Database.DMLOptions();
			    dml.allowFieldTruncation = true;
                database.update(Prods, dml);
            } else{
                return 'No portfolio with Id \''+ portfolioId + '\' found.';
            }
        }
        return 'Die Inhalte der verknüpften Seminare wurden aktualisiert.';
    }
    
    private static String createSeminarsFromPortfolio(Portfolio2__c p, Integer anzahl) {
        String message='';
        try{
            if(p!=null){
                List<Product2> productToInsertList = new List<Product2>();
                Integer i = 0;
                //loop and create products
                for(i=0; i<anzahl; i++){
                    Product2 prod = createNewProduct(p);
                    productToInsertList.add(prod);
                }
                
                if(!productToInsertList.isEmpty()){
                    try{
                        insert productToInsertList;
                        message = 'Es wurde/n erfolgreich ' + productToInsertList.size()+ ' Seminar/e erstellt.';
                    }catch(System.DMLException e){
                        message = 'Bei der Seminarerstellung ist ein Fehler aufgetreten: ' + e.getMessage();
                    }
                }else
                    message = 'Es wurden keine Seminare erstellt.';
            }else
                message = 'Es wurde kein Portfolio gefunden.';
        }catch(System.Exception e){
            System.debug('*** Exception: ' + e);
            message = e.getMessage();
        }
        System.debug('***message ' + message);
        return message;
    }
    
    private static Product2 createNewProduct(Portfolio2__c p) {
        Product2 prod = new Product2();
        prod.Name = p.Seminartitel__c;
        prod.Sonderpreis__c = p.Sonderpreis__c;
        prod.Seminargebuehr__c = p.Web_Preis__c;
        prod.Seminarcode__c = p.Name;
        prod.Max_Teilnehmer__c = p.Max_Teilnehmer__c;
        prod.Key_Note_Speaker__c = p.Key_Note_Speaker__c;
        prod.FM_Dozent__c = p.Leitung__c;
        prod.Description = p.Zertifikatsinhalte__c;
        prod.Dauer_in_Tagen__c = p.Dauer_in_Tagen__c;
        prod.In_Vorbereitung__c = true;
        prod.Portfolio2__c = p.Id;
        prod.Uhrzeit_Beginn__c = p.Beginn__c;
        prod.Uhrzeit_Ende__c = p.Ende__c;
        prod.Min_Teilnehmer_f_r_Garantie__c = p.Min_Teilnehmer__c;
        prod.Kostenstelle__c = p.Kostenstelle__c;
        prod.Produktmanager__c = p.Produktmanager__c;
        prod.Bereiche__c = p.Bereiche__c;
        prod.AZWV_Ma_nahmenzulassung__c = p.AZWV_Massnahmenzulassung__c;
        return prod;
    }
    
    private static Portfolio2__c getPortfolio(Id portfolioId) {
        Portfolio2__c p;
        try {
            p=[Select 
                p.Termine_n_chstes_Jahr__c
                , p.Name
                , p.Min_Teilnehmer__c
                , p.Beginn__c
                , p.Ende__c
                , p.Sonderpreis__c
                , p.Seminartitel__c
                , p.Zertifikatsinhalte__c
                , p.Web_Preis__c
                , p.Max_Teilnehmer__c
                , p.Leitung__c
                , p.Key_Note_Speaker__c
                , p.Dauer_in_Tagen__c 
                , p.Kostenstelle__c
                , p.Produktmanager__c
                , p.Bereiche__c
                , p.AZWV_Massnahmenzulassung__c
                From Portfolio2__c p where p.Id = :portfolioId];
        } catch (System.Exception e) {}
        return p;
    }

}