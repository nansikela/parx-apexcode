public class JahresAbschluss {

	public static void JahresAbschlussAccountRun(list<sObject> acc) {
		map<Id, Account> accounts = new map<Id, Account>();
		if (!acc.isEmpty()) {
			for (sObject s: acc) {
				Account a=(Account)s;
				if (!accounts.containsKey(a.id)) accounts.put(a.id, a);
			}
		}
		JahresAbschlussAccount.run(accounts);
	}

		
	public static void JahresAbschlussArtikelRun(list<sObject> prod) {
		map<Id, Product2> artikel=new map<Id, Product2>();
		if (!prod.isEmpty()) {
			for (sObject s: prod) {
				Product2 p=(Product2)s;
				if (!artikel.containsKey(p.id)) artikel.put(p.id, p);
			}
		}
		JahresAbschlussArtikel.run(artikel);
	}
}