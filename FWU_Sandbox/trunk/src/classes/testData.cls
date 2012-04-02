@isTest
public class testData {

	public static String creationAccount() {
		Account acc = new Account(
								Name='TestAcc', 
								BillingCity = 'city', 
								BillingStreet = 'Street',
								BillingPostalCode = '12345', 
								BillingCountry = 'DE',
								CODE02__c = '01');
    	insert acc;
		return acc.Id;
	}
	
	public static String creationPersonAccount() {
		Account acc = new Account(
								PersonEmail = 'bq212efwefwe223235dfehg531@ase3412d21.qw', 
								lastname= 'last', 
								firstname = 'first', 
								BillingCity = 'city', 
								BillingStreet = 'Street', 
								BillingPostalCode = '12345', 
								BillingCountry = 'DE',
								Salutation = 'Herr',
								CODE02__c = '01');
    	insert acc;
		return acc.Id;
	}
	
	public static String creationContact(String AccId) {
		Contact ctct = new Contact(
								LastName='Lastname', 
								FirstName = 'Firstname', 
								Salutation = 'Herr',
								email = 'q212efwefwe223235dfehg531@ase3412d21.qw',
								AccountId = AccId);
    	insert ctct;
		return ctct.Id;
	}
		
	// test type to transfer test data simplier
	public class testSammelnummer {
		public map<Id, PricebookEntry> pbemap = new map<Id, PricebookEntry>();
		public map<Id, Product2> pmap = new map<Id, Product2>();
		public map<Id, ArtikelLizenz__c> almap = new map<Id, ArtikelLizenz__c>();
		public map<Id, Medienart__c> mmap = new map<Id, Medienart__c>();
		public map<Id, Medienpaket_Lizenz__c> mplmap = new map<Id, Medienpaket_Lizenz__c>();
		public Product2 sammelnummer=new Product2();
		public PricebookEntry snpbe= new PricebookEntry();
		public map<Id, Id> pbetoal= new map<Id, Id>();
		public Integer numberOfPRoducts=5;
		public Boolean hasData=false;
		
		public testSammelnummer() {
			pbemap=new map<Id, PricebookEntry>();
			pmap = new map<Id, Product2>();
			almap = new map<Id, ArtikelLizenz__c>();
			mmap = new map<Id, Medienart__c>();
			mplmap = new map<Id, Medienpaket_Lizenz__c>();
			sammelnummer=new Product2();
			createMedienarten();
			createSammelnummer();
			if (sammelnummer.id!=null) createProduct();
			pmap.put(sammelnummer.id, sammelnummer);
			if (sammelnummer.id!=null) createPricebookEntry();
			if (sammelnummer.id!=null && !pmap.isEmpty()) createArtikelLizenz();
			if (sammelnummer.id!=null && !almap.isEmpty()) createMedienpaketLizenzen();
			for (ArtikelLizenz__c al: almap.values()) {
				for (PricebookEntry pbe:pbemap.values()) {
					if (al.Artikel__c==pbe.Product2Id && !pbetoal.containsKey(pbe.id)) pbetoal.put(pbe.id,al.id); 
				}
			}
			if (sammelnummer.id!=null && !pmap.isEmpty() && !almap.isEmpty() && !mplmap.isEmpty() ) hasData=true;
		}
		
		// creates sammelnummer
		void createSammelnummer() {
			sammelnummer=new Product2();
			sammelnummer.Name='Sammelnummer';
			sammelnummer.ProductCode='PC';
			sammelnummer.IsActive=true;
			sammelnummer.MEDA01__c=mmap.values().get(0).id;
			sammelnummer.PDKZ01__c=4;
			sammelnummer.RECH01__c='A';
			sammelnummer.RecordTypeId=[SELECT Id FROM RecordType WHERE Name='Sammelnummer'].Id;
			insert sammelnummer;
		}
		
