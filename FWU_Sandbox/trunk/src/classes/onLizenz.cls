public class onLizenz {
	
	@Future (callout=true)
	public static void listtodo(list<String> lizenzIds, list<String> mediaIds) {
		list<Artikellizenz__c> Artikellizenz = new list<Artikellizenz__c>();
		list<Artikellizenz__c> ALtoInsert;
		list<lizenz__c> Lizenz = new list<lizenz__c>();
		
		cloneClever.cloneDynamic(Artikellizenz, Lizenz, lizenzIds);

		//limit 9990: we reserve 10 lines for other jobs.
		list<Product2> prod = new list<Product2>([select id, MEDA01__c, AUSW01__c from Product2 where MEDA01__c IN: mediaIds limit 9990]);
		
		Artikellizenz__c AL;
		ALtoInsert = new list<Artikellizenz__c>();

		for(Product2 trig:prod) {
			for(Artikellizenz__c temp:Artikellizenz) {
				if(temp.MED017__c == trig.MEDA01__c && (temp.LZN015__c != '10306'/*||(trig.AUSW01__c == '8' && temp.LZN015__c == '10306')*/)) { 
					//if lizenz 10306, then it must be a second label (AUSW01 == 8)				
					AL = new Artikellizenz__c();
					AL = temp.clone(false,true);
					AL.Artikel__c = trig.Id;
					ALtoInsert.add(AL);
				}
			}
		}
		if(!ALtoInsert.isEmpty())
			insert ALtoInsert;
	}
}