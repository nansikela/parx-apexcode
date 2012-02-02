public class onProduct {
//    public static boolean inFutureContext = false;
      public static String inFutureContextStoredId = '';
      public static boolean alreadyRunning=false;
      
      public static void onUpdate(list<Product2> trigNew, list<Product2> trigOld) {
            
            Integer i = 0;
            Set<Double> Produktionsstufen = new set <Double> {1,2,4,6,7,8};
            list<Product2> listtoWorkon = new list<Product2>();
            list<Produktionsstand__c> listtoUpdate = new list<Produktionsstand__c>();
            Produktionsstand__c temptoUpdate;
            
            map<double, double> dqwer = new map<Double, Double>();
      
            for(Product2 trig:trigNew) {  
                  //for the produktionsstufe
                  if(trig.PDKZ01__c != trigOld.get(i).PDKZ01__c && Produktionsstufen.contains(trig.PDKZ01__c) ) {
                        temptoUpdate = new Produktionsstand__c();
                        temptoUpdate.Artikel__c = trig.Id;
                        temptoUpdate.Datum__c = trig.Aenderung_Produktionsstufe__c;
                        if(trig.PDKZ01__c < trigOld.get(i).PDKZ01__c && trigOld.get(i).PDKZ01__c >= 4)
                             trig.FRMJ01__c = null;
                        
                        if(trig.PDKZ01__c == 1)
                             temptoUpdate.Status__c = '01';
                        else if(trig.PDKZ01__c == 2)
                             temptoUpdate.Status__c = '02';
                        else if(trig.PDKZ01__c == 4)
                             temptoUpdate.Status__c = '05';
                        else if(trig.PDKZ01__c == 6)
                             temptoUpdate.Status__c = '07';
                        else if(trig.PDKZ01__c == 7)
                             temptoUpdate.Status__c = '08';
                        else if(trig.PDKZ01__c == 8)
                             temptoUpdate.Status__c = '09';
                        
                        listtoUpdate.add(temptoUpdate);
                  }
                  //for the Datum
                  if(trig.Auslieferung_geplant__c != null && trig.Auslieferung_geplant__c != trigOld.get(i).Auslieferung_geplant__c ) {           
                        temptoUpdate = new Produktionsstand__c();
                        temptoUpdate.Artikel__c = trig.Id;
                        temptoUpdate.Datum__c = trig.Auslieferung_geplant__c;
                        temptoUpdate.Status__c = '10';
                        
                        listtoUpdate.add(temptoUpdate);
                  }
                  
                  i++;
            }
            try {
            if(!listtoUpdate.isEmpty())
                  alreadyRunning=true;
                  insert listtoUpdate;
                  alreadyRunning=false;
            }
            catch(system.DmlException e) {
                  system.debug('Problem to insert');
            }
      }
      /*public static void onUpdate_NeuberechnungKO_O2_init(list<Product2> trigNew) {
            list<String>
            
      }*/


    public static void orderQuerverweis(list<Product2> trigNew) {
        
    /*  list<String> Ids = new list<String>();
        
    
        for(Product2 trig:trigNew) {
            
            Ids.add(trig.Id);
        }
        
        list<Product2> listProd = new list<Product2>([select id, medienartnummer__c, medienartSig1__c, Sig1Zaehlnummer__c, 
                                        ProductCode, name, SIG1__c, SIG2__c, 
                                        SIG3__c, SIG4__c, SIG5__c, SIG6__c
                                        from Product2 where Id IN: Ids]);
    */                                  
                                        
                                        
        map<String, map<String, map<String, Id>>> Signature3 = new map<String, map<String, map<String, Id>>>();
        map<String, map<String, Id>> Signature2;
        map<String, Product2> Signature = new map<String, Product2>();
        list<String> Sig = new list<String>();
        for(Product2 p:trigNew/*listProd*/) {
            if(/*!((p.medienartnummer__c == '55' ||p.medienartnummer__c == '57') && p.medienartSig1__c == '46') &&
               !(p.medienartnummer__c == '46' && (p.medienartSig1__c == '55' ||p.medienartnummer__c == '57'))*/true) {
                if(p.Sig2__c != null)
                    Sig.add(p.Sig2__c);
                if(p.Sig3__c != null)
                    Sig.add(p.Sig3__c);
                if(p.Sig4__c != null)
                    Sig.add(p.Sig4__c);
                if(p.Sig5__c != null)
                    Sig.add(p.Sig5__c);
                if(p.Sig6__c != null)
                    Sig.add(p.Sig6__c);
            }
        }
        list<Product2> product = new list<Product2>();
        if(!Sig.isEmpty() )
            product = [select id, medienartnummer__c, F16001__c, UntermedienartSig1__c from Product2 where Id IN: Sig];
        
        for(Product2 p:product) {
            Signature.put(p.Id, p);
        }
        
        for(Product2 p:trigNew/*listProd*/) {
            Signature2 = new map<String, map<String, Id>>();
            
            if(Signature.containsKey(p.Sig1__c)) {
                if(!Signature2.containsKey(Signature.get(p.Sig1__c).Medienartnummer__c))
                    Signature2.put(Signature.get(p.Sig1__c).Medienartnummer__c, new map<String, Id>());
                Signature2.get(Signature.get(p.Sig1__c).Medienartnummer__c).put(Signature.get(p.Sig1__c).F16001__c, Signature.get(p.Sig1__c).Id);
            }
            if(Signature.containsKey(p.Sig2__c)){
                if(!Signature2.containsKey(Signature.get(p.Sig2__c).Medienartnummer__c))
                    Signature2.put(Signature.get(p.Sig2__c).Medienartnummer__c, new map<String, Id>());
                Signature2.get(Signature.get(p.Sig2__c).Medienartnummer__c).put(Signature.get(p.Sig2__c).F16001__c, Signature.get(p.Sig2__c).Id);
            }
            if(Signature.containsKey(p.Sig3__c)){
                if(!Signature2.containsKey(Signature.get(p.Sig3__c).Medienartnummer__c))
                    Signature2.put(Signature.get(p.Sig3__c).Medienartnummer__c, new map<String, Id>());
                Signature2.get(Signature.get(p.Sig3__c).Medienartnummer__c).put(Signature.get(p.Sig3__c).F16001__c, Signature.get(p.Sig3__c).Id);
            }
            if(Signature.containsKey(p.Sig4__c)){
                if(!Signature2.containsKey(Signature.get(p.Sig4__c).Medienartnummer__c))
                    Signature2.put(Signature.get(p.Sig4__c).Medienartnummer__c, new map<String, Id>());
                Signature2.get(Signature.get(p.Sig4__c).Medienartnummer__c).put(Signature.get(p.Sig4__c).F16001__c, Signature.get(p.Sig4__c).Id);
            }
            if(Signature.containsKey(p.Sig5__c)){
                if(!Signature2.containsKey(Signature.get(p.Sig5__c).Medienartnummer__c))
                    Signature2.put(Signature.get(p.Sig5__c).Medienartnummer__c, new map<String, Id>());
                Signature2.get(Signature.get(p.Sig5__c).Medienartnummer__c).put(Signature.get(p.Sig5__c).F16001__c, Signature.get(p.Sig5__c).Id);
            }
            if(Signature.containsKey(p.Sig6__c)) {
                if(!Signature2.containsKey(Signature.get(p.Sig6__c).Medienartnummer__c))
                    Signature2.put(Signature.get(p.Sig6__c).Medienartnummer__c, new map<String, Id>());
                Signature2.get(Signature.get(p.Sig6__c).Medienartnummer__c).put(Signature.get(p.Sig6__c).F16001__c, Signature.get(p.Sig6__c).Id);
            }
            if(!Signature2.isEmpty())
                Signature3.put(p.Id, Signature2);
        }

        for(Product2 p:trigNew/*listProd*/) {
            if((p.medienartnummer__c == '55' || p.medienartnummer__c == '57') && p.medienartSig1__c != '46') { //O2, Sig1 should be 46 or 42 if this reference exists in Sig2 3 4 5 or 6
                if(Signature3.containsKey(p.Id) && Signature3.get(p.Id).containsKey('46')) {
                    String temp = p.Sig1__c;
                    p.Sig1__c = Signature3.get(p.Id).get('46').values().get(0);
                    if(p.Sig2__c == p.Sig1__c) 
                        p.Sig2__c = temp;   
                    if(p.Sig3__c == p.Sig1__c) 
                        p.Sig3__c = temp;   
                    if(p.Sig4__c == p.Sig1__c) 
                        p.Sig4__c = temp;   
                    if(p.Sig5__c == p.Sig1__c) 
                        p.Sig5__c = temp;   
                    if(p.Sig6__c == p.Sig1__c) 
                        p.Sig6__c = temp;   
                }
                else if(Signature3.containsKey(p.Id) && Signature3.get(p.Id).containsKey('42')) {
                    String temp = p.Sig1__c;
                    p.Sig1__c = Signature3.get(p.Id).get('42').values().get(0);
                    if(p.Sig2__c == p.Sig1__c) 
                        p.Sig2__c = temp;   
                    if(p.Sig3__c == p.Sig1__c) 
                        p.Sig3__c = temp;   
                    if(p.Sig4__c == p.Sig1__c) 
                        p.Sig4__c = temp;   
                    if(p.Sig5__c == p.Sig1__c) 
                        p.Sig5__c = temp;   
                    if(p.Sig6__c == p.Sig1__c) 
                        p.Sig6__c = temp;   
                }                       
            }           
            else if(p.medienartnummer__c == '46') {  //KO, Sig1 should be 55 or 57 if this reference exists in Sig2 3 4 5 or 6
                if(Signature3.containsKey(p.Id) && Signature3.get(p.Id).containsKey('55') && (p.medienartSig1__c == '55' && p.UntermedienartSig1__c != '05' || p.medienartSig1__c != '55')) {
                    String temp = p.Sig1__c;
                    system.debug('test sig:' + Signature3.get(p.Id).get('55'));
                    if(Signature3.get(p.Id).get('55').containsKey('05'))
                        p.Sig1__c = Signature3.get(p.Id).get('55').get('05');
                    else
                        p.Sig1__c = Signature3.get(p.Id).get('55').values().get(0);
                    if(p.Sig2__c == p.Sig1__c) 
                        p.Sig2__c = temp;   
                    if(p.Sig3__c == p.Sig1__c) 
                        p.Sig3__c = temp;   
                    if(p.Sig4__c == p.Sig1__c) 
                        p.Sig4__c = temp;   
                    if(p.Sig5__c == p.Sig1__c) 
                        p.Sig5__c = temp;   
                    if(p.Sig6__c == p.Sig1__c) 
                        p.Sig6__c = temp;   
                }
                else if(Signature3.containsKey(p.Id) && Signature3.get(p.Id).containsKey('57') && p.medienartSig1__c != '55') {
                    String temp = p.Sig1__c;
                    p.Sig1__c = Signature3.get(p.Id).get('57').values().get(0);
                    if(p.Sig2__c == p.Sig1__c) 
                        p.Sig2__c = temp;   
                    if(p.Sig3__c == p.Sig1__c) 
                        p.Sig3__c = temp;   
                    if(p.Sig4__c == p.Sig1__c) 
                        p.Sig4__c = temp;   
                    if(p.Sig5__c == p.Sig1__c) 
                        p.Sig5__c = temp;   
                    if(p.Sig6__c == p.Sig1__c) 
                        p.Sig6__c = temp;   
                }   
            }       
        }

    
    }

      
       // ArtikelLizenzpreisberechnung
      // KO Neuberechnung
      static map<Id, ArtikelLizenz__c> ALtoUpdate = new map<Id, ArtikelLizenz__c>();
      static list<ArtikelLizenz__c> ArtikelLizenzen = new list<ArtikelLizenz__c>(); 
      
       @future(callout=true )
      public static void onUpdate_Neuberechnung_ArtikelLizenzPreise_future(set<Id> ids) {
           meta_onUpdate_Neuberechnung_ArtikelLizenzPreise(getProducts(Ids));
      }
      
       public static void onUpdate_Neuberechnung_ArtikelLizenzPreise_alreadyfuture(list<Product2> products) {
           meta_onUpdate_Neuberechnung_ArtikelLizenzPreise(products);
      }
      
       public static void onUpdate_Neuberechnung_ArtikelLizenzPreise(list<Product2> products) {
           meta_onUpdate_Neuberechnung_ArtikelLizenzPreise(products);
      }
      
       private static list<Product2> getProducts(set<Id> ids) {
           return new list<Product2>([select id, medienartnummer__c, medienartSig1__c, Sig1Zaehlnummer__c, AUSW01__c, 
                                               ProductCode, name, SIG1__c, SIG2__c, 
                                               SIG3__c, SIG4__c, SIG5__c, SIG6__c
                                               from Product2 
                                               where Id IN: Ids AND RecordType.Name = 'Signatur']);
      }
      
       private static void updateAL() {
            if(!ALtoUpdate.isEmpty())
                  update ALtoUpdate.values();
      }
      
       private static void meta_onUpdate_Neuberechnung_ArtikelLizenzPreise(list<Product2> products) {
           getArtikelLizenzen(products);
           onUpdate_NeuberechnungKO_O2(products);
           calculatePriceForK1_K2(products);
           updateAL();
           systemsettings.insertErrors();
      }
      
       private static void getArtikelLizenzen(list<Product2> products) {
           // Neuberechnung KO
            list<String> AL_name_42_46_10001 = new list<String>();
            list<String> AL_name_42_46_10002 = new list<String>();
            list<String> AL_name_55_57_40100 = new list<String>();
            list<String> AL_name_46_10206 = new list<String>();
            list<String> AL_name_46_10001 = new list<String>();
            list<String> AL_name_46_10002 = new list<String>();
            list<String> AL_name_55_57_10206 = new list<String>();
            list<String> AL_name_K1_K2_10261_10262 = new list<String>();
            list<String> AL_name_K1_K2_10269 = new list<String>();
            
            //set<String> Ids = new set<String>();
            
            for(Product2 product:products) {
                  if(product != null) {
            //          Ids.add(product.Id);
      
                        if((product.medienartnummer__c == '55' || product.medienartnummer__c == '57') && (product.medienartSig1__c == '46' || product.medienartSig1__c == '42')){

                             AL_name_42_46_10001.add(product.medienartSig1__c + product.Sig1Zaehlnummer__c + '10001');
                             AL_name_42_46_10002.add(product.medienartSig1__c + product.Sig1Zaehlnummer__c + '10002');
                             //AL_name_55_57_40100.add(product.medienartnummer__c + product.ProductCode + '40100');
                             // name should do the same
                             AL_name_55_57_40100.add(product.name + '40100');
                              // K1/K2 hope this will do
                             AL_name_K1_K2_10261_10262.add(product.name + '10261');
                             AL_name_K1_K2_10261_10262.add(product.name + '10262');
                        }
                        if(product.medienartnummer__c == '46'){
                             //Ids.add(product.Sig1__c);
                             //AL_name_46_10206.add(product.medienartnummer__c + product.ProductCode + '10206');
                             //AL_name_46_10001.add(product.medienartnummer__c + product.ProductCode + '10001');
                             //AL_name_46_10002.add(product.medienartnummer__c + product.ProductCode + '10002');
                             // name should do the same
                             AL_name_46_10206.add(product.name + '10206');
                             AL_name_46_10001.add(product.name + '10001');
                             AL_name_46_10002.add(product.name + '10002');
                             // K1/K2 hope this will do
                             AL_name_K1_K2_10261_10262.add(product.name + '10261');
                             AL_name_K1_K2_10261_10262.add(product.name + '10262');
                             AL_name_K1_K2_10269.add(product.name + '10269');
                        }
                        if(product.medienartnummer__c == '46' && (product.medienartSig1__c == '55' || product.medienartSig1__c == '57')){
                             //Ids.add(product.Sig1__c);
                             AL_name_55_57_10206.add(product.medienartSig1__c + product.Sig1Zaehlnummer__c + '10206');
                        }
                  }
            }

            system.debug('die ids2 !!' + AL_name_42_46_10001);
            system.debug('die ids3 !!' + AL_name_42_46_10002);
            
            // get all neccessary ArtikelLizenzen
            ArtikelLizenzen = [select id, name, VPR015__c, Artikel__c, LZN015__c, medienart__c, Zaehlnummer__c, 
                        Formel_Feld_5_Euros__c, Untermedienart__c, SPK015__c, ArtikelLizenzKey__c
                  from ArtikelLizenz__c where Artikel__c != null AND(name IN: AL_name_42_46_10001 OR 
                  name IN:AL_name_42_46_10002 OR name IN:AL_name_55_57_40100 OR name IN:AL_name_46_10206
                  OR name IN:AL_name_46_10001 OR name IN:AL_name_46_10002 OR name IN:AL_name_55_57_10206
                  // K1/K2
                  OR Name IN :AL_name_K1_K2_10261_10262
                  OR Name IN :AL_name_K1_K2_10269
                  )];
      }
      
      private static void onUpdate_NeuberechnungKO_O2(list<Product2> products) {
                   
            map<String, ArtikelLizenz__c> ALmap = new map<String, ArtikelLizenz__c>();
            map<String, ArtikelLizenz__c> ALmapIdtemp = new map<String, ArtikelLizenz__c>();
            map<Id, map<String, ArtikelLizenz__c>> ALmapId = new map<Id, map<String, ArtikelLizenz__c>>();
            
            for(ArtikelLizenz__c a:ArtikelLizenzen) {
                  // JS, 5.9.11: eigentlich unnötige Abfrage?!
                  if(a.LZN015__c == '10206' || a.LZN015__c == '10001' || a.LZN015__c == '10002' || a.LZN015__c == '40100') {
                        ALmap.put(a.name, a);
                        system.debug('value of a ' + a);
                        
                        if(!ALmapId.containsKey(a.Artikel__c))
                             ALmapId.put(a.Artikel__c, new map<String, ArtikelLizenz__c>());
                        if (!ALmapId.get(a.Artikel__c).containsKey(a.LZN015__c))
                             ALmapId.get(a.Artikel__c).put(a.LZN015__c, a);
                  }
            }
            
            //list<String> willbeTriggerd = new list<String>();
            
            for(Product2 product:products) {
                  system.debug('product .. !! ' + product);
                  //for O2: we have to find a 46 or a 42 with a signature 55 ---- 40100
      //          system.debug('helper for debug ' + product.medienartnummer__c + ' ' + ALmapId.containsKey(product.Id) + ' ' +  ALmap.containsKey('55' + product.ProductCode + '40100') + ' ' + '55' + product.ProductCode + '40100'); 
                  if((product.medienartnummer__c == '55' || product.medienartnummer__c == '57' )&& ALmapId.containsKey(product.Id) && ALmapId.get(product.Id).containsKey('40100') && (ALmap.containsKey('55' + product.ProductCode + '40100') || ALmap.containsKey('57' + product.ProductCode + '40100'))){
                        Decimal temp;
                        if(ALmap.containsKey('55' + product.ProductCode + '40100'))
                              temp = ALmap.get('55' + product.ProductCode + '40100').VPR015__c;
                        else if(ALmap.containsKey('57' + product.ProductCode + '40100'))
                              temp = ALmap.get('57' + product.ProductCode + '40100').VPR015__c;
                              
                        if(ALmap.containsKey('55' + product.ProductCode + '40100') && ALmap.get('55' + product.ProductCode + '40100').Untermedienart__c == 'Lernobjekt') {  //Untermedienart == 02
                              ALmap.get('55' + product.ProductCode + '40100').VPR015__c = 0.25 * ALmap.get('55' + product.ProductCode + '40100').Formel_Feld_5_Euros__c;
                              ALmap.get('55' + product.ProductCode + '40100').SPK015__c = False;
                        } 
                        else if(ALmap.containsKey('57' + product.ProductCode + '40100') && ALmap.get('57' + product.ProductCode + '40100').Untermedienart__c == 'Lernobjekt') {  //Untermedienart == 02
                              ALmap.get('57' + product.ProductCode + '40100').VPR015__c = 0.25 * ALmap.get('57' + product.ProductCode + '40100').Formel_Feld_5_Euros__c;
                              ALmap.get('57' + product.ProductCode + '40100').SPK015__c = False;
                        }
                        else if(product.medienartSig1__c == '46') {
                              if(ALmap.containsKey('46' + product.Sig1Zaehlnummer__c + '10001')) {
                                    if(ALmap.get('46' + product.Sig1Zaehlnummer__c + '10001').VPR015__c != null) {
                                          if(ALmap.containsKey('55' + product.ProductCode + '40100')){
                                               ALmap.get('55' + product.ProductCode + '40100').VPR015__c = 0.25 * ALmap.get('46' + product.Sig1Zaehlnummer__c + '10001').VPR015__c;
                                               ALmap.get('55' + product.ProductCode + '40100').SPK015__c = False;
                                          }
                                          else if(ALmap.containsKey('57' + product.ProductCode + '40100')) {
                                               ALmap.get('57' + product.ProductCode + '40100').VPR015__c = 0.25 * ALmap.get('46' + product.Sig1Zaehlnummer__c + '10001').VPR015__c;
                                               ALmap.get('57' + product.ProductCode + '40100').SPK015__c = False;
                                          }
                                    }           
                              }
                              else if(ALmap.containsKey('46' + product.Sig1Zaehlnummer__c + '10002')) {
                                    if(ALmap.get('46' + product.Sig1Zaehlnummer__c + '10002').VPR015__c != null){
                                          if(ALmap.containsKey('55' + product.ProductCode + '40100')) { 
                                               ALmap.get('55' + product.ProductCode + '40100').VPR015__c = 0.25 * ALmap.get('46' + product.Sig1Zaehlnummer__c + '10002').VPR015__c;
                                               ALmap.get('55' + product.ProductCode + '40100').SPK015__c = False;
                                          }
                                          else if(ALmap.containsKey('57' + product.ProductCode + '40100')) {
                                               ALmap.get('57' + product.ProductCode + '40100').VPR015__c = 0.25 * ALmap.get('46' + product.Sig1Zaehlnummer__c + '10002').VPR015__c;                    
                                               ALmap.get('57' + product.ProductCode + '40100').SPK015__c = False;
                                          }
                                    }
                              }                                                                                                               
                        }
                        else if(product.medienartSig1__c == '42') {
                              if(ALmap.containsKey('42' + product.Sig1Zaehlnummer__c + '10001')) {
                                    if(ALmap.get('42' + product.Sig1Zaehlnummer__c + '10001').VPR015__c != null){
                                          if(ALmap.containsKey('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100')) {
                                               ALmap.get('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').VPR015__c = 0.25 * ALmap.get('42' + product.Sig1Zaehlnummer__c + '10001').VPR015__c;
                                               ALmap.get('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').SPK015__c = False;
                                          }
                                          else if(ALmap.containsKey('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100')){
                                               ALmap.get('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').VPR015__c = 0.25 * ALmap.get('42' + product.Sig1Zaehlnummer__c + '10001').VPR015__c;
                                               ALmap.get('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').SPK015__c = False;
                                          }
                                    }
                              }
                              else if(ALmap.containsKey('42' + product.Sig1Zaehlnummer__c + '10002')) {
                                    if(ALmap.get('42' + product.Sig1Zaehlnummer__c + '10002').VPR015__c != null){
                                          if(ALmap.containsKey('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100')) {
                                               ALmap.get('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').VPR015__c = 0.25 * ALmap.get('42' + product.Sig1Zaehlnummer__c + '10002').VPR015__c;
                                               ALmap.get('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').SPK015__c = False; 
                                          }
                                          else if(ALmap.containsKey('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100')) {
                                               ALmap.get('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').VPR015__c = 0.25 * ALmap.get('42' + product.Sig1Zaehlnummer__c + '10002').VPR015__c;
                                               ALmap.get('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').SPK015__c = False;
                                          }
                                    }
                             }
                        }
                        if(ALmap.containsKey('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100') && ALmap.get('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').VPR015__c != null) {
                              if(!ALtoUpdate.containsKey(ALmap.get('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').Id))
                                    ALtoUpdate.put(ALmap.get('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').Id,ALmap.get('55' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100'));
                        }
                        else if(ALmap.containsKey('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100') && ALmap.get('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').VPR015__c != null){
                              if(!ALtoUpdate.containsKey(ALmap.get('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').Id))
                                    ALtoUpdate.put(ALmap.get('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100').Id,ALmap.get('57' + ALmapId.get(product.Id).get('40100').Zaehlnummer__c + '40100'));
                        }
                        
                  }
                  
                  //regular case -- Neuberechnung KO 
                  else if(product.medienartnummer__c == '46' && product.AUSW01__c != '8' && ALmap.containsKey(product.name + '10206') && (ALmap.containsKey(product.name + '10002') || ALmap.containsKey(product.name + '10001'))){
                        system.debug('helper !! ' + product);
                        system.debug('helper map !! ' + ALmapId);
                        if(ALmap.containsKey(product.name + '10001')) {
                             ALmap.get(product.name + '10206').VPR015__c = ALmap.get(product.name + '10001').VPR015__c;
                             ALmap.get(product.name + '10206').SPK015__c = False;
                        }
                        else if(ALmap.containsKey(product.name + '10002')){
                             ALmap.get(product.name + '10206').VPR015__c = ALmap.get(product.name + '10002').VPR015__c;
                             ALmap.get(product.name + '10206').SPK015__c = False;
                        }
                        if(ALmap.get(product.name + '10206').VPR015__c == null) {
                             ALmap.get(product.name + '10206').VPR015__c = 0;
                             ALmap.get(product.name + '10206').SPK015__c = False;
                        }
                        
                  //    system.debug('medienart sig1 ' +product.medienartSig1__c + ' ' +  ALmapId.containsKey(product.SIG1__c) + ' ' + ALmapId.get(product.SIG1__c).containsKey('10206'));
                  
                        if((product.medienartSig1__c == '55' || product.medienartSig1__c == '57') && ALmapId.containsKey(product.SIG1__c) && ALmapId.get(product.SIG1__c).containsKey('10206')){
                             ALmapId.get(product.SIG1__c).get('10206').VPR015__c = 1.2 *ALmap.get(product.name + '10206').VPR015__c;
                             ALmapId.get(product.SIG1__c).get('10206').SPK015__c = False;
                             system.debug('1 !! ' + ALtoUpdate);
                              if(!ALtoUpdate.containsKey(ALmapId.get(product.SIG1__c).get('10206').Id))
                                   ALtoUpdate.put(ALmapId.get(product.SIG1__c).get('10206').Id, ALmapId.get(product.SIG1__c).get('10206')) ;
                             system.debug('2 !! ' + ' ' + product.SIG1__c + ' '+  ALtoUpdate);
                        }
                        else {
                             ALmap.get(product.name + '10206').VPR015__c *= 2.2;
                             ALmap.get(product.name + '10206').SPK015__c = False;             
                        }
                        //ALtoUpdate.add(ALmapId.get(product.SIG1__c)) ;
                        system.debug('al to update ... ' + ALtoUpdate);
                        system.debug('al to update 2... ' + ALmap.get(product.name + '10206'));
                        if(!ALtoUpdate.containsKey(ALmap.get(product.name + '10206').Id))
                             ALtoUpdate.put(ALmap.get(product.name + '10206').Id, ALmap.get(product.name + '10206'));

                  }
            }

            system.debug('al to update ' + ALtoUpdate);
            //system.debug('al2 to update ' + trigNew);
      }
      // END of KO Neuberechnung
      
      private static void calculatePriceForK1_K2(list<Product2> products) {
            final Double pricelimit=999.0;
            final Double topprice=995.0;
            final Double faktorforK1=2.5;
            final Double faktorforK2=3.4;
            final Double numberOfCopies=2;
            
            // Ideas:
            // rearange ArtikelLizenzen
            // create set of licences (10261,10262)
            // Iterate through this set
            // and calculate the price depending on the medienart
            // problem: error handling
            
            map<String, map<String, Double>> K1K2Licensenumbers = new map<String, map<String, Double>>();
            K1K2Licensenumbers.put('10261', new map<String, Double>()); 
            K1K2Licensenumbers.put('10262', new map<String, Double>());
            //K1K2Licensenumbers.put('10269', new map<String, Double>());
            K1K2Licensenumbers.get('10261').put('46',1);
            K1K2Licensenumbers.get('10262').put('46',1);
            //K1K2Licensenumbers.get('10269').put('46',1);
            K1K2Licensenumbers.get('10261').put('55',faktorforK1-1); // reduced faktor for 55er Medium
            K1K2Licensenumbers.get('10262').put('55',faktorforK2-1); // reduced faktor for 55er Medium
            K1K2Licensenumbers.get('10261').put('MAX',faktorforK1);
            K1K2Licensenumbers.get('10262').put('MAX',faktorforK2);
            
            set<String> BasicLicensenumbers = new set<String>();
            BasicLicensenumbers.add('10001');
            
            set<String> Copylicensenumbers = new set<String>();
            Copylicensenumbers.add('10269');
            
            set<String> KMedienarten = new set<String>();
            KMedienarten.add('46');
            KMedienarten.add('55');
            
            set<String> BMedienarten = new set<String>();
            BMedienarten.add('46');
            
            // rearange ArtikelLizenzen
            // map<alid, al> for K1K2Licensenumbers
            map<id, ArtikelLizenz__c> kartikellizenzen = new map<Id, ArtikelLizenz__c>();
            set<String> kartikellizenzkeys = new set<String>();
            // map<ALkey, al> for Basic Licences
            map<String, Double> bartikellizenzpreis = new map<String, Double>();
            // map<alkey , al> for copy licenses
            map<String, Double> cartikellizenzpreis = new map<String, Double>();
            
            // rearange
            for (ArtikelLizenz__c al:ArtikelLizenzen) {
                  if (K1K2Licensenumbers.containsKey(al.LZN015__c) && KMedienarten.contains(al.medienart__c)) {
                        if (!kartikellizenzen.containsKey(al.id)) kartikellizenzen.put(al.id, al);
                        if (!kartikellizenzkeys.contains(al.ArtikelLizenzKey__c)) kartikellizenzkeys.add(al.ArtikelLizenzKey__c);
                        system.debug('Kartikellizenz: ' + al.id);
                  }
                  if (BasicLicensenumbers.contains(al.LZN015__c) && BMedienarten.contains(al.medienart__c)) {
                        bartikellizenzpreis.put(al.name, al.VPR015__c==null?0:al.VPR015__c);
                  }
                  if (Copylicensenumbers.contains(al.LZN015__c) && BMedienarten.contains(al.medienart__c)) {
                        cartikellizenzpreis.put(al.name, al.VPR015__c==null?0:al.VPR015__c);
                  }
            }
            
            // artikellizenz Signaturnummer zu passender 46er Signaturnummer für 55er medien
            map<String, String> alsign2productcode = new map<String, String>();
            map<String, Product2> sign2product=new map<String, Product2>();
            for (Product2 p:products) {
                  if (!sign2product.containsKey(p.Name)) sign2product.put(p.Name, p);
                  if (p.medienartnummer__c=='46' && p.SIG1__c!=null && p.medienartSig1__c=='55') {
                        if (!alsign2productcode.containsKey(p.medienartSig1__c+p.Sig1Zaehlnummer__c))
                              alsign2productcode.put(p.medienartSig1__c+p.Sig1Zaehlnummer__c,p.ProductCode);
                  }
                  // Validation of Licenses
                  for (String lzn: K1K2Licensenumbers.keySet()) {
                        if (!kartikellizenzkeys.contains(p.Name + lzn)) systemsettings.logError('K1/K2 Preisberechnung, ArtikelLizenzKey ' + p.Name + lzn + ' fehlt. Bitte prüfen!');
                  }
                  for (String lzn: Copylicensenumbers) {
                        if (!kartikellizenzkeys.contains(p.Name + lzn)) systemsettings.logError('K1/K2 Preisberechnung, ArtikelLizenzKey ' + p.Name + lzn + ' fehlt. Bitte prüfen!');
                  }
            }
            kartikellizenzkeys=null;
            
            // pricecalculation
            for (ArtikelLizenz__c al:kartikellizenzen.values()) {
                  Double maxnewprice=0;
                  Double topnewprice=0;
                  for (String bma: BMedienarten) {
                        for (String bln: BasicLicensenumbers) {
                             String bartikellizenzkey=bma;
                             if (al.medienart__c=='46')
                                   bartikellizenzkey=bartikellizenzkey+al.Zaehlnummer__c+bln;
                             else {
                                   if (alsign2productcode.containsKey(al.medienart__c+al.Zaehlnummer__c)) {
                                         bartikellizenzkey=bartikellizenzkey+alsign2productcode.get(al.medienart__c+al.Zaehlnummer__c)+bln; 
                                   }
                             }
                                   
                             if (bartikellizenzpreis.containsKey(bartikellizenzkey)) {
                                   system.debug('AL Lzn ' + al.id + ': ' + al.LZN015__c + ' / MA: ' + al.medienart__c + ' / contains: ' + K1K2Licensenumbers.containsKey(al.LZN015__c));
                                   system.debug('Value: ' + K1K2Licensenumbers.get(al.LZN015__c).get(al.medienart__c));
                                   system.debug('bvalue: ' + bartikellizenzpreis.get(bartikellizenzkey));
                                   Double baseprice = bartikellizenzpreis.get(bartikellizenzkey);
                                   // special case maxprice - if reached we reduce the baseprice
                                   maxnewprice=baseprice*K1K2Licensenumbers.get(al.LZN015__c).get('MAX');
                                   if (maxnewprice>pricelimit)
                                         baseprice=topprice/K1K2Licensenumbers.get(al.LZN015__c).get('MAX');
                                   Double newprice = baseprice*K1K2Licensenumbers.get(al.LZN015__c).get(al.medienart__c);
                                   
                                   // special situation that the 46er has no reference to another 55er medium 
                                   if (al.medienart__c=='46') 
                                         system.debug('al.id: ' + al.id + ' sign2product containsKey ' + sign2product.containsKey(al.medienart__c+al.Zaehlnummer__c) + ' / Sig1: ' + sign2product.get(al.medienart__c+al.Zaehlnummer__c).Sig1__c );
                                   if (al.medienart__c=='46' && sign2product.containsKey(al.medienart__c+al.Zaehlnummer__c) && sign2product.get(al.medienart__c+al.Zaehlnummer__c).Sig1__c==null)
                                         newprice=newprice+baseprice*K1K2Licensenumbers.get(al.LZN015__c).get('55');
                                   // we have to remove the copies from the online price if they exist
                                   // I think we have only one LZN here ...
                                   for (String copylzn: Copylicensenumbers) {
                                         if (al.medienart__c=='55' 
                                               && cartikellizenzpreis.containsKey('46' + alsign2productcode.get(al.medienart__c+al.Zaehlnummer__c) + copylzn)) {
                                               newprice=newprice-cartikellizenzpreis.get('46' + alsign2productcode.get(al.medienart__c+al.Zaehlnummer__c) + copylzn)*numberOfCopies;
                                         }
                                   }
                                   // special max price
                                   //if (al.medienart__c=='55' && newprice>pricelimit) newprice=topprice;
                                   if (al.VPR015__c!=newprice) {
                                         al.VPR015__c=newprice;
                                         if (!ALtoUpdate.containsKey(al.id)) ALtoUpdate.put(al.id, al);
                                         else ALtoUpdate.get(al.id).VPR015__c=newprice;
                                   }
                             } else
                             // log error that we did not find a artikellizenz that should exist
                                   systemsettings.logError('Preisberechnung K1/K2, Artikellizenz mit Key: ' + bartikellizenzkey + ' wurde nicht gefunden! Bitte prüfen!');
                        }
                  }
            }
      }

      // END of ArtikelLizenzpreisberechnung
      
      
      public static void onInsert(list<Product2> trigg) {
            System.debug('onProduct.onInsert');
            list<String> Medienart = new list<String>();
            for(Product2 trig:trigg) {
                  Medienart.add(trig.MEDA01__c);
            }
            list<Artikellizenz__c> Artikellizenz = new list<Artikellizenz__c>();
            list<lizenz__c> lizenz = new list<lizenz__c>();
            
            list<Lizenz__c> liz = new list<Lizenz__c>([Select id from Lizenz__c where MED017__c IN: Medienart and aktiv__c = true]);
            list<String> Ids = new list<String>();
            for(Lizenz__c temp:liz){
                  Ids.add(temp.Id);
            }
            
            if(!Ids.isEmpty())
                  cloneClever.cloneDynamic(Artikellizenz, lizenz, Ids);
            //set<String> helper;
            Artikellizenz__c AL;
            list<Artikellizenz__c> ALtoInsert = new list<Artikellizenz__c>();
            for(Product2 trig:trigg) {
            //    helper = new set<String>();
            
                  for(Artikellizenz__c temp:Artikellizenz) {
                        if(temp.MED017__c == trig.MEDA01__c && (temp.LZN015__c != '10306'/* ||(trig.AUSW01__c == '8' && temp.LZN015__c == '10306')*/)) {
                             //if lizenz 10306, then it must be a second label (AUSW01 == 8)
                             AL = new Artikellizenz__c();
                             AL = temp.clone(false,true);
                             AL.Artikel__c = trig.Id;
                             AL.OwnerId=UserInfo.getUserId();
                             AL.name = trig.medienartnummer__c + trig.ProductCode + AL.LZN015__c;
                             system.debug('AL name = ' + AL.name);
                             ALtoInsert.add(AL);
                             //helper.add(temp.Name);
                        //    break;
                        }
                  }
            }
            if(!ALtoInsert.isEmpty())
                  insert ALtoInsert;
            list<Pricebook2> bookId = [Select id, Name from Pricebook2 where Name IN ('Standard Price Book')];

            
            // boolean firstLoop = true;
            
            list<PricebookEntry> bookToInsert = new list<PricebookEntry>();
            PricebookEntry book;
            // for(Integer i=0;i<2;i++) {
                  for(Product2 trig:trigg) {
                        book = new PricebookEntry();
                        
                        book.UnitPrice = 0;
                        book.Product2Id = trig.Id;
                        book.isActive = True;
                        book.UseStandardPrice = False;
                        
                        // if(bookId.get(0).Name == 'Standard Price Book' && firstLoop) {
                             book.Pricebook2Id = bookId.get(0).Id;
                             bookToInsert.add(book);
                        // }
                        
                        /* if(bookId.get(1).Name == 'Standard Price Book' && firstLoop) {
                             book.Pricebook2Id = bookId.get(1).Id;
                             bookToInsert.add(book);
                        }
                        
                        if(bookId.get(0).Name == 'Standard' && !firstLoop) {
                             book.Pricebook2Id = bookId.get(0).Id;
                             bookToInsert.add(book);
                        }
                        
                        if(bookId.get(1).Name == 'Standard' && !firstLoop) {
                             book.Pricebook2Id = bookId.get(1).Id;
                             bookToInsert.add(book);
                        }*/
                        
                  }
            //    firstLoop = false;
            //}
            if(!bookToInsert.isEmpty())
                  insert bookToInsert;
      }
      
}