		// creates needed Medienarten
		void createMedienarten() {
			list<Medienart__c> mlist=new list<Medienart__c>();
			Medienart__c m1=new Medienart__c(Name='88',MALTXT__c='VHS');
			Medienart__c m2=new Medienart__c(Name='99',MALTXT__c='DVD');
			mlist.add(m1); mlist.add(m2);
			if (!mlist.isEmpty()) insert mlist;
			for (Medienart__c m:mlist) {
				mmap.put(m.id, m);
			}
		}
		
		//creates signatures for testing
		void createProduct() {
			list<Product2> sigs=new list<Product2>();
			Id rtypeid=[SELECT Id FROM RecordType WHERE Name='Signatur'].Id;
			for (Integer i=0;i<numberOfProducts;i++) {
				Product2 news=new Product2();
				news.Name='Signatur' + i;
				news.ProductCode='PC';
				news.PDKZ01__c=System.Math.Floor(1+i*1.5)<8?System.Math.Floor(1+i*1.5):8;
				news.RECH01__c='A';
				news.RecordTypeId=rtypeid;
				news.MEDA01__c=mmap.values().get(1).id;
				news.GESB01__c=100;
				news.VRKZ01__c='+';
				news.TXT013__c='Text';
				news.LAOR01__c='00';
				news.IsActive=true;
				sigs.add(news);
			}
			if (!sigs.isEmpty()) insert sigs;
			for (Product2 p:sigs) {
				pmap.put(p.id, p);
			}
		}
		
		// creats the necessary pricebookentry for sammelnummer
		// and the signatures
		void createPricebookEntry() {
			if (pbemap.isEmpty()) {
				// first we need to select the standard price book
				Id pricebook2id=[SELECT Id FROM Pricebook2 WHERE IsActive=true AND Name=:SystemSettings.STANDARDPRICEBOOKNAME limit 1].Id;
				list<PricebookEntry> pbes=new list<PricebookEntry>();
				if (pricebook2id!=null) {
					for (Product2 p: pmap.values()) {
						PricebookEntry pbe=new PricebookEntry(Pricebook2Id=pricebook2id,Product2Id=p.id,UnitPrice=1,IsActive=true);
						pbes.add(pbe);
					}
					if (!pbes.isEmpty()) {
						try { 
							insert pbes;
						} catch (System.DmlException e) {
							// just to catch the problem, that this prices already exits
							// the prices already exist, now we select them
							pbes=[SELECT Id, Pricebook2Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id IN :pmap.values()];
						}
					}
				}
				for (PricebookEntry pbe:pbes) {
					if (pbe.id!=null && pbe.Pricebook2Id==pricebook2id) {
						if (pbe.Product2Id==sammelnummer.id) snpbe=pbe;
						pbemap.put(pbe.id,pbe);
					}
				}
			}
		}
		
		// creates the Artikel Lizenzen for all signatures
		// and binds them to the sammelnummer
		void createArtikelLizenz() {
			list<ArtikelLizenz__c> allist=new list<ArtikelLizenz__c>();
			for (Product2 p:pmap.values()) {
				ArtikelLizenz__c al=new ArtikelLizenz__c(Artikel__c=p.id,VPR015__c=10,LZN015__c='10001', SPK015__c=false,MNG015__c=1,KOM016__c='Test');
				allist.add(al);
			}
			if (!allist.isEmpty()) insert allist;
			for (ArtikelLizenz__c al:allist) {
				almap.put(al.id,al);
			}
		}
		
		// creates all the Medienpaketlizenzen for Sammelnr
		void createMedienpaketLizenzen() {
			list<Medienpaket_Lizenz__c> mpllist = new list<Medienpaket_Lizenz__c>();
			for (ArtikelLizenz__c a : almap.values()) {
				Medienpaket_Lizenz__c mpl = new Medienpaket_Lizenz__c();
				mpl.Medienpaket__c=sammelnummer.id;
				mpl.VPR012__c=1;
				mpl.LZN012__c=a.id;
				mpllist.add(mpl);
			}
			if (!mpllist.isEmpty()) {
				insert mpllist;
			}
			for (Medienpaket_Lizenz__c mpl: mpllist) {
				if (!mplmap.containsKey(mpl.id)) mplmap.put(mpl.id,mpl);
			}
		}
	}

