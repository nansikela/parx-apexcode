/**
 * @author Christian Deckert
 * @date 18/08/2011
 * @description Firmenakademie Helper. Ausgabe von aktuellem Nutzer / Firma / Portfolio a.s.o.
 * @author Christian Deckert
 * @version 1.0
 */
public class FAHelper 
{
	private static Person__c currentPerson;
	private static Firma__c currentFirma;
	private static List<Bereich__c> bereichList;
	private static List<Portfolio2__c> portfolioList;
	public static boolean userIsTemp;
	
	/** 
     * @author Christian Deckert
	 * @date 18/08/2011
	 * @description Liefert aktuellen Nutzer zurück als Person__c zurück.
     * @return current Person
     */
	public static Person__c getCurrentPerson()
	{
		
		if(currentPerson== null)
		{
			if(FAIdentityManagement.getPersonCookie() != null)
			{
				List<Person__c> p = [Select p.Id, strasse__c, ort__c, Land__c, plz__c, Titel__c, Personaler_Firma__c, Company__c,  name, Telefon__c, Funktion__c, Geburtsdatum__c, Genehmigungsverfahren_ausgeschlossen__c, Abteilung__c,  anrede__c, Vorname__c, Firma__c, eMail_Adresse_Vorgesetzter__c, Vorgesetzer__c, Firma__r.id, Firma__r.name, Email__c From Person__c p WHERE id = :FAIdentityManagement.getPersonCookie() LIMIT 1];
				if(p.size()>0)
				{
					userIsTemp = false;
					return currentPerson = p.get(0);
				}
			}
			else
			{
				List<Person__c> p = [Select p.Id, Titel__c, Funktion__c, Geburtsdatum__c, Personaler_Firma__c,  name, Telefon__c, Genehmigungsverfahren_ausgeschlossen__c, Abteilung__c,  anrede__c, Vorname__c, Firma__c, eMail_Adresse_Vorgesetzter__c, Vorgesetzer__c, Firma__r.id, Firma__r.name, Email__c From Person__c p WHERE Benutzer__r.id = : getUserId() LIMIT 1];
				if(p.size()>0)
				{
					userIsTemp = false;
					currentPerson = p.get(0);
				}
				else
				{
					currentPerson = [Select id, Titel__c, Personaler_Firma__c,  name, Telefon__c, Genehmigungsverfahren_ausgeschlossen__c, Abteilung__c,  anrede__c, Vorname__c, Firma__c, eMail_Adresse_Vorgesetzter__c, Vorgesetzer__c, Firma__r.id, Firma__r.name, Email__c, recordTypeId From Person__c p WHERE p.eMail__c = 'website@die-akademie.de'];
					userIsTemp = true;
					return currentPerson;
				}
				//currentPerson = null;
				//return getCurrentPerson();
			}
		}
		return currentPerson;
	}
	
	
	
	/** 
     * @author Christian Deckert
	 * @date 18/08/2011
	 * @description Liefert Firma__c des aktuellen Nutzers zurück
     * @return current Firma
     */
	public static Firma__c getCurrentFirma()
	{
		Person__c person = getCurrentPerson();
		System.debug('**********PERSON:'+person);
		if(currentFirma == null && person != null && person.Firma__c != null)
		{
			currentFirma = person.Firma__r;
		}
		return currentFirma;
	}
	
