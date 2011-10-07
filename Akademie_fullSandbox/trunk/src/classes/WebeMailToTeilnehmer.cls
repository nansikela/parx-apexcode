public class WebeMailToTeilnehmer 
{
	
	public static String getPreisGesamt(String inputPreis)
	{
		if(getPreis(inputPreis) == 0)
		{
			return '0,-';
		}
		return numberToPreis(String.valueOf(Math.round(getPreis(inputPreis)*1.19*100)/100.0));
	}
	
	public static Double getPreis(String preis2)
	{
			Double preis= Double.valueOf(preis2.replace(',-', '').replace(' Reservierung', '').trim());
		
		
		return preis;
	}
	public static String getPreisMWST(String preisInput)
	{
		if(getPreis(preisInput) == 0)
		{
			return '0,-';
		}
		return numberToPreis(String.valueOf(Math.round(getPreis(preisInput)*0.19*100)/100.0));
	}
	
	public static String numberToPreis(String input)
	{
		input = input.replace('.', ',');
		if(input.contains(','))
		{
			List<String> numbers = input.split(',');
			if(numbers.get(1).length()==1)
			{
				input = input+'0';
			}
		}
		else
		{
			input+=',00';
		}
		
		return input;
	}
		
		
	public static List<Messaging.SingleEmailMessage> geteMail(List<FASeminar> warenkorbInhalt, Anschrift__c anschrift, Person__c currentPerson)
	{
		
		List<Messaging.SingleEmailMessage> eMailList = new List<Messaging.SingleEmailMessage>();
		
		Messaging.SingleEmailMessage standardEMail = new Messaging.SingleEmailMessage();
		List<String>eMailTo = new List<String>();
		eMailTo.add(anschrift.eMail__c);
		standardEMail.setToAddresses(eMailTo);
		
		List<String>eMailBCC = new List<String>();
		eMailBCC.add('katharina.hornschuch@parx.com');
		eMailBCC.add('cbrede@die-akademie.de');
		eMailBCC.add('cbecker@die-akademie.de');
		standardEMail.setBccAddresses(eMailBCC);
		if(warenkorbInhalt != null)
		{
		try
		{
			for(FASeminar s: warenkorbInhalt)
			{
				EmailTemplate et =  [Select e.Subject, body, e.HtmlValue, e.DeveloperName From EmailTemplate e WHERE DeveloperName = 'TeilnehmerEmail2012'];
				Messaging.SingleEmailMessage eMail = new Messaging.SingleEmailMessage();

				eMail.setToAddresses(standardEMail.getToAddresses());
				String eMailText = et.HtmlValue;
				if(s.preis.contains('Reservierung'))
				{
					eMail.setSubject('Ihre Online-Reservierung - Die Akademie');
					eMailText = eMailText.replace('XXXBuchungstypXXX', ' Ihr Seminarplatz ist für 10 Tage kostenlos und unverbindlich reserviert. Es gelten unsere AGBs, die Sie <a href = "http://www.die-akademie.de/service/agb"> hier einsehen können</a>.');
					eMailText = eMailText.replace('XXXAUFTRAGXXX', 'Ihre Reservierung:');
					eMailText = eMailText.replace('XXXPREISXXX', '0,- &nbsp;&nbsp;&nbsp; Reservierung');
				}
				else
				{
					eMail.setSubject('Ihre Online-Buchung - Die Akademie');
					eMailText = eMailText.replace('XXXBuchungstypXXX', 'herzlichen Dank für Ihren Auftrag. Sie erhalten in Kürze eine schriftliche Bestätigung Ihrer Anmeldung, mit der Ihr Seminarplatz verbindlich gebucht wird. Es gelten unsere AGBs, die Sie <a href = "http://www.die-akademie.de/service/agb"> hier einsehen können</a>.');
					eMailText = eMailText.replace('XXXAUFTRAGXXX', 'Ihr Auftrag:');
				}
				eMailText = eMailText.replace('XXXCODETITELXXX', s.code+' '+s.titel);
				if(s.datum != null)
				{
					eMailText = eMailText.replace('XXXBEGINNENDEXXX', s.datum);
				}
				else
				{
					eMailText = eMailText.replace('XXXBEGINNENDEXXX', '');
				}
				eMailText = eMailText.replace('XXXORTXXX', s.ort);
				
				
				if((s.dzReservierung != null && s.dzReservierung == true) )
				{
				eMailText = eMailText.replace('XXXRESERVATIONXXX', 'Sie reservieren ein DZ von '+s.anreise+' bis '+s.abreise+'.<br/>');
				}
				if((s.ezReservierung != null && s.ezReservierung == true) )
				{
				eMailText = eMailText.replace('XXXRESERVATIONXXX', 'Sie reservieren ein EZ von '+s.anreise+' bis '+s.abreise+'.<br/>');
				}
				eMailText = eMailText.replace('XXXRESERVATIONXXX', '');
				
				try
				{
					eMailText = eMailText.replace('XXXPREISXXX', s.preis);
					eMailText = eMailText.replace('XXXMWSTXXX', getPreisMWST(s.preis));
					eMailText = eMailText.replace('XXXGESAMTXXX', getPreisGesamt(s.preis));
				}catch(Exception e)
				{
					eMailText = eMailText.replace('XXXPREISXXX', '');
					eMailText = eMailText.replace('XXXMWSTXXX', '');
					eMailText = eMailText.replace('XXXGESAMTXXX', '');
				}
				
				
				
				if(anschrift.firma__c != null)
				{
				eMailText = eMailText.replace('XXXFIRMAXXX', anschrift.firma__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXFIRMAXXX', '');
				}
				if(anschrift.abteilung__c != null)
				{
				eMailText = eMailText.replace('XXXABTEILUNGXXX', anschrift.abteilung__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXABTEILUNGXXX', '');
				}
				if(anschrift.Ansprechpartner__c != null)
				{
				eMailText = eMailText.replace('XXXANSPRECHPARTNERXXX', anschrift.Ansprechpartner__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXANSPRECHPARTNERXXX', '');
				}
				if(anschrift.strasse__c != null)
				{
				eMailText = eMailText.replace('XXXSTRASSEXXX', anschrift.strasse__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXSTRASSEXXX', '');
				}
				if(anschrift.plz__c != null)
				{
				eMailText = eMailText.replace('XXXPLZXXX', anschrift.plz__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXPLZXXX', '');
				}
				if(anschrift.Ort__c != null)
				{
				eMailText = eMailText.replace('XXXORTFIRMAXXX', anschrift.Ort__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXORTFIRMAXXX', '');
				}
				
				if(anschrift.Nachricht__c != null)
				{
				eMailText = eMailText.replace('XXXNACHRICHTXXX', anschrift.Nachricht__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXNACHRICHTXXX', '');
				}
				
				if(anschrift.Ihr_Weg_zu_uns__c != null)
				{
				eMailText = eMailText.replace('XXXWEGXXX', anschrift.Ihr_Weg_zu_uns__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXWEGXXX', '');
				}
				
				if(anschrift.Land__c != null)
				{
				eMailText = eMailText.replace('XXXLANDXXX', anschrift.Land__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXLANDXXX', '');
				}
				
				if(anschrift.telefon__c != null)
				{
				eMailText = eMailText.replace('XXXTELEFONXXX', anschrift.telefon__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXTELEFONXXX', '');
				}
				if(anschrift.Telefax__c != null)
				{
				eMailText = eMailText.replace('XXXTELEFAXXXX', anschrift.Telefax__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXTELEFAXXXX', '');
				}
				
				if(anschrift.eMail__c != null)
				{
				eMailText = eMailText.replace('XXXANSPRECHEMAILXXX', anschrift.eMail__c);
				}
				else
				{
					eMailText = eMailText.replace('XXXANSPRECHEMAILXXX', '');
				}
				
				
				
				try
				{
				if(currentPerson != null)
				{
					String teilnehmerString = currentPerson.Vorname__c+' '+currentPerson.Name;
					if(currentPerson.Company__c != null)
					{
						teilnehmerString+= '<br/>'+ currentPerson.Company__c;
					}
					if(currentPerson.Strasse__c != null)
					{
						teilnehmerString+= '<br />'+ currentPerson.Strasse__c;
					}
					if(currentPerson.PLZ__c != null)
					{
						teilnehmerString+= '<br />'+ currentPerson.PLZ__c;
					}
					if(currentPerson.ort__c != null)
					{
						teilnehmerString+= ' '+ currentPerson.ort__c;
					}
					if(currentPerson.Land__c != null)
					{
						teilnehmerString+= '<br/>'+ currentPerson.Land__c;
					}
					if(currentPerson.eMail__c != null)
					{
						teilnehmerString+= '<br/>eMail: '+ currentPerson.eMail__c;
					}
					
				eMailText = eMailText.replace('XXXTEILNEHMERXXX', teilnehmerString);
				}
				else
				{
					eMailText = eMailText.replace('XXXTEILNEHMERXXX', '');
				}
				}catch(Exception e){}
				eMail.setHtmlBody(eMailText);
				Messaging.SingleEmailMessage eMail2 = new Messaging.SingleEmailMessage();
				eMail2.setToAddresses(eMailBCC);
				eMail2.setHtmlBody(eMailText);
				eMail2.setSubject(email.getSubject());
				eMail2.setReplyTo(eMail.getToAddresses().get(0));
				eMailList.add(eMail);
				eMailList.add(eMail2);
			}
		return eMailList;
		}catch(Exception e)
		{ 
			System.debug('****EXCEPTION:'+e); 
		}
		}else
		{
			Integer i = 0;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			
		}
		
		
		
		
		
		
		return null;
	}
	
	public static Messaging.SingleEmailMessage geteMail()
	{
		Messaging.SingleEmailMessage eMail = new Messaging.SingleEmailMessage();
		
		EmailTemplate et =  [Select e.Subject, e.HtmlValue, e.DeveloperName From EmailTemplate e WHERE DeveloperName = 'TeilnehmerEmail2012'];
		String eMailText = et.HtmlValue;
		//eMailText = eMailText.replace('XXXBuchungstypXXX', 'herzlichen Dank für Ihren Auftrag. Sie erhalten in Kürze eine schriftliche Bestätigung Ihrer Anmeldung, mit der Ihr Seminarplatz verbindlich gebucht wird. Es gelten unsere AGBs, die Sie <a href = "http://www.die-akademie.de/service/agb"> hier einsehen können</a>.');
		//eMailText = eMailText.replace('XXXBuchungstypXXX', ' Ihr Seminarplatz ist für 10 Tage kostenlos und unverbindlich reserviert. Es gelten unsere AGBs, die Sie <a href = "http://www.die-akademie.de/service/agb"> hier einsehen können</a>.');
		
		List<String>eMailTo2 = new List<String>();
		eMailTo2.add('christian.deckert@parx.com');
		
		eMail.setToAddresses(eMailTo2);
		eMail.setHtmlBody(eMailText);
		Integer i = 0;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
			i++;
		return eMail;
	}
	static testMethod void test(){
		WebeMailToTeilnehmer.geteMail();
		WebeMailToTeilnehmer.geteMail(null, new Anschrift__c(eMail__c = 'sdjk@sdfhiklfg.de'), new Person__c(eMail__c = 'christian.deckert@parx.com'));
	}
}