	// creates necessary products, opps and lineitems for testing of KO, K1 and K2
	public class testKreisOnline {
		public map<Id, Opportunity> oppmap =new map<Id, Opportunity>();
		public Account a=[SELECT Id, Name FROM Account WHERE Id =:creationAccount()];
		public map<Id, Medienart__c> mmap = new map<Id, Medienart__c>();
		public map<Id, OpportunityLineItem> olimap=new map<Id, OpportunityLineItem>();
		public map<Id, PricebookEntry> pbemap = new map<Id, PricebookEntry>();
		public map<Id, Product2> pmap = new map<Id, Product2>();
		public map<Id, ArtikelLizenz__c> almap = new map<Id, ArtikelLizenz__c>();
		public Boolean hasData=false;
		Id pricebook2id=[SELECT Id FROM Pricebook2 WHERE IsActive=true AND Name=:SystemSettings.STANDARDPRICEBOOKNAME limit 1].Id;
		
		// basic settings
		set<String> KOMA = new set<String>{'46','55'};
		set<String> KOLZN = new set<String>{'10206','10001','10002','10261','10262','10269'};
		// Verkaufsprogramm zu Lizenznummer
		map<String, String> VKPs = new map<String, String>();
		map<String, set<String>> validLZN = new map<String, set<String>>(); 
				
		public testKreisOnline() {
			VKPs.put('KO','10206');
			VKPs.put('K1','10261');
			VKPs.put('K2','10262');
			validLZN.put('KO',new set<String>{'10206'});
			validLZN.put('K1',new set<String>{'10261','10269'});
			validLZN.put('K2',new set<String>{'10262','10269'});
			pmap = new map<Id, Product2>();
			pbemap=new map<Id, PricebookEntry>();
			almap = new map<Id, ArtikelLizenz__c>();
			mmap = new map<Id, Medienart__c>();
			oppmap =new map<Id, Opportunity>();
			createMedienarten();
			if (!mmap.isEmpty()) createProduct();
			if (!pmap.isEmpty()) createPricebookEntry();
			if (!pmap.isEmpty()) createArtikelLizenz();
			if (!pbemap.isEmpty()) createOpportunities();
			if (!oppmap.isEmpty()) createOli();
			if (!olimap.isEmpty()) hasData=true;
		}
		
		
		public void updateOliData() {
			olimap = new map<Id, OpportunityLineItem>([SELECT Id 
											, Kreisliste__c 
											, Lizenznummer__c 
											, KreisOnlineCopyId__c
											, Anzahl_Schulen__c
											, Anzahl_Schulen_berechnet__c
											, ArtikelProduktionsstufe__c
											, Discount
											, FRME2D__c
											, Fremdvertrieb__c
											, GELM2D__c
											, Gesamtpreis__c
											, Gesamtpreis_Netto__c
											, isMWST__c
											, K1_K2_Zahl_der_Vervielf_ltigungen__c
											, Kopien_Rabatt__c
											, Liefermenge__c
											, ListPrice
											, Lizenzart__c
											, MEDA2D__c
											, medienart_55__c
											, medienart_id__c
											, OppAnzahlSchulen__c
											, OppBestelldatum__c
											, OpportunityId
											, OppRechnungsArt__c
											, OppStageName__c
											, OppTeillieferung__c
											, OppVKP_Einzelpreis__c
											, Preis465557__c
											, PreisbuchId__c
											, PricebookEntryId
											, Product2Id__c
											, Produktionsstufe__c
											, Produkttyp__c
											, Quantity
											, rabattfaehig__c
											, SCHL2D__c
											, Sig1Id__c
											, Sperrkz__c
											, SkipTriggerfromDataloader__c
											, STAT2D__c
											, StatusPosition__c
											, TotalPrice
											, UnitPrice
											, Verkaufspreis_Netto__c
											, Verkaufsprogramm__c
											, Lizenzmenge__c
											FROM OpportunityLineItem WHERE
											isSammelnummernOLI__c=false AND
											(
											Id IN :olimap.keySet()
											)
										]);
		}
		
