global class Austauschartikel {
  
  private static list<OpportunityLineItem> olis = new list<OpportunityLineItem>();
  private static list<PricebookEntry> prods = new list<PricebookEntry>();
  private static map<Id, Id> prodsMap = new map<Id, Id>();
  private static list<ArtikelLizenz__c> ALs = new list<ArtikelLizenz__c>();
  private static map<String, Id> ALsMap = new map<String, Id>();
  
  webService static String init(String artId, String Austauschartikel){
    if(Austauschartikel == null || Austauschartikel == '')
      return 'bitte ein Austauschartikel auswählen!';
    
    Product2 prod = new Product2();
    prod = [select id, PDKZ01__c from Product2 where Id =: artId limit 1];
    if(prod.PDKZ01__c > 3)
      return 'Austausch unmöglich weil Produktionsstufe > 3';
      
    getThem(artId, Austauschartikel);
    updateThem(Austauschartikel);
    
    return 'true';
  }     
         
  webService static String initMassUnlock(String artId, String Austauschartikel){
    if(Austauschartikel == null || Austauschartikel == '')
      return 'bitte ein Austauschartikel auswählen!';

    getNewOLIsandUpdate(Austauschartikel);
    
    return 'true';
  } 
  
  private static void getThem(Id artIdTemp, String Austauschartikel) {
    String artId = artIdTemp;  
    artId = artId.substring(0,15);
    String artIdQ='%'+artId+'%'; 
    olis = [select  o.SCHL2D__r.LZN015__c
          , o.medienart_id__c
          , o.medienart_55__c
          , o.isSammelnummernOLI__c
          , o.isMWST__c
          , o.isFWULager__c
          , o.Verkaufsprogramm__c
          , o.Verkaufspreis_Netto__c
          , o.UnitPrice
          , o.UmsatzEinzelpreis__c
          , o.Titel__c
          , o.StatusPosition__c
          , o.Sperrkz__c
          , o.Sperrkz_Text__c
          , o.SortOrder
          , o.Sig1Id__c
          , o.ServiceDate
          , o.STAT2D__c
          , o.SCHL2D__c
          , o.Rechnung__c
          , o.RED211__c
          , o.Quantity
          , o.Produkttyp__c
          , o.Produktionsstufe__c
          , o.Product2Id__c
          , o.PricebookEntryId
          , o.PreisbuchId__c
          , o.Preis465557__c
          , o.Preis465557_Gesamt__c
          , o.PDKZ2D__c
          , o.OpportunityId
          , o.OppVKP_Einzelpreis__c
          , o.OppVKP_Einzelpreis10306__c
          , o.OppTeillieferung__c
          , o.OppStageName__c
          , o.OppRechnungsempf_nger__c
          , o.OppRechnungsArt__c
          , o.OppRabatt__c
          , o.OppAnzahlSchulen__c
          , o.OeV_Rechtetext__c
          , o.Name_Splitted__c
          , o.Medienart_copy_for_roll_up__c
          , o.MedSig1Prod__c
          , o.MWSt__c
          , o.MWSt_Satz_berechnet__c
          , o.MWSt_Gesamtpreis__c
          , o.MWSt_19_Betrag__c
          , o.MWSt_07_Betrag__c
          , o.MEDA2D__c
          , o.Lizenztext__c
          , o.Lizenzrechtende__c
          , o.Lizenznummer__c
          , o.Lizenzmenge__c
          , o.ListPrice
          , o.Liefertext__c
          , o.Liefermenge__c
          , o.LieferanzeigeId__c
          , o.LastModifiedDate
          , o.LastModifiedById
          , o.LIKZ2D__c
          , o.LAOR2D__c
          , o.KreisListe__c
          , o.KOMM2D__c
          , o.KENN2D__c
          , o.IsDeleted
          , o.Id
          , o.GELM2D__c
          , o.Fremdvertrieb__c
          , o.FRME2D__c
          , o.Description
          , o.CreatedDate
          , o.CreatedById
          , o.Betrag_Rabatt__c
          , o.Beschreibung_Sammelnummer__c
          , o.Belegtext__c
          , o.Beleg_MWSt_19_Betrag__c
          , o.Beleg_MWSt_07_Betrag__c
          , o.Beleg_Gesamtpreis_fuer_Rollup__c
          , o.ArtikelProduktionsstufe__c
          , o.Anzahl_Schulen_berechnet__c
          , o.Anzahl_Schulen__c
          , o.AbsatzMengeDerLizenz__c
          , o.AUPO2D__c 
          From OpportunityLineItem o 
          where o.Product2Id__c  like : artIdQ AND o.STAT2D__c != 'Gelöscht'];
    prods = [Select id, Pricebook2Id From PricebookEntry where Product2Id =: Austauschartikel];
    for(PriceBookEntry prod:prods) {
      prodsMap.put(prod.PriceBook2Id, prod.Id);
    } 
    ALs = [select id, LZN015__c from ArtikelLizenz__c where Artikel__c =: Austauschartikel ];
    //AND SPK015__c = false];
    
    for(ArtikelLizenz__c AL:ALs) {
      ALsMap.put(AL.LZN015__c, AL.Id);
    }
  }
  
  private static void getNewOLIsandUpdate(String Austauschartikel) {
    olis = [select o.SCHL2D__r.LZN015__c, o.medienart_id__c, o.medienart_55__c, o.isSammelnummernOLI__c, o.isMWST__c, o.isFWULager__c, o.Verkaufsprogramm__c, o.Verkaufspreis_Netto__c, o.UnitPrice, o.UmsatzEinzelpreis__c, o.Titel__c, o.StatusPosition__c, o.Sperrkz__c, o.Sperrkz_Text__c, o.SortOrder, o.Sig1Id__c, o.ServiceDate, o.STAT2D__c, o.SCHL2D__c, o.Rechnung__c, o.RED211__c, o.Quantity, o.Produkttyp__c, o.Produktionsstufe__c, o.Product2Id__c, o.PricebookEntryId, o.PreisbuchId__c, o.Preis465557__c, o.Preis465557_Gesamt__c, o.PDKZ2D__c, o.OpportunityId, o.OppVKP_Einzelpreis__c, o.OppVKP_Einzelpreis10306__c, o.OppTeillieferung__c, o.OppStageName__c, o.OppRechnungsempf_nger__c, o.OppRechnungsArt__c, o.OppRabatt__c, o.OppAnzahlSchulen__c, o.OeV_Rechtetext__c, o.Name_Splitted__c, o.Medienart_copy_for_roll_up__c, o.MedSig1Prod__c, o.MWSt__c, o.MWSt_Satz_berechnet__c, o.MWSt_Gesamtpreis__c, o.MWSt_19_Betrag__c, o.MWSt_07_Betrag__c, o.MEDA2D__c, o.Lizenztext__c, o.Lizenzrechtende__c, o.Lizenznummer__c, o.Lizenzmenge__c, o.ListPrice, o.Liefertext__c, o.Liefermenge__c, o.LieferanzeigeId__c, o.LastModifiedDate , o.LastModifiedById, o.LIKZ2D__c, o.LAOR2D__c, o.KreisListe__c, o.KOMM2D__c, o.KENN2D__c, o.IsDeleted, o.Id, o.GELM2D__c, o.Fremdvertrieb__c, o.FRME2D__c , o.Description, o.CreatedDate, o.CreatedById, o.Betrag_Rabatt__c, o.Beschreibung_Sammelnummer__c, o.Belegtext__c, o.Beleg_MWSt_19_Betrag__c, o.Beleg_MWSt_07_Betrag__c, o.Beleg_Gesamtpreis_fuer_Rollup__c, o.ArtikelProduktionsstufe__c, o.Anzahl_Schulen_berechnet__c, o.Anzahl_Schulen__c, o.AbsatzMengeDerLizenz__c, o.AUPO2D__c
                From OpportunityLineItem o where Product2Id__c  =: Austauschartikel AND STAT2D__c != 'Gelöscht'];
    list<OpportunityLineItem> olistoupdate = new list<OpportunityLineItem>();
    for(OpportunityLineItem oli:olis) {
      if(oli.STAT2D__c != '' && oli.STAT2D__c != null)
        SystemSettings.logError('Entsperrung unmöglich weil Status ist nicht leer', 'Massentsperren/getNewOLIs()', 'Product2', oli.Id);
      else {
        oli.Sperrkz__c = false;
        olistoupdate.add(oli);
      }
    }
    
    if(!olis.isEmpty())
      update olistoupdate;
      
    SystemSettings.insertErrors();
  }
  
  private static void updateThem(String Austauschartikel) {
    OpportunityLineItem oToClone;
    list<OpportunityLineItem> oToCloneToUpdate = new list<OpportunityLineItem>();
    list<OpportunityLineItem> olistoupdate = new list<OpportunityLineItem>();
    list<OpportunityLineItem> olistoinsert = new list<OpportunityLineItem>();
 //   list<String> OliIds2Delete = new list<String>();
  //  list<OpportunityLineItem> OliIds2Deletelist = new list<OpportunityLineItem>();
 //    list<OpportunityLineItem> olistoupdate_old = new list<OpportunityLineItem>();
 //    list<OpportunityLineItem> olistoupdate_new = new list<OpportunityLineItem>();
     
    for(OpportunityLineItem oli:olis) {
      if((oli.GELM2D__c!=null && oli.GELM2D__c>0) || oli.STAT2D__c=='Fakturiert' || oli.STAT2D__c=='Freigabe')
        SystemSettings.logError('Austausch unmöglich weil bereits Lieferung erfolgt ist!', 'Austauschartikel/Updatethem()', 'Product2', oli.Id);
      else {      
        oToClone = new OpportunityLineItem();
      //  list<String> Ids = new list<String>();
      //  Ids.add(oli.)
      //  cloneClever.cloneDynamic(oToClone, oToClone, lizenzIds);
        oToClone = oli.clone(false, true);
        
        system.debug('Oclone debug ' + oToClone.PricebookEntryId);
        oToClone.PricebookEntryId = prodsMap.get(oToClone.PreisbuchId__c);
        system.debug('Oclone debug2 ' + oToClone.PricebookEntryId);
        
        if(ALsMap.containsKey(oli.SCHL2D__r.LZN015__c)) {
          //will be update normally
          oToClone.SCHL2D__c = ALsMap.get(oli.SCHL2D__r.LZN015__c);
          
    //      OliIds2Delete.add(oToClone.KreisListe__c);
          oToClone.KreisListe__c=null;
          oToClone.TotalPrice = null;
          oToClone.skip_Workflow__c = true;
          oToClone.FRME2D__c=0;
          oToClone.GELM2D__c=0;
          oToClone.Liefermenge__c=0;
          oToClone.STAT2D__c=null;
          oToClone.Sperrkz__c = true;
          olistoinsert.add(oToClone);
 //         olistoupdate_old.add(oli);
          oli.STAT2D__c = 'Gelöscht';
          olistoupdate.add(oli);
 //         olistoupdate_new.add(oli);
        }
        else {
          //will be add to the Error Log cause the Lizenz does not exist.
          SystemSettings.logError('Austausch unmöglich weil die Lizenznummer nicht existiert oder gesperrt ist', 'Austauschartikel/Updatethem()', 'Product2', oli.Id);
        }
      }
    }

 /*   if(!OliIds2Delete.isEmpty()) {
	    OliIds2Deletelist  = [select  o.SCHL2D__r.LZN015__c, o.medienart_id__c, o.medienart_55__c, o.isSammelnummernOLI__c, o.isMWST__c, o.isFWULager__c, o.Verkaufsprogramm__c, o.Verkaufspreis_Netto__c, o.UnitPrice, o.UmsatzEinzelpreis__c, o.Titel__c, o.StatusPosition__c, o.Sperrkz__c, o.Sperrkz_Text__c, o.SortOrder, o.Sig1Id__c, o.ServiceDate, o.STAT2D__c, o.SCHL2D__c, o.Rechnung__c, o.RED211__c, o.Quantity, o.Produkttyp__c, o.Produktionsstufe__c, o.Product2Id__c, o.PricebookEntryId, o.PreisbuchId__c, o.Preis465557__c, o.Preis465557_Gesamt__c, o.PDKZ2D__c, o.OpportunityId, o.OppVKP_Einzelpreis__c, o.OppVKP_Einzelpreis10306__c, o.OppTeillieferung__c, o.OppStageName__c, o.OppRechnungsempf_nger__c, o.OppRechnungsArt__c, o.OppRabatt__c, o.OppAnzahlSchulen__c, o.OeV_Rechtetext__c, o.Name_Splitted__c, o.Medienart_copy_for_roll_up__c, o.MedSig1Prod__c, o.MWSt__c, o.MWSt_Satz_berechnet__c, o.MWSt_Gesamtpreis__c, o.MWSt_19_Betrag__c, o.MWSt_07_Betrag__c, o.MEDA2D__c, o.Lizenztext__c, o.Lizenzrechtende__c, o.Lizenznummer__c, o.Lizenzmenge__c, o.ListPrice, o.Liefertext__c, o.Liefermenge__c, o.LieferanzeigeId__c, o.LastModifiedDate , o.LastModifiedById, o.LIKZ2D__c, o.LAOR2D__c, o.KreisListe__c, o.KOMM2D__c, o.KENN2D__c, o.IsDeleted, o.Id, o.GELM2D__c, o.Fremdvertrieb__c, o.FRME2D__c , o.Description, o.CreatedDate, o.CreatedById, o.Betrag_Rabatt__c, o.Beschreibung_Sammelnummer__c, o.Belegtext__c, o.Beleg_MWSt_19_Betrag__c, o.Beleg_MWSt_07_Betrag__c, o.Beleg_Gesamtpreis_fuer_Rollup__c, o.ArtikelProduktionsstufe__c, o.Anzahl_Schulen_berechnet__c, o.Anzahl_Schulen__c, o.AbsatzMengeDerLizenz__c, o.AUPO2D__c
	                from OpportunityLineItem o where Id IN: OliIds2Delete];
	    for(OpportunityLineItem oli:OliIds2Deletelist) {
	  //  	olistoupdate_old.add(oli);
	    	oli.STAT2D__c = 'Gelöscht';
	    }
	    if(!OliIds2Deletelist.isEmpty())
	    	olistoupdate.addAll(OliIds2Deletelist);
    }
    */
    if(!olistoinsert.isEmpty())
      insert olistoinsert;
    if(!olistoupdate.isEmpty()) {
     	onOpportunityLineItem.inFutureContextStoredId = '';
        update olistoupdate;
    }
      
  //  if(!olistoupdate_new.isEmpty() )
  // 	  onOpportunityLineItem.onupdate(olistoupdate_new, olistoupdate_old);
      
    if (!olistoinsert.isEmpty()) {
      map<Id, OpportunityLineItem> newolimap = new map<Id, OpportunityLineItem>();
      set<Id> newoliids=new set<ID>();
      for (OpportunityLineItem oli: olistoinsert) {
        if (!newoliids.contains(oli.id)) newoliids.add(oli.id);
      }
      for (OpportunityLineItem oli:[SELECT Id, medienart_55__c, KreisListe__c, medienart_id__c, Product2Id__c, Sperrkz__c FROM OpportunityLineItem WHERE Id IN :newoliids OR KreisListe__c IN:newoliids]) {
        oli.Sperrkz__c = true;
        if (!newolimap.containsKey(oli.id)) newolimap.put(oli.id,oli);    
      }
      if (!newolimap.isEmpty()) {
     //   map<String, OpportunityLineItem> olimap = new map<String, OpportunityLineItem>();
       /* for (OpportunityLineItem oli46: newolimap.values()) {
          if (oli46.medienart_55__c!=null && oli46.medienart_55__c!='' && !olimap.containsKey(oli46.medienart_55__c)) {
            for (OpportunityLineItem oli55: newolimap.values()) {
              if (oli55.Product2Id__c==oli46.medienart_55__c) {
                oli46.KreisListe__c=oli55.Id;
                oli55.KreisListe__c=oli46.Id;
                oli55.Sperrkz__c = true;
                if (!olimap.containsKey(oli46.Id)) olimap.put(oli46.Id,oli46);
                if (!olimap.containsKey(oli55.Id)) olimap.put(oli55.Id,oli55);
              }
            }
          }
        }*/
      //  if (!olimap.isEmpty()) {
          try {
            update newolimap.values();
          } catch (System.DmlException e) {
            SystemSettings.logError(e.getMessage(),'DEBUG');
            if (SystemSettings.isDebug) throw e;
          }
      //  }
      }
    }  
      
    SystemSettings.insertErrors();
  }
}