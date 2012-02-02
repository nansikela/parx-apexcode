public class JahresAbschlussArtikel {

  private static map<Id, Product2> artikel=new map<Id, Product2>();
  public static Boolean runTest=false;
  private static final Integer MONTHTORUN=System.today().month(); // TODO has to to be changed to 1, if we go live!
  
  // in this process we have to change values of turnover and sales volume
  // -
  // umsatz/absatz current month == 0
  // umsatz/absatz current year == 0 if we have month 1
  // -
   // we have to take care that products with no more rights will set to PS 8
  // -
  // 
  public static void run(map<Id, Product2> arts) {
    //clone to keep the old state
    onProduct.inFutureContextStoredId = 'true'; 
    artikel=arts.deepClone();
    setPS5();
    setUmsaetze();
    updateArtikel();
    SystemSettings.insertErrors();
  }
  
  private static void setPS5() {
    if (!artikel.isEmpty()) {
      for (Id pid: artikel.keySet()) {
        if (artikel.get(pid).PDKZ01__c==4 && (runTest || System.today().month()==MONTHTORUN)) {
          artikel.get(pid).PDKZ01__c=5;
          if (artikel.get(pid).Aenderung_Produktionsstufe__c!=System.today())
            artikel.get(pid).Aenderung_Produktionsstufe__c=System.today();
          else
            artikel.get(pid).Aenderung_Produktionsstufe__c=System.today()+1;
        }
      }
    }
  }
  
  private static void setUmsaetze() {
    if (!artikel.isEmpty()) {
      for (Id pid: artikel.keySet()) {
        if (runTest || System.today().month()==MONTHTORUN) artikel.get(pid).AUEA01__c=0;
        if (artikel.get(pid).UMLJ01__c!=null && (runTest || System.today().month()==MONTHTORUN)) {
          artikel.get(pid).UMVJ01__c=artikel.get(pid).UMLJ01__c;
        } else if ((System.today().month()==MONTHTORUN || runTest))
          artikel.get(pid).UMVJ01__c=0;
        if (artikel.get(pid).UMLJ01__c==null || runTest || System.today().month()==MONTHTORUN)
          artikel.get(pid).UMLJ01__c=0;
        
        if (artikel.get(pid).ABLJ01__c!=null && (runTest || System.today().month()==MONTHTORUN)) {
          artikel.get(pid).ABVJ01__c=artikel.get(pid).ABLJ01__c;
        } else if ((System.today().month()==MONTHTORUN || runTest))
          artikel.get(pid).ABVJ01__c=0;
        if (artikel.get(pid).ABLJ01__c==null || runTest || System.today().month()==MONTHTORUN) 
          artikel.get(pid).ABLJ01__c=0;
        
        
        if (artikel.get(pid).ZULJ01__c!=null && (runTest || System.today().month()==MONTHTORUN)) {
          artikel.get(pid).ZUVJ01__c=artikel.get(pid).ZULJ01__c;
        } else if ((System.today().month()==MONTHTORUN || runTest))
          artikel.get(pid).ZUVJ01__c=0;
        if (artikel.get(pid).ZULJ01__c==null || runTest || System.today().month()==MONTHTORUN) 
          artikel.get(pid).ZULJ01__c=0;
          
        if (artikel.get(pid).GESB01__c!=null && (runTest || System.today().month()==MONTHTORUN))
          artikel.get(pid).LBVO01__c=artikel.get(pid).GESB01__c;
        else
          artikel.get(pid).LBVO01__c=0;
      }
    } 
  }
  
  private static void updateArtikel() {
    if (!artikel.isEmpty()) {
      try {
        update artikel.values();
      } catch (System.Dmlexception e) {
        SystemSettings.logError(e.getMessage(),'DEBUG');
        if (SystemSettings.isDebug) throw e;
      }
    }
  }
}