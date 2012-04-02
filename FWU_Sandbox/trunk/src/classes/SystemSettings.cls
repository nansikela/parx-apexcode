public class SystemSettings {
	public static final Boolean isDebug=false;
	public static final String STANDARDPRICEBOOKNAME='Standard Price Book';
	private static list<ErrorLog__c> errors = new list<ErrorLog__c>();
	public static set<Integer> Lagerabgang = new set<Integer>{0, 4, 8};
	public static set<Integer> Lagerzugang = new set<Integer>{1, 5};
	public static set<Integer> DebSoll = new set<Integer>{0, 8, 9}; 
	public static set<Integer> DebHaben=new set<Integer>{1, 7};
	public static list<Integer> RechnungsArt09 = new list<Integer>{1, 79999};
	public static list<Integer> RechnungsArt17 = new list<Integer>{80000, 89999};
	public static list<Integer> RechnungsArt36 = new list<Integer>{99000, 99999};
	public static list<Integer> RechnungsArt458 = new list<Integer>{90000, 98999};
	
	
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
	
	public static void sendInformationalEmailToUser(String subjectmsg, String message) {
		System.debug('PARX send mail to Systemdeveloper with exception message');
		User u=[SELECT Id, Email, Name FROM User WHERE Id = :UserInfo.getUserId()];
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		// Strings to hold the email addresses to which you are sending the email.
		String[] toAddresses = new String[] {u.Email};
		String[] bccAddresses = new String[] {'salesforce@parx.de'};
		mail.setToAddresses(toAddresses);
		mail.setBccAddresses(bccAddresses);
		mail.setReplyTo('salesforce@parx.de');
		mail.setSenderDisplayName('Salesforce Fehlerbenachrichtigung');
		mail.setSubject('Salesforce APEX Fehler ' + subjectmsg);
		mail.setPlainTextBody('Hallo ' + u.Name + ' Es gab einen Fehler bei der Datenverarbeitung in Salesforce: ' + message);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
	public static void logError(String message, String job, String component, String errorid, String loglevel) {
		if (message!=null) {
			System.debug('PARX logError ' + ' Job: ' + job + ' Component: ' + component + ' errorid: ' + errorid + ' message: ' +message);
			ErrorLog__c el=new ErrorLog__c();
			el.ErrorMsg__c=message;
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
				errors.clear();
			} catch (System.Dmlexception e) {
				sendApexWarnEmail('Error creating ErrorLog entry: ' + e.getMessage());
			}
		}
	}


}