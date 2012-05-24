public class systemHelper {
	public static Boolean isDebug=false;
	
	private static map<String, String> mapPauschal= new map<String, String>();
	private static map<String, String> mapCoachingActivity= new map<String, String>();
	private static map<String, String> mapAbklaerungPauschal = new map<String, String>();
	private static map<String, String> mapVerrechenbareLeistungen = new map<String, String>();
	private static set<String> setNachAufwandGKPK = new set<String>();
	private static list<ErrorLog__c> errors = new list<ErrorLog__c>();
	
	public static set<String> getSetNachAufwandGKPK() {
		if (setNachAufwandGKPK.isEmpty()) {
			setNachAufwandGKPK.add('Nach Aufwand Geschäftskunde');
			setNachAufwandGKPK.add('Nach Aufwand Privatkunde');
			setNachAufwandGKPK.add('Nach Aufwand Variabel');
		}
		return setNachAufwandGKPK;
	}
	
	public static map<String, String> getMapPauschal() {
		if (mapPauschal.isEmpty()) {
			// CR NP
			//mapPauschal.put('Pauschale A','Pauschale A');
			//mapPauschal.put('Pauschale B','Pauschale B');
			//mapPauschal.put('Pauschale C','Pauschale C');
			mapPauschal.put('Seminar Pauschale','Seminar Pauschale');
			mapPauschal.put('Coaching Pauschale','Coaching Pauschale');
			mapPauschal.put('Abklärung Pauschal','Abklärung Pauschal');
			//mapPauschal.put('Abklärung Pauschal Axa','Abklärung Pauschal Axa');
			mapPauschal.put('Abklärung pauschal kurz','Abklärung pauschal kurz');
		}
		return mapPauschal;
	}
	
	public static map<String, String> getMapCoachingActivity() {
		if (mapCoachingActivity.isEmpty()) {
			mapCoachingActivity.put('Coaching','Coaching');
			mapCoachingActivity.put('Coaching incl. Vor- und Nachbereitung','Coaching incl. Vor- und Nachbereitung');
			mapCoachingActivity.put('Coaching Intensivtage','Coaching Intensivtage');
			mapCoachingActivity.put('Standortgespräch','Standortgespräch');
			mapCoachingActivity.put('Teamabstimmung','Teamabstimmung');
			mapCoachingActivity.put('Vorbereitung / Nachbereitung','Vorbereitung / Nachbereitung');
			mapCoachingActivity.put('Administration','Administration');
			mapCoachingActivity.put('Kommunikation extern','Kommunikation extern');
			mapCoachingActivity.put('Lehrcoaching','Lehrcoaching');
			mapCoachingActivity.put('Seminar','Seminar');
			mapCoachingActivity.put('Supervision','Supervision');
			mapCoachingActivity.put('Sitzung','Sitzung');
			mapCoachingActivity.put('Berichterstellung','Berichterstellung');
			mapCoachingActivity.put('Wegentschädigung','Wegentschädigung');
			mapCoachingActivity.put('Aus-/Weiterbildung','Aus-/Weiterbildung');
		}
		return mapCoachingActivity;
	}
	
	public static map<String, String> getMapAbklaerungPauschal() {
		if (mapAbklaerungPauschal.isEmpty()) {
			mapAbklaerungPauschal.put('Abklärung Pauschal','Abklärung Pauschal');
			// CR NP
			//mapAbklaerungPauschal.put('Abklärung Pauschal Axa','Abklärung Pauschal Axa');
			mapAbklaerungPauschal.put('Abklärung pauschal kurz','Abklärung pauschal kurz');
		}
		return mapAbklaerungPauschal;
	}
	
	public static map<String, String> getMapVerrechenbareLeistungen() {
		if (mapVerrechenbareLeistungen.isEmpty()) {
			mapVerrechenbareLeistungen=getMapCoachingActivity();
			//mapVerrechenbareLeistungen.put('Fahrdienst','Fahrdienst');
			//mapVerrechenbareLeistungen.put('Wegentschädigung','Wegentschädigung');
			//mapVerrechenbareLeistungen.put('Infoline Pauschal Axa','Infoline Pauschal Axa');
		}
		return mapVerrechenbareLeistungen;
	}
		
	public static Boolean isVerrechenbareLeistung(String f) {
		Boolean retval=false;
		getMapVerrechenbareLeistungen();
		// moegliche Pauschalen:
		if (mapVerrechenbareLeistungen.containsKey(f))
			return true;
		else
			return false;
	}
		
	public static Boolean isPauschale(String f) {
		Boolean retval=false;
		getMapPauschal();
		// moegliche Pauschalen:
		if (mapPauschal.containsKey(f))
			return true;
		else
			return false;
	}
	
	public static Boolean isCoachingActivity(String f) {
		Boolean retval=false;
		getMapCoachingActivity();
		// moegliche "Coachings" (verrechenbare Leistungen):
		if (mapCoachingActivity.containsKey(f))
			return true;
		else
			return false;
	}


	public static Boolean isAbklaerungPauschal(String f) {
		Boolean retval=false;
		getMapAbklaerungPauschal();
		if (mapAbklaerungPauschal.containsKey(f))
			return true;
		else
			return false;
	}
	// Sonstiges
	public static void sendApexWarnEmail(String message) {
		System.debug('PARX send mail to Systemdeveloper with exception message');
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		// Strings to hold the email addresses to which you are sending the email.
		String[] toAddresses = new String[] {'salesforce@parx.de'};
		mail.setToAddresses(toAddresses);
		mail.setReplyTo('salesforce@parx.de');
		mail.setSenderDisplayName('Salesforce APEX Exception Handler');
		mail.setSubject('APEX Exception at ORG ' + UserInfo.getOrganizationId() + ' / ' + UserInfo.getOrganizationName());
		mail.setPlainTextBody('There was an exception by userid ' + UserInfo.getUserId() + ' (' + UserInfo.getUserName() + ') ' + ': ' + message);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
	public static void logError(String message, String job, String component, String errorid, String loglevel) {
		if (message!=null) {
			System.debug('PARX logError ' + ' Job: ' + job + ' Component: ' + component + ' errorid: ' + errorid + ' message: ' +message);
			ErrorLog__c el=new ErrorLog__c();
			if (message!=null) {
				if (message.length()<255)
					el.ErrorMsg__c=message!=null?message:'';
				else
					el.ErrorMsg__c=message.substring(0,255);
			}
			
			el.Job__c=job!=null?job:'';
			el.Component__c=component!=null?component:'';
			el.ErrorIdText__c=errorid!=null?errorid:'';
			el.LogLevel__c=loglevel!=null?loglevel:'';
			errors.add(el);
		}
	}
	
	public static void logError(String message, String job, String component, String errorid) {
		if (message!=null) {
			logError(message,job,component,errorid,'ERROR');
		}
	}
	
	public static void logError(String message) {
		if (message!=null) {
			logError(message,'','','','DEBUG');
		}
	}
	
	public static void logError(String message, String loglevel) {
		if (message!=null) {
			logError(message,'','','',loglevel);
		}
	}
	
	public static void insertErrors() {
		if (!errors.isEmpty()) {
			try {
				insert errors;
			} catch (System.Dmlexception e) {
				sendApexWarnEmail('Error creating ErrorLog entry: ' + e.getMessage());
			}
		}
	}
}