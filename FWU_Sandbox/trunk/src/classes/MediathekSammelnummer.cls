/*
* @author Jochen Schrader
* @date 18.06.2012
* @description Creates the Medienpaket Licenses for each package and calculates the prices
*/
public class MediathekSammelnummer {

	public static Boolean createMedienpaketLizenzenOnce=false;
	public static Boolean updatePricesOnce=false;
	private static final String SEPERATOR=';';
	
	public static set<Double> validProduktionsstufen=new set<Double>{ 4,5 };
	
	public static Id SignaturRecordTypeId=[SELECT Id FROM RecordType WHERE Name='Signatur' AND SObjectType='Product2' AND IsActive=true].Id;
	public static Id SammelnummerRecordTypeId=[SELECT Id FROM RecordType WHERE Name='Sammelnummer' AND SObjectType='Product2' AND IsActive=true].Id;
	
	// for prices
	public static list<Medienpaket_Lizenz__c> mpltoupdate=new list<Medienpaket_Lizenz__c>();
	public static map<String, map<String, map<String, Double>>> pkg2liz2umedart2price = new map<String, map<String, map<String, Double>>>();
	
	// for medienpaketlizenzen
	// maps productids, then lizenznummer, then the artikellizenz
	public static map<Id, map<String, ArtikelLizenz__c>> artikellizenzen = new map<Id, map<String, ArtikelLizenz__c>>();
	public static map<String, map<String, map<String, Medienpaket_Lizenz__c>>> existing_mpl = new map<String, map<String, map<String, Medienpaket_Lizenz__c>>>();
	public static map<String, map<String, String>> pkg2lzn = new map<String, map<String, String>>();
	public static map<String, Id> pkg2productid = new map<String, Id>(); 
	public static list<Medienpaket_Lizenz__c> mpltoinsert = new list<Medienpaket_Lizenz__c>();
	public static list<Medienpaket_Lizenz__c> mpltodelete = new list<Medienpaket_Lizenz__c>();
	
	
	// insert or change medienpaketlizenzen
	public static void createMedienpaketLizenzen(map<Id, Product2> products) {
		// for the unit tests
		mpltoinsert.clear();
		mpltodelete.clear();
		
		// for each product we have to identify the Medienpaket (Sammelnummer) and we need to get all necessary ArtikelLizenzen if they exist
		// then we will create the medienpaketlizenzen. We won't calculate any prices here because we don't know how much changes will come
		set<String> lizenznummern = new set<String>();
		set<String> signaturnummern = new set<String>();
		// map matched Artikel Kennzeichen with packages
		map<String, map<String, String>> kz2pkg = new map<String, map<String, String>>();
		for (MTSammelnummer__c mts: MTSammelnummer__c.getAll().values()) {
			// the name of the MTSammelnumer record can contain the licence number therefor we have to use the first seven numbers!
			if (!signaturnummern.contains(mts.Name.substring(0,7))) signaturnummern.add(mts.Name.substring(0,7));
			if (!lizenznummern.contains(mts.Lizenznummer__c)) lizenznummern.add(mts.Lizenznummer__c);
			if (!pkg2lzn.containsKey(mts.Name.substring(0,7))) pkg2lzn.put(mts.Name.substring(0,7), new map<String, String>());
			if (!pkg2lzn.get(mts.Name.substring(0,7)).containsKey(mts.Lizenznummer__c)) pkg2lzn.get(mts.Name.substring(0,7)).put(mts.Lizenznummer__c,mts.Lizenznummer__c);
			for (String kz: mts.Artikel_Kennzeichen__c.split(' ')) {
				if (!kz2pkg.containsKey(kz)) kz2pkg.put(kz,new map<String, String>());
				if (!kz2pkg.get(kz).containsKey(mts.Name.substring(0,7))) kz2pkg.get(kz).put(mts.Name.substring(0,7), mts.Name.substring(0,7));
			}
		}
		
		// we need the product ids for the packages
		getProductIdsForPackages(signaturnummern);
		System.debug('PARX MTSammelnummer: productids for packages ' + pkg2productid.size());
		
		// get all needed Artikel Lizenzen
		getArtikelLizenzen(products.keySet(), lizenznummern);
		
		// and we need all existing Medienpaket Lizenzen for the packages and the artikel lizenzen
		getExistingMedienpaketLizenzen(signaturnummern, lizenznummern);
		
		// we want to check for each product and the packages, if we need to add a new Medienpaket Lizenz or we have to remove an
		// existing one
		createOrRemoveMedienpaketLizenzen(products,kz2pkg);
		
		// delete or insert the Medienpaket_Lizenz__c
		deleteMedienpaketLizenzen();
		insertMedienpaketLizenzen();
		
		createMedienpaketLizenzenOnce=true;
	}
	
