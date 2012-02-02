public class onRechnung {
	public static void onInsert(list<Rechnung__c> trigg, boolean comeFromGutschriftRueckrechnung) {
		list<Nummernkreis__c> NummerKreis;
		try {
		NummerKreis = new list<Nummernkreis__c>([Select Id, Nummer__c from Nummernkreis__c]);
	 	}
		catch (system.Queryexception e) {
			system.debug('EXCEPTION !!!');
		}
		if(NummerKreis.size() < 4) {  //it should be 4 
			try {
			delete NummerKreis; }
			catch (system.Dmlexception e) {
				system.debug('EXCEPTION !!!');
			}
				NummerKreis = new list<Nummernkreis__c>();
			Nummernkreis__c temp;
			for(Integer x=0;x<4;x++) {
				temp = new Nummernkreis__c();
				temp.Nummer__c = 0;
				NummerKreis.add(temp);
			}
			try {
			insert NummerKreis;}
			catch (system.Dmlexception e) {
				system.debug('EXCEPTION !!!');
			}
		}
		//for(integer i=0;i<NummerKreis.size();i++) {  // if we are out of the limits, we check for every new rechnung
		//	if(i == 0) {
		//		if(NummerKreis.get(i).Nummer__c < SystemSettings.RechnungsArt09[0] || NummerKreis.get(i).Nummer__c > SystemSettings.RechnungsArt09[1])
		//		      NummerKreis.get(i).Nummer__c = SystemSettings.RechnungsArt09[0];
		//	}
		//	if(i == 1) {
		//		if(NummerKreis.get(i).Nummer__c < SystemSettings.RechnungsArt17[0] || NummerKreis.get(i).Nummer__c > SystemSettings.RechnungsArt17[1])
		//		      NummerKreis.get(i).Nummer__c = SystemSettings.RechnungsArt17[0];
		//	}	
		//	if(i == 2) {
		//		if(NummerKreis.get(i).Nummer__c < SystemSettings.RechnungsArt36[0] || NummerKreis.get(i).Nummer__c > SystemSettings.RechnungsArt36[1])
		//		      NummerKreis.get(i).Nummer__c = SystemSettings.RechnungsArt36[0];
		//	}
		//	if(i == 3) {
		//		if(NummerKreis.get(i).Nummer__c < SystemSettings.RechnungsArt458[0] || NummerKreis.get(i).Nummer__c > SystemSettings.RechnungsArt458[1])
		//		      NummerKreis.get(i).Nummer__c = SystemSettings.RechnungsArt458[0];
		//	}
		//}
	
		for(Rechnung__c trig:trigg) {   //we set the right invoice number for the rechnung according to the rechnungsart
			if(comeFromGutschriftRueckrechnung) { //it is for the gutschrift or rueckrechnung: we are in the interval 80000-89999
				Integer length = string.valueof(NummerKreis.get(1).Nummer__c.intValue()).length();
				trig.nummer_Rechnung__c = '';
				for(Integer i = length; i < 5; i++) {
					trig.nummer_Rechnung__c += '0';
				}
				trig.nummer_Rechnung__c += string.valueof(NummerKreis.get(1).Nummer__c.intValue());
				trig.nummer_Rechnung__c = Trig.nummer_Rechnung__c.substring(4,trig.nummer_Rechnung__c.length());
				NummerKreis.get(1).Nummer__c ++;
			}
			else if(trig.REA211__c == 0 || trig.REA211__c == 9) { 
				Integer length = string.valueof(NummerKreis.get(0).Nummer__c.intValue()).length();
				trig.Name = '';
				
				for(Integer i = length; i < 5; i++) {
					trig.Name += '0';
				}
				trig.Name += string.valueof(NummerKreis.get(0).Nummer__c.intValue());
				trig.Name = Trig.Name.substring(4,trig.Name.length());
				NummerKreis.get(0).Nummer__c ++;
			}
			else if(trig.REA211__c == 1 || trig.REA211__c == 7) { 
				Integer length = string.valueof(NummerKreis.get(1).Nummer__c.intValue()).length();
				trig.Name = '';
				for(Integer i = length; i < 5; i++) {
					trig.Name += '0';
				}
				trig.Name += string.valueof(NummerKreis.get(1).Nummer__c.intValue());
				trig.Name = Trig.Name.substring(4,trig.Name.length());
				NummerKreis.get(1).Nummer__c ++;
			}
			else if(trig.REA211__c == 3 || trig.REA211__c == 6) { 
				Integer length = string.valueof(NummerKreis.get(2).Nummer__c.intValue()).length();
				trig.Name = '';
				for(Integer i = length; i < 5; i++) {
					trig.Name += '0';
				}
				trig.Name += string.valueof(NummerKreis.get(2).Nummer__c.intValue());
				trig.Name = Trig.Name.substring(4,trig.Name.length());
				NummerKreis.get(2).Nummer__c ++;
			}
			else if(trig.REA211__c == 4 || trig.REA211__c == 5 || trig.REA211__c == 8) { 
				Integer length = string.valueof(NummerKreis.get(3).Nummer__c.intValue()).length();
				trig.Name = '';
				for(Integer i = length; i < 5; i++) {
					trig.Name += '0';
				}
				trig.Name += string.valueof(NummerKreis.get(3).Nummer__c.intValue());
				trig.Name = Trig.Name.substring(4,trig.Name.length());
				NummerKreis.get(3).Nummer__c ++;
			}
		}
		
		for(integer i=0;i<NummerKreis.size();i++) {  // if we are out of the limits, we check for every new rechnung
			if(i == 0) {
				if(NummerKreis.get(i).Nummer__c < SystemSettings.RechnungsArt09[0] || NummerKreis.get(i).Nummer__c > SystemSettings.RechnungsArt09[1])
				      NummerKreis.get(i).Nummer__c = SystemSettings.RechnungsArt09[0];
			}
			if(i == 1) {
				if(NummerKreis.get(i).Nummer__c < SystemSettings.RechnungsArt17[0] || NummerKreis.get(i).Nummer__c > SystemSettings.RechnungsArt17[1])
				      NummerKreis.get(i).Nummer__c = SystemSettings.RechnungsArt17[0];
			}	
			if(i == 2) {
				if(NummerKreis.get(i).Nummer__c < SystemSettings.RechnungsArt36[0] || NummerKreis.get(i).Nummer__c > SystemSettings.RechnungsArt36[1])
				      NummerKreis.get(i).Nummer__c = SystemSettings.RechnungsArt36[0];
			}
			if(i == 3) {
				if(NummerKreis.get(i).Nummer__c < SystemSettings.RechnungsArt458[0] || NummerKreis.get(i).Nummer__c > SystemSettings.RechnungsArt458[1])
				      NummerKreis.get(i).Nummer__c = SystemSettings.RechnungsArt458[0];
			}
		}
		
		try {
			update NummerKreis;  }//we update the full invoice number
		catch (system.Dmlexception e) {
			system.debug('EXCEPTION !!!');
		}
		
	}
}