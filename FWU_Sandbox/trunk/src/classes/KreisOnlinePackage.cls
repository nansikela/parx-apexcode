/*
	Description:
	
	bei Konstruktor Aufruf erstellt das system automatisch eine liste an paket zu den gegebenen olis
	
	Methoden:
	- getter für ein paket auf Grundlage einer beliebigen oli id
	- setter für auftragserfassung? (creating new items)
	- sync
	- abfrage lieferbarkeit
	- update
	- insert?

	Umgang mit den verschiedenen KO Varianten?
*/
public class KreisOnlinePackage {

	static final set<String> K1K2_LZN=new set<String>{'10261','10262'};
	static final set<String> KO_LZN=new set<String>{'10206'};
	static final set<String> Copy_LZN=new set<String>{'10269'};
	static final set<String> Base_LZN=new set<String>{'10001','10002'};
	static final set<String> KO_VKP = new set<String>{'KO','K1','K2','AK'};
	static final set<String> OLD_KO_VKP = new set<String>{'KO','AK'};
	static final Double vatpart = 0.07;
	static Integer globalcounter = 0;
	static Boolean updateInitialOlis=true;
	
	map<Id, OpportunityLineItem> global_olimap = new map<Id, OpportunityLineItem>();
	map<Id, OpportunityLineItem> initial_olis = new map<Id, OpportunityLineItem>();
	map<Id, Integer> pkgby46g = new map<Id, Integer>();
	map<Id, Integer> pkgby46v = new map<Id, Integer>();
	map<Id, Integer> pkgby55 = new map<Id, Integer>();
	map<Integer, KOpkg> packages = new map<Integer, KOpkg>();
	//map<Id, OpportunityLineItem> changedOlis = new map<Id, OpportunityLineItem>();
	
	// Product2id and changes in Reserverd Quantity
	map<Id, Double> p2reserveddiff = new map<Id, Double>();
	
	
	
	public class KOpkg {
		public Integer pkgid=0;
		public OpportunityLineItem oli46g;
		public OpportunityLineItem oli46v;
		public OpportunityLineItem oli55;
		public Double copyquantity;
		private Boolean modified=false;
		public Integer KOType; // type is easier to query, 0 == KO & 1 == K1 & 2 == K2
		
		public KOpkg(OpportunityLineItem o46g, OpportunityLineItem o46v, OpportunityLineItem o55) {
			oli46g=o46g;
			oli46v=o46v;
			oli55=o55;
			if (oli46g!=null) {
				if (oli46g.Discount==null) oli46g.Discount=0;
				if (oli46g.Preis465557__c==null) oli46g.Preis465557__c=0;
			}
			if (oli46v!=null) {
				if (oli46v.Discount==null) oli46v.Discount=0;
				if (oli46v.Preis465557__c==null) oli46v.Preis465557__c=0;
				copyquantity=oli46v.Quantity;
			}
			if (oli55!=null) {
				if (oli55.Discount==null) oli55.Discount=0;
				if (oli55.Preis465557__c==null) oli55.Preis465557__c=0;
			}
			if (o46g!=null) KOType=getLastsign(o46g.Lizenznummer__c);
			else if (oli55!=null) KOType=getLastsign(oli55.Lizenznummer__c);
			modified=false;
			globalcounter++;
			pkgid=globalcounter;
		}
		
		// this method tries to return the current totalprice
		public Double getTotalprice() {
			// not the best Idea to hardcode the MWST but it is convenient at the moment
			// we have to calculate the prices manually
			Double totalprice=0;
			//oli46g has to exist but sometimes initially we don't have the complete package
			if (oli46g!=null) {
				system.debug('oli46g is not null!');
				totalprice=totalprice+oli46g.quantity*oli46g.UnitPrice*(1-oli46g.Discount==null?0:oli46g.Discount);
				if (oli46v!=null)
					totalprice=totalprice+oli46v.quantity*oli46v.UnitPrice*(1-oli46v.Discount==null?0:oli46v.Discount);
				if (oli55!=null)
					totalprice=totalprice+oli55.quantity*oli55.UnitPrice*(1-oli55.Discount==null?0:oli55.Discount);
				
				//now check for VAT
				if (oli46g.isMWSt__c==0)
					totalprice=totalprice/(1+vatpart);
			}
			System.debug('kopkg: the price ' + totalprice);
			return totalprice;
		}
		