		// creates needed Medienarten
		void createMedienarten() {
			
			map<String, Medienart__c> existing_ma = new map<String, Medienart__c>();
			for (Medienart__c ma: [SELECT Id, Name FROM Medienart__c WHERE Name IN :KOMA]) {
				existing_ma.put(ma.Name, ma);
			}
			list<Medienart__c> mlist=new list<Medienart__c>();
			for (String makey:KOMA) {
				if (existing_ma.containsKey(makey))
					mmap.put(existing_ma.get(makey).id, existing_ma.get(makey));
				else {
					Medienart__c m1=new Medienart__c(Name=makey,MALTXT__c='DVD'+makey);
					mlist.add(m1);
				}
			}
			if (!mlist.isEmpty()) insert mlist;
			for (Medienart__c m:mlist) {
				mmap.put(m.id, m);
			}
		}
		
		//creates signatures for testing
		void createProduct() {
			list<Product2> sigs=new list<Product2>();
			Id rtypeid=[SELECT Id FROM RecordType WHERE Name='Signatur'].Id;
			for (Medienart__c ma:mmap.values()) {
				Product2 news=new Product2();
				news.Name=ma.Name + 'PC1231';
				news.ProductCode='PC1231';
				news.RecordTypeId=rtypeid;
				news.MEDA01__c=ma.id;
				news.PDKZ01__c=4;
				news.RECH01__c='A';
				news.VRKZ01__c='+';
				news.TXT013__c='Testtext';
				news.IsActive=true;
				news.GESB01__c=200;
				news.LAOR01__c='00';
				sigs.add(news);
			}
			if (!sigs.isEmpty()) insert sigs;
			for (Product2 p:sigs) {
				pmap.put(p.id, p);
			}
		}
		
		// creats the necessary pricebookentry for sammelnummer
		// and the signatures
		void createPricebookEntry() {
			if (pbemap.isEmpty()) {
				list<PricebookEntry> pbes=new list<PricebookEntry>();
				if (pricebook2id!=null) {
					for (Product2 p: pmap.values()) {
						PricebookEntry pbe=new PricebookEntry(Pricebook2Id=pricebook2id,Product2Id=p.id,UnitPrice=1,IsActive=true);
						pbes.add(pbe);
					}
					if (!pbes.isEmpty()) {
						try {
							insert pbes;
						} catch (System.DmlException e) {
							// the prices already exist, now we select them
							pbes=[SELECT Id, Pricebook2Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id IN :pmap.values()];
						}
					}
				}
				for (PricebookEntry pbe:pbes) {
					if (pbe.id!=null && pbe.Pricebook2Id==pricebook2id) {
						pbemap.put(pbe.id,pbe);
					}
				}
			}
		}
		
		// creates the Artikel Lizenzen for all signatures
		void createArtikelLizenz() {
			list<ArtikelLizenz__c> allist=new list<ArtikelLizenz__c>();
			for (Product2 p:pmap.values()) {
				for (String lzn: KOLZN) {
					ArtikelLizenz__c al=new ArtikelLizenz__c(Artikel__c=p.id,VPR015__c=1,LZN015__c=lzn, SPK015__c=false,MNG015__c=1, ArtikelLizenzKey__c='' + mmap.get(p.MEDA01__c).Name + p.ProductCode + lzn);
					allist.add(al);
				}
			}
			System.assertEquals(pmap.size()*KOLZN.size(),allist.size());
			if (!allist.isEmpty()) insert allist;
			for (ArtikelLizenz__c al:allist) {
				almap.put(al.id,al);
			}
		}
		