	public static void getProductIdsForPackages(set<String> signaturnummern) {
		for (Product2 p:[SELECT Id, Name FROM Product2 WHERE Name IN :signaturnummern]) {
			if (!pkg2productid.containsKey(p.Name)) pkg2productid.put(p.Name, p.id);
		}
	}
	
	public static void getArtikelLizenzen(set<Id> pids, set<String> lizenznummern) {
		for (ArtikelLizenz__c al: [SELECT Id, Artikel__c, LZN015__c FROM ArtikelLizenz__c WHERE Artikel__c IN :pids AND LZN015__c IN :lizenznummern]) {
			if (!artikellizenzen.containsKey(al.Artikel__c)) artikellizenzen.put(al.Artikel__c, new map<String, ArtikelLizenz__c>());
			if (!artikellizenzen.get(al.Artikel__c).containsKey(al.LZN015__c)) artikellizenzen.get(al.Artikel__c).put(al.LZN015__c, al);
			System.debug('PARX MTSammelnummer Artikellizenzen: Artikel: ' + al.Artikel__c + ' / Lizenznummer ' + al.LZN015__c);
		}
	}
	
	public static void getExistingMedienpaketLizenzen(set<String> signaturnummern, set<String> lizenznummern) {
		for (Medienpaket_Lizenz__c mpl: [SELECT Id, VPR012__c, LZN012__c, Lizenznummer__c, Medienpaket__c, Signatur__c, Untermedienart__c, MedienpaketSignatur__c, Medienart__c FROM Medienpaket_Lizenz__c WHERE MedienpaketSignatur__c IN :signaturnummern AND Lizenznummer__c IN :lizenznummern ]) {
			if (!existing_mpl.containsKey(mpl.Medienart__c + mpl.Signatur__c)) existing_mpl.put(mpl.Medienart__c + mpl.Signatur__c, new map<String, map<String, Medienpaket_Lizenz__c>>());
			if (!existing_mpl.get(mpl.Medienart__c + mpl.Signatur__c).containsKey(mpl.MedienpaketSignatur__c)) existing_mpl.get(mpl.Medienart__c + mpl.Signatur__c).put(mpl.MedienpaketSignatur__c, new map<String, Medienpaket_Lizenz__c>());
			if (!existing_mpl.get(mpl.Medienart__c + mpl.Signatur__c).get(mpl.MedienpaketSignatur__c).containsKey(mpl.Lizenznummer__c)) existing_mpl.get(mpl.Medienart__c + mpl.Signatur__c).get(mpl.MedienpaketSignatur__c).put(mpl.Lizenznummer__c, mpl);
			System.debug('PARX MTSammelnummer Existing MedienpaketLizenzen: pkg ' + mpl.MedienpaketSignatur__c + ' / Lizenznummer ' + mpl.Lizenznummer__c + ' / Medienart + Signatur ' + mpl.Medienart__c + mpl.Signatur__c);
		}
	}
	