		// this method returns the current number of copies
		public Double getCopyquantity() {
			return oli46v!=null?oli46v.quantity:0;
		}
		
		// this method should give the information with faktura, if
		// the package is deliverable
		// it is based on the freed quantity (FRME2D__c)
		public Boolean isDeliverable() {
			// when is the package deliverable?
			// it is only deliverable if all olis are deliverable
			// so we start with default true and set this to false if one item is not deliverable
			Boolean deliverable=true;
			if (oli46g.FRME2D__c==null || oli46g.FRME2D__c==0) deliverable=false;
			if (oli46v!=null && (oli46v.FRME2D__c==null || oli46v.FRME2D__c==0)) deliverable=false;
			if (oli55!=null && (oli55.FRME2D__c==null || oli55.FRME2D__c==0)) deliverable=false;
			// that was pretty easy!
			// now we are friendly and set the freed quantity to 0
			if (!deliverable) {
				oli46g.FRME2D__c=0;
				if (oli46v!=null) oli46v.FRME2D__c=0;
				if (oli55!=null) oli55.FRME2D__c=0;
			} else if (OLD_KO_VKP.contains(oli46g.Verkaufsprogramm__c)) {
				// we set the freed Quantity to the minimum
				if (oli55!=null && oli55.FRME2D__c==null) oli55.FRME2D__c=0;
				oli46g.FRME2D__c=Math.min(oli46g.FRME2D__c, oli55!=null?oli55.FRME2D__c:0);
				oli55.FRME2D__c=Math.min(oli46g.FRME2D__c, oli55!=null?oli55.FRME2D__c:0);
			}
			return deliverable;
		}
		
		public void setModified() {
			modified=true;
		}
		
		public list<OpportunityLineItem> getOliList() {
			list<OpportunityLineItem> olis=new list<OpportunityLineItem>();
			olis.add(oli46g);
			if (oli46v!=null) olis.add(oli46v);
			if (oli55!=null) olis.add(oli55);
			return olis;
		}
		
		public void updateOli(OpportunityLineItem newoli) {
			if (oli46g.id==newoli.id) oli46g=newoli;
			if (oli46v!=null && oli46v.id==newoli.id) oli46v=newoli;
			if (oli55!=null && oli55.id==newoli.id) oli55=newoli;
			modified=true;
		}
		
		public void updateOli(list<OpportunityLineItem> newolis) {
			for (OpportunityLineItem newoli:newolis) {
				if (oli46g.id==newoli.id) oli46g=newoli;
				if (oli46v!=null && oli46v.id==newoli.id) oli46v=newoli;
				if (oli55!=null && oli55.id==newoli.id) oli55=newoli;
			} 
			modified=true;
		}
		
		private Integer getLastsign(String lzn) {
			if (lzn.endsWith('1')) return 1;
			if (lzn.endsWith('2')) return 2;
			else return 0;
		}
		
	}