		// create the different Opps
		void createOpportunities() {
			list<Opportunity> opps=new list<Opportunity>();
			for (String vkp: VKPs.keySet()) {
				Opportunity opp = new Opportunity(Name='Test'+vkp,AccountId=a.id);
				opp.Anzahl_Schulen__c=10;
				opp.CloseDate=System.today()+10;
				opp.VKPG2A__c=vkp;
				opp.Lizenznummer__c=VKPs.get(vkp);
				opp.BEDA2A__c=System.today();
				opp.Pricebook2Id=pricebook2id;
				opp.REAR2A__c=0;
				opp.StageName='In Erstellung';
				opps.add(opp);
			}
			if (!opps.isEmpty()) insert opps;
			set<Id> oppids= new set<Id>();
			for (Opportunity opp: opps) {
				oppids.add(opp.id);
			}
			for (Opportunity opp: [SELECT Id, Name, AccountId, VKPG2A__c, REAR2A__c, Lizenznummer__c FROM Opportunity WHERE Id IN :oppids]) {
				oppmap.put(opp.id, opp);
			}
		}
		
		// now we create the suitable KOs for the 46er
		void createOli() {
			list<OpportunityLineItem> olilist=new list<OpportunityLineItem>();
			map<Id, Id> pbetoal= new map<Id, Id>();
			for (Opportunity opp: oppmap.values()) {
				pbetoal.clear();
				// select base lzn for this opp
				String baselzn=opp.Lizenznummer__c;
				for (ArtikelLizenz__c al: almap.values()) {
					// only add valid LZNs to the Opp
					System.debug('testData valid LZN: ' + al.LZN015__c);
					if (validLZN.get(opp.VKPG2A__c).contains(al.LZN015__c) && (al.LZN015__c==baselzn || al.LZN015__c=='10269')) {
						for (PricebookEntry pbe:pbemap.values()) {
							if (al.Artikel__c==pbe.Product2Id && !pbetoal.containsKey(al.id)) pbetoal.put(al.id,pbe.id); 
						}
					}
				}
				for (Id alid: pbetoal.keySet()) {
					OpportunityLineItem oli=new OpportunityLineItem(OpportunityId=opp.id,PricebookEntryId=pbetoal.get(alid),SCHL2D__c=alid,Quantity=1,UnitPrice=5);
					olilist.add(oli);
				}
			}
			insert olilist;
			for (OpportunityLineItem oli:olilist) {
				if (!olimap.containsKey(oli.id)) olimap.put(oli.id,oli);
			}
			olimap = new map<Id, OpportunityLineItem>([SELECT Id 
											, Kreisliste__c 
											, Lizenznummer__c 
											, KreisOnlineCopyId__c
											, Anzahl_Schulen__c
											, Anzahl_Schulen_berechnet__c
											, ArtikelProduktionsstufe__c
//											, Discount
											, FRME2D__c
											, GELM2D__c
											, Gesamtpreis__c
											, Gesamtpreis_Netto__c
											, isMWST__c
											, K1_K2_Zahl_der_Vervielf_ltigungen__c
											, Kopien_Rabatt__c
											, Liefermenge__c
											, ListPrice
											, Lizenzart__c
											, MEDA2D__c
											, medienart_55__c
											, medienart_id__c
											, OppAnzahlSchulen__c
											, OppBestelldatum__c
											, OpportunityId
											, OppRechnungsArt__c
											, OppStageName__c
											, OppTeillieferung__c
											, OppVKP_Einzelpreis__c
											, Preis465557__c
											, PreisbuchId__c
											, PricebookEntryId
											, Product2Id__c
											, Produktionsstufe__c
											, Produkttyp__c
											, Quantity
											, rabattfaehig__c
											, SCHL2D__c
											, Sig1Id__c
											, Sperrkz__c
											, SkipTriggerfromDataloader__c
											, STAT2D__c
											, StatusPosition__c
											, TotalPrice
											, UnitPrice
											, Verkaufspreis_Netto__c
											, Verkaufsprogramm__c
											, Lizenzmenge__c
											FROM OpportunityLineItem WHERE
											isSammelnummernOLI__c=false AND
											(
											Id IN :olimap.keySet()
											)
										]);
			
			//system.debug('Oli-List: ' + olimap.values());
			// set Kreisliste__c and KreisOnlineCopyId right (btw. why does the trigger not his job?)
			// go through 46er
			//map<Id, OpportunityLineItem> olistoupdate= new map<Id, OpportunityLineItem>();
			for (OpportunityLineItem oli46g: [SELECT Id, OpportunityId, Kreisliste__c, KreisOnlineCopyId__c, medienart_id__c, medienart_55__c, SCHL2D__c, Verkaufsprogramm__c, Lizenznummer__c, Sig1Id__c, PricebookEntry.ProductCode, Quantity FROM OpportunityLineItem WHERE Id IN: olimap.KeySet() AND medienart_id__c='46' AND Lizenznummer__c!='10269']) {
				for (OpportunityLineItem otherOli: [SELECT Id, OpportunityId, Kreisliste__c, KreisOnlineCopyId__c, medienart_id__c, medienart_55__c, SCHL2D__c, Verkaufsprogramm__c, Lizenznummer__c, Sig1Id__c, PricebookEntry.ProductCode, Quantity FROM OpportunityLineItem WHERE Id IN: olimap.KeySet() AND (medienart_id__c='55' OR Lizenznummer__c='10269')]) {
					if (otherOli.medienart_id__c=='55' && olimap.get(otherOli.id).OpportunityId==oli46g.OpportunityId) { // we got a corresponding 55er/this works only for single artikel in the opps
						olimap.get(oli46g.id).Kreisliste__c=otherOli.id;
						olimap.get(otherOli.id).Kreisliste__c=oli46g.id;
					} else if (otherOli.medienart_id__c=='46' && otherOli.OpportunityId==oli46g.OpportunityId){ // it is K1/K2 and a copies license
						olimap.get(otherOli.Id).Kreisliste__c=oli46g.id;
						System.debug('Artikel Id und Lizenznummer: ' + oli46g.medienart_55__c + ' - ' + oli46g.lizenznummer__c);
						String alkey='55' + oli46g.PricebookEntry.ProductCode + oli46g.Lizenznummer__c;
						System.debug('ArtikelLizenzKey: ' + alkey);
						for (ArtikelLizenz__c al: almap.values()) {
							if (al.ArtikelLizenzKey__c==alkey) olimap.get(otherOli.Id).KreisOnlineCopyId__c=al.id;
						}
						System.assert(olimap.get(otherOli.Id).KreisOnlineCopyId__c!=null);
					}
				}
			}
			update olimap.values();
			system.debug('Oli-List: ' + olimap.values());
		}
		