	public static void createOrRemoveMedienpaketLizenzen(map<Id, Product2> products, map<String, map<String, String>> kz2pkg) 
	{
		for (Product2 p: products.values()) 
		{
			System.debug('PARX MTSammelnummer create or remove Product: ' + p.id + ' / Name ' + p.Name + ' / Mediathek ' + (p.Mediathek__c==null?'':p.Mediathek__c));
			// we delete every mpl for each updated product and will create new ones if neccessary
			for (String pkg: pkg2lzn.keySet()) 
			{
				if (existing_mpl.containsKey(p.Name) && existing_mpl.get(p.Name).containsKey(pkg) && !existing_mpl.get(p.Name).get(pkg).isEmpty())
				{
					// mpls for all lizenzen have to be deleted
					mpltodelete.addAll(existing_mpl.get(p.Name).get(pkg).values());
				}
			}
			// we iterate through every existing package (and every license) and create new mpls
			if (p.Mediathek__c!=null && validProduktionsstufen.contains(p.PDKZ01__c) && p.IsActive) 
			{	
				for (String mkz:p.Mediathek__c.split(SEPERATOR)) 
				{
					if (kz2pkg.containsKey(mkz.trim())) 
					{	
						for (String pkg: kz2pkg.get(mkz.trim()).values()) 
						{	
							// for each lizenznummer
							for (String lzn: pkg2lzn.get(pkg).values()) 
							{	
								System.debug('PARX MTSammelnummer create or remove: pkg ' + pkg + ' / lzn ' + lzn);
								// create a new one
								// find suitable artikellizenz
								Id alid;
								try 
								{
									alid=artikellizenzen.get(p.id).get(lzn).id;
								} 
								catch (System.Nullpointerexception e) 
								{
									SystemSettings.logError('MT Error, for Product ' + p.id + ' no ArtikelLizenz ' + lzn + ' exists!');
								}
								if (alid!=null) 
								{
								Medienpaket_Lizenz__c mpl = new Medienpaket_Lizenz__c(
									VPR012__c=0.11,
									LZN012__c=artikellizenzen.get(p.id).get(lzn).id,
									Medienpaket__c=pkg2productid.get(pkg)
									);
								mpltoinsert.add(mpl);
								}
							}
						}
					}
				}
			}
		}
		SystemSettings.insertErrors();
	}
	
	public static void deleteMedienpaketLizenzen() {
		if (!mpltodelete.isEmpty()) {
			delete mpltodelete;
		}
	}
	
	public static void insertMedienpaketLizenzen() {
		if (!mpltoinsert.isEmpty()) {
			insert mpltoinsert;
		}
	}
	
	// update the prices ...
	@future
	public static void updatePrices(set<String> mtkennzeichen) {
		onProduct.inFutureContextStoredId = 'true';
		// for the unittests ...
		mpltoupdate.clear();
		
		// for each medienkennzeichen we try to find the package and recalculate the price
		
		// get the data ...
		set<String> packages=getSammelnummernFor(mtkennzeichen);
		map<String, map<String , map<String, map<Id, Medienpaket_Lizenz__c>>>> pkg2lzn2umedart2mpl=getMedienpaketLizenzen(packages);
		
		// get the prices
		// total price for each package
		//map<String, map<String, Double>> pkg2liz2price=getPackagePrices(packages);
		pkg2liz2umedart2price=getUntermedienartPrices(packages);
		
		// now we can calculate the individual price for each Medienpaket Lizenz and each Untermedienart and each package
		map<String, map<String, map<String, Double>>> pkg2liz2umedart2unitprice = calculateUnitPrices(pkg2lzn2umedart2mpl);
		
		// update the prices
		updateMedienpaketLizenzPrices(pkg2lzn2umedart2mpl,pkg2liz2umedart2unitprice);
		
		// update MedienpaketLizenzen
		updateMedienpaketLizenzen();
		
		updatePricesOnce=true;
	}
	
	
	// helper
	public static String getConfigArtikelKennzeichen() {
		String akz='';
		for (MTSammelnummer__c mts: MTSammelnummer__c.getAll().values()) {
			akz=akz+mts.Artikel_Kennzeichen__c;
		}
		return akz;
	}
	
	// returns the packages (map Product2) for the given medienkennzeichen
	private static set<String> getSammelnummernFor(set<String> medienkennzeichen) {
		map<Id, Product2> pkgs = new map<Id, Product2>();
		set<String> signaturnumbers = new set<String>();
		for (MTSammelnummer__c mts: MTSammelnummer__c.getAll().values()) {
			if (!signaturnumbers.contains(mts.Name.substring(0,7))) signaturnumbers.add(mts.Name.substring(0,7));
		}
		return signaturnumbers;
	}
	
