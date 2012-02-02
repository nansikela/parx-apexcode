/*
this class creates the testdata needed for testing the two functions of the MediathekSammelnummer Trigger
*/
public class MTTestData {
	
	private String sgn='TT0TEST';
	private String lzn='20001';
	private double gpreis=333;
	private String artikelkennzeichen='Z';
	private list<String> umed = new list<String>{'01', '02', '05'};
	private map<String, Double> umvalues = new map<String, Double>();
	private Id SammelnummerRecordTypeId=[SELECT Id FROM RecordType WHERE Name='Sammelnummer' AND SObjectType='Product2' AND IsActive=true].Id;
	private Id SignaturRecordTypeId=[SELECT Id FROM RecordType WHERE Name='Signatur' AND SObjectType='Product2' AND IsActive=true].Id;
	private Id medartId;

	public list<MTSammelnummer__c> cs_mtsammelnummer=new list<MTSammelnummer__c>();
	public list<MTPreisaufteilung__c> cs_mtpreisaufteilung=new list<MTPreisaufteilung__c>();
	public Product2 mtsammelnummer = new Product2();
	public map<Id, Product2> products = new map<Id, Product2>();
	public list<ArtikelLizenz__c> artikellizenzen = new list<ArtikelLizenz__c>();
	public list<Medienpaket_Lizenz__c> mplizenzen = new list<Medienpaket_Lizenz__c>();

	public MTTestData() {
		createMedienart();
		fillUmValues();
		createCustomSettings();
		createSammelnummer();
		appendMedienpaketLizenz();
	}
	
	private void createMedienart() {
		Medienart__c mart=new Medienart__c(Name=sgn.substring(0,2));
		insert mart;
		medartId=mart.id;
		Lizenz__c lizenz=new Lizenz__c(MED017__c=mart.id,LZN015__c=lzn,aktiv__c=true,VPR015__c=10);
		insert lizenz;
	}
	
	private void fillUmValues() {
		Double divisor=0;
		Double sum=0;
		for (String um:umed) {
			divisor=divisor+double.valueOf(um);
		}
		for (Integer i=0;i<umed.size();i++) {
			if (i<umed.size()-1) {
				umvalues.put(umed.get(i),gpreis*(Double.valueOf(umed.get(i))/divisor));
				sum=sum+gpreis*(Double.valueOf(umed.get(i))/divisor);
			} else
				umvalues.put(umed.get(i),gpreis-sum);
		} 
	}
	
	private void createCustomSettings() {
		// we create only one sammelnummer
		cs_mtsammelnummer.add(new MTSammelnummer__c(Name=sgn,Lizenznummer__c=lzn,Gesamtpreis_Brutto__c=gpreis,Artikel_Kennzeichen__c=artikelkennzeichen,isactive__c=true));
		insert cs_mtsammelnummer;
		for (String um:umvalues.keySet()) {
			cs_mtpreisaufteilung.add(new MTPreisaufteilung__c(Name=sgn + lzn + um,Signaturnummer__c=sgn,Lizenznummer__c=lzn,Untermedienart__c=um,Preis__c=umvalues.get(um)));
		}
		insert cs_mtpreisaufteilung;
	}
	
	private void createSammelnummer() {
		onProduct.inFutureContextStoredId='';
		// the sammelnummer with a ArtikelLizenz as configured in the CustomSetting
		mtsammelnummer = new Product2(
						Name=sgn,
						ProductCode='0TEST',
						TITL01__c='Testsammelnummer',
						MEDA01__c=medartId,
						RecordTypeId=SammelnummerRecordTypeId,
						IsActive=true);
		insert mtsammelnummer;
		// the artikellizenz for lzn
		ArtikelLizenz__c al=new ArtikelLizenz__c(Artikel__c=mtsammelnummer.id,LZN015__c=lzn,MED017__c=medartId,SPK015__c=false, VPR015__c=10);
		insert al;
	}
	
	private void appendMedienpaketLizenz() {
		onProduct.inFutureContextStoredId='';
		list<Product2> plist = new list<Product2>();
		// now we need some new Products
		// three products for each configured Untermedienart
		for (String um:umed) {
			for (Integer i=0;i<3;i++) {
				Product2 p = new Product2(
						Name=sgn.substring(0,2)+'TEST0'+i,
						ProductCode='TEST0'+i,
						PDKZ01__c=4,
						TITL01__c='Testartikel ' + i,
						MEDA01__c=medartId,
						F16001__c=um,
						RecordTypeId=SignaturRecordTypeId,
						Mediathek__c=artikelkennzeichen,
						IsActive=true
						);
				plist.add(p);
			}
		}
		insert plist;
		// now we have to unlock the ArtikelLizenzen
		set<Id> pids=new set<Id>();
		for (Product2 p:plist) {
			pids.add(p.id);
			products.put(p.id,p);
		}
		// the AL have to be created by a trigger
		System.debug('MTTestData, created ArtikelLizenzen by Trigger ...');
		for (ArtikelLizenz__c al:[SELECT Id, SPK015__c FROM ArtikelLizenz__c WHERE Artikel__c IN :pids AND LZN015__c=:lzn]) {
			al.SPK015__c=false;
			al.VPR015__c=10;
			artikellizenzen.add(al);
		}
		if (!artikellizenzen.isEmpty()) update artikellizenzen;
		// afterwards we have to check that the trigger added the products as medienpaketlizenzen successfully
		// if not, we will add the medienpaketlizenzen at this point
		// but we will do this only on request ...
	}
	
	public Boolean checkforMedienpaketLizenz(map<Id, Product2> prds) {
		list<Medienpaket_Lizenz__c> mpliz = new list<Medienpaket_Lizenz__c>();
		if (!prds.isEmpty()) {
			try {
				mpliz = [SELECT Id FROM Medienpaket_Lizenz__c WHERE Medienpaket__c =: mtsammelnummer.id ];
			} catch (System.QueryException e) {}
		}
		if (mpliz.isEmpty()) return false;
		else return true;
	}
	
	public list<Medienpaket_Lizenz__c> createMedienpaketLizenz(map<Id, Product2> prds) {
		onProduct.inFutureContextStoredId='';
		if (!prds.isEmpty()) {
			if (mplizenzen.isEmpty()) {// trigger did not work
				if (!artikellizenzen.isEmpty()) {
					for (ArtikelLizenz__c al:artikellizenzen) {
						Medienpaket_Lizenz__c mpl = new Medienpaket_Lizenz__c(LZN012__c=al.id,Medienpaket__c=mtsammelnummer.id,VPR012__c=1);
						mplizenzen.add(mpl);
					}
					insert mplizenzen;
				}
			}
		}
		return mplizenzen;
	}
	
	public void updateProductRemoveFromMediathek() {
		onProduct.inFutureContextStoredId='';
		Product2 producttoupdate=products.values().get(0);
		System.debug('Unit Test Updating Product ' + producttoupdate.Name + ' with Mediathek Key ' + producttoupdate.Mediathek__c);
		producttoupdate.Mediathek__c='';
		update producttoupdate;
	}
	
	public void updateProductInsertToMediathek() {
		onProduct.inFutureContextStoredId='';
		Product2 producttoupdate=products.values().get(0);
		System.debug('Unit Test Updating Product ' + producttoupdate.Name + ' with Mediathek Key ' + producttoupdate.Mediathek__c);
		producttoupdate.Mediathek__c='A';
		update producttoupdate;
	}
}