		public void unlookOpportunities() {
			for (id oppid:oppmap.keySet()) {
				oppmap.get(oppid).Locked__c=false;
			}
			update oppmap.values();
		}
		
	}
	
	// creates Opportunity for testing purpose
	public class testOpportunity {
		public Opportunity opp=new Opportunity();
		public Account a=new Account();
		public Boolean hasData=false;
		Id pricebook2id=[SELECT Id FROM Pricebook2 WHERE IsActive=true AND Name=:SystemSettings.STANDARDPRICEBOOKNAME limit 1].Id;
		
		public testOpportunity() {
			a = new Account(
								Name='TestAcc', 
								BillingCity = 'city', 
								BillingStreet = 'Street',
								BillingPostalCode = '12345', 
								BillingCountry = 'DE',
								CODE02__c = '01');
			insert a;
			if (a.Id!=null) opp=new Opportunity(Name='Test',AccountId=a.Id,CloseDate=System.today()+365,StageName='In Erstellung',Pricebook2Id=pricebook2id,Lizenznummer__c='10001');
			insert opp;
			if (opp.id!=null) hasData=true;
		}
				
		public void unlookOpportunities() {
			opp.Locked__c=false;
			update opp;
		}
	}
	
	// creates LineItem for testing purpose
	public class testOli {
		public map<Id, OpportunityLineItem> olimap=new map<Id, OpportunityLineItem>();
		public map<Id, PricebookEntry> pbemap = new map<Id, PricebookEntry>();
		public map<Id, Product2> pmap = new map<Id, Product2>();
		public map<Id, ArtikelLizenz__c> almap = new map<Id, ArtikelLizenz__c>();
		public map<Id, Medienart__c> mmap = new map<Id, Medienart__c>();
		
