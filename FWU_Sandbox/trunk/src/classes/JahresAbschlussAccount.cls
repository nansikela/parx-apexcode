public class JahresAbschlussAccount {

	private static map<Id, Account> accounts=new map<Id, Account>();
	private static list<Account> accountstoupdate= new list<Account>();
	public static Boolean runTest=false;
	private static final Integer MONTHTORUN=1; // TODO has to to be changed to 1, if we go live!

	// in this batch we only need to change something if years have changed
	// the turnover volume of all acounts will be propageted through the turnover volume fields
	// turnover volume recent year -> turnover volume last year
	// turnover volume last year -> turnover volume 2 years ago ...
	public static void run(map<Id, Account> accs) {
		//clone to keep the old state
		accounts=accs.deepClone();
		setUmsaetze();
		updateAccounts();
		SystemSettings.insertErrors();
	}
	
	private static void setUmsaetze() {
		if (!accounts.isEmpty() && (System.today().month()==MONTHTORUN || runTest)) {
			for (Id aid: accounts.keySet()) {
				if (accounts.get(aid).UMLJ02__c==null) accounts.get(aid).UMLJ02__c=0;
				if (accounts.get(aid).UM1V02__c==null) accounts.get(aid).UM1V02__c=0;
				if (accounts.get(aid).UM2V02__c==null) accounts.get(aid).UM2V02__c=0;
				if (accounts.get(aid).UM3V02__c==null) accounts.get(aid).UM3V02__c=0;
				if (accounts.get(aid).UM4V02__c==null) accounts.get(aid).UM4V02__c=0;
				if (!(accounts.get(aid).UMLJ02__c==0 
						&& accounts.get(aid).UM1V02__c==0 
						&& accounts.get(aid).UM2V02__c==0 
						&& accounts.get(aid).UM3V02__c==0
						&& accounts.get(aid).UM4V02__c==0)
						) {	
					accounts.get(aid).UM4V02__c=accounts.get(aid).UM3V02__c;
					accounts.get(aid).UM3V02__c=accounts.get(aid).UM2V02__c;
					accounts.get(aid).UM2V02__c=accounts.get(aid).UM1V02__c;
					accounts.get(aid).UM1V02__c=accounts.get(aid).UMLJ02__c;
					accounts.get(aid).UMLJ02__c=0;
					accountstoupdate.add(accounts.get(aid));
				}
			}
		}
	}
	
	private static void updateAccounts() {
		if (!accountstoupdate.isEmpty()) {
			try {
				update accountstoupdate;
			} catch (System.Dmlexception e) {
				SystemSettings.logError(e.getMessage(),'DEBUG');
				if (SystemSettings.isDebug) throw e;
			}
		}
	}
}