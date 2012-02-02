public class onProduktionsstandHelper {
	/*
	public static void run(map<Id, Date> npdates) {
		if (!npdates.isEmpty()) {
			list<Product2> ptoupdate = new list<Product2>();
			try {
				for (Product2 p:[SELECT Id, Datum_Neuproduktion__c FROM Product2 WHERE Id IN: npdates.keySet()]) {
					if (p.Datum_Neuproduktion__c==null) p.Datum_Neuproduktion__c=npdates.get(p.id);
					ptoupdate.add(p);
				}
			} catch (System.Queryexception e) {
				SystemSettings.logError(e.GetMessage());
			}
			if (!ptoupdate.isEmpty()) {
				try {
					update ptoupdate;
				} catch (System.DmlException e) {
					SystemSettings.logError(e.GetMessage());
				}
			}
		}
	}
	*/
}