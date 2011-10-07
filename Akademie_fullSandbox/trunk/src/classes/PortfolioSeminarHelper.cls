global class PortfolioSeminarHelper {
	
	webService static String createSeminar(Id portfolioId){
		String message = '';
		
		try{
			if(portfolioId != null){
				List<Portfolio__c> pList = [Select p.Anzahl_Termine_2010__c, p.Name, p.Min_Teilnehmer_f_r_Garantie__c, p.Beginn__c, p.Ende__c, p.Unterregister__c, p.Sonderpreis__c, p.Seminartitel__c, p.Seminarbeschreibung__c, p.Register__c, p.Preis__c, p.PM__c, p.Max_Teilnehmer__c, p.Leitung__c, p.Key_Note_Speaker__c, p.Dauer_in_Tagen__c From Portfolio__c p where p.Id = :portfolioId];	
				if(!pList.isEmpty()){
					Portfolio__c p = pList[0];
					Integer anzahl = p.Anzahl_Termine_2010__c.intValue();
					Integer i = 0;
					List<Product2> productToInsertList = new List<Product2>();
			
					//loop and create products
					for(i=0; i<anzahl; i++){
						Product2 prod = new Product2();
						prod.Name = p.Seminartitel__c;
						prod.Unterregister__c = p.Unterregister__c;
						prod.Themen_Register__c = p.Register__c;
						prod.Sonderpreis__c = p.Sonderpreis__c;
						prod.Seminargebuehr__c = p.Preis__c;
						prod.Seminarcode__c = p.Name;
						prod.PM__c = p.PM__c;
						prod.Max_Teilnehmer__c = p.Max_Teilnehmer__c;
						prod.Key_Note_Speaker__c = p.Key_Note_Speaker__c;
						prod.FM_Dozent__c = p.Leitung__c;
						prod.Description = p.Seminarbeschreibung__c;
						prod.Dauer_in_Tagen__c = p.Dauer_in_Tagen__c;
						prod.In_Vorbereitung__c = true;
						prod.Portfolio__c = p.Id;
						
						prod.Uhrzeit_Beginn__c = p.Beginn__c;
						prod.Uhrzeit_Ende__c = p.Ende__c;
						prod.Min_Teilnehmer_f_r_Garantie__c = p.Min_Teilnehmer_f_r_Garantie__c;
						
						productToInsertList.add(prod);
					}
					
					if(!productToInsertList.isEmpty()){
						try{
							insert productToInsertList;
							message = 'Successfully inserted ' + productToInsertList.size()+ ' seminare.';
						}catch(System.DMLException e){
							message = 'An error occured while inserting the seminare: ' + e.getMessage();
						}
					}else{
						message = 'No Seminare created.';
					}
				}else{
					message = 'No portfolio with Id \''+ portfolioId + '\' found.';
				}
			}else{
				message = 'No portfolio found.';
			}
			
		}catch(System.Exception e){
			System.debug('*** Exception: ' + e);
			message = e.getMessage();
		}
		System.debug('***message ' + message);
		return message;
			
	}
	
	
	/*webService static String createFASeminar(Id portfolioId){
		String message = '';
		//String RECORDTYPE_FIRMENAKADEMIE = '012R00000000MGG';	//SANDBOX
		String RECORDTYPE_FIRMENAKADEMIE = '012200000005GxX';	//LIVE
		
		try{
			if(portfolioId != null){
				List<Portfolio__c> pList = [Select p.Id, p.Name, p.Code_Titel__c, p.Seminartitel__c, p.Seminarbeschreibung__c, p.Max_Teilnehmer__c, p.Dauer_in_Tagen__c From Portfolio__c p where p.Id = :portfolioId];	
				if(!pList.isEmpty()){
					Portfolio__c p = pList[0];
				
					Inhouse_Produkt__c seminar = new Inhouse_Produkt__c();
					seminar.RecordTypeId = RECORDTYPE_FIRMENAKADEMIE;
					seminar.Name = p.Code_Titel__c;
					seminar.Code__c = p.Name;
					seminar.Seminartitel__c = p.Seminartitel__c; 
					seminar.Seminarbeschreibung__c = p.Seminarbeschreibung__c;
					seminar.Max_Teilnehmerzahl__c = p.Max_Teilnehmer__c; 
					seminar.Dauer__c = p.Dauer_in_Tagen__c;
					seminar.Portfolio__c = p.Id;
					
					try{
						insert seminar;
						message = 'Successfully created.';
					}catch(System.DMLException e){
						message = 'An error occured while inserting the seminare: ' + e.getMessage();
					}
				}else{
					message = 'No portfolio with Id \''+ portfolioId + '\' found.';
				}
			}else{
				message = 'No portfolio found.';
			}
			
		}catch(System.Exception e){
			System.debug('*** Exception: ' + e);
			message = e.getMessage();
		}
		System.debug('***message ' + message);
		return message;
			
	}*/
	
	
	
}