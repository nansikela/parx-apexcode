trigger Product2_Before_InstertUpdate on Product2 (before insert, before update) {
	
	
	for(Product2 p: trigger.new)
	{
		if(p.Seminarbeginn__c>=Date.valueOf('2011-01-01'))
		{
			
			
			//DB 1
			p.Direkte_Kosten__c = 0;
			if(p.Summe_Trainerkosten__c!= null) 					p.Direkte_Kosten__c+=p.Summe_Trainerkosten__c;
			if(p.Summe_Sonstiges__c!= null) 						p.Direkte_Kosten__c+=p.Summe_Sonstiges__c;
			if(p.Summe_Hotelkosten__c!= null) 						p.Direkte_Kosten__c+=p.Summe_Hotelkosten__c;
			
			//DB 2
			p.Kosten_DB2__c = 0;
			if(p.Telefon_PM__c!= null) 								p.Kosten_DB2__c +=p.Telefon_PM__c;
			if(p.Personalkosten_PM__c!= null) 						p.Kosten_DB2__c +=p.Personalkosten_PM__c;
			if(p.Sonstiges_PM__c!= null) 							p.Kosten_DB2__c +=p.Sonstiges_PM__c;
			if(p.Miete_PM__c!= null) 								p.Kosten_DB2__c +=p.Miete_PM__c;
			if(p.Logistik__c!= null) 								p.Kosten_DB2__c +=p.Logistik__c;
			if(p.Entwicklung_offene_Seminare__c!= null) 			p.Kosten_DB2__c +=p.Entwicklung_offene_Seminare__c;
			
			//DB 3
			p.Kosten_DB3__c = 0;
			if(p.Marketing_Anteil_Offene_Seminare__c!= null) 		p.Kosten_DB3__c+=p.Marketing_Anteil_Offene_Seminare__c;
			if(p.Vertrieb_Sales_Anteil_Offene_Seminare__c!= null) 	p.Kosten_DB3__c+=p.Vertrieb_Sales_Anteil_Offene_Seminare__c;
			
			
			//DB 4
			p.Kosten_DB4__c = 0;
			if(p.FIBU_PEWE__c!= null) 								p.Kosten_DB4__c+=p.FIBU_PEWE__c;
			if(p.Konzernumlage_Ab_2011__c!= null) 					p.Kosten_DB4__c+=p.Konzernumlage_Ab_2011__c;
			if(p.Personalkosten_GFVerwaltung__c!= null) 			p.Kosten_DB4__c+=p.Personalkosten_GFVerwaltung__c;
			if(p.Allgemeine_Verwaltung__c!= null) 					p.Kosten_DB4__c+=p.Allgemeine_Verwaltung__c;
		}
	}
}