	// returns the MedienpaketLizenzen for which we have to change the price
	private static map<String, map<String, map<String, map<Id, Medienpaket_Lizenz__c>>>> getMedienpaketLizenzen(set<String> packages) {
		map<String, map<String, map<String, map<Id, Medienpaket_Lizenz__c>>>> pkg2lzn2umedart2mpl = new map<String, map<String, map<String, map<Id, Medienpaket_Lizenz__c>>>>();
		if (!packages.isEmpty()) {
			for (Medienpaket_Lizenz__c mpl:[SELECT Id, VPR012__c, LZN012__c, Lizenznummer__c, Medienpaket__c, Signatur__c, Untermedienart__c, MedienpaketSignatur__c FROM Medienpaket_Lizenz__c 
				WHERE MedienpaketSignatur__c IN :packages
				AND isDeleted=false
				]) {
				//System.debug('Mediathek Sammelnummer MedienpaketLizenzen ' + mpl.id + ' Signatur__c '+ mpl.Signatur__c + ' Medienpaket ' + mpl.Medienpaket__c);
				if (!pkg2lzn2umedart2mpl.containsKey(mpl.MedienpaketSignatur__c)) 
					pkg2lzn2umedart2mpl.put(mpl.MedienpaketSignatur__c, new map<String, map<String, map<Id, Medienpaket_Lizenz__c>>>());
				if (!pkg2lzn2umedart2mpl.get(mpl.MedienpaketSignatur__c).containsKey(mpl.Lizenznummer__c)) 
					pkg2lzn2umedart2mpl.get(mpl.MedienpaketSignatur__c).put(mpl.Lizenznummer__c, new map<String, map<Id, Medienpaket_Lizenz__c>>());
				if (!pkg2lzn2umedart2mpl.get(mpl.MedienpaketSignatur__c).get(mpl.Lizenznummer__c).containsKey(mpl.Untermedienart__c))
					pkg2lzn2umedart2mpl.get(mpl.MedienpaketSignatur__c).get(mpl.Lizenznummer__c).put(mpl.Untermedienart__c, new map<Id, Medienpaket_Lizenz__c>());
				if (!pkg2lzn2umedart2mpl.get(mpl.MedienpaketSignatur__c).get(mpl.Lizenznummer__c).get(mpl.Untermedienart__c).containsKey(mpl.id))
					pkg2lzn2umedart2mpl.get(mpl.MedienpaketSignatur__c).get(mpl.Lizenznummer__c).get(mpl.Untermedienart__c).put(mpl.id, mpl);
			}
		}
		return pkg2lzn2umedart2mpl;
	}
	
	// returns the configured price for each untermedienart
	private static map<String, map<String ,map<String, Double>>> getUntermedienartPrices(set<String> packages) {
		pkg2liz2umedart2price = new map<String, map<String, map<String, Double>>>();
		for (String signaturnumber:packages) {
			for (MTPreisaufteilung__c mtp: MTPreisaufteilung__c.getAll().values()) {
				if (mtp.Signaturnummer__c.startsWith(signaturnumber)) {
					// we take care with this her and not on top that we have only packages with real prices in our map
					if (!pkg2liz2umedart2price.containsKey(signaturnumber)) 
						pkg2liz2umedart2price.put(signaturnumber, new map<String, map<String, Double>>());
					// step Lizenz
					if (!pkg2liz2umedart2price.get(signaturnumber).containsKey(mtp.Lizenznummer__c)) 
						pkg2liz2umedart2price.get(signaturnumber).put(mtp.Lizenznummer__c, new map<String, Double>());
					// step untermedienart
					if (!pkg2liz2umedart2price.get(signaturnumber).get(mtp.Lizenznummer__c).containsKey(mtp.Untermedienart__c)) 
						pkg2liz2umedart2price.get(signaturnumber).get(mtp.Lizenznummer__c).put(mtp.Untermedienart__c, mtp.Preis__c);
				}
			}
		}
		return pkg2liz2umedart2price;
	}
	