		public Id oppid;
		public Integer numberOfPRoducts=1;
		public Boolean hasData=false;
		
		public testOli(Id oid) {
			if (oid!=null) {
				oppid=oid;
				pmap = new map<Id, Product2>();
				pbemap=new map<Id, PricebookEntry>();
				almap = new map<Id, ArtikelLizenz__c>();
				mmap = new map<Id, Medienart__c>();
				createMedienarten();
				if (!mmap.isEmpty()) createProduct();
				if (!pmap.isEmpty()) createPricebookEntry();
				if (!pmap.isEmpty()) createArtikelLizenz();
				if (!pbemap.isEmpty()) createOli();
			}
			if (!olimap.isEmpty()) hasData=true;
		}
		
		// creates needed Medienarten
		void createMedienarten() {
			list<Medienart__c> mlist=new list<Medienart__c>();
			Medienart__c m1=new Medienart__c(Name='88',MALTXT__c='VHS');
			Medienart__c m2=new Medienart__c(Name='99',MALTXT__c='DVD');
			mlist.add(m1); mlist.add(m2);
			if (!mlist.isEmpty()) insert mlist;
			for (Medienart__c m:mlist) {
				mmap.put(m.id, m);
			}
		}
		
		//creates signatures for testing
		void createProduct() {
			list<Product2> sigs=new list<Product2>();
			Id rtypeid=[SELECT Id FROM RecordType WHERE Name='Signatur'].Id;
			for (Integer i=0;i<numberOfProducts;i++) {
				Product2 news=new Product2();
				news.Name='Signatur' + i;
				news.ProductCode='PC';
				news.RecordTypeId=rtypeid;
				news.MEDA01__c=mmap.values().get(1).id;
				news.PDKZ01__c=4;
				news.RECH01__c='A';
				news.VRKZ01__c='+';
				news.TXT013__c='Testtext';
				news.IsActive=true;
				news.GESB01__c=200;
				news.LAOR01__c='00';
				sigs.add(news);
			}
			if (!sigs.isEmpty()) insert sigs;
			for (Product2 p:sigs) {
				pmap.put(p.id, p);
			}
		}
		
		// creats the necessary pricebookentry for sammelnummer
		// and the signatures
		void createPricebookEntry() {
			if (pbemap.isEmpty()) {
				// first we need to select the standard price book
				Id pricebook2id=[SELECT Id FROM Pricebook2 WHERE IsActive=true AND Name=:SystemSettings.STANDARDPRICEBOOKNAME limit 1].Id;
				list<PricebookEntry> pbes=new list<PricebookEntry>();
				if (pricebook2id!=null) {
					for (Product2 p: pmap.values()) {
						PricebookEntry pbe=new PricebookEntry(Pricebook2Id=pricebook2id,Product2Id=p.id,UnitPrice=1,IsActive=true);
						pbes.add(pbe);
					}
					if (!pbes.isEmpty()) {
						try {
							insert pbes;
						} catch (System.DmlException e) {
							// the prices already exist, now we select them
							pbes=[SELECT Id, Pricebook2Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry WHERE Product2Id IN :pmap.values()];
						}
					}
				}
				for (PricebookEntry pbe:pbes) {
					if (pbe.id!=null && pbe.Pricebook2Id==pricebook2id) {
						pbemap.put(pbe.id,pbe);
					}
				}
			}
		}
		
