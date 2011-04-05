public class InterfaceLinks {
	// Fixe Werte
	private static final String COUNTRY = 'de';
	private static final String UNIT = '1';
	private static final String SECRET = 'mJ724siW;'; 
	
    /**
     * Generiert eine URL, mit der der Benutzer 
     * auf ein anderes System (Bilderdatenbank) zugreifen kann, 
     * ohne sich erneut anzumelden. 
     */
    public static String generateStringTestTraining(String secrettext) {
    	  return encodeMD5(secrettext);

    } 
    public static String generatePictureURL() {
        String url = '';
        
        //Zufallszahl generieren 
        String random = generateRandomNumber();
        
        // Anfangs Link 
        String link = SystemSettings.picturemanagementLink;
        
        // Aktuelle Zeit
        Long timestamp = System.now().getTime();
         
        // Gigaset User Id
        String gigasetUserId = '';
        
        /******************** TODO *******************/
        /**  
        * Vom aktuellen Benutzer die KontakId holen
        */
        /******************** TODO *******************/ 
        String contactId = getUserContactId();      
        
        try {
        	// ID1__c von Kontakt holen, diese ist die Gigaset User Id
        	// und fuer die URL Generierung notwendig
			gigasetUserId=[select Id, ID__c from Contact where Id=:contactId].ID__c;
   		} catch (System.QueryException e) {
			// Der Kontakt besitzt keine ID1__c
			System.debug('PARX QueryException generatePictureURL (Kontakt besitzt keine ID1__c) ' + e.getMessage());
		}
   		
        // Den sogenannten secrettext erstellen
        if (gigasetUserId!='') {
	        String secrettext = UNIT + '-' + timestamp + '-' + gigasetUserId + '-' + SECRET
	                + '-' + COUNTRY;
	                
	        String closed = encodeMD5(secrettext); 
	        
	        // Anmeldeurl zusammensetzen 
	        url = createLink(link, random, closed, gigasetUserId, timestamp);
        }
        return url;
    }
    
    
    
     /**
     * Generiert eine URL, mit der der Benutzer 
     * auf ein anderes System (Werbemittel) zugreifen kann, 
     * ohne sich erneut anzumelden. 
     */
    public static String generateWebBasedTrainingURL() {
        String url = '';
        
        //Zufallszahl generieren 
        String random = generateRandomNumber();
        
        // Anfangs Link 
        String link = SystemSettings.werbemittelLink;
        
        // Aktuelle Zeit
        Long timestamp = System.now().getTime();
         
        // Gigaset Firma Id
        String gigasetFirmaId = '';
        
        
        /******************** TODO *******************/
        /**  
        * Vom aktuellen Benutzer die KontakId holen
        */
        /******************** TODO *******************/ 
        //String contactId = getUserContactId();
        ID contactId;
        try {
	    for (User u : [SELECT ContactId FROM User WHERE IsActive=true AND ContactId!=null AND Id=:UserInfo.getUserId() limit 1]) {
	    	if (u.ContactId!=null) contactid=u.ContactId;
	    }
        } catch (System.QueryException e) {
        	SystemSettings.logError('PARX QueryException generateWebBasedTrainingURL User besitzt keine ContactId ' + e.getMessage(),'DEInterfaceLinks','generateWebBasedTrainingURL','','ERROR');
        	if (SystemSettings.isDebug) throw e;
        }
        //ID contactId = [SELECT ContactId FROM User WHERE IsActive=true AND ContactId!=null AND Id=:UserInfo.getUserId() limit 1].ContactID;      
        if (contactid!=null) {
		try {
			// ID1__c von Kontakt holen, diese ist die Gigaset User Id
			// und fuer die URL Generierung notwendig
			Id accountId=[select AccountId from Contact where Id=:contactId].AccountId;
			if (accountId!=null) {
				try {
					gigasetFirmaId=[select ID1__c from Account where Id=:accountId].ID1__c;
				} catch (System.QueryException einner) {
					System.debug('PARX QueryException generateWebBasedTrainingURL (Kontakt oder Account besitzt kein ID1__c) ' + einner.getMessage());
					SystemSettings.logError('PARX QueryException generateWebBasedTrainingURL (Kontakt oder Account besitzt kein ID1__c) ' + einner.getMessage(),'DEInterfaceLinks','generateWebBasedTrainingURL','','WARN');
					if (SystemSettings.isDebug) throw einner;
				}
			}
		} catch (System.QueryException e) {
			// Der Account besitzt keine ID1__c
			System.debug('PARX QueryException generateWebBasedTrainingURL (Kontakt oder Account besitzt kein ID1__c) ' + e.getMessage());
			SystemSettings.logError('PARX QueryException generateWebBasedTrainingURL (Kontakt oder Account besitzt kein ID1__c) ' + e.getMessage(),'DEInterfaceLinks','generateWebBasedTrainingURL','','WARN');
			if (SystemSettings.isDebug) throw e;
		}
        }
   		
   	  if (gigasetFirmaId!='') {
	        // Den sogenannten secrettext erstellen
	        String secrettext = UNIT + '-' + timestamp + '-' + gigasetFirmaId + '-' + SECRET
	                + '-' + COUNTRY;
	                
	        String closed = encodeMD5(secrettext);
	        
	        // Anmeldeurl zusammensetzen 
	        url = createLink(link, random, closed, gigasetFirmaId, timestamp) + '&mode=CP';
   	  }
        
        return url;
        
    }
    
    /**
    * holt sich die contact id des angemeldeten Users
    */
    private static String getUserContactId() {
    	String contactid='';	
    	try {
    		contactid=[SELECT Contactid FROM User WHERE Id =:UserInfo.getUserId()].contactid;
    	} catch (System.QueryException e) {
    		System.debug('PARX QueryException generateWebBasedTrainingURL (Kontakt oder Account besitzt kein ID1__c) ' + e.getMessage());
    		SystemSettings.logError('PARX QueryException generateWebBasedTrainingURL (Kontakt oder Account besitzt kein ID1__c) ' + e.getMessage(),'DEInterfaceLinks','getUserContactId','','WARN');
    		if (SystemSettings.isDebug) throw e;
    	}
    	return contactid;
    }
    
    /**
    * Setzt den endgueltigen Link zusammen
    */
    private static String createLink(String startLink, String random, 
    										String closed, String id, 
    										Long timestamp) {
    											
    	return startLink + random + '&closed=' + closed + '&user='
                + id + '&unit=' + UNIT + '&ctry=' + COUNTRY + '&timestamp='
                + timestamp;
    }
    
    /**
    * Gibt den MD5 Hash-Wert des Eingabewertes zurueck 
    */
    private static String encodeMD5(String secrettext) {
    	
    	// MD5 Hashwert von secrettext generieren 
        Blob secrettextBlob = Blob.valueOf(secrettext);
        Blob secrettextMD5 = Crypto.generateDigest('MD5', secrettextBlob);
        
        // MD5 Hashwert in HEX umwandeln 
    	return EncodingUtil.convertToHex(secrettextMD5);
    }
    
    /**
    * Generiert eine dreistellige Zufallszahl
    */
    private static String generateRandomNumber(){
    	//Zufallszahl generieren 
        Integer randomnumber = Crypto.getRandomInteger() * 333;
        if(randomnumber < 0) {
            randomnumber = randomnumber *(-1);
        }
        // In String umwandeln und auf drei Stellen kuerzen
        String random = String.valueOf(randomnumber);
        random = random.substring(0,3);
        
        return random;
        
    }
    
    
    private static testMethod void test(){
        
        System.debug('/*************** PARX BEGIN TEST *****************/'); 
        
        /************ RANDOM NUMBER TEST ************/
        String randomNumber = generateRandomNumber();
		// Die Zufallszahl muss exakt 3 Ziffern besitzen
        System.assertEquals(randomNumber.length(), 3);
        
        Integer randomNumberInteger = Integer.valueOf(randomNumber);
        // Bei der Zuffallszahl muss es sich um eine positive Zahl handeln
        System.assert(randomNumberInteger > 0);
        /************ RANDOM NUMBER TEST ************/
        
        
        
        /************* ENCODE MD5 TEST *************/
        String encodedMD5Text = encodeMD5('PARX_GIGASET');
        // Der generierte Wert (rechte Seite) ist mit einem Java Programm erstellt worden 
        System.assertEquals(encodedMD5Text, 'c4e9bde3168a4bc9ef069a984246d524');		
        
        // Gegenpruefung						 
        System.assertNotEquals(encodedMD5Text, 'PARX_GIGASET');
        /************* ENCODE MD5 TEST *************/
        
        
        /*************** PICTURE URL KEIN TEST **************/
        String pictureURL = generatePictureURL();
        System.debug('Picture URL is: ' + pictureURL);
        /*************** PICTURE URL KEIN TEST **************/
        User u = [Select Id FROM User WHERE ContactId != null limit 1];
        System.debug('/***************'+u.ID+'*****************/');
        System.runAs(u){
        	InterfaceLinks ctrl = new InterfaceLinks();
     	   /*************** WERBEMITTEL URL KEIN TEST **************/
			String wbtURL = InterfaceLinks.generateWebBasedTrainingURL();
			//System.debug('WBT URL is: ' + wbtURL);
        	/*************** WERBEMITTEL URL KEIN TEST **************/
        	
        	System.assertEquals(generateStringTestTraining('test'), encodeMD5('test'));
        }
        System.debug('/*************** PARX END TEST *****************/');   
    }

}