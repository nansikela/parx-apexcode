public class onEinkaufBewegungen {
  private static map<String, Product2> p = new map<String, Product2>();
  private static list<String> ids = new list<String>();
  private static list<Produktionsstand__c> PS=new list<Produktionsstand__c>();
  private static String Error = 'Einkaufspreis darf nicht leer sein wenn BS = 06, 08, 16 oder 18';
  
  public static void init(list<Einkauf__c> Einkauf) {
    for(Einkauf__c E:Einkauf){
      if (E.ImportId__c==null) // verhindert veränderungen durch den import
      ids.add(E.Artikel__c);
    }
    list<Product2> temp = [Select id, Verfuegbarer_Bestand__c, BESB01__c, PDKZ01__c, GESB01__c, RESB01__c, OFPO01__c, LZBW01__c, EKPR01__c, Kreditor__c,
            Gesamt_Bestand_04051415__c, ZULJ01__c, Magento_Liefertermin__c  from Product2 where Id IN: ids];
    for(Product2 t:temp) {
      t.LZBW01__c = system.today();
      p.put(t.Id,t);
    }
    
    /*update*/ choose(Einkauf);
    try{
      update p.values();
    }
    catch(exception e) {
        Einkauf[0].addError(e.getMessage());
    }
    
    if(!PS.isEmpty())
      insert PS;
    
  }
  
  private static list<Einkauf__c> choose(list<Einkauf__c> Einkauf) {
    for(Einkauf__c E:Einkauf) {
    	if (E.ImportId__c==null) { // verhindert Produktionsstaende beim import!
      E.KPSL22__c = p.get(E.Artikel__c).Kreditor__c;   // lieferant
      
      if(E.BWSL22__c == '03') {
        BS03(E);
      }
      else if(E.BWSL22__c == '04') {
        BS04(E);
      }
      else if(E.BWSL22__c == '05') {
        BS05(E);
      }
      else if(E.BWSL22__c == '06') {
        BS06(E);
        AUMA(E);
      }
      else if(E.BWSL22__c == '08') {
        BS08(E);
      }
      else if(E.BWSL22__c == '13') {
        BS13(E);
      }
      else if(E.BWSL22__c == '14') {
        BS14(E);
      }
      else if(E.BWSL22__c == '15') {
        BS15(E);
      }
      else if(E.BWSL22__c == '16') {
        BS16(E);
        AUMA(E);
      }
      else if(E.BWSL22__c == '18') {
        BS18(E);
      }
      else {
        E.addError('BWSL22 leer oder falsch');
      }
    }
    }
    return Einkauf;
  }
  
  private static void AUMA(Einkauf__c Einkauf) {
    Double sign=1;
    if (Einkauf.BWSL22__c == '16') sign=-1;
    if (p.get(Einkauf.Artikel__c).AUMA01__c==null) p.get(Einkauf.Artikel__c).AUMA01__c=0;
    if(Einkauf.Inventurwert__c != null)
      p.get(Einkauf.Artikel__c).AUMA01__c+=Einkauf.Inventurwert__c*sign;
    if(Einkauf.Inventurpreis__c != null) 
      p.get(Einkauf.Artikel__c).IVPR01__c=Einkauf.Inventurpreis__c*sign;
  }
   
  private static void BS03(Einkauf__c Einkauf) {
    if(p.get(Einkauf.Artikel__c).BESB01__c == null)
      p.get(Einkauf.Artikel__c).BESB01__c = 0;
    p.get(Einkauf.Artikel__c).BESB01__c += Einkauf.MENG22__c;  //bestell bestand

    if(p.get(Einkauf.Artikel__c).GESB01__c != null && p.get(Einkauf.Artikel__c).RESB01__c != null && p.get(Einkauf.Artikel__c).GESB01__c - p.get(Einkauf.Artikel__c).RESB01__c < 0 && p.get(Einkauf.Artikel__c).BESB01__c>0 && p.get(Einkauf.Artikel__c).Verfuegbarer_Bestand__c>0){
      Date d = system.today() + 7;
      p.get(Einkauf.Artikel__c).Magento_Liefertermin__c = String.valueOf(d.day()) + '.' + String.valueOf(d.month()) + '.' + String.valueOf(d.year()); 
    }
    else {
      p.get(Einkauf.Artikel__c).Magento_Liefertermin__c = '';      
    }

    if(p.get(Einkauf.Artikel__c).PDKZ01__c <4) {
      produktionsstand(p.get(Einkauf.Artikel__c).Id, '03');
    }  
  }
  
  private static void BS04(Einkauf__c Einkauf) {
    if(p.get(Einkauf.Artikel__c).BESB01__c == null)
      p.get(Einkauf.Artikel__c).BESB01__c = 0;
    if(Einkauf.Ueberlieferung__c == null)
      Einkauf.Ueberlieferung__c = 0;
    p.get(Einkauf.Artikel__c).BESB01__c -= Einkauf.MENG22__c - Einkauf.Ueberlieferung__c;  //bestell bestand

    if(p.get(Einkauf.Artikel__c).GESB01__c == null)
      p.get(Einkauf.Artikel__c).GESB01__c = 0;
    p.get(Einkauf.Artikel__c).GESB01__c += Einkauf.MENG22__c ;  //gesamt bestand
    
    if(p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c == null)
      p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c = 0;
    p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c += Einkauf.MENG22__c;  //gesamt bestand (for comparison)  
    
    if(p.get(Einkauf.Artikel__c).ZULJ01__c == null)
      p.get(Einkauf.Artikel__c).ZULJ01__c = 0;
    p.get(Einkauf.Artikel__c).ZULJ01__c += Einkauf.MENG22__c;  //letztes Jahr (like gesamt bestand)  
    
    if(p.get(Einkauf.Artikel__c).OFPO01__c == null)
      p.get(Einkauf.Artikel__c).OFPO01__c = 0;
    p.get(Einkauf.Artikel__c).OFPO01__c += Einkauf.MENG22__c;  //offene Posten
    
    if(p.get(Einkauf.Artikel__c).PDKZ01__c <4) {
      produktionsstand(p.get(Einkauf.Artikel__c).Id, '04');
    }
  }
  
  private static void BS05(Einkauf__c Einkauf) {
    if(p.get(Einkauf.Artikel__c).GESB01__c == null)
      p.get(Einkauf.Artikel__c).GESB01__c = 0;
    p.get(Einkauf.Artikel__c).GESB01__c += Einkauf.MENG22__c;  //gesamt bestand
    
    if(p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c == null)
      p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c = 0;
    p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c += Einkauf.MENG22__c;  //gesamt bestand (for comparison)
    
    if(p.get(Einkauf.Artikel__c).ZULJ01__c == null)
      p.get(Einkauf.Artikel__c).ZULJ01__c = 0;
    p.get(Einkauf.Artikel__c).ZULJ01__c += Einkauf.MENG22__c;  //letztes Jahr (like gesamt bestand)
  }
    
  private static void BS06(Einkauf__c Einkauf) {
    if(Einkauf.EKPR22__c == null)
      Einkauf.addError(Error);
    else{  
      if(p.get(Einkauf.Artikel__c).OFPO01__c == null)
        p.get(Einkauf.Artikel__c).OFPO01__c = 0;
      p.get(Einkauf.Artikel__c).OFPO01__c -= Einkauf.MENG22__c;  //offene Posten
      
      p.get(Einkauf.Artikel__c).EKPR01__c = Einkauf.EKPR22__c;   //letzter Einkaufspreis
    }
  }
  
  private static void BS08(Einkauf__c Einkauf) {
    if(Einkauf.EKPR22__c == null)
      Einkauf.addError(Error);
    else{  
      if(p.get(Einkauf.Artikel__c).EKPR01__c == null)
        p.get(Einkauf.Artikel__c).EKPR01__c = 0;
      p.get(Einkauf.Artikel__c).EKPR01__c += Einkauf.EKPR22__c;   //letzter Einkaufspreis
    }
  }
  
  private static void BS13(Einkauf__c Einkauf) {
    if(p.get(Einkauf.Artikel__c).BESB01__c == null)
      p.get(Einkauf.Artikel__c).BESB01__c = 0;
    p.get(Einkauf.Artikel__c).BESB01__c -= Einkauf.MENG22__c;  //bestell bestand
  }
  
  private static void BS14(Einkauf__c Einkauf) {
    if(p.get(Einkauf.Artikel__c).BESB01__c == null)
      p.get(Einkauf.Artikel__c).BESB01__c = 0;
    if(Einkauf.Ueberlieferung__c == null)
      Einkauf.Ueberlieferung__c = 0;
   
    p.get(Einkauf.Artikel__c).BESB01__c += Einkauf.MENG22__c - Einkauf.Ueberlieferung__c;  //bestell bestand
  
    if(p.get(Einkauf.Artikel__c).GESB01__c == null)
      p.get(Einkauf.Artikel__c).GESB01__c = 0;
    p.get(Einkauf.Artikel__c).GESB01__c -= Einkauf.MENG22__c;  //gesamt bestand
    
    if(p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c == null)
      p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c = 0;
    p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c -= Einkauf.MENG22__c ;  //gesamt bestand (for comparison)
    
    if(p.get(Einkauf.Artikel__c).ZULJ01__c == null)
      p.get(Einkauf.Artikel__c).ZULJ01__c = 0;
    p.get(Einkauf.Artikel__c).ZULJ01__c -= Einkauf.MENG22__c;  //letztes Jahr (like gesamt bestand)
  
    if(p.get(Einkauf.Artikel__c).OFPO01__c == null)
      p.get(Einkauf.Artikel__c).OFPO01__c = 0;
    p.get(Einkauf.Artikel__c).OFPO01__c -= Einkauf.MENG22__c;  //offene Posten
  }
  
  private static void BS15(Einkauf__c Einkauf) {
    if(p.get(Einkauf.Artikel__c).GESB01__c == null)
      p.get(Einkauf.Artikel__c).GESB01__c = 0;
    p.get(Einkauf.Artikel__c).GESB01__c -= Einkauf.MENG22__c;  //gesamt bestand
    
    if(p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c == null)
      p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c = 0;
    p.get(Einkauf.Artikel__c).Gesamt_Bestand_04051415__c -= Einkauf.MENG22__c;  //gesamt bestand (for comparison)
    
    if(p.get(Einkauf.Artikel__c).ZULJ01__c == null)
      p.get(Einkauf.Artikel__c).ZULJ01__c = 0;
    p.get(Einkauf.Artikel__c).ZULJ01__c -= Einkauf.MENG22__c;  //letztes Jahr (like gesamt bestand)
  }
  
  private static void BS16(Einkauf__c Einkauf) {
    if(Einkauf.EKPR22__c == null)
      Einkauf.addError(Error);
    else{
      if(p.get(Einkauf.Artikel__c).OFPO01__c == null)
        p.get(Einkauf.Artikel__c).OFPO01__c = 0;
      p.get(Einkauf.Artikel__c).OFPO01__c += Einkauf.MENG22__c;  //offene Posten
    }
  }
  
  private static void BS18(Einkauf__c Einkauf) {
    if(Einkauf.EKPR22__c == null)
      Einkauf.addError(Error);
    else{
      if(p.get(Einkauf.Artikel__c).EKPR01__c == null)
        p.get(Einkauf.Artikel__c).EKPR01__c = 0;
      p.get(Einkauf.Artikel__c).EKPR01__c -= Einkauf.EKPR22__c;   //letzter Einkaufspreis
    }
  }
  
  public static void produktionsstand(String Id, String Status){
    Produktionsstand__c pr;
    pr = new Produktionsstand__c();
    pr.Status__c = Status;
    pr.Datum__c = system.today();
    pr.Artikel__c = Id;
    PS.add(pr);
  }
  
  
}