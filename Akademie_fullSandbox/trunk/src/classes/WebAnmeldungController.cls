public class WebAnmeldungController {
	
	//All seminars
	public List<SelectOption> seminarCodeList {get;set;}
	
	//Selected Seminar
	public String seminarCode {get; set;}
	
	
	//Days and Months for Dropdowns
	public List<SelectOption> dayList {get; set;}
	public List<SelectOption> monthList {get; set;}
	public List<SelectOption> byearList {get; set;}
	
	
	public List<SelectOption> seminarList {get; set;}
	public String seminarTitel {get; set;}	
	
	//Bestellung
	public Bestellung__c bestellung {get; set;}
	public Lead teilnehmer1 {get; set;}
	public Lead teilnehmer2 {get; set;} 
	public String t1bday{get; set;}
	public String t1bmonth {get; set;}
	public String t1byear {get; set;}
	
	public String t2bday{get; set;}
	public String t2bmonth {get; set;}
	public String t2byear {get; set;}
	public String buchungsSeminar {get; set;}
	public HotelDaten hoteldaten {get; set;}
	
	public List<SelectOption> tenList {get; set;}
	public List<SelectOption> seminarYearList {get; set;}
	public List<SelectOption> buchungstypList {get; set;}
	public List<SelectOption> zahlungsArtList {get; set;}
	
	
	public String ankunftday {get; set;} 
	public String abreiseday {get; set;}
	
	public String ankunftmonth {get; set;}
	public String abreisemonth {get; set;}
	
	public String ankunftyear {get; set;}
	public String abreiseyear {get; set;}
	
	public Preise preise{get; set;}
	
	public String hotelBuchungsText{get; set;}
	
	
	public WebAnmeldungController(){
		//Select Seminar
		if(buchungsSeminar==null || buchungsSeminar == ''){
			buchungsSeminar = WebUrlEncoder.decodeParam('seminarId');
		}
		//SeminarCode
		if(seminarCode == null || seminarCode== ''){
			seminarCode = WebUrlEncoder.decodeParam('seminarCode');
		}
		
		
		//List of days
		dayList = new List<SelectOption>();
		for(Integer i = 1; i<=31; i++){
			dayList.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
		}
		
		//List of Months
		monthList = new List<SelectOption>();
		monthList.add(new SelectOption('1', 'Januar'));
		monthList.add(new SelectOption('2', 'Februar'));
		monthList.add(new SelectOption('3', 'März'));
		monthList.add(new SelectOption('4', 'April'));
		monthList.add(new SelectOption('5', 'Mai'));
		monthList.add(new SelectOption('6', 'Juni'));
		monthList.add(new SelectOption('7', 'Juli'));
		monthList.add(new SelectOption('8', 'August'));
		monthList.add(new SelectOption('9', 'September'));
		monthList.add(new SelectOption('10', 'Oktober'));
		monthList.add(new SelectOption('11', 'November'));
		monthList.add(new SelectOption('12', 'Dezember'));
		
		//List of byears
		byearList = new List<SelectOption>();
		for(Integer i = 0; i< 110; i++){
			byearList.add(new SelectOption(String.valueOf(1900+i), String.valueOf(1900+i)));
		}
		
		//List of 1 to 10
		tenList = new List<SelectOption>();
		for(Integer i = 0; i< 11; i++){
			tenList.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
		}
		
		//Bookingtype List
		buchungstypList = new List<SelectOption>();
		buchungstypList.add(new SelectOption('Buchung', 'Seminar buchen'));
		buchungstypList.add(new SelectOption('Reservierung', 'Seminar 10 Tage reservieren'));
		
		//Payment
		zahlungsArtList = new List<SelectOption>();
		zahlungsArtList.add(new SelectOption('Rechnung', 'Rechnung'));
		
		if(seminarCode == '' || seminarCode == null){
			seminarCodeList = new List<SelectOption>();
			SelectOption item; 
			List<AggregateResult> seminareQ = [	Select 
													p.Portfolio__r.name, 
													Portfolio__r.SeminarTitel__c 
												From 
													Product2 p 
												WHERE 
													p.Seminarbeginn__c > today 
												AND p.Anzeige_auf_website__c = true 
												AND p.Portfolio__r.Portfolio_Typ__c = 'Offene Seminare' 
												AND p.Portfolio__r.name <> '' 
												AND p.portfolio__r.Ist_Intensivprogramm__c = false
												AND p.Ampel__c != '<img src="/img/samples/light_red.gif" alt="status color" border="0"/>'
												
												GROUP BY 
													p.Portfolio__r.name, 
													Portfolio__r.SeminarTitel__c LIMIT 300];
			item = new SelectOption('', '- bitte Seminar wählen -');
			seminarCodeList.add(item);
			for(AggregateResult p: seminareQ){
				item = new SelectOption(String.valueOf(p.get('name')),String.valueOf(p.get('name'))+' '+String.valueOf(p.get('SeminarTitel__c')));
				seminarCodeList.add(item);
			}
		}else{
			seminarList = new List<SelectOption>();
			List<Product2> productList = [	SELECT 
												p.id, 
												p.Seminarbeginn__c, 
												p.Portfolio__r.name, 
												p.Portfolio__r.Seminartitel__c, 
												p.Seminarende__c, 
												p.Veranstaltungsort2__r.Account__r.billingCity 
											FROM 
												Product2 p 
											WHERE 
												p.portfolio__r.name = :seminarCode
												AND p.Seminarbeginn__c>today
												AND Ampel__c <> '/img/samples/light_red.gif'
												AND Status_durchfuehrung__c = true
												AND Restpl_tze__c != 0
												AND Restpl_tze__c >0
											ORDER BY p.seminarbeginn__c LIMIT 200];
			
			
			for(Product2 p: productList){
				if(seminarTitel =='' || seminarTitel == null){
					seminarTitel = p.Portfolio__r.name + ' '+ p.Portfolio__r.Seminartitel__c;
				}
				seminarList.add(new SelectOption(p.id, p.seminarBeginn__c.format()+' - '+p.Seminarende__c.format()+ '  '+p.Veranstaltungsort2__r.Account__r.billingCity));
			}
			
			bestellung = new Bestellung__c();
			teilnehmer1 = new Lead();
			teilnehmer2 = new Lead();
			teilnehmer1.LeadSource='Buchung';
			teilnehmer2.LeadSource='Buchung';
			
		}
		
		String bestellid = WebURLEncoder.decodeParam('bid');
		if(bestellid != '' && bestellid != null){
			bestellung = [	SELECT 
								b.teilnehmer2__c, 
								b.agb_akzeptiert__c, 
								b.Einzelpreis_Seminar__c, 
								b.teilnehmer1__r.name, 
								b.teilnehmer2__r.name, 
								b.seminar__r.veranstaltungsort2__r.account__r.billingcity, 
								b.seminar__r.portfolio__r.name, 
								b.firma__c, 
								b.Abteilung__c, 
								b.ansprechpartner__c, 
								b.strasse__c, 
								b.PLZ__c, 
								b.Telefon__c, 
								b.Telefax__c, 
								b.Ort__c, 
								b.eMail__c, 
								b.Zahlungsart__c, 
								b.Nachricht__c, 
								b.Marketing_Kanal__c, 
								b.seminar__r.seminarbeginn__c, 
								b.Anzahl_EZ__c, 
								b.Anzahl_DZ__c, 
								b.seminar__r.seminarende__c, 
								b.seminar__r.portfolio__r.seminarTitel__c, 
								b.seminar__r.veranstaltungsort2__r.name, 
								b.seminar__r.veranstaltungsort2__r.account__r.EZ_Preis_dieses_Jahr__c, 
								b.seminar__r.veranstaltungsort2__r.account__r.DZ_Preis_dieses_Jahr__c,
								b.Hotel_Reservierung__c,
								b.Anreise__c,
								b.abreise__c
							FROM 
								Bestellung__c b 
							WHERE 
								b.id = :bestellid];
			hoteldaten = new HotelDaten();
			
			if(bestellung.seminar__r.veranstaltungsort2__r.account__r.EZ_Preis_dieses_Jahr__c == null){
				 bestellung.seminar__r.veranstaltungsort2__r.account__r.EZ_Preis_dieses_Jahr__c = 0;
			}
			if(bestellung.seminar__r.veranstaltungsort2__r.account__r.DZ_Preis_dieses_Jahr__c == null){
				 bestellung.seminar__r.veranstaltungsort2__r.account__r.DZ_Preis_dieses_Jahr__c = 0;
			}
			hoteldaten.preisEZ = String.valueOf(bestellung.seminar__r.veranstaltungsort2__r.account__r.EZ_Preis_dieses_Jahr__c).replace('.',',').replace(',00', ',-')+' EUR';
			hoteldaten.preisDZ = String.valueOf(bestellung.seminar__r.veranstaltungsort2__r.account__r.DZ_Preis_dieses_Jahr__c).replace('.',',').replace(',00', ',-')+' EUR';
			hoteldaten.beginn = bestellung.seminar__r.seminarBeginn__c.format();
			hoteldaten.ende = bestellung.seminar__r.seminarEnde__c.format();
		
		
			seminarYearList = new List<SelectOption>();
			for(Integer i = 0; i< 2; i++){
				seminarYearList.add(new SelectOption(String.valueOf(bestellung.seminar__r.seminarBeginn__c.year()+i), String.valueOf(bestellung.seminar__r.seminarbeginn__c.year()+i)));
			}
			
			ankunftday = String.valueOf((bestellung.seminar__r.seminarBeginn__c-1).day());
			ankunftmonth = String.valueOf((bestellung.seminar__r.seminarBeginn__c-1).month());
			ankunftyear = String.valueOf((bestellung.seminar__r.seminarBeginn__c-1).year());
			
			abreiseday = String.valueOf((bestellung.seminar__r.seminarEnde__c).day());
			abreisemonth = String.valueOf((bestellung.seminar__r.seminarEnde__c).month());
			abreiseyear = String.valueOf(bestellung.seminar__r.seminarEnde__c.year());
			preise = new Preise();
			preise.einzelpreis = String.valueOf(bestellung.Einzelpreis_Seminar__c).replace('.',',').replace(',00',',-');
			preise.summe = String.valueOf(bestellung.Einzelpreis_Seminar__c).replace('.',',').replace(',00',',-');
			preise.gesamtpreisZahl = bestellung.Einzelpreis_Seminar__c;
			if(bestellung.teilnehmer2__c != null){
				preise.gesamtpreisZahl = bestellung.Einzelpreis_Seminar__c*2;
				preise.summe = String.valueOf(bestellung.Einzelpreis_Seminar__c*2).replace('.',',').replace(',00',',-');
			}
			
			preise.mwst = String.valueOf(((preise.gesamtpreisZahl*19).round())/100+0.00).replace('.',',').replace(',00',',-');
			preise.gesamtpreis = String.valueOf(((preise.gesamtpreisZahl*119).round())/100+0.00).replace('.',',').replace(',00',',-');
		
			if(bestellung.Hotel_Reservierung__c){
				hotelBuchungsText = 'Sie haben '+ bestellung.Anzahl_EZ__c+' EZ und ' + bestellung.Anzahl_DZ__c +' DZ vom '+bestellung.Anreise__c.format()+' bis '+bestellung.Abreise__c.format()+' reserviert. Übernachtungen sind nicht im Preis enthalten, bitte zahlen Sie diese direkt vor Ort.';
			}else{
				hotelBuchungsText = 'Sie haben kein Hotelzimmer reserviert.';
			}
		}
		
		
		
	}
	
	
	public PageReference save0(){
		try{
			if(seminarCode=='' || seminarCode == null){
				throw new ValidationException();
			}
			return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00015')+'&seminarCode='+seminarCode);
			
		}catch(Exception e){
			return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00014')+'&error=1');
		}
	}
	public PageReference save1(){
		try{
			teilnehmer1.Geburtsdatum__c = Date.valueOf(t1byear+'-'+t1bmonth+'-'+t1bday);
			teilnehmer2.Geburtsdatum__c = Date.valueOf(t2byear+'-'+t2bmonth+'-'+t2bday);
			
			if(teilnehmer1.Company =='') teilnehmer1.Company = 'Privat';
			if(teilnehmer2.Company =='') teilnehmer2.Company = 'Privat';
			
			if(teilnehmer1.LastName=='' | teilnehmer1.FirstName==''){
				throw new ValidationException();
			}
			
			insert teilnehmer1;
			
			if(bestellung.Buchungstyp__c==''){
				throw new ValidationException();
			}
			
			
			
			
			
			if(teilnehmer2.FirstName != '' && teilnehmer2.LastName != '') {
				insert teilnehmer2;
				bestellung.Teilnehmer2__c = teilnehmer2.id;
			}
			bestellung.Teilnehmer1__c = teilnehmer1.id;
			
			bestellung.seminar__c = buchungsSeminar;
			insert bestellung;
			
			
				return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00019')+'&bid='+bestellung.id);
			
			
			
		}catch(Exception e){
			return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00015')+'&error=1&seminarCode='+seminarCode);
		}
	}
	
	
	public PageReference save2(){
		try{
			
		
			if(bestellung.Anzahl_DZ__c+bestellung.Anzahl_EZ__c<1){
				bestellung.Hotel_Reservierung__c = false;
			}else{
				bestellung.Hotel_Reservierung__c = true;
			}
			bestellung.anreise__c = Date.valueOf(ankunftyear+'-'+ankunftmonth+'-'+ankunftday);
			bestellung.abreise__c = Date.valueOf(abreiseyear+'-'+abreisemonth+'-'+abreiseday);
			
			update bestellung;
			
			return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00020')+'&bid='+bestellung.id);
		}catch(Exception e){
			return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00019')+'&error=1&bid='+bestellung.id);
		}
	}
	
	
	public PageReference save3(){
			try{
				
				if(!bestellung.eMail__c.contains('@') ||bestellung.Strasse__c ==null || bestellung.PLZ__c == null || bestellung.ort__c ==null || bestellung.Telefon__c ==null|| bestellung.eMail__c == null){
					throw new ValidationException();
				}
				update bestellung;
				
				return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00021')+'&bid='+bestellung.id);
			}catch(Exception e){
				return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00020')+'&error=1&bid='+bestellung.id);
			}
	}
	
	public PageReference save4(){
		try{
		if(!bestellung.AGB_akzeptiert__c){
			throw new ValidationException();
		}
		update bestellung;
		return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00022'));
		}catch(Exception e){
			return new PageReference('/apex/page?pageid='+WebURLEncoder.getPageIdById('p-00021')+'&error=1&bid='+bestellung.id);
		}
		
	}
	
	
	
	public class HotelDaten {
		public String preisEZ {get; set;}
		public String preisDZ {get; set;}
		public String beginn {get; set;}
		public String ende {get; set;}
	}
	
	public class Preise {
		public String einzelpreis {get;set;}
		public String summe {get;set;}	
		public String mwst {get;set;}
		public Decimal gesamtpreisZahl {get; set;}
		public String gesamtpreis {get;set;}
	}
	
	public class ValidationException extends Exception {
		/*public ValidationException(){
			this.setMessage('Fehler');
		}*/
	}
	
	
}