public class Portfolio_beforeUpdateTEST {
	
	static testMethod void testportfolio()	{
		
		List<Portfolio__c> portfolioList = new List<Portfolio__c>();
		String STATUS_FINAL = 'Verabschiedet';
		String STATUS_SEMIFINAL = 'Eckdaten verabschiedet';
		
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
			p1.Status__c = STATUS_FINAL;
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
			
			Portfolio__c p4 = new Portfolio__c();
			p4.Anzahl_Termine_2010__c = 7; 
			p4.Unterregister__c = 'Persönlichkeit'; 
			p4.Sonderpreis__c = 1501; 
			p4.Seminartitel__c = 'parx test 1'; 
			p4.Seminarbeschreibung__c = 'Das ist die Beschreibung'; 
			p4.Register__c = 'Persönlichkeitsentwicklung und Selbstmanagement'; 
			p4.Preis__c = 2500; 
			p4.PM__c = 'IW'; 
			p4.Max_Teilnehmer__c = 32; 
			p4.Leitung__c = 'Dr. Christa-Jana Hartwig Margot Behrend  Ruth Hellmich'; 
			p4.Key_Note_Speaker__c = 'Herr Max Muster'; 
			p4.Dauer_in_Tagen__c = 10; 
			p4.Name = 'xxx9t9t';
			p4.Status__c = STATUS_SEMIFINAL;
			portfolioList.add(p4);
			
			try{
				insert portfolioList;
			}catch(System.DMLException e){
				System.debug('*** Exception: ' + e);
				System.assert(false);
			}
			
			//p1 should not be editable
			p1.PM__c = 'KL'; 
			p1.Max_Teilnehmer__c = 2; 
			try{
				update p1;
				System.assert(false);
			}catch(System.DMLException e){
				System.debug('*** Exception, should occur: ' + e);
			}
			
			//p2 should  be editable
			p2.PM__c = 'KL'; 
			p2.Max_Teilnehmer__c = 2;
			p2.Status__c = STATUS_FINAL;
			try{
				update p2;
			}catch(System.DMLException e){
				System.debug('*** Exception: ' + e);
				System.assert(false);
			}
			
			//p2 should  not be editable anymore, status is verabschiedet
			p2.PM__c = 'R'; 
			p2.Max_Teilnehmer__c = 18;
			try{
				update p2;
				System.assert(false);
			}catch(System.DMLException e){
				System.debug('*** Exception, should occur: ' + e);
			}
			
			//p4 should work
		   	p4.Seminarbeschreibung__c = 'Neue Seminarbeschreibung'; 
			try{
				update p4;
			}catch(System.DMLException e){
				System.debug('*** Exception: ' + e);
				System.assert(false);
			}
			
			//p4 should not work status is eckdatenverabschiedet
		   	p4.PM__c = 'Rts'; 
			p4.Max_Teilnehmer__c = 17;
			p4.Zielgruppe__c = 'Neue Zielgruppe';
			try{
				update p4;
				System.assert(false);
			}catch(System.DMLException e){
				System.debug('*** Exception, should occur: ' + e);
			}
			
			//run as helga borkert, edit should be possible
			User hbUser = [Select Id from User where Id = '00520000000lHIIAA2'];
			System.runAs(hbUser) {
				
				//p4 should work status is eckdatenverabschiedet but helga
			   	p4.PM__c = 'Rts'; 
				p4.Max_Teilnehmer__c = 17;
				p4.Zielgruppe__c = 'Neue Zielgruppe';
				try{
					update p4;
				}catch(System.DMLException e){
					System.debug('*** Exception: ' + e);
					System.assert(false);
				}
				
				//p2 should be editable, status is verabschiedet but helga
				p2.PM__c = 'R'; 
				p2.Max_Teilnehmer__c = 18;
				try{
					update p2;
				}catch(System.DMLException e){
					System.debug('*** Exception: ' + e);
					System.assert(false);
				}
			}
		}catch(System.Exception e){
			System.debug('*** Exception: ' + e);
				System.assert(false);
		}
	}
}