	private static map<String, map<String, map<String, Double>>> calculateUnitPrices(map<String, map<String , map<String, map<Id, Medienpaket_Lizenz__c>>>> pkg2lzn2umedart2mpl) {
		map<String, map<String, map<String, Double>>> pkg2liz2umedart2unitprice = new map<String, map<String, map<String, Double>>>();
		for (String pkg:pkg2liz2umedart2price.keySet()) {
			if (!pkg2liz2umedart2unitprice.containsKey(pkg)) pkg2liz2umedart2unitprice.put(pkg, new map<String, map<String, Double>>());
			for (String lzn:pkg2liz2umedart2price.get(pkg).keySet()) {
				if (!pkg2liz2umedart2unitprice.get(pkg).containsKey(lzn)) pkg2liz2umedart2unitprice.get(pkg).put(lzn, new map<String, Double>());
				for (String umedart: pkg2liz2umedart2price.get(pkg).get(lzn).keySet()) {
					// price for untermedienart
					if (pkg2lzn2umedart2mpl.containsKey(pkg) && pkg2lzn2umedart2mpl.get(pkg).containsKey(lzn) && pkg2lzn2umedart2mpl.get(pkg).get(lzn).containsKey(umedart) && !pkg2lzn2umedart2mpl.get(pkg).get(lzn).get(umedart).isEmpty()) {
						Double unitprice=pkg2liz2umedart2price.get(pkg).get(lzn).get(umedart)/pkg2lzn2umedart2mpl.get(pkg).get(lzn).get(umedart).size();
						if (!pkg2liz2umedart2unitprice.get(pkg).get(lzn).containsKey(umedart)) pkg2liz2umedart2unitprice.get(pkg).get(lzn).put(umedart, unitprice);
					}
				}
			}
		}
		return pkg2liz2umedart2unitprice;
	}
	
	// updates the prices and fills the mpltoupdate list
	private static void updateMedienpaketLizenzPrices(map<String, map<String , map<String, map<Id, Medienpaket_Lizenz__c>>>> pkg2lzn2umedart2mpl,map<String, map<String, map<String, Double>>> pkg2liz2umedart2unitprice) {
		// iterate through packages, licences and untermedienarten
		for (String pkg: pkg2liz2umedart2unitprice.keySet()) {
			for (String lzn: pkg2liz2umedart2unitprice.get(pkg).keySet()) {
				for (String umedart: pkg2liz2umedart2unitprice.get(pkg).get(lzn).keySet()) {
					// diff will get the minor difference between rounded value and the real value
					Double diff=0;
					Medienpaket_Lizenz__c mpl;
					Double rest=pkg2liz2umedart2price.get(pkg).get(lzn).get(umedart);
					for (Integer i=0;i<pkg2lzn2umedart2mpl.get(pkg).get(lzn).get(umedart).values().size()-1;i++) {
						mpl=pkg2lzn2umedart2mpl.get(pkg).get(lzn).get(umedart).values().get(i);
						Decimal unitprice = pkg2liz2umedart2unitprice.get(pkg).get(lzn).get(umedart);
						Decimal unitpricerounded = unitprice.divide(1, 2, System.RoundingMode.DOWN);
						diff=diff+(unitprice-unitpricerounded);
						if (diff>0.01) {
							unitpricerounded=unitpricerounded+0.01;
							diff=diff-0.01;
						}
						// the last list entry will get the rest
						mpl.VPR012__c=unitpricerounded;
						rest=rest-unitpricerounded;
						mpltoupdate.add(mpl);
					}
					// now we have to reduce the unitprice to adopt get the prices well
					mpl=pkg2lzn2umedart2mpl.get(pkg).get(lzn).get(umedart).values().get(pkg2lzn2umedart2mpl.get(pkg).get(lzn).get(umedart).values().size()-1);
					mpl.VPR012__c=rest;
					mpltoupdate.add(mpl);
				}
			}
		}
	}
	
	// do the update
	private static void updateMedienpaketLizenzen() {
		if (!mpltoupdate.isEmpty()) {
			update mpltoupdate;
		}
	}
}