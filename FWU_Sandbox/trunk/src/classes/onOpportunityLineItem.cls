public class onOpportunityLineItem {
	
//	public static boolean inFutureContext = false;
	public static String inFutureContextStoredId = '';
	public static Boolean doNotRun=false;
	public static Boolean doNotRunKOSync=false;
	public static boolean ForcePassage = true;
	public static Double vatpart=0.07;
	public static boolean onSignatureAfterInsert = true;  //normal case, it should not be executed
	public static list<OpportunityLineItem>listtoSend = new list<OpportunityLineItem>();
	public static map<Id, Product2> Product = new map<Id, Product2>();
	// TODO
	// bitte versuche den Code stärker zu modularisieren, es ist hier einiges sehr redundant
	// Unit Tests bitte vervollständigen
	// SELECT kann auch in for schleifen verwendet werden, um maps zu generieren
	// bitte trenne und dokumentiere die einzelnen funktionen (falls sinnvoll und machbar)
	
	// Produktionsstufen spezial
	// Produktionstufe < 4 und EK Bewegungsschlüssel 03 
	// Datum: Bestelldatum
	// Status: Kopierauftrag erteilt (03)
	
	// Produktionstufe < 4 und EK Bewegungsschlüssel 04 
	// Datum: Bestelldatum
	// Status: Massekopien im Lager (04)
	
	// JS K1/K2 Calculation
	static set<String> KNEW_LZN=new set<String>{'10261','10262'};
	static set<String> CopiesLZN = new set<String>{'10269'};
	static final Double NumberOfCopies=2;
	 
	public static void ondelete(list <OpportunityLineItem> trigg){
		
		
		for(OpportunityLineItem trig:trigg) {    // if Fakturiert, we cannot remove the item
//			if(trig.OppStageName__c == 'Bereit zur Freigabe') {  //run only on this condition
			if(UserInfo.getUserId() != '005A0000000Hkk9IAC') { //for the dataloader ....
				if(trig.STAT2D__c == 'Gelöscht')
					trig.addError(Label.OpportunityProdAlreadyDeleted);
				if(trig.STAT2D__c == 'Rückstellung' && (trig.GELM2D__c == null || trig.GELM2D__c == 0))
					trig.addError(Label.OpportunityProductDeleteError + Label.OpportunityDeleteError3);
				if(trig.STAT2D__c != '' && trig.STAT2D__c != null )
					trig.addError(Label.OpportunityProductDeleteError);
					// es darf nur noch gelöscht werden, falls "In Erstellung"
       			if ((trig.STAT2D__c=='' || trig.STAT2D__c==null) && trig.OppStageName__c!='In Erstellung')
          				trig.addError(Label.OpportunityProductDeleteError);
			}
//			}
		} 
		
		
		Product = getProduct(trigg);
		
		for(integer i = 0; i<trigg.size(); i++) {	
			system.debug('test debugging delete' + trigg.get(i).OppRechnungsArt__c + ' ' + trigg.get(i).Fremdvertrieb__c + ' ' + trigg.get(i).Sperrkz__c);	
			
			if(trigg.get(i).OppRechnungsArt__c != 7 && trigg.get(i).OppRechnungsArt__c != 9 &&   // Ohne Lagerbewegung
			trigg[i].OppStageName__c != 'In Erstellung' && trigg[i].OppStageName__c != 'Gelöscht' && 
			(trigg.get(i).Fremdvertrieb__c == null || trigg.get(i).Fremdvertrieb__c == '') &&
			   trigg.get(i).Sperrkz__c == false) {			
				if (Product.get(trigg[i].Product2Id__c).RESB01__c==null)
						Product.get(trigg[i].Product2Id__c).RESB01__c=0;
				if (Trigg[i].Lizenzmenge__c!=null) {
					if(SystemSettings.Lagerabgang.contains(trigg.get(i).oppRechnungsArt__c.intValue())) {
						Product.get(trigg[i].Product2Id__c).RESB01__c -= Trigg[i].Lizenzmenge__c;
					}
					if(SystemSettings.Lagerzugang.contains(trigg.get(i).oppRechnungsArt__c.intValue()))  {
						Product.get(trigg[i].Product2Id__c).RESB01__c += Trigg[i].Lizenzmenge__c;
					}
				}
			}			
		}
		
		updateProduct(trigg, Product);
		SystemSettings.insertErrors();
	}
	
	
	// KO Sync
	public static void onupdate(list <OpportunityLineItem> trigg, list <OpportunityLineItem> trigOld){
		onProduct.inFutureContextStoredId = 'true';  //we avoid that the product trigger run.
		
		Product = getProduct(trigg);
		//list<String> Ids = new list<String>();
		list <OpportunityLineItem> OliExtended = new list <OpportunityLineItem>();
		list <OpportunityLineItem> olitoUpdate = new list <OpportunityLineItem>();
		map <Id, OpportunityLineItem> mapOliExtended = new map <Id, OpportunityLineItem>();
		set<String> trigIds = new set<String>();
		//////*******************Start of Synchronize Anzahl Schulen *****************************////////////////
		for(OpportunityLineItem oli:trigg) {
			//Ids.add(oli.OpportunityId);
			trigIds.add(oli.Id);
		}  
		OliExtended = [select id, OpportunityId, Anzahl_Schulen__c, medienart_id__c, Lizenznummer__c, UnitPrice, Anzahl_Schulen_berechnet__c, Kopien_Rabatt__c, Sperrkz__c, oppRechnungsArt__c
				 ,Discount, AL_Preis__c, OppVKP_Einzelpreis__c, OppAnzahlSchulen__c, Product2Id__c, Lizenzmenge__c, STAT2D__c from OpportunityLineItem where Id IN:trigIds OR KreisListe__c IN: trigIds/*OpportunityId IN: Ids*/];
		Integer i=0;
		
  		map<Id, Product2> Product_Extended = new map<Id, Product2>();
		Product_Extended = getProduct(OliExtended);
		
		for(OpportunityLineItem oliExt:OliExtended) {
			i=0;
			for(OpportunityLineItem oliTrig:trigg) {	
				//system.debug('debugging oliTrig, oliExt:' + oliTrig.isSammelnummernOLI__c  + ' ' + oliTrig.KreisListe__c  + ' ' + oliExt.Id);
				Id KreislisteId;
				try {
					KreislisteId = Id.valueOf(oliTrig.KreisListe__c);
				} catch (System.Exception e) {
					oliTrig.KreisListe__c='';
				} // sometimes there is rubbish in this field
				if(!oliTrig.isSammelnummernOLI__c && KreislisteId!=null && KreislisteId == oliExt.Id){
					oliExt.Anzahl_Schulen__c = oliTrig.Anzahl_Schulen__c;
					oliExt.Discount = oliTrig.Discount;	
					oliExt.Quantity = oliTrig.Quantity;
					
					if((oliTrig.STAT2D__c == 'gelöscht' && oliExt.STAT2D__c != oliTrig.STAT2D__c) ||
					   (oliTrig.Sperrkz__c  && oliExt.Sperrkz__c != oliTrig.Sperrkz__c)) {
					   	
						oliExt.STAT2D__c = oliTrig.STAT2D__c;
						oliExt.Sperrkz__c = oliTrig.Sperrkz__c;
						
						if(trigg.get(i).OppRechnungsArt__c != 7 && trigg.get(i).OppRechnungsArt__c != 9 &&   // Ohne Lagerbewegung
			   				(trigg.get(i).Fremdvertrieb__c == null || trigg.get(i).Fremdvertrieb__c == '')  
			         		&& trigg[i].OppStageName__c != 'In Erstellung'
			         		&& trigg[i].OppStageName__c != 'Gelöscht') {
			         			
							if (Product_Extended.get(oliExt.Product2Id__c).RESB01__c==null)
								Product_Extended.get(oliExt.Product2Id__c).RESB01__c=0;
							if (oliExt.Lizenzmenge__c!=null) {
								if(SystemSettings.Lagerabgang.contains(oliExt.oppRechnungsArt__c.intValue())) {
									Product_Extended.get(oliExt.Product2Id__c).RESB01__c -= oliExt.Lizenzmenge__c;
								}
								if(SystemSettings.Lagerzugang.contains(oliExt.oppRechnungsArt__c.intValue()))  {
									Product_Extended.get(oliExt.Product2Id__c).RESB01__c += oliExt.Lizenzmenge__c;
								}
							}
			         		}
					}
					else if(!oliTrig.Sperrkz__c  && oliExt.Sperrkz__c != oliTrig.Sperrkz__c) {
						
						oliExt.Sperrkz__c = oliTrig.Sperrkz__c;

						if(trigg.get(i).OppRechnungsArt__c != 7 && trigg.get(i).OppRechnungsArt__c != 9 &&   // Ohne Lagerbewegung
			   				(trigg.get(i).Fremdvertrieb__c == null || trigg.get(i).Fremdvertrieb__c == '')  
			         			&& trigg[i].OppStageName__c != 'In Erstellung'
			         			&& trigg[i].OppStageName__c != 'Gelöscht') {
			         					
							if (Product_Extended.get(oliExt.Product2Id__c).RESB01__c==null)
								Product_Extended.get(oliExt.Product2Id__c).RESB01__c=0;
							if (oliExt.Lizenzmenge__c!=null) {
								if(SystemSettings.Lagerabgang.contains(oliExt.oppRechnungsArt__c.intValue())) {
									Product_Extended.get(oliExt.Product2Id__c).RESB01__c += oliExt.Lizenzmenge__c;
								}
								if(SystemSettings.Lagerzugang.contains(oliExt.oppRechnungsArt__c.intValue()))  {
									Product_Extended.get(oliExt.Product2Id__c).RESB01__c -= oliExt.Lizenzmenge__c;
								}
							}
						}
					}
					else if(trigg.get(i).OppRechnungsArt__c != 7 && trigg.get(i).OppRechnungsArt__c != 9 &&   // Ohne Lagerbewegung
			   			(trigg.get(i).Fremdvertrieb__c == null || trigg.get(i).Fremdvertrieb__c == '')  
			         		&& trigg[i].OppStageName__c != 'In Erstellung'
			         		&& trigg[i].OppStageName__c != 'Gelöscht') {
			         					
						if (Product_Extended.get(oliExt.Product2Id__c).RESB01__c==null)
							Product_Extended.get(oliExt.Product2Id__c).RESB01__c=0;
						if (oliExt.Lizenzmenge__c!=null) {
							if(SystemSettings.Lagerabgang.contains(oliExt.oppRechnungsArt__c.intValue())) {
								Product_Extended.get(oliExt.Product2Id__c).RESB01__c += oliTrig.Lizenzmenge__c - trigOld[i].Lizenzmenge__c;
							}
							if(SystemSettings.Lagerzugang.contains(oliExt.oppRechnungsArt__c.intValue()))  {
								Product_Extended.get(oliExt.Product2Id__c).RESB01__c -= oliTrig.Lizenzmenge__c - trigOld[i].Lizenzmenge__c;
							}
						}
					}
					
					if(oliExt.medienart_id__c == '55' || oliExt.medienart_id__c == '57') {
						oliExt.UnitPrice += (oliTrig.Anzahl_Schulen_berechnet__c - trigOld[i].Anzahl_Schulen_berechnet__c) * oliTrig.OppVKP_Einzelpreis__c;
					//	if(oliExt.Preis465557__c != null && oliTrig.Anzahl_Schulen_berechnet__c != null && trigOld[i] != null && trigOld[i].Anzahl_Schulen_berechnet__c != null && oliTrig.OppVKP_Einzelpreis__c != null)
					//		oliExt.Preis465557__c += (oliTrig.Anzahl_Schulen_berechnet__c - trigOld[i].Anzahl_Schulen_berechnet__c) * oliTrig.OppVKP_Einzelpreis__c;
						//if(oliExt.Id == oliTrig.Id)
						//	oliTrig.UnitPrice = oliExt.UnitPrice;
					}
					/*if(oliExt.medienart_id__c == '55' || oliExt.medienart_id__c == '57') {
						if(oliExt.Discount == null)
							oliExt.Discount = 0;
							//we have to calculate the new price because the anzahl schulen have been changed.
						if(oliExt.Anzahl_Schulen__c != null && oliExt.Anzahl_Schulen__c > 0) { 
							oliExt.UnitPrice = (oliExt.AL_Preis__c + oliExt.Anzahl_Schulen__c * oliExt.OppVKP_Einzelpreis__c) * (1- oliExt.Discount/100);
						}
						else if(oliExt.OppAnzahlSchulen__c != null && oliExt.OppAnzahlSchulen__c > 0) {
							oliExt.UnitPrice = (oliExt.AL_Preis__c + oliExt.OppAnzahlSchulen__c * oliExt.OppVKP_Einzelpreis__c) * (1- oliExt.Discount/100);
			 			}
					}		
					if(oliExt.medienart_id__c == '46') {
						if(oliExt.Discount == null)
							oliExt.Discount = 0;
						oliExt.UnitPrice = oliExt.AL_Preis__c * (1- oliExt.Discount/100);
					}*/
						
					if(!trigIds.contains(oliExt.Id))
						olitoUpdate.add(oliExt);
					//break;

					i++;
				}
			}
		}
		updateProduct(OliExtended, Product_Extended);
		
		if(!olitoUpdate.isEmpty()) {
			try {
				update olitoUpdate ;
			}
			catch(exception e) {
				String oliIds = 'Ids: ';
				for(OpportunityLineItem oli:olitoUpdate) {
					oliIds += oli.Id + ' ';
				}
				SystemSettings.logError(e.getMessage(), 'update Oli', '', oliIds);
			}
		}

		//////******************End of Synchronize Anzahl Schulen *****************************////////////////
		// Changes in Quantity will change reserved quantity on products
		for(i = 0; i<trigg.size(); i++) {
			if(trigg.get(i).OppRechnungsArt__c != 7 && trigg.get(i).OppRechnungsArt__c != 9 &&   // Ohne Lagerbewegung
			   (trigg.get(i).Fremdvertrieb__c == null || trigg.get(i).Fremdvertrieb__c == '')  
			         && trigg[i].OppStageName__c != 'In Erstellung'
			         && trigg[i].OppStageName__c != 'Gelöscht') {
				//the quantity has been updated.
				if(trigg.get(i).Sperrkz__c == false && trigOld.get(i).Sperrkz__c == true && trigg[i].STAT2D__c != 'Gelöscht')  {
					if (Product.get(trigg[i].Product2Id__c).RESB01__c==null)
						Product.get(trigg[i].Product2Id__c).RESB01__c=0;
					if (trigg[i].Lizenzmenge__c!=null) {
						if(SystemSettings.Lagerabgang.contains(trigg.get(i).oppRechnungsArt__c.intValue())) {
							Product.get(trigg[i].Product2Id__c).RESB01__c += trigg[i].Lizenzmenge__c;
						}
						if(SystemSettings.Lagerzugang.contains(trigg.get(i).oppRechnungsArt__c.intValue()))  {
							Product.get(trigg[i].Product2Id__c).RESB01__c -= trigg[i].Lizenzmenge__c;
						}
					}
				}
				else if(trigg.get(i).quantity != trigOld.get(i).quantity && trigg.get(i).Sperrkz__c == false && trigg.get(i).STAT2D__c != 'Gelöscht') {
					if (Product.get(trigg[i].Product2Id__c).RESB01__c==null)
						Product.get(trigg[i].Product2Id__c).RESB01__c=0;
					if (trigg[i].Lizenzmenge__c!=null) {
						if(SystemSettings.Lagerabgang.contains(trigg.get(i).oppRechnungsArt__c.intValue())) {
							Product.get(trigg[i].Product2Id__c).RESB01__c += trigg[i].Lizenzmenge__c - trigOld[i].Lizenzmenge__c;
						}
						if(SystemSettings.Lagerzugang.contains(trigg.get(i).oppRechnungsArt__c.intValue()))  {
							Product.get(trigg[i].Product2Id__c).RESB01__c -= trigg[i].Lizenzmenge__c - trigOld[i].Lizenzmenge__c;
						}
					}
				}
				
				//OppLineItem has been deleted and we remove the reserved quantity
				if((trigg.get(i).Sperrkz__c == true && trigOld.get(i).Sperrkz__c == false && trigg.get(i).STAT2D__c != 'Gelöscht') ||
				   (trigg.get(i).STAT2D__c == 'Gelöscht' && trigOld.get(i).STAT2D__c != 'Gelöscht' && trigg.get(i).Sperrkz__c == false)) {
					if (Product.get(trigg[i].Product2Id__c).RESB01__c==null)
							Product.get(trigg[i].Product2Id__c).RESB01__c=0;
					if (Trigg[i].Lizenzmenge__c!=null) {
						if(SystemSettings.Lagerabgang.contains(trigg.get(i).oppRechnungsArt__c.intValue())) {
							Product.get(trigg[i].Product2Id__c).RESB01__c -= Trigg[i].Lizenzmenge__c;
						}
						if(SystemSettings.Lagerzugang.contains(trigg.get(i).oppRechnungsArt__c.intValue()))  {
							Product.get(trigg[i].Product2Id__c).RESB01__c += Trigg[i].Lizenzmenge__c;
						}
					}
				}
			}					
		}
		
		updateProduct(trigg, Product);
		SystemSettings.insertErrors();
	}
	
	// K1/K2 Sync
	public static void syncOfK1K2OpportunityLineItems(map<Id, OpportunityLineItem> newOlis, map<Id, OpportunityLineItem> oldOlis){
		KreisOnlinePackage kopkgs=new KreisOnlinePackage(newOlis);
		for (OpportunityLineItem oli:newOlis.values()) {
			kopkgs.syncPkg(oli, oldOlis.get(oli.id));
		}
		Boolean donotUpdateLineItems=true;
		kopkgs.finish(newOlis);
	}
	
	
	public static void oninsert_after(list <OpportunityLineItem> trigg) {

		Boolean willUpdate = false;
		
		for(integer i = 0; i<trigg.size(); i++) {
			system.debug('test debugging ' + trigg.get(i).OppRechnungsArt__c + ' ' + trigg.get(i).OppStageName__c + ' ' + trigg.get(i).Fremdvertrieb__c + ' ' + trigg.get(i).Sperrkz__c);	
				
			if(trigg.get(i).OppRechnungsArt__c != 7 && trigg.get(i).OppRechnungsArt__c != 9 &&   // Ohne Lagerbewegung
			trigg[i].OppStageName__c != 'In Erstellung' && trigg[i].OppStageName__c != 'Gelöscht' && 
			(trigg.get(i).Fremdvertrieb__c == null || trigg.get(i).Fremdvertrieb__c == '') &&
			   trigg.get(i).Sperrkz__c == false) {		
				if (Product.get(trigg[i].Product2Id__c).RESB01__c==null)
						Product.get(trigg[i].Product2Id__c).RESB01__c=0;
				if (Trigg[i].Lizenzmenge__c!=null) {
					willUpdate = True;
					if(SystemSettings.Lagerabgang.contains(trigg.get(i).oppRechnungsArt__c.intValue())) {
						Product.get(trigg[i].Product2Id__c).RESB01__c += Trigg[i].Lizenzmenge__c;
					}
					if(SystemSettings.Lagerzugang.contains(trigg.get(i).oppRechnungsArt__c.intValue()))  {
						Product.get(trigg[i].Product2Id__c).RESB01__c -= Trigg[i].Lizenzmenge__c;
					}
				}
			}
			if(trigg.get(i).Anzahl_Schulen__c == null)
				trigg.get(i).Anzahl_Schulen__c = trigg.get(i).Opportunity.Anzahl_Schulen__c;		
		}
		
		if(willUpdate)
			updateProduct(trigg, Product);
	}
	
	public static void oninsert_before(list <OpportunityLineItem> trigg) {
		list<String> OppIds = new list<String>();		
		Product = getProduct(trigg);
		
		for(OpportunityLineItem oli:trigg) {
			OppIds.add(oli.OpportunityId);
		}
		map<String, Opportunity> Oppmap = new map<String, Opportunity>([select id, Lizenznummer__c from Opportunity where Id IN: OppIds]);
		list<ArtikelLizenz__c> ArtikelLizenz = new list<ArtikelLizenz__c>();
		list<String> Lizenznummer = new list<String>();
		list<String> Product2Ids = new list<String>();
		map<String, String> ALmap = new map<String, String>();
		for(OpportunityLineItem oli:trigg) {
			if(Product.containsKey(oli.Product2Id__c) && Oppmap.containsKey(oli.OpportunityId)) {
				Lizenznummer.add(Product.get(oli.Product2Id__c).name + Oppmap.get(oli.OpportunityId).Lizenznummer__c);
				Product2Ids.add(oli.Product2Id__c);
			}
		}
		
		ArtikelLizenz = [select id, Name, Artikel__c from ArtikelLizenz__c where ArtikelLizenz__c.Name IN: Lizenznummer AND Artikel__c IN:Product2Ids /* AND SPK015__c = False*/];
		for(ArtikelLizenz__c AL: ArtikelLizenz) {
			String ALid = AL.Artikel__c;
			ALmap.put(ALid.substring(0,15), AL.Id);
		}
		
		for(OpportunityLineItem oli:trigg) {
			if(ALmap.containsKey(oli.Product2Id__c)) {
				if(oli.SCHL2D__c == null )  //only if it's not filled out.
					oli.SCHL2D__c = ALmap.get(oli.Product2Id__c);
			}
		}
		
		SystemSettings.insertErrors();

	}
	
	private static void updateProduct(list<OpportunityLineItem> tempOpp, map<Id, Product2> Prods) {
		map<String, Product2> Prod2Update = new map <String, Product2>();
		
		for(OpportunityLineItem temp:tempOpp) {   //list to update
			if(temp.Product2Id__c!=null && Prods.containsKey(temp.Product2Id__c) && !Prod2Update.containsKey(Prods.get(temp.Product2Id__c).Id))
				Prod2Update.put(Prods.get(temp.Product2Id__c).Id, Prods.get(temp.Product2Id__c));
		}
		try{
			update Prod2Update.values();
		}
		catch (exception e) {
			SystemSettings.logError(e.getMessage());
			if (SystemSettings.isDebug) throw e;
		}
	}
	
	private static map<Id, Product2> getProduct(list<OpportunityLineItem> trigg) {
		
		list<String> ProdId = new list<String>(); 
		for(OpportunityLineItem trig:trigg) {   
			ProdId.add(trig.Product2Id__c);
		}
		
		try{
			Product = new map<Id, Product2>([select Id, RESB01__c, name
							from Product2 where Id IN :ProdId]);
		}
		catch (exception e) {
			SystemSettings.logError(e.getMessage());
			if (SystemSettings.isDebug) throw e;
		}
		
		return Product;
	}
	
	public static void onSignature(list<OpportunityLineItem> trigNew) {
	 
		list<OpportunityLineItem> toInsert = new list<OpportunityLineItem>();
		OpportunityLineItem tempInsert;
		list<String> ListMedienart = new list<String>();
		map<String, String> MapPreisbuch = new map< String, String>();
		
		for(OpportunityLineItem trig:listtoSend) {
			system.debug('should go here .. ' + trig.medienart_55__c);
			if(trig.medienart_55__c != null && trig.medienart_55__c != '')
				ListMedienart.add(trig.medienart_55__c);
			if(KNEW_LZN.contains(trig.Lizenznummer__c)) 
				ListMedienart.add(Id.valueOf(trig.Product2Id__c));
		}
	
		set<Id> setOfKOOliIds = new set<Id>();
		map<String, map<String, String>> mapPriceBook = new map<String, map< String, String>>();
		map<String, String> mapPriceBookfirst = new map< String, String>();
		map<String, ArtikelLizenz__c> mapAL = new map< String, ArtikelLizenz__c>();
		map<String, ArtikelLizenz__c> ALKeymap = new map<String, ArtikelLizenz__c>();
		map<Id, map<String, ArtikelLizenz__c>> mapArtikelLizenz = new map<Id, map<String, ArtikelLizenz__c>>();
		map<String, Double> mapPriceBookUnitPrice = new map<String, Double>();
		map<Id, ArtikelLizenz__c> ALtoUpdate = new map<Id, ArtikelLizenz__c> ();
		String PriceBuchId;
		if(listtoSend[0].PreisbuchId__c == null || listtoSend[0].PreisbuchId__c == '')
			PriceBuchId = [Select Id From Pricebook2  where IsActive = True limit 1].Id;
		else
			PriceBuchId = listtoSend[0].PreisbuchId__c;
		//Opportunity opp = new Opportunity([Select Pricebook2Id From Opportunity where Id =:trigger.new[0].OpportunityId limit 1]);
		//String PriceBuchId = opp.Pricebook2Id;
		//String PriceBuchId = [Select Pricebook2Id From Opportunity where Id =:listtoSend[0].OpportunityId limit 1].Pricebook2Id;
		//system.debug('debug price book ' + PriceBuchId + ' ' + MapMedienart.values() + ' ' + listtoSend[0].OpportunityId); 
		for(PricebookEntry temp:[Select Id, UnitPrice, Product2Id, Pricebook2Id From PricebookEntry  where Product2Id IN:  ListMedienart AND Pricebook2Id =: PriceBuchId]) {
			String prodId = temp.Product2Id;
			prodId = prodId.substring(0,15);
			String Pricebook2Id = temp.Pricebook2Id;
			Pricebook2Id = Pricebook2Id.substring(0,15);
			
			mapPriceBookfirst.put(prodId, temp.Id);
			//mapPriceBook.put(Pricebook2Id, mapPriceBookfirst);
			mapPriceBookUnitPrice.put(temp.Id, temp.UnitPrice);
		}
		
		map<Id, Product2> mapProduct = new map<Id, Product2>([select id, RESB01__c from Product2 where Id IN: listMedienart]);
		system.debug('map product 1 ... ' + mapProduct);
		for(ArtikelLizenz__c temp:[Select Id, Artikel__c, LZN015__c, VPR015__c, SPK015__c from ArtikelLizenz__c where Artikel__c IN: ListMedienart ]) {
			system.debug('artikellizenz ' + temp.Artikel__c );
			Id ArtikelId = temp.Artikel__c;
			if(!mapArtikelLizenz.containsKey(ArtikelId)) {
				mapArtikelLizenz.put(ArtikelId, new map<String, ArtikelLizenz__c>());
			}

			mapArtikelLizenz.get(ArtikelId).put(temp.LZN015__c, temp);

			
			system.debug('artikellizenz2 ' + mapArtikelLizenz.size());
		}
		
		for(OpportunityLineItem trig:listtoSend) {
			// JS,
			// KO calculation
			system.debug('trigger of the 55 ' + trig.medienart_55__c );
			system.debug('map artikellizenz ' + mapArtikelLizenz);
			if(trig.medienart_55__c != null && mapArtikelLizenz.containsKey(Id.valueOf(trig.medienart_55__c)))
				system.debug('map artikellizenz2 ' + mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)));
			
			// KO calculation
			if(trig.medienart_55__c != null && trig.medienart_55__c != '' &&
				trig.Lizenznummer__c=='10206' &&
			   mapArtikelLizenz.containsKey(Id.valueOf(trig.medienart_55__c))&&
			 //  mapArtikelLizenz.get(trig.medienart_55__c).containsKey(trig.Lizenznummer__c)) {
			  mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).containsKey('10206')) { //55***10206 in the querverweis should exist
				tempInsert= new OpportunityLineItem();

				//tempInsert = trig.clone(false, true);
				
				system.debug('debug pricebookId ' + trig.PreisbuchId__c + ' ' + trig.medienart_55__c);
				system.debug('debug pricebookId2 ' + mapPriceBookfirst);
				try {
					
					tempInsert.PricebookEntryId = mapPriceBookfirst.get(trig.medienart_55__c);}//mapPriceBook.get(trig.PreisbuchId__c).get(trig.medienart_55__c); }
				catch (exception e) {
					system.debug('map error');
				}
				
				tempInsert.SCHL2D__c = mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get('10206').Id;

				tempInsert.OpportunityId = trig.OpportunityId;
				tempInsert.Quantity = trig.Quantity ;
				tempInsert.Kopien_Rabatt__c = trig.Kopien_Rabatt__c ;
				tempInsert.Anzahl_Schulen__c = trig.Anzahl_Schulen__c;
				tempInsert.Discount = trig.Discount;
				tempInsert.UnitPrice = trig.Anzahl_Schulen_berechnet__c * trig.OppVKP_Einzelpreis__c;//mapArtikelLizenz.get(trig.medienart_55__c).get('10206').VPR015__c;
				if(tempInsert.Kopien_Rabatt__c)
					tempInsert.UnitPrice *= 2;
			//	tempInsert.TotalPrice = mapPriceBookUnitPrice.get(tempInsert.PricebookEntryId);
			//	if(tempInsert.TotalPrice == null)
			//		tempInsert.TotalPrice = 0;
				tempInsert.KreisListe__c = trig.Id;
				
				toInsert.add(tempInsert); 
				/***** the artikel Lizenz is automatically unlocked *****/
				mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get('10206').SPK015__c = False;
				if(trig.OppRechnungsArt__c != 7 && trig.OppRechnungsArt__c != 9 &&   // Ohne Lagerbewegung
					trig.OppStageName__c != 'In Erstellung' && trig.OppStageName__c != 'Gelöscht' && 
					(trig.Fremdvertrieb__c == null || trig.Fremdvertrieb__c == '') &&
			  		 trig.Sperrkz__c == false) {	
			  		 onProduct.inFutureContextStoredId = 'true';	
					if (mapProduct.get(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get('10206').Artikel__c).RESB01__c==null)
						mapProduct.get(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get('10206').Artikel__c).RESB01__c=0;
					if (Trig.Lizenzmenge__c!=null) {

						if(SystemSettings.Lagerabgang.contains(trig.oppRechnungsArt__c.intValue())) {
							mapProduct.get(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get('10206').Artikel__c).RESB01__c += Trig.Lizenzmenge__c;
						}
						if(SystemSettings.Lagerzugang.contains(trig.oppRechnungsArt__c.intValue()))  {
							mapProduct.get(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get('10206').Artikel__c).RESB01__c -= Trig.Lizenzmenge__c;
						}
					}
				}
				system.debug('map product 2 ... ' + mapProduct);
				if(!ALtoUpdate.containsKey(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get('10206').Id))
					ALtoUpdate.put(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get('10206').Id, mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get('10206'));
				/*****end of the artikel Lizenz is automatically unlocked *****/
			  }
			  
			// K1/K2 Calculation	
			for (String lzn:KNEW_LZN) {	
				if(trig.medienart_55__c != null && trig.medienart_55__c != '' &&
				   mapArtikelLizenz.containsKey(Id.valueOf(trig.medienart_55__c))&&
				   trig.Lizenznummer__c==lzn &&
				 //  mapArtikelLizenz.get(trig.medienart_55__c).containsKey(trig.Lizenznummer__c)) {
				  mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).containsKey(lzn)) { //55***lzn in the querverweis should exist
					// now we have a 46er Base LineItem
					setOfKOOliIds.add(trig.id);
					
					// first we create the suitable 55er
					tempInsert= new OpportunityLineItem();
					
					system.debug('debug pricebookId ' + trig.PreisbuchId__c + ' ' + trig.medienart_55__c);
					system.debug('debug pricebookId2 ' + mapPriceBookfirst);
					try {
						tempInsert.PricebookEntryId = mapPriceBookfirst.get(trig.medienart_55__c);
				  	} catch (exception e) {
						system.debug('map error');
					}
					System.debug('K1/K2 LZN: ' + lzn + ' / ID: ' + mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).Id);
					tempInsert.SCHL2D__c = mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).Id;
	
					tempInsert.OpportunityId = trig.OpportunityId;
					tempInsert.Quantity = trig.Quantity;
					tempInsert.Kopien_Rabatt__c = trig.Kopien_Rabatt__c;
					tempInsert.Anzahl_Schulen__c = trig.Anzahl_Schulen__c;
					tempInsert.Discount = trig.Discount;
					tempInsert.UnitPrice=0;
					tempInsert.KreisListe__c = trig.Id;
					toInsert.add(tempInsert); 
					
					
					// then we append the copies
					for (String clzn: CopiesLZN) {
						if (mapArtikelLizenz.get(Id.valueOf(trig.Product2Id__c)).containsKey(clzn)) {
							tempInsert= new OpportunityLineItem();
							tempInsert.OpportunityId = trig.OpportunityId;
							// quantity has to be fixed at Number of Copies because there is no other solution for this
							tempInsert.Quantity = NumberOfCopies;
							tempInsert.UnitPrice=0;
							tempInsert.Discount = trig.Discount;
							tempInsert.Kopien_Rabatt__c = trig.Kopien_Rabatt__c;
							tempInsert.SCHL2D__c = mapArtikelLizenz.get(Id.valueOf(trig.Product2Id__c)).get(clzn).Id;
							try {
								tempInsert.PricebookEntryId = trig.PricebookEntryId;
						  	} catch (exception e) {
								system.debug('map error');
							}
							tempInsert.KreisListe__c = trig.Id;
							tempInsert.KreisOnlineCopyId__c = mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).Id;
						}
					}					
					
					toInsert.add(tempInsert); 
					/***** the artikel Lizenz is automatically unlocked *****/
					mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).SPK015__c = False;
					if(trig.OppRechnungsArt__c != 7 && trig.OppRechnungsArt__c != 9 &&   // Ohne Lagerbewegung
						trig.OppStageName__c != 'In Erstellung' && trig.OppStageName__c != 'Gelöscht' && 
						(trig.Fremdvertrieb__c == null || trig.Fremdvertrieb__c == '') &&
				  		 trig.Sperrkz__c == false) {	
				  		 onProduct.inFutureContextStoredId = 'true';	
						if (mapProduct.get(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).Artikel__c).RESB01__c==null)
							mapProduct.get(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).Artikel__c).RESB01__c=0;
						if (Trig.Lizenzmenge__c!=null) {
	
							if(SystemSettings.Lagerabgang.contains(trig.oppRechnungsArt__c.intValue())) {
								mapProduct.get(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).Artikel__c).RESB01__c += Trig.Lizenzmenge__c;
							}
							if(SystemSettings.Lagerzugang.contains(trig.oppRechnungsArt__c.intValue()))  {
								mapProduct.get(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).Artikel__c).RESB01__c -= Trig.Lizenzmenge__c;
							}
						}
					}
					system.debug('map product 2 ... ' + mapProduct);
					if(!ALtoUpdate.containsKey(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).Id))
						ALtoUpdate.put(mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn).Id, mapArtikelLizenz.get(Id.valueOf(trig.medienart_55__c)).get(lzn));
					/*****end of the artikel Lizenz is automatically unlocked *****/
					}
			  }	
		}
		// JS K1/K2 End of K1/K2 Calculation
		

					
		if(!toInsert.isEmpty()) {
			try {
				onSignatureAfterInsert = false;
				update ALtoUpdate.values();
				ForcePassage = false;
				system.debug('toinsert size: ' + toInsert.size());
				insert toInsert;
				system.debug('toinsert first id: ' + toInsert.get(0).ID);
				update mapProduct.values();
				system.debug('map product 3 ... ' + mapProduct);
			}
			catch(exception e) {
				for(OpportunityLineItem OLI:trigNew) {
					OLI.addError(e.getMessage());
				}
			}
			if (!setOfKOOliIds.isEmpty()) futureUpdateKOTotalPrice(setOfKOOliIds);
		}
	}
	
	
	@future
	public static void futureUpdateKOTotalPrice(set<Id> oliids) {
		// get the olis to create the packages
		// then we can update the olis with the total price
		map<Id, OpportunityLineItem> global_olimap = new map<Id, OpportunityLineItem>([SELECT Id 
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
										Id IN : oliids
										]);
		system.debug('global_olimap: ' + global_olimap.values());
		KreisOnlinePackage kopkg=new KreisOnlinePackage(global_olimap);
		for (Id oliid:global_olimap.keySet()) {
			system.debug('totalprice ' + kopkg.getTotalpriceById(oliid) + ' zu id ' + oliid);
			global_olimap.get(oliid).Preis465557__c=kopkg.getTotalpriceById(oliid);
			global_olimap.get(oliid).K1_K2_Zahl_der_Vervielf_ltigungen__c=String.valueOf(kopkg.getKOpkgById(oliid).getCopyquantity());
		}
		update global_olimap.values();
	}
	
}