	public KreisOnlinePackage(map<Id, OpportunityLineItem> initial_olis) {
		globalcounter=0;
		// trying to find get the other olis and create lists of kopkgs
		set<String> initial_lzn = new set<String>();
		set<Id> kreislisten_ids = new set<Id>();
		set<Id> artikelizenz_ids = new set<Id>();
		set<Id> oppids = new set<Id>();
		set<Id> initial_product2Ids = new set<Id>();
		
		// collect all the information to get the olis with a single query
		for (OpportunityLineItem oli:initial_olis.values()) {
			if (!oppids.contains(oli.OpportunityId)) oppids.add(oli.OpportunityId);
			try {
				Id kreislistenid;
				kreislistenid=Id.valueOf(oli.KreisListe__c);
				if (kreislistenid!=null && !kreislisten_ids.contains(kreislistenid))
					kreislisten_ids.add(kreislistenid);
			} catch (System.Exception e) {}
			try {
				Id artikellizenzid;
				artikellizenzid=Id.valueOf(oli.KreisOnlineCopyId__c);
				if (artikellizenzid!=null && !artikelizenz_ids.contains(artikellizenzid))
					artikelizenz_ids.add(artikellizenzid);
			} catch (System.Exception e) {}
			if (!initial_lzn.contains(oli.Lizenznummer__c)) initial_lzn.add(oli.Lizenznummer__c);
			// we add the copy license to get those olis as well
			if (K1K2_LZN.contains(oli.Lizenznummer__c)) {
				for (String lzn: Copy_LZN) {
					if (!initial_lzn.contains(lzn)) initial_lzn.add(lzn);
				}
			}
		}
		
		global_olimap = new map<Id, OpportunityLineItem>([SELECT Id 
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
										Verkaufsprogramm__c IN :KO_VKP AND
										OpportunityId IN :oppids AND
										//Id Not IN :initial_olis.keySet() AND
										(
										Id IN :initial_olis.keySet() OR
										Id IN :kreislisten_ids OR 
										Kreisliste__c IN :initial_olis.keySet() OR 
										Kreisliste__c IN :kreislisten_ids OR 
										Lizenznummer__c IN :initial_lzn OR 
										SCHL2D__c IN :artikelizenz_ids
										)
										]);
		// replace the selected olis of global_olimap by matching initial ones, because they have newer information
		if (!System.isBatch() && !System.isScheduled() && !System.isFuture()) { //then i think we have a trigger
			for (OpportunityLineItem oli:initial_olis.values()) {
				if (global_olimap.containsKey(oli.id)) global_olimap.remove(oli.id);
				global_olimap.put(oli.id, oli);
			}
			updateInitialOlis=false;
		}
		
		

		
		// sort olis into the suitable Lists and create the packages
		for (OpportunityLineItem oli : global_olimap.values()) {
			// the 46erG
			if (oli.medienart_id__c=='46' && (K1K2_LZN.contains(oli.Lizenznummer__c) || KO_LZN.contains(oli.Lizenznummer__c))) {
				OpportunityLineItem found46voli;
				if (K1K2_LZN.contains(oli.Lizenznummer__c))
					for (OpportunityLineItem findoli:global_olimap.values()) {
						if (findoli.medienart_id__c=='46' 
							&& findoli.KreisListe__c!=null
							&& oli.KreisListe__c!=null
							&& findoli.KreisListe__c==global_olimap.get(oli.KreisListe__c).Kreisliste__c
							//&& Id.valueOf(findoli.KreisOnlineCopyId__c)==global_olimap.get(oli.KreisListe__c).SCHL2D__c
							&& Copy_LZN.contains(findoli.Lizenznummer__c)
							)
							found46voli=findoli;
					}
				KOpkg pkg=new KOpkg(oli, found46voli, oli.KreisListe__c!=null?global_olimap.get(Id.valueOf(oli.KreisListe__c)):null);
				system.debug('creating package: ' + pkg );
				if (!pkgby46g.containsKey(oli.id)) pkgby46g.put(oli.id, pkg.pkgid);
				if (found46voli!=null && !pkgby46v.containsKey(found46voli.id)) pkgby46v.put(found46voli.id, pkg.pkgid);
				if (!pkgby55.containsKey(oli.KreisListe__c)) pkgby55.put(oli.KreisListe__c, pkg.pkgid);
				if (!packages.containsKey(pkg.pkgid)) packages.put(pkg.pkgid,pkg);
			}
		}
	}
	
