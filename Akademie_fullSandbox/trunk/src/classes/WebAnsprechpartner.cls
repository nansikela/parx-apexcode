public class WebAnsprechpartner {
	public String category {get; set;}
	public List <Ansprechpartner> ansprechpartner {get; set;}
	public Ansprechpartner miniAnsprechpartner {get; set;}
	
	
	public WebAnsprechpartner(){
		ansprechpartner = new List <Ansprechpartner>();
		category = WebURLEncoder.decodeParam('category');
		Ansprechpartner item = new Ansprechpartner();
		if(category != '' || category != null){
			if(category == 'Führung'){
				
				
				item = new Ansprechpartner();
				item.name = 'Martin Sens';
				item.bereich ='Ihr Ansprechpartner für <ul class = "list"><li style="padding-bottom: 0px;"> Erfahrene Führungskräfte</li><li style="padding-bottom: 0px;">Führungskräfte aller Ebenen</li><li style="padding-bottom: 0px;">	Neu in Führung</li></ul>';
				item.telefon = '+49.7551.9368-122';
				item.eMail = 'msens@die-akademie.de';
				item.bildURL = 'MartinSens.jpg';
				ansprechpartner.add(item);
			}
			
			if(category == 'Strategie und Organisationsentwicklung'){
				item = new Ansprechpartner();
				item.name = 'Stephan Kopietz';
				item.bereich ='Ihr Ansprechpartner für <ul class = "list"><li style="padding-bottom: 0px;">Strategie</li><li style="padding-bottom: 0px;">	Organisationsentwicklung</li></ul>';
				item.telefon = '+49.7551.9368-127';
				item.eMail = 'skopietz@die-akademie.de';
				item.bildURL = 'StephanKopietz.jpg';
				ansprechpartner.add(item);
				
				
				
				item = new Ansprechpartner();
				item.name = 'Martin Sens';
				item.bereich ='Ihr Ansprechpartner für <ul class = "list"><li style="padding-bottom: 0px;">	Organisationsentwicklung</li></ul>';
				item.telefon = '+49.7551.9368-122';
				item.eMail = 'msens@die-akademie.de';
				item.bildURL = 'MartinSens.jpg';
				ansprechpartner.add(item);
				
			}
			
			if(category == 'Fachkompetenz'){
				
				
				
				
				item = new Ansprechpartner();
				item.name = 'Stephan Kopietz';
				item.bereich ='Ihr Ansprechpartner für <ul class = "list"><li style="padding-bottom: 0px;">Projektmanagement</li><li style="padding-bottom: 0px;">Finanzen und Controlling</li><li style="padding-bottom: 0px;">Marketing und Produktmanagement</li><li style="padding-bottom: 0px;">Vertrieb</li><li style="padding-bottom: 0px;">Office Management</li></ul>';
				item.telefon = '+49.7551.9368-127';
				item.eMail = 'skopietz@die-akademie.de';
				item.bildURL = 'StephanKopietz.jpg';
				ansprechpartner.add(item);
			}
			
			if(category == 'Persönlichkeitsentwicklung'){
				item = new Ansprechpartner();
				item.name = 'Stephan Kopietz';
				item.bereich ='Ihr Ansprechpartner für <ul class = "list"><li>Selbstmanagement</li></ul>';
				item.telefon = '+49.7551.9368-127';
				item.eMail = 'skopietz@die-akademie.de';
				item.bildURL = 'StephanKopietz.jpg';
				ansprechpartner.add(item);
				
				
				
				item = new Ansprechpartner();
				item.name = 'Martin Sens';
				item.bereich ='Ihr Ansprechpartner für <ul class = "list"><li>Kommunikation</li><li>Tools und Techniken</li></ul>';
				item.telefon = '+49.7551.9368-122';
				item.eMail = 'msens@die-akademie.de';
				item.bildURL = 'MartinSens.jpg';
				ansprechpartner.add(item);
				
				
			}
			if(category == WebConfig.AUSBILDUNGEN){
				
				item = new Ansprechpartner();
				item.name = 'Martin Sens';
				item.bereich ='Ihr Ansprechpartner für <ul class = "list"><li>General Management Programm</li></ul>';
				item.telefon = '+49.7551.9368-122';
				item.eMail = 'msens@die-akademie.de';
				item.bildURL = 'MartinSens.jpg';
				ansprechpartner.add(item);
				
				item = new Ansprechpartner();
				item.name = 'Silvia Ufer';
				item.bereich ='Ihre Ansprechpartnerin für <ul class = "list"><li style="padding-bottom: 0px;">Coaching</li></ul>';
				item.telefon = '+49.7551.9368-180';
				item.eMail = 'sufer@die-akademie.de';
				item.bildURL = 'SilviaUfer.jpg';
				ansprechpartner.add(item);
				
				
				item = new Ansprechpartner();
				item.name = 'Thorsten Wulf';
				item.bereich ='Ihr Ansprechpartner für <ul class = "list"><li style="padding-bottom: 0px;">Trainerausbildung</li></ul>';
				item.telefon = '+49.7551.9368-182';
				item.eMail = 'twulf@die-akademie.de';
				item.bildURL = 'ThorstenWulf.jpg';
				ansprechpartner.add(item);
				
			}
			
			
			
			
			
		}
		
	}
	
	public class Ansprechpartner {
		public String name {get; set;}
		public String bereich {get; set;}
		public String telefon {get; set;}
		public String eMail {get; set;}
		public String bildURL {get; set;}
	}
	
}