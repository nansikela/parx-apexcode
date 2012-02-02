public class MonatsAbschlussArtikel {

  private static map<Id, Product2> artikel=new map<Id, Product2>();
  public static Boolean runTest=false;
  
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
    setPS8();
    setUmsaetze();
    updateArtikel();
    SystemSettings.insertErrors();
  }
  
  private static void setPS8() {
    if (!artikel.isEmpty()) {
      for (Id pid: artikel.keySet()) {
        if ((artikel.get(pid).RBMJ01__c!=null && System.today()>artikel.get(pid).RBMJ01__c && artikel.get(pid).PDKZ01__c!=8) || runTest) {
          artikel.get(pid).PDKZ01__c=8;
          if (artikel.get(pid).Aenderung_Produktionsstufe__c!=System.today())
            artikel.get(pid).Aenderung_Produktionsstufe__c=System.today();
          else
            artikel.get(pid).Aenderung_Produktionsstufe__c=System.today();
        }
      }
    }
  }
  
  private static void setUmsaetze() {
    if (!artikel.isEmpty()) {
      for (Id pid: artikel.keySet()) {
        artikel.get(pid).UMMO01__c=0;
        artikel.get(pid).ABMO01__c=0;
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