public class PortfolioSeminarHelperTEST {
	
	
	
	
	
	static testMethod void testSeminarCreation()	{
		
		List<Portfolio__c> portfolioList = new List<Portfolio__c>();
		
		try{
			Portfolio__c p1 = new Portfolio__c();
			p1.Anzahl_Termine_2010__c = 3; 
			p1.Unterregister__c = 'Persönlichkeit'; 
			p1.Sonderpreis__c = 1850; 
			p1.Seminartitel__c = 'parx test 1'; 
			p1.Seminarbeschreibung__c = 'Das ist die Beschreibung'; 
			p1.Register__c = 'Persönlichkeitsentwicklung und Selbstmanagement'; 
			p1.Preis__c = 3350; 
			p1.PM__c = 'IW'; 
			p1.Max_Teilnehmer__c = 32; 
			p1.Leitung__c = 'Dr. Christa-Jana Hartwig Margot Behrend  Ruth Hellmich'; 
			p1.Key_Note_Speaker__c = 'Herr Max Muster'; 
			p1.Dauer_in_Tagen__c = 3; 
			p1.Name = 'xxx999';
			portfolioList.add(p1);
			
			
			Portfolio__c p2 = new Portfolio__c();
			p2.Anzahl_Termine_2010__c = 22; 
			p2.Unterregister__c = 'Persönlichkeit'; 
			p2.Sonderpreis__c = 1501; 
			p2.Seminartitel__c = 'parx test 1'; 
			p2.Seminarbeschreibung__c = 'Das ist die Beschreibung'; 
			p2.Register__c = 'Persönlichkeitsentwicklung und Selbstmanagement'; 
			p2.Preis__c = 2500; 
			p2.PM__c = 'IW'; 
			p2.Max_Teilnehmer__c = 32; 
			p2.Leitung__c = 'Dr. Christa-Jana Hartwig Margot Behrend  Ruth Hellmich'; 
			p2.Key_Note_Speaker__c = 'Herr Max Muster'; 
			p2.Dauer_in_Tagen__c = 10; 
			p2.Name = 'xxx989';
			portfolioList.add(p2);
			
			Portfolio__c p3 = new Portfolio__c();
			p3.Anzahl_Termine_2010__c = 0; 
			p3.Unterregister__c = 'Persönlichkeit'; 
			p3.Sonderpreis__c = 1501; 
			p3.Seminartitel__c = 'parx test 1'; 
			p3.Seminarbeschreibung__c = 'Das ist die Beschreibung'; 
			p3.Register__c = 'Persönlichkeitsentwicklung und Selbstmanagement'; 
			p3.Preis__c = 2500; 
			p3.PM__c = 'IW'; 
			p3.Max_Teilnehmer__c = 32; 
			p3.Leitung__c = 'Dr. Christa-Jana Hartwig Margot Behrend  Ruth Hellmich'; 
			p3.Key_Note_Speaker__c = 'Herr Max Muster'; 
			p3.Dauer_in_Tagen__c = 10; 
			p3.Name = 'xxx9t9';
			portfolioList.add(p3);
			
			try{
				insert portfolioList;
			}catch(System.DMLException e){
				System.debug('*** Exception: ' + e);
				System.assert(false);
			}
			
			String message = PortfolioSeminarHelper.createSeminar(p1.Id);
		   	System.assertEquals(message, 'Successfully inserted 3 seminare.');
		    Integer portfoliocount = [Select count() from Product2 p where p.Portfolio__c = :p1.Id];
		    System.assertEquals(portfoliocount, 3);
		   	
		   	message = PortfolioSeminarHelper.createSeminar(p2.Id);
		   	System.assertEquals(message, 'Successfully inserted 22 seminare.');
		   	portfoliocount = [Select count() from Product2 p where p.Portfolio__c = :p2.Id];
		    System.assertEquals(portfoliocount, 22);
		    
		   	message = PortfolioSeminarHelper.createSeminar(p3.Id);
		   	System.assertEquals(message, 'No Seminare created.');
		   	portfoliocount = [Select count() from Product2 p where p.Portfolio__c = :p3.Id];
		    System.assertEquals(portfoliocount, 0);
		    
		   	message = PortfolioSeminarHelper.createSeminar('xxD60000000TTTT');
		   	System.assertEquals(message.substring(0,20), 'No portfolio with Id');
		   	
		}catch(System.Exception e){
			System.debug('*** Exception: ' + e);
				System.assert(false);
		}
	}
	
	
	/*
	static testMethod void testFASeminarCreation()	{
		//String RECORDTYPE_FIRMENAKADEMIE = '012R00000000MGG';	//SANDBOX
		String RECORDTYPE_FIRMENAKADEMIE = '012200000005GxX';	//LIVE
		
		List<Portfolio__c> portfolioList = new List<Portfolio__c>();

		try{
			Portfolio__c p1 = new Portfolio__c();
			p1.Anzahl_Termine_2010__c = 3; 
			p1.Seminartitel__c = 'parx test 1'; 
			p1.Seminarbeschreibung__c = 'Das ist die Beschreibung 1';
			p1.Preis__c = 3350; 
			p1.PM__c = 'IW'; 
			p1.Max_Teilnehmer__c = 98; 
			p1.Dauer_in_Tagen__c = 3; 
			p1.Name = 'xxx999';
			portfolioList.add(p1);
			
			
			Portfolio__c p2 = new Portfolio__c();
			p2.Anzahl_Termine_2010__c = 2; 
			p2.Seminartitel__c = 'parx test 2'; 
			p2.Seminarbeschreibung__c = 'Das ist die Beschreibung 2';
			p2.Preis__c = 1250; 
			p2.PM__c = 'IW'; 
			p2.Max_Teilnehmer__c = 2; 
			p2.Dauer_in_Tagen__c = 6; 
			p2.Name = 'xxx998';
			portfolioList.add(p2);
			
			try{
				insert portfolioList;
			}catch(System.DMLException e){
				System.debug('*** Exception: ' + e);
				System.assert(false);
			}
			
			List<Inhouse_Produkt__c> seminarList = new List<Inhouse_Produkt__c>();
			
			String message = PortfolioSeminarHelper.createFASeminar(p1.Id);
		   	System.assertEquals(message, 'Successfully created.');
		    seminarList = [Select Portfolio__c, RecordTypeId, Dauer__c, Seminarbeschreibung__c, Code__c, Max_Teilnehmerzahl__c from Inhouse_Produkt__c where Portfolio__c = :p1.Id];
		    if(seminarList.size() != 1){
		    	System.assert(false);
		    }else{
			    System.assertEquals(seminarList[0].RecordTypeId, RECORDTYPE_FIRMENAKADEMIE);
			   	System.assertEquals(seminarList[0].Seminarbeschreibung__c, 'Das ist die Beschreibung 1');
			   	System.assertEquals(seminarList[0].Max_Teilnehmerzahl__c, 98);
			   	System.assertEquals(seminarList[0].Portfolio__c, p1.Id);
		    }
		   	
		   	message = PortfolioSeminarHelper.createFASeminar(p2.Id);
		   	System.assertEquals(message, 'Successfully created.');
		   	seminarList = [Select Portfolio__c, RecordTypeId, Dauer__c, Seminarbeschreibung__c, Code__c, Max_Teilnehmerzahl__c from Inhouse_Produkt__c where Portfolio__c = :p2.Id];
		    if(seminarList.size() != 1){
		    	System.assert(false);
		    }else{
			    System.assertEquals(seminarList[0].RecordTypeId, RECORDTYPE_FIRMENAKADEMIE);
			   	System.assertEquals(seminarList[0].Seminarbeschreibung__c, 'Das ist die Beschreibung 2');
			   	System.assertEquals(seminarList[0].Max_Teilnehmerzahl__c, 2);
			   	System.assertEquals(seminarList[0].Portfolio__c, p2.Id);
		    }
		    
		    
		   	message = PortfolioSeminarHelper.createFASeminar('xxD60000000TTTT');
		   	System.assertEquals(message.substring(0,20), 'No portfolio with Id');
		   	
		}catch(System.Exception e){
			System.debug('*** Exception: ' + e);
				System.assert(false);
		}
	}*/
}