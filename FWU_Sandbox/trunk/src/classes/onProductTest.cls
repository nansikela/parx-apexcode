/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class onProductTest {

    static testMethod void myUnitTest() {
        Product2 p1 = new Product2(Name='Test',IsActive=true, PDKZ01__c=2, ProductCode = '01234');
	  Medienart__c m1=new Medienart__c(Name='46',MALTXT__c='VHS');
	  insert m1;
	  Lizenz__c l1= new Lizenz__c(MED017__c = m1.Id, Aktiv__c = True, VPR015__c = 10);
	  
	  insert l1;
	  p1.MEDA01__c = m1.Id;
	  p1.Auslieferung_geplant__c = system.today();
	  p1.ProductCode = '01234';
        insert p1;
        
        Product2 p2 = new Product2(Name='Test',IsActive=true, PDKZ01__c=2, ProductCode = '01234');
        Medienart__c m2=new Medienart__c(Name='55',MALTXT__c='VHS');
	  insert m2;
        p2.MEDA01__c = m2.Id;
	  p2.Auslieferung_geplant__c = system.today();
        insert p2;
        
        p1.PDKZ01__c = 4;
        p1.Auslieferung_geplant__c = system.today()+1;
        p1.Aenderung_Produktionsstufe__c = system.today() + 15;
       
        
        p1.Sig2__c = p2.Id;
      //  update p1;
        p1.Sig3__c = p2.Id;
        p1.Sig4__c = p2.Id;
        p1.Sig5__c = p2.Id;
        p1.Sig6__c = p2.Id;

        update p1;
        
        
        ArtikelLizenz__c AL1 = new ArtikelLizenz__c();
        AL1.Artikel__c = p1.Id;
        AL1.LZN015__c = '10206';
        AL1.VPR015__c = 10;
        AL1.Name = '0';
        insert AL1;
        ArtikelLizenz__c AL2 = new ArtikelLizenz__c();
        AL2.Artikel__c = p2.Id;
        AL2.LZN015__c = '10206';
        AL2.VPR015__c = 10;
        AL2.Name = '0';
        insert AL2;
        
        Product2 p3 = new Product2(Name='Test',IsActive=true, PDKZ01__c=2, ProductCode = '01234');
        Medienart__c m3=new Medienart__c(Name='46',MALTXT__c='VHS');
	  insert m3;
        p3.MEDA01__c = m3.Id;
	  p3.Auslieferung_geplant__c = system.today();
        insert p3;
        
        ArtikelLizenz__c AL3 = new ArtikelLizenz__c();
        AL3.Artikel__c = p3.Id;
        AL3.LZN015__c = '10001';
        AL3.VPR015__c = 10;
        AL3.Name = '0';
        insert AL3;
        
        ArtikelLizenz__c AL10206 = new ArtikelLizenz__c();
        AL10206.Artikel__c = p3.Id;
        AL10206.LZN015__c = '10206';
        AL10206.VPR015__c = 10;
        AL10206.Name = '0';
        insert AL10206;
        update p3;
        
        m2.Name = '57';
        update m2;
        
        p1.SIG1__c = null;
        onProduct.inFutureContextStoredId = '';
        update p1;
        m2.Name = '55';
        update m2;
        p1.SIG1__c = null;
        onProduct.inFutureContextStoredId = '';
        p1.PDKZ01__c =8;
        p1.Aenderung_Produktionsstufe__c = System.today()+6;
        p1.Auslieferung_geplant__c = System.today()+4;
        update p1;
        
       
        m2.Name = '46';
        update m2;
        
        m1.Name = '55';
        update m1;
        AL1.LZN015__c = '40100';
        update AL1;
        onProduct.inFutureContextStoredId = '';
        Product2 p4 = new Product2(Name='Test',IsActive=true, PDKZ01__c=2, SIG2__c = p2.Id, MEDA01__c = m1.Id, ProductCode = '01234'); 
       
        p1.SIG1__c = null;
        update p1;
        onProduct.inFutureContextStoredId = '';
        insert p4;
        AL1.Artikel__c = p4.Id;
        update AL1;
        update p4;
    //    
        
        m2.Name = '42';
        update m2;
        p1.SIG1__c = p4.id;
        onProduct.inFutureContextStoredId = '';
        p1.PDKZ01__c =1;
        p1.Aenderung_Produktionsstufe__c = System.today()+1;
        update p1;
        onProduct.inFutureContextStoredId = '';
        p1.PDKZ01__c =2;
        p1.Aenderung_Produktionsstufe__c = System.today()+2;
        p1.MEDA01__c = m1.Id;
        m1.Name = '46';
        update m1;
        m2.Name = '55';
        update m2;
        p1.SIG1__c = p2.Id;
        
        ArtikelLizenz__c AL5 = new ArtikelLizenz__c();
        AL5.Artikel__c = p2.Id;
        AL5.LZN015__c = '40100';
        AL5.VPR015__c = 10;
        AL5.Name = '0';
        AL5.Artikel__c = p2.Id;
        insert AL5;
        
        update p1;
        p2.SIG1__c = p1.Id;
        onProduct.inFutureContextStoredId = '';

        p2.PDKZ01__c =6;
        p2.Aenderung_Produktionsstufe__c = System.today()+4;       
        update p2;
   //     m1.Name = '42';
  //      update m1;
        onProduct.inFutureContextStoredId = '';
     
        p2.PDKZ01__c =7;
        p2.Aenderung_Produktionsstufe__c = System.today()+5;
        p2.Auslieferung_geplant__c = System.today()+2;
    //    AL3.Artikel__c = p2.Id;
    //    update AL3;
        
        update p2;
        
        onProduct.inFutureContextStoredId = '';
        p1.PDKZ01__c =4;
        p1.Aenderung_Produktionsstufe__c = System.today()+3;
    //    update p1;
        
      //  update p1;
       
       // update p1;
        //m1.Name = '42';
        //update m1;
        
        update p1;
    }
    
    static testMethod void initialK1K2UnitTest() {
    	set<String> lzns=new set<String>();
    	lzns.add('10001');
    	lzns.add('10261');
    	lzns.add('10262');
    	lzns.add('10269');
    	// prepare test area
    	// get medienarten or create them
    	map<String, Id> mmap = new map<String, Id>();
    	for (Medienart__c ma: [SELECT Id, Name FROM Medienart__c WHERE Name='55' OR Name='46']) {
    		if (ma.Name=='46') mmap.put('46',ma.id);
    		if (ma.Name=='55') mmap.put('55',ma.id);
    	}
    	list<Medienart__c> malist = new list<Medienart__c>();
    	if (mmap.isEmpty() || mmap.size()<2) {
    		if (!mmap.containsKey('46')) {
    			malist.add(new Medienart__c(Name='46'));
    		}
    		if (!mmap.containsKey('55')) {
    			malist.add(new Medienart__c(Name='55'));
    		}
    	}
    	if (!malist.isEmpty()) insert malist;
    	for (Medienart__c ma: malist) {
    		if (!mmap.containsKey(ma.Name)) mmap.put(ma.Name, ma.id);
    	}
    	
    	map<Id, Product2> pmap = new map<Id, Product2>();
    	list<Product2> sigs=new list<Product2>();
		Id rtypeid=[SELECT Id FROM RecordType WHERE Name='Signatur'].Id;
		for (Integer i=0;i<5;i++) {
			Product2 news=new Product2();
			news.Name='Signatur' + i;
			news.ProductCode='PC'+i;
			news.PDKZ01__c=System.Math.Floor(1+i*1.5)<8?System.Math.Floor(1+i*1.5):8;
			news.RECH01__c='A';
			news.RecordTypeId=rtypeid;
			news.MEDA01__c=mmap.get('55');
			news.GESB01__c=100;
			news.VRKZ01__c='+';
			news.TXT013__c='Text';
			news.LAOR01__c='00';
			news.IsActive=true;
			sigs.add(news);
		}
		onProduct.inFutureContextStoredId = '';
		if (!sigs.isEmpty()) insert sigs;
		list<Product2> oldsigs=sigs.deepClone();
		for (Product2 p:oldsigs) {
			Product2 news=new Product2();
			news.Name='55erSignatur ' + p.Name;
			news.ProductCode='PC'+p.Name;
			news.PDKZ01__c=4;
			news.RECH01__c='A';
			news.RecordTypeId=rtypeid;
			news.MEDA01__c=mmap.get('46');
			news.SIG1__c=p.id;
			news.GESB01__c=100;
			news.VRKZ01__c='+';
			news.TXT013__c='Text';
			news.LAOR01__c='00';
			news.IsActive=true;
			sigs.add(news);
		}
		if (!sigs.isEmpty()) upsert sigs;
		for (Product2 p:sigs) {
			if (p.id!=null) pmap.put(p.id, p);
		}
		for (Product2 p: sigs) {
			if (p.Sig1__c!=null) {
				Product2 sig1=pmap.get(p.Sig1__c);
				pmap.get(sig1.id).Sig1__c=p.id;
			}
		}
		onProduct.inFutureContextStoredId = '';
		upsert pmap.values();
		system.assertNotEquals(0,pmap.size());
		// create new licenses if they don't exist:
    	set<String> linzenzkeys = new set<String>();
    	for (String ma :mmap.keySet()) {
    		for (String lzn:lzns) {
    			linzenzkeys.add(ma+lzn);
    		}
    	}
    	
    	map<String, Lizenz__c> lizenzen=new map<String, Lizenz__c>();
    	for (Lizenz__c l:[SELECT Id, Name, MED017__c, LizenzKey__c FROM Lizenz__c WHERE LizenzKey__c IN :linzenzkeys]) {
    		lizenzen.put(l.LizenzKey__c, l);
    	}
    	list<Lizenz__c> lizenzenlist = new list<Lizenz__c>();
    	if (lizenzen.isEmpty() || lizenzen.size()<4) {
			for (String ma:mmap.keySet()) {
				for (String lzn:lzns) {
					if (!lizenzen.containsKey(ma+lzn))
						lizenzenlist.add(new Lizenz__c(MED017__c=mmap.get(ma),LizenzKey__c=ma+lzn));
				}
			}    		
    	}
    	if (!lizenzenlist.isEmpty()) {
    		insert lizenzenlist;
    	}
    	for (Lizenz__c l:lizenzenlist) {
    		lizenzen.put(l.LizenzKey__c, l);
    	}
    	// create the necessary ArtikelLizenzen
    	list<ArtikelLizenz__c> allist=new list<ArtikelLizenz__c>();
		for (Product2 p:pmap.values()) {
			for (String lzn: lzns) {
				ArtikelLizenz__c al=new ArtikelLizenz__c(Artikel__c=p.id,VPR015__c=500,LZN015__c=lzn, SPK015__c=false,MNG015__c=1);
				if (lzn=='10269') 
					al.VPR015__c=12;
				allist.add(al);
			}
		}
		onProduct.inFutureContextStoredId = '';
		if (!allist.isEmpty()) insert allist;
		map<id, ArtikelLizenz__c> almap = new map<id, ArtikelLizenz__c>();
		for (ArtikelLizenz__c al:allist) {
			almap.put(al.id,al);
		}
		
		// lets check if there are any artikellizenzen for this
		for (ArtikelLizenz__c al:[SELECT Id, VPR015__c, medienart__c, LZN015__c, ArtikelLizenzKey__c, Zaehlnummer__c FROM ArtikelLizenz__c WHERE Id IN :almap.keySet()]) {
			system.debug('AL Status: ' + al.ArtikelLizenzKey__c + ' / ' + al.Medienart__c + ' / ' + al.LZN015__c + ' / ' + al.Zaehlnummer__c + ' / ' + al.VPR015__c );
			if (al.Medienart__c=='46' && al.LZN015__c!='10269') System.assertEquals(500,al.VPR015__c);
			if (al.Medienart__c=='55' && (al.LZN015__c=='10261' || al.LZN015__c=='10262')) System.assertEquals(500,al.VPR015__c);
			else if (al.LZN015__c=='10269') System.assertEquals(12,al.VPR015__c);
			else System.assertEquals(500,al.VPR015__c);
		}
		
		for (ArtikelLizenz__c al: allist) {
			if (al.LZN015__c=='10001') al.VPR015__c=1000;
			onProduct.inFutureContextStoredId = '';
			update al; // this will do the price calculaton but only @future for this we run the code manually
		}
		test.startTest();
		onProduct.onUpdate_Neuberechnung_ArtikelLizenzPreise(pmap.values());
		test.stopTest();
		//now lets check if the prices are as expected
		// IMPORT
		/*
		for (ArtikelLizenz__c al:[SELECT Id, VPR015__c, medienart__c, LZN015__c, ArtikelLizenzKey__c, Zaehlnummer__c FROM ArtikelLizenz__c WHERE Id IN :almap.keySet()]) {
			system.debug('AL Status of id ' + al.id +': ' + al.ArtikelLizenzKey__c + ' / ' + al.Medienart__c + ' / ' + al.LZN015__c + ' / ' + al.Zaehlnummer__c + ' / ' + al.VPR015__c );
			if (al.Medienart__c=='46' && al.LZN015__c=='10261') System.assertEquals(398,al.VPR015__c);
			if (al.Medienart__c=='46' && al.LZN015__c=='10262') System.assert(al.VPR015__c>292);
			if (al.Medienart__c=='55' && (al.LZN015__c=='10261' || al.LZN015__c=='10262')) System.assert(al.VPR015__c>=573);
			else if (al.LZN015__c=='10269') System.assertEquals(12,al.VPR015__c);
			else System.assert(al.VPR015__c>292);
		}
		*/
    }
    
    static testMethod void SpecialCasesK1K2UnitTest() {
    	// we check for the special cases
    	// + no sig1__c relation
    	// + no existing license
    	set<String> lzns=new set<String>();
    	lzns.add('10001');
    	lzns.add('10261');
    	lzns.add('10262');
    	lzns.add('10269');
    	// prepare test area
    	// get medienarten or create them
    	map<String, Id> mmap = new map<String, Id>();
    	for (Medienart__c ma: [SELECT Id, Name FROM Medienart__c WHERE Name='55' OR Name='46']) {
    		if (ma.Name=='46') mmap.put('46',ma.id);
    		if (ma.Name=='55') mmap.put('55',ma.id);
    	}
    	list<Medienart__c> malist = new list<Medienart__c>();
    	if (mmap.isEmpty() || mmap.size()<2) {
    		if (!mmap.containsKey('46')) {
    			malist.add(new Medienart__c(Name='46'));
    		}
    		if (!mmap.containsKey('55')) {
    			malist.add(new Medienart__c(Name='55'));
    		}
    	}
    	if (!malist.isEmpty()) insert malist;
    	for (Medienart__c ma: malist) {
    		if (!mmap.containsKey(ma.Name)) mmap.put(ma.Name, ma.id);
    	}
    	
    	map<Id, Product2> pmap = new map<Id, Product2>();
    	list<Product2> sigs=new list<Product2>();
		Id rtypeid=[SELECT Id FROM RecordType WHERE Name='Signatur'].Id;
		for (Integer i=0;i<5;i++) {
			Product2 news=new Product2();
			news.Name='Signatur' + i;
			news.ProductCode='PC'+i;
			news.PDKZ01__c=System.Math.Floor(1+i*1.5)<8?System.Math.Floor(1+i*1.5):8;
			news.RECH01__c='A';
			news.RecordTypeId=rtypeid;
			news.MEDA01__c=mmap.get('55');
			news.GESB01__c=100;
			news.VRKZ01__c='+';
			news.TXT013__c='Text';
			news.LAOR01__c='00';
			news.IsActive=true;
			sigs.add(news);
		}
		onProduct.inFutureContextStoredId = '';
		if (!sigs.isEmpty()) insert sigs;
		list<Product2> oldsigs=sigs.deepClone();
		Integer i=0;
		for (Product2 p:oldsigs) {
			Product2 news=new Product2();
			news.Name='55erSignatur ' + p.Name;
			news.ProductCode='PC'+p.Name;
			news.PDKZ01__c=4;
			news.RECH01__c='A';
			news.RecordTypeId=rtypeid;
			news.MEDA01__c=mmap.get('46');
			news.SIG1__c=i==0?null:p.id;
			news.GESB01__c=100;
			news.VRKZ01__c='+';
			news.TXT013__c='Text';
			news.LAOR01__c='00';
			news.IsActive=true;
			sigs.add(news);
			i++;
		}
		if (!sigs.isEmpty()) upsert sigs;
		for (Product2 p:sigs) {
			if (p.id!=null) pmap.put(p.id, p);
		}
		for (Product2 p: sigs) {
			if (p.Sig1__c!=null) {
				Product2 sig1=pmap.get(p.Sig1__c);
				pmap.get(sig1.id).Sig1__c=p.id;
			}
		}
		onProduct.inFutureContextStoredId = '';
		upsert pmap.values();
		system.assertNotEquals(0,pmap.size());
		// create new licenses if they don't exist:
    	set<String> linzenzkeys = new set<String>();
    	for (String ma :mmap.keySet()) {
    		for (String lzn:lzns) {
    			linzenzkeys.add(ma+lzn);
    		}
    	}
    	
    	map<String, Lizenz__c> lizenzen=new map<String, Lizenz__c>();
    	for (Lizenz__c l:[SELECT Id, Name, MED017__c, LizenzKey__c FROM Lizenz__c WHERE LizenzKey__c IN :linzenzkeys]) {
    		lizenzen.put(l.LizenzKey__c, l);
    	}
    	list<Lizenz__c> lizenzenlist = new list<Lizenz__c>();
    	if (lizenzen.isEmpty() || lizenzen.size()<4) {
			for (String ma:mmap.keySet()) {
				for (String lzn:lzns) {
					if (!lizenzen.containsKey(ma+lzn))
						lizenzenlist.add(new Lizenz__c(MED017__c=mmap.get(ma),LizenzKey__c=ma+lzn));
				}
			}    		
    	}
    	if (!lizenzenlist.isEmpty()) {
    		insert lizenzenlist;
    	}
    	for (Lizenz__c l:lizenzenlist) {
    		lizenzen.put(l.LizenzKey__c, l);
    	}
    	// create the necessary ArtikelLizenzen
    	list<ArtikelLizenz__c> allist=new list<ArtikelLizenz__c>();
		for (Product2 p:pmap.values()) {
			for (String lzn: lzns) {
				if (lzn!='10261' && lzn!='10269') {
					ArtikelLizenz__c al=new ArtikelLizenz__c(Artikel__c=p.id,VPR015__c=100,LZN015__c=lzn, SPK015__c=false,MNG015__c=1);
					allist.add(al);
				}
				if (lzn=='10269') {
					ArtikelLizenz__c al=new ArtikelLizenz__c(Artikel__c=p.id,VPR015__c=12,LZN015__c=lzn, SPK015__c=false,MNG015__c=1);
					allist.add(al);
				}
			}
		}
		onProduct.inFutureContextStoredId = '';
		if (!allist.isEmpty()) insert allist;
		map<id, ArtikelLizenz__c> almap = new map<id, ArtikelLizenz__c>();
		for (ArtikelLizenz__c al:allist) {
			almap.put(al.id,al);
		}
		
		// lets check if there are any artikellizenzen for this
		for (ArtikelLizenz__c al:[SELECT Id, VPR015__c, medienart__c, LZN015__c, ArtikelLizenzKey__c, Zaehlnummer__c FROM ArtikelLizenz__c WHERE Id IN :almap.keySet()]) {
			system.debug('AL Status: ' + al.ArtikelLizenzKey__c + ' / ' + al.Medienart__c + ' / ' + al.LZN015__c + ' / ' + al.Zaehlnummer__c + ' / ' + al.VPR015__c );
			if (al.Medienart__c=='46' && al.LZN015__c!='10269') System.assertEquals(100,al.VPR015__c);
			if (al.Medienart__c=='55' && (al.LZN015__c=='10261' || al.LZN015__c=='10262')) System.assertEquals(100,al.VPR015__c);
			else if (al.LZN015__c=='10269') System.assertEquals(12,al.VPR015__c);
			else System.assertEquals(100,al.VPR015__c);
		}
		
		for (ArtikelLizenz__c al: allist) {
			if (al.LZN015__c=='10001') al.VPR015__c=150;
			onProduct.inFutureContextStoredId = '';
			update al; // this will do the price calculaton but only @future for this we run the code manually
		}
		test.startTest();
		onProduct.onUpdate_Neuberechnung_ArtikelLizenzPreise(pmap.values());
		test.stopTest();
		//now lets check if the prices are as expected
		for (ArtikelLizenz__c al:[SELECT Id, VPR015__c, medienart__c, LZN015__c, ArtikelLizenzKey__c, Zaehlnummer__c FROM ArtikelLizenz__c WHERE Id IN :almap.keySet()]) {
			system.debug('AL Status of id ' + al.id +': ' + al.ArtikelLizenzKey__c + ' / ' + al.Medienart__c + ' / ' + al.LZN015__c + ' / ' + al.Zaehlnummer__c + ' / ' + al.VPR015__c );
			if (al.Medienart__c=='46') System.assert(al.VPR015__c>=1);
			if (al.Medienart__c=='55' && (al.LZN015__c=='10261' || al.LZN015__c=='10262')) {
				System.assert(al.VPR015__c>=100);
			}
			else System.assert(al.VPR015__c>=1);
		}
		
    }
}