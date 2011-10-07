trigger Inhouse_Produkt_BeforeInsertUpdate on Inhouse_Produkt__c (before insert, before update) {
	Map<String, TriggerSetting__c>settings = TriggerSetting__c.getAll();
	
	try{
		/*Errechne TrainerHonorar*/
		Map<Id, Inhouse_Produkt__c> triggeredInhouseProduktMap = trigger.newMap;
	
		if(!trigger.isInsert)
		{
			for(AggregateResult e : [SELECT Inhouse_Produkt__c product, SUM(Reisekosten__c) reisekosten, SUM(Dozentenhonorar__c) honorar FROM Dozenteneinsatz_Inhouse__c WHERE Inhouse_Produkt__c IN :trigger.newMap.keySet() GROUP BY Inhouse_Produkt__c])
			{
				Inhouse_Produkt__c p	= triggeredInhouseProduktMap.get(String.valueOf(e.get('product')));
				if(p.Beginndatum__c>=Date.today())
				{
					p.DB_Honorar__c 		= Double.valueOf(e.get('honorar'));
					p.DB_Reisekosten__c 	= Double.valueOf(e.get('reisekosten'));
				}
			}
		}
	//Summe
	List<Inhouse_Produkt__c> scope;
	if(!trigger.isInsert)
	{
		scope = triggeredInhouseProduktMap.values();
	}
	else
	{
		scope = trigger.new;
	}
	
	for(Inhouse_Produkt__c p : scope)
	{
		if(p.Beginndatum__c>=Date.valueOf('2011-01-01'))
		{
			/*Summe Direkte Kosten*/
			p.DB_Direkte_Kosten__c = 0;
			if(p.DB_Honorar__c!= null)
			{
				p.DB_Direkte_Kosten__c +=p.DB_Honorar__c;
			}
			if(p.DB_Reisekosten__c!= null)
			{
				p.DB_Direkte_Kosten__c +=p.DB_Reisekosten__c;
			}
			if(p.DB_Sonstiges__c!= null)
			{
				p.DB_Direkte_Kosten__c +=p.DB_Sonstiges__c;
			}
			if(p.DB_Durchf_hrungskosten__c!= null)
			{
				p.DB_Direkte_Kosten__c +=p.DB_Durchf_hrungskosten__c;
			}
			if(p.DB_Toolkosten__c!= null)
			{
				p.DB_Direkte_Kosten__c +=p.DB_Toolkosten__c;
			}
			/*Summe Direkte Kosten ENDE*/
			
			/*Summe DB 2*/
			
			p.Kosten_DB_2__c = 0;
			if(p.DB_Personal_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB_2__c +=p.DB_Personal_Inhouse_Betrag__c;
			}
			if(p.DB_Miete_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB_2__c +=p.DB_Miete_Inhouse_Betrag__c;
			}
			if(p.DB_Telefon_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB_2__c +=p.DB_Miete_Inhouse_Betrag__c;
			}
			if(p.DB_Sonstige_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB_2__c +=p.DB_Sonstige_Inhouse_Betrag__c;
			}
			if(p.DB_Logistik_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB_2__c +=p.DB_Logistik_Inhouse_Betrag__c;
			}
			if(p.DB_Entwicklung_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB_2__c +=p.DB_Entwicklung_Inhouse_Betrag__c;
				
			}
			/*Summe DB 2 ENDE*/
			/*Summe DB 3*/
			p.Kosten_DB3__c = 0;
			if(p.DB_Marketing_Anteil_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB3__c +=p.DB_Marketing_Anteil_Inhouse_Betrag__c;
			}
			
			if(p.DB_Vertrieb_Sales_Anteil_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB3__c +=p.DB_Vertrieb_Sales_Anteil_Inhouse_Betrag__c;
			}
			/*Summe DB 3 ENDE*/
			/*Summe DB 4*/
			p.Kosten_DB4__c = 0;
			if(p.DB_PersonalGF_Verwaltung_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB4__c +=p.DB_PersonalGF_Verwaltung_Inhouse_Betrag__c;
			}
			
			if(p.DB_Allgemeine_Verwaltung_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB4__c +=p.DB_Allgemeine_Verwaltung_Inhouse_Betrag__c;
			}
			
			if(p.DB_Umlage_FiBu_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB4__c +=p.DB_Umlage_FiBu_Inhouse_Betrag__c;
			}
			if(p.DB_Konzernumlage_Inhouse_Betrag__c!= null)
			{
				p.Kosten_DB4__c +=p.DB_Konzernumlage_Inhouse_Betrag__c;
			}
			/*Summe DB 4 ENDE*/
		}
	}
	}
	catch(Exception e)
	{}
	
	
	/*Seminartitel */
	/*"Inhouse-Produktname: ((STORNO -)) Accountname - ((K - )) Seminartitel - Dozent
	Storno: wenn Phase Inhouse Produkte = Storno - zusätzlich: Umsatz = 0
	K: wenn Veranstaltungsform = Konzeptionstag"*/
	Set<Id>opportunityIdSet = new Set<Id>();
	for(Inhouse_Produkt__c ip : trigger.new)
	{
		if(ip.Opportunity__c != null && !opportunityIdSet.contains(ip.Opportunity__c))
		{
			opportunityIdSet.add(ip.Opportunity__c);
		}
		//Clear name
		ip.name = '';
			//Seminartitel aus
			if(ip.RecordTypeId!= null && String.valueOf(ip.RecordTypeId).subString(0,15) == settings.get('RTInhProEntwicklungsprogramme').value__c)
			{
				if(ip.Veranstaltungsdetails__c != null)
				{
					//ERROR Titel zu Lang
					if(ip.Veranstaltungsdetails__c.length()>100)
					{
						ip.name += ip.Veranstaltungsdetails__c.subString(0,100);
					}
					else
					{
						ip.name += ip.Veranstaltungsdetails__c;
					}
				}
			
			
		}else if(ip.RecordTypeId!= null && String.valueOf(ip.RecordTypeId).subString(0,15) == settings.get('RTInhProTools').value__c)
		{
			ip.name += ip.Tool__c;
		}else if(ip.Seminartitel__c != null)
		{
			// JS: ChangeRequest 4 - Seminartitel soll nur noch 15 Zeichen lang sein
			if (ip.Seminartitel__c.length()>15)
				ip.name += ip.Seminartitel__c.subString(0,15);
			else
				ip.name += ip.Seminartitel__c;
			
		}
		
		if(ip.Sprache__c != null)
		{
			ip.name += ' '+ip.Sprache__c.subString(0,1);
		}
	}
	Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([Select o.id, o.StageName, o.Account.Name, o.AccountId, o.Account.Kurz_Name__c From Opportunity o WHERE ID IN :opportunityIdSet]);
	
	//Dozent kann nur gefunden werden bei Update
	if(!trigger.isInsert)
	{
		set<Id> firstDozent = new set<Id>();
		for(Dozenteneinsatz_Inhouse__c d : [Select d.Inhouse_Produkt__c, d.Dozent__r.FirstName, d.Dozent__r.LastName, d.Dozent__c From Dozenteneinsatz_Inhouse__c d WHERE d.Inhouse_Produkt__c IN :trigger.new])
		{
			if(d.Inhouse_Produkt__c != null && d.Dozent__c != null && trigger.newMap.containsKey(d.Inhouse_Produkt__c))
			{
				Inhouse_Produkt__c product =trigger.newMap.get(d.Inhouse_Produkt__c);
				if (!firstDozent.contains(d.Inhouse_Produkt__c)) {
					product.name += ' - '+d.Dozent__r.LastName;
					firstDozent.add(d.Inhouse_Produkt__c);
				}
				else {
					product.name += ', '+d.Dozent__r.LastName;
				}
			}
		}
	}
	for(Inhouse_Produkt__c product : trigger.new)
	{
		if(product.Veranstaltungsform__c != null && product.Veranstaltungsform__c == 'Konzeptionstag')
		{
			product.name = 'K - '+product.name;
		}
		//Accountname
		if(product.Opportunity__c!= null && opportunityMap.containsKey(product.Opportunity__c))
		{
			if(product.Account__c == null)
			{
				product.Account__c = opportunityMap.get(product.Opportunity__c).AccountId;
			}
			product.name = opportunityMap.get(product.Opportunity__c).Account.Kurz_Name__c + ' - '+product.name;
		}
		//Phase = Storno
		if(product.Phase_Inhouse_Produkt__c != null && product.Phase_Inhouse_Produkt__c == 'Storno')
		{
			product.name = 'STORNO - '+product.name;
			product.Umsatz__c = 0;
		}
		if(product.name.length()>80)
		{
			product.name = product.name.subString(0,80);
		}
	}
	
	//Anzahl Dozenten Einsätze
	for(Inhouse_Produkt__c p : trigger.new)
	{
		p.Anzahl_Trainer__c = 0;
	}
	
	//Dozent kann nur gefunden werden bei Update
	if(!trigger.isInsert)
	{
		for(AggregateResult a : [SELECT Inhouse_Produkt__c product, COUNT(id) counter FROM Dozenteneinsatz_Inhouse__c  WHERE Inhouse_Produkt__c IN :trigger.new GROUP BY Inhouse_Produkt__c])
		{
			Inhouse_Produkt__c product = trigger.newMap.get(String.valueOf(a.get('product')));
			product.Anzahl_Trainer__c = Integer.valueOf(a.get('counter'));
		}
	}
	
	
	//Trainer Tage berechnen
	for(Inhouse_Produkt__c p : trigger.new)
	{
		if((p.Trainertage_manuell_berechnen__c == null || !p.Trainertage_manuell_berechnen__c) && p.Dauer__c != null)
		{
			p.Trainertage__c = p.Anzahl_Trainer__c * p.Dauer__c;
		}
	}
}