		// creates the Artikel Lizenzen for all signatures
		// and binds them to the sammelnummer
		void createArtikelLizenz() {
			list<ArtikelLizenz__c> allist=new list<ArtikelLizenz__c>();
			for (Product2 p:pmap.values()) {
				ArtikelLizenz__c al=new ArtikelLizenz__c(Artikel__c=p.id,VPR015__c=1,LZN015__c='10001', SPK015__c=false,MNG015__c=1);
				allist.add(al);
			}
			if (!allist.isEmpty()) insert allist;
			for (ArtikelLizenz__c al:allist) {
				almap.put(al.id,al);
			}
		}
		
		void createOli() {
			list<OpportunityLineItem> olilist=new list<OpportunityLineItem>();
			map<Id, Id> pbetoal= new map<Id, Id>();
			for (ArtikelLizenz__c al: almap.values()) {
				for (PricebookEntry pbe:pbemap.values()) {
					if (al.Artikel__c==pbe.Product2Id && !pbetoal.containsKey(pbe.id)) pbetoal.put(pbe.id,al.id); 
				}
			}
			for (Id pbeid: pbemap.keySet()) {
				OpportunityLineItem oli=new OpportunityLineItem(OpportunityId=oppid,PricebookEntryId=pbeid,SCHL2D__c=pbetoal.get(pbeid),Quantity=1,UnitPrice=5);
				olilist.add(oli);
			}
			insert olilist;
			for (OpportunityLineItem oli:olilist) {
				if (!olimap.containsKey(oli.id)) olimap.put(oli.id,oli);
			}
		}
	}

	public class testInvoices {
		public list<Rechnung__c> invoices= new list<Rechnung__c>();
		public list<RechnungPosten__c> invoiceitems = new list<RechnungPosten__c>();
		list<RecordType> rtlist = [SELECT Id, Name FROM RecordType WHERE isActive=true AND SobjectType='Rechnung__c'];
		
		public testInvoices(Opportunity opp, list<Product2> products, Integer NoInvoices) {
			createListInvoices(opp, products, NoInvoices);
		}
		
		private void createListInvoices(Opportunity opp, list<Product2> products, Integer NoInvoices) {
			Rechnung__c r = new Rechnung__c();
			for (Integer i=0;i<NoInvoices;i++) {
				r = new Rechnung__c();
				r.AUN211__c=opp.id;
				r.KDR211__c=opp.AccountId;
				r.KDW211__c=opp.AccountId;
				r.RED211__c=System.today()-30*i;
				r.RecordTypeId=rtlist.get(math.mod(i,2)!=0?0:1).id;
				invoices.add(r);
			}
			insert invoices;
		}
		
		private void createListInvoiceItems(list<Product2> products) {
			RechnungPosten__c rp = new RechnungPosten__c();
			map<String, Id> rp_rt = new map<String, Id>();
			for (RecordType rtype: [SELECT Id, Name FROM RecordType WHERE isActive=true AND SobjectType='RechnungPosten__c']) {
				rp_rt.put(rtype.Name, rtype.Id);
			}
			map<Id, String> r_rt = new map<Id, String>();
			for (RecordType rtype: rtlist) {
				r_rt.put(rtype.Id, rtype.Name);
			}
			for (Rechnung__c r: invoices) {
				for (Product2 p:products) {
					rp = new RechnungPosten__c();
					rp.Artikel__c=p.id;
					rp.GNP212__c=10;
					rp.REN212__c=r.id;
					rp.LMG212__c=1;
					rp.RecordTypeId=rp_rt.get(r_rt.get(r.id));
					invoiceitems.add(rp);
				}
			}
			insert rp;
		}
	}

}