	// this method tries to return the current totalprice
	public Double getTotalpriceById(Id oliid) {
		Double totalprice=0;
		// I assume that the oliid with newoli.id has been changed and the other have to be sync with that
		KOpkg pkg=getKOpkgById(oliid);
		if (pkg==null)
			System.debug('No package for oli id ' + oliid);
		else { // only useful if we really have a package for this oli
			Integer pkgid=pkg.pkgid;
			pkg=null;
			// not the best Idea to hardcode the MWST but it is convenient at the moment
			// we have to calculate the prices manually
			
			//oli46g has to exist but sometimes initially we don't have the complete package
			if (packages.get(pkgid).oli46g!=null) {
				system.debug('oli46g is not null!');
				totalprice=totalprice+packages.get(pkgid).oli46g.Totalprice;
				System.debug('kopkg: the price ' + totalprice);
				if (packages.get(pkgid).oli46v!=null)
					totalprice=totalprice+packages.get(pkgid).oli46v.Totalprice;
				System.debug('kopkg: the price ' + totalprice);
				if (packages.get(pkgid).oli55!=null)
					totalprice=totalprice+packages.get(pkgid).oli55.Totalprice;
				System.debug('kopkg: the price ' + totalprice);
				//now check for VAT
				if (packages.get(pkgid).oli46g.isMWSt__c==0)
					totalprice=totalprice/(1+vatpart);
				System.debug('kopkg: the price ' + totalprice);
			}
		}
		System.debug('kopkg: the price ' + totalprice);
		return totalprice;
	}
	
	public KOpkg getKOpkgById(Id oliid) {
		if (oliid==null) return null;
		if (pkgby46g!=null && pkgby46g.containsKey(oliid)) return packages.get(pkgby46g.get(oliid));
		if (pkgby46v!=null && pkgby46v.containsKey(oliid)) return packages.get(pkgby46v.get(oliid));
		if (pkgby55!=null && pkgby55.containsKey(oliid)) return packages.get(pkgby55.get(oliid));
		return null;
	}
	