	/** 
     * @author Christian Deckert
	 * @date 18/08/2011
	 * @description Liefert userId des eingeloggten Nutzers zurück
     * @return User.id
     */
	public static ID getUserId()
	{
		return UserInfo.getUserId();
	}
	/** 
     * @author Christian Deckert
	 * @date 18/08/2011
	 * @description Liefert Bereiche "Register" für die aktuelle Firma zurück
     * @return List of bereich__c
     */
	public static List<Bereich__c> getBereichList()
	{
		Firma__c tempFirma = getCurrentFirma();
		System.debug('**********tempFirma:'+tempFirma);
		if(bereichList == null && tempFirma!= null)
		{
			bereichList = new List<Bereich__c>();
			bereichList = [SELECT ID, name, Beschreibung__c, Hauptbereich__c FROM Bereich__c WHERE Firma__c = : tempFirma.id ORDER BY Anordnung__c];
			if(bereichList.size()== 0)
			{
				bereichList = null;
			}
		}
		return bereichList;
	}
	/** 
     * @author Christian Deckert
	 * @date 18/08/2011
	 * @description Liefert Portfolios zurück, die für die aktuelle Firma relevant sind
     * @return List of Portfolio2__c
     */
	public static List<Portfolio2__c> getPortfolioList()
	{
		List<Bereich__c> tempBereichList = getBereichList();
		if(portfolioList == null && tempBereichList != null)
		{
			Set<String> bereichIdSet = new Set<String>();
			for(Bereich__c b:tempBereichList)
			{
				bereichIdSet.add(b.id);
			}
			System.debug('**********bereichIdSet:'+bereichIdSet);
			portfolioList = [SELECT ID, name, neu__c, Englisch__c, Seminartitel__c, Bereich__c, url__c, Inhouse_Seminar__c  FROM Portfolio2__c WHERE Bereich__c IN : bereichIdSet AND Live__c = true ORDER BY Anordnung__c,Bereich__r.Anordnung__c LIMIT 1000];
			if(portfolioList.size()== 0)
			{
				portfolioList = null;
			}
		}
		return portfolioList;
	}
	/** 
     * @author Christian Deckert
	 * @date 18/08/2011
	 * @description Generates Token
     * @return Token String
     */
	public static String generateToken()
	{
		String secret = 'Ii/)~*5W#%?];Lp';
		Blob keyblob = Blob.valueOf(String.valueOf(DateTime.now())+secret);
			Blob key = Crypto.generateDigest('MD5',keyblob);
			String token = EncodingUtil.convertToHex(key);
			if(token.length()>30)
			{
				token = token.subString(0,29);
			}
			return token;
	}
	/** 
     * @author Christian Deckert
	 * @date 18/08/2011
	 * @description  Generates new Single eMail Message with standard Data
     * @return eMail Message
     */
	public static Messaging.SingleEmailMessage getNewMailFromAkademie(String toEMailAddress)
	{
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[]{toEMailAddress};
		mail.setToAddresses(toAddresses);
		mail.setOrgWideEmailAddressId('0D220000000Kz6y');
        mail.setReplyTo('christina.karschti@ag.vossloh.com');
        //mail.setSenderDisplayName('Christina Karschti');
        
        String[] bccAddresses = new String[]{'support.customer+AnmeldungenDieAkademie@parx.com', 'cbrede@die-akademie.de', 'rvochezer@die-akademie.de'};
		mail.setBccAddresses(bccAddresses);
        return mail;
	}
	
	/** 
     * @author Christian Deckert
	 * @date 18/08/2011
	 * @description  Liefert Produktgruppen zurück falls aktuell eine Produktgruppe ausgewählt ist.
     * @return Gruppe__c
     */
	public static Gruppe__c getCurrentProduktGruppe()
	{
		List<Gruppe__c> preisgruppeList = [SELECT Id, Name, Beschreibung_2__c, Preisinformation__c, Ansprechpartner__c, Ansprechpartner__r.name, Ansprechpartner__r.Vorname__c, Ansprechpartner__r.eMail__c, Ansprechpartner__r.Telefon__c,  Buchbar__c, Beschreibung__c, Name__c, ShortInfo__c, url__c, (Select Portfolio2__c, Portfolio2__r.name, Portfolio2__r.Seminartitel__c, Portfolio2__r.Url__c From Produktgruppenmitglieder__r WHERE Anzeigen_als_Modul__c = true ORDER BY Anordnung__c)  FROM Gruppe__c WHERE Id = :ApexPages.currentPage().getParameters().get('groupId')];
		if( preisgruppeList.size()>0 )
		{
			return preisgruppeList.get(0);
		}
		return null;
	}
	
	
	static testMethod void testFaHelper() {
		
		
		Person__c p = [SELECT Benutzer__c, Benutzer__r.id FROM Person__c WHERE Benutzer__c != null LIMIT 1];
		User u = p.Benutzer__r;
		System.runAs(u){
			getPortfolioList();
			generateToken();
		}
	}
	/** 
     * @author Christian Deckert
	 * @date 18/08/2011
	 * @description  Liefert anzahl der Objekte im Warenkorb zurück
     * @return Warenkorb Anzahl as Integer
     */
	public static Integer getWarenkorbAnzahl()
	{
		Warenkorb w = Warenkorb.getInstance();
		return w.countElements();
	}
	
	
}