	public void syncPkg(OpportunityLineItem newOli, OpportunityLineItem oldOli) {
		// I assume that the oli with newoli.id has been changed and the other have to be sync with that
		KOpkg pkg=getKOpkgById(newOli.id);
		if (pkg==null)
			System.debug('No package for oli id ' + newOli.Id);
		else { // only useful if we really have a package for this oli
			Integer pkgid=pkg.pkgid;
			pkg=null;
			OpportunityLineItem baseoli=newOli;
			
			// calculate total price just here for debugging
			Double totalprice=0;
			//oli46g has to exist but sometimes initially we don't have the complete package
			if (packages.get(pkgid).oli46g!=null) {
				totalprice=totalprice+packages.get(pkgid).oli46g.quantity*packages.get(pkgid).oli46g.UnitPrice*(1-packages.get(pkgid).oli46g.Discount==null?0:packages.get(pkgid).oli46g.Discount);
				if (packages.get(pkgid).oli46v!=null)
					totalprice=totalprice+packages.get(pkgid).oli46v.quantity*packages.get(pkgid).oli46v.UnitPrice*(1-packages.get(pkgid).oli46v.Discount==null?0:packages.get(pkgid).oli46v.Discount);
				if (packages.get(pkgid).oli55!=null)
					totalprice=totalprice+packages.get(pkgid).oli55.quantity*packages.get(pkgid).oli55.UnitPrice*(1-packages.get(pkgid).oli55.Discount==null?0:packages.get(pkgid).oli55.Discount);
				
				//now check for VAT
				if (packages.get(pkgid).oli46g.isMWSt__c==0)
					totalprice=totalprice/(1+vatpart);
			}
			
			// things we have to sync:
			// - discount
			// - quantity
			// - Anzahl_Schulen__c
			// - STAT2D__c
			// - Sperrkz__c
			// - update pricing and copy quantity on 46g
			// - update reserved quantities on product2
			
			// for copies we have to update the number of copies on 46g and the total pkg price
			// may be the discount has changed, but we will keep this unsynced because it thems reasonable that discount can differ
			if (Copy_LZN.contains(baseoli.Lizenznummer__c)) {
				packages.get(pkgid).setModified();
				//packages.get(pkgid).oli46g.Preis465557__c=packages.get(pkgid).getTotalprice();
				packages.get(pkgid).oli46g.Preis465557__c=totalprice;
				packages.get(pkgid).oli46g.K1_K2_Zahl_der_Vervielf_ltigungen__c=String.valueOf(baseoli.Quantity);
			} else
				if (baseoli.medienart_id__c=='46') {
					// sometimes there is no 55er for this 46er
					if (packages.get(pkgid).oli55!=null) {
						packages.get(pkgid).oli55.discount=baseoli.Discount;
						packages.get(pkgid).oli55.quantity=baseoli.quantity!=null?baseoli.Quantity:0;
						packages.get(pkgid).oli55.Anzahl_Schulen__c=baseoli.Anzahl_Schulen__c;
						if (OLD_KO_VKP.contains(baseoli.Verkaufsprogramm__c)) packages.get(pkgid).oli55.UnitPrice += (baseoli.Anzahl_Schulen_berechnet__c - oldOli.Anzahl_Schulen_berechnet__c) * baseoli.OppVKP_Einzelpreis__c;
					}
					
					if((baseoli.STAT2D__c == 'gelöscht' && (packages.get(pkgid).oli55!=null && packages.get(pkgid).oli55.STAT2D__c != baseoli.STAT2D__c)) ||
							(baseoli.Sperrkz__c  && packages.get(pkgid).oli55.Sperrkz__c != baseoli.Sperrkz__c)) {
						packages.get(pkgid).oli55.STAT2D__c=baseoli.STAT2D__c;
						if (packages.get(pkgid).oli46v!=null) packages.get(pkgid).oli46v.STAT2D__c=baseoli.STAT2D__c;
						if (packages.get(pkgid).oli46v!=null) packages.get(pkgid).oli46v.Sperrkz__c=baseoli.Sperrkz__c;
						packages.get(pkgid).oli55.Sperrkz__c=baseoli.Sperrkz__c;
					} else if(!baseoli.Sperrkz__c  && packages.get(pkgid).oli55.Sperrkz__c != baseoli.Sperrkz__c) {
						packages.get(pkgid).oli55.Sperrkz__c=baseoli.Sperrkz__c;
						if (packages.get(pkgid).oli46v!=null) packages.get(pkgid).oli46v.Sperrkz__c=baseoli.Sperrkz__c;
					}
					//packages.get(pkgid).oli46g.Preis465557__c=packages.get(pkgid).getTotalprice();
					packages.get(pkgid).oli46g.Preis465557__c=totalprice;
					
					packages.get(pkgid).setModified();
				} else {
					packages.get(pkgid).oli46g.discount=baseoli.Discount==null?0:baseoli.Discount;
					packages.get(pkgid).oli46g.quantity=baseoli.quantity;
					packages.get(pkgid).oli46g.Anzahl_Schulen__c=baseoli.Anzahl_Schulen__c==null?0:baseoli.Anzahl_Schulen__c;
					if((baseoli.STAT2D__c == 'gelöscht' && packages.get(pkgid).oli46g.STAT2D__c != baseoli.STAT2D__c) ||
							   (baseoli.Sperrkz__c && packages.get(pkgid).oli46g.Sperrkz__c != baseoli.Sperrkz__c)) {
						if (packages.get(pkgid).oli46v!=null) packages.get(pkgid).oli46v.STAT2D__c=baseoli.STAT2D__c;
						if (packages.get(pkgid).oli46v!=null) packages.get(pkgid).oli46v.Sperrkz__c=baseoli.Sperrkz__c;
						packages.get(pkgid).oli46g.STAT2D__c=baseoli.STAT2D__c;
						packages.get(pkgid).oli46g.Sperrkz__c=baseoli.Sperrkz__c;
					} else if(!baseoli.Sperrkz__c && packages.get(pkgid).oli46g.Sperrkz__c != baseoli.Sperrkz__c) {
						packages.get(pkgid).oli46g.Sperrkz__c=baseoli.Sperrkz__c;
						if (packages.get(pkgid).oli46v!=null) packages.get(pkgid).oli46v.Sperrkz__c=baseoli.Sperrkz__c;
					}
					//packages.get(pkgid).oli46g.Preis465557__c=packages.get(pkgid).getTotalprice();
					packages.get(pkgid).oli46g.Preis465557__c=totalprice;
					
					packages.get(pkgid).setModified();
				}
			
			// reserve quantity of product stock - prepare map
			if (newOli!=null && newOli.Quantity!=null && newOli.OppRechnungsArt__c!=null && newOli.OppStageName__c!=null && oldOli!=null && oldOli.Quantity!=null &&
				newOli.Quantity!=oldOli.Quantity && (
				SystemSettings.Lagerzugang.contains(newOli.OppRechnungsArt__c.intValue())
				|| SystemSettings.Lagerabgang.contains(newOli.OppRechnungsArt__c.intValue()))
				&& (newOli.Fremdvertrieb__c == null || newOli.Fremdvertrieb__c == '')
				&& newOli.OppStageName__c != 'In Erstellung'
				&& newOli.OppStageName__c != 'Gelöscht' 
				) {
				Double diff=0;
				if (!p2reserveddiff.containsKey(Id.valueOf(newOli.Product2Id__c))) p2reserveddiff.put(Id.valueOf(newOli.Product2Id__c), diff);
				else
					diff=p2reserveddiff.get(Id.valueOf(newOli.Product2Id__c));
				if (newOli.Lizenzmenge__c!=null) {
					if(SystemSettings.Lagerabgang.contains(newOli.oppRechnungsArt__c.intValue())) {
						diff += (newOli.Lizenzmenge__c-oldOli.Lizenzmenge__c);
					}
					if(SystemSettings.Lagerzugang.contains(newOli.oppRechnungsArt__c.intValue()))  {
						diff -= (newOli.Lizenzmenge__c-oldOli.Lizenzmenge__c);
					}
				}
				p2reserveddiff.remove(Id.valueOf(newOli.Product2Id__c));
				p2reserveddiff.put(Id.valueOf(newOli.Product2Id__c), diff);
			}
		}
	}
	
	private void clearMapsAndLists() {
		global_olimap.clear();
		pkgby46g.clear();
		pkgby46v.clear();
		pkgby55.clear();
		p2reserveddiff.clear();
		p2reserveddiff.clear();
	}
	
	public void finish() {
		updatePkgs();
		clearMapsAndLists();
	}
	
	public void finish(map<Id, OpportunityLineItem> triggerOlis) {
		initial_olis=triggerOlis;
		updateInitialOlis=false;
		finish();
	}
	
	private void updateProductsReservedQuantity() {
		// get products and update the reservered quantity
		list<Product2> p2update = new list<Product2>();
		
		for (Product2 p: [SELECT Id, RESB01__c FROM Product2 WHERE Id IN :p2reserveddiff.keySet()]) {
			p.RESB01__c=p.RESB01__c==null?0:p.RESB01__c;
			p.RESB01__c+=p2reserveddiff.get(p.id);
			p2update.add(p);
		}
		
		update p2update;
	}
	
	private list<OpportunityLineItem> modifiedOlis() {
		list<OpportunityLineItem> completelist = new list<OpportunityLineItem>();
		if (updateInitialOlis)
			for (KOpkg pkg: packages.values()) {
				completelist.addAll(pkg.getOliList());
			}
		else
			for (KOpkg pkg: packages.values()) {
				for (OpportunityLineItem oli:pkg.getOliList()) {
					System.debug('modifiedOlis - is Oli ' + oli.id + ' in trigger list ' + initial_olis.values() + '? ' + initial_olis.containsKey(oli.id));
					if (!initial_olis.containsKey(oli.id))
						completelist.add(oli);
				}
			}
		return completelist;
	}
	
	private void updatePkgs() {
		update modifiedOlis();
		
		if (!p2reserveddiff.isEmpty()) {
			updateProductsReservedQuantity();
		}
	}

}