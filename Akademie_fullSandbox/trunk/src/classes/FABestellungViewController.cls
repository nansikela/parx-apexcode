/**
* @author Christian Deckert
* @date 18/08/2011
* @description View Controller für Bestullungsanzeige / Storno Anzeige
*/
public class FABestellungViewController 
{
	public  List<Warenkorb_Element__c> warenkorbElementList {get; set;}
	public Warenkorb_Element__c stornoElement {get; set;}
	private static FABestellungViewController sigelton;
	
	public String stornoMessage {get; set;}
	
	public String elementForStorno {get; set;}
	
	public static FABestellungViewController getInstance()
	{
		if(sigelton == null)
		{
			sigelton = new FABestellungViewController();
		}
		return sigelton;
	}
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Konstruktor je nach Modus werden die korrekten Seminare ausgegeben
	*/
	public FABestellungViewController()
	{
		try{
		Person__c currentPerson = FAHelper.getCurrentPerson();
		if(WebURLEncoder.decodeParam('mode')== null || WebURLEncoder.decodeParam('mode')=='')
		{
		warenkorbElementList = [Select w.Seminarende__c, w.status__c, w.Seminarbeginn__c, w.Portfolio__r.url__c, w.Portfolio__r.Web_Preis__c, w.Portfolio__r.Seminartitel__c, w.Portfolio__c, w.Ort__c, w.Hotelreservierung__c, w.Hotel__c, w.EZ_Preis__c, w.DZ_Preis__c, w.Bestelltermin__c, w.Anreise__c, w.Abreise__c From Warenkorb_Element__c w WHERE Warenkorb__r.Person__c = :currentPerson.id AND w.status__c!= null AND w.warenkorb__r.status__c = 'Abgeschlossen' ORDER BY Seminarbeginn__c desc];
		}
		
		if(WebURLEncoder.decodeParam('mode')== 'abgeschlossen')
		{
		warenkorbElementList = [Select w.Seminarende__c, w.status__c, w.Seminarbeginn__c, w.Portfolio__r.url__c, w.Portfolio__r.Web_Preis__c, w.Portfolio__r.Seminartitel__c, w.Portfolio__c, w.Ort__c, w.Hotelreservierung__c, w.Hotel__c, w.EZ_Preis__c, w.DZ_Preis__c, w.Bestelltermin__c, w.Anreise__c, w.Abreise__c From Warenkorb_Element__c w WHERE Warenkorb__r.Person__c = :currentPerson.id AND w.status__c!= null AND w.warenkorb__r.status__c = 'Abgeschlossen' AND Seminarbeginn__c<today ORDER BY Seminarbeginn__c desc];
		}
		if(WebURLEncoder.decodeParam('mode')== 'zukuenftig')
		{
		warenkorbElementList = [Select id, w.Seminarende__c, w.status__c, w.Seminarbeginn__c, w.Portfolio__r.url__c, w.Portfolio__r.Web_Preis__c, w.Portfolio__r.Seminartitel__c, w.Portfolio__c, w.Ort__c, w.Hotelreservierung__c, w.Hotel__c, w.EZ_Preis__c, w.DZ_Preis__c, w.Bestelltermin__c, w.Anreise__c, w.Abreise__c From Warenkorb_Element__c w WHERE Warenkorb__r.Person__c = :currentPerson.id AND w.status__c!= null AND w.warenkorb__r.status__c = 'Abgeschlossen'  AND Seminarbeginn__c>=today AND (NOT w.status__c  Like '%Storno%') ORDER BY Seminarbeginn__c desc];
		}
		if(WebURLEncoder.decodeParam('mode')== 'storno')
		{
		warenkorbElementList = [Select id, w.Seminarende__c, w.status__c, w.Portfolio__r.Inhouse_seminar__c, w.Seminarbeginn__c, w.Portfolio__r.url__c, w.Portfolio__r.Web_Preis__c, w.Portfolio__r.Seminartitel__c, w.Portfolio__c, w.Ort__c, w.Hotelreservierung__c, w.Hotel__c, w.EZ_Preis__c, w.DZ_Preis__c, w.Bestelltermin__c, w.Anreise__c, w.Abreise__c, w.Stornogrund__c, w.Anderer_Stornogrund__c From Warenkorb_Element__c w WHERE Warenkorb__r.Person__c = :currentPerson.id AND w.status__c!= null AND w.warenkorb__r.status__c = 'Abgeschlossen' AND (NOT w.status__c LIKE '%Storno%') AND w.status__c = 'Warten auf Apporval durch Akademie' AND Seminarbeginn__c>=today ORDER BY Seminarbeginn__c desc];
		}
		
		for(Warenkorb_Element__c w : warenkorbElementList)
		{
			if(w.status__c =='Warten auf Approval von Vorgesetztem')
			{
				w.status__c = 'Warten auf die Vorgesetzten-Freigabe';
			}
			else if(w.status__c =='Warten auf Apporval durch Akademie')
			{
				w.status__c = 'Bestellung abgeschlossen';
			}
		}
		
		//Init Storno Element
		stornoElement = new Warenkorb_Element__c();
		}catch(Exception e)
		{
			System.debug('*****************************EX'+e);
		}
	}
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description SelectOptions (Seminare) für Storno werden erstellt
	* @return Liste von Selektoptions
	*/
	public List<SelectOption> getSelectOptions()
	{
		List<SelectOption> result = new List<SelectOption>();
		
		for(Warenkorb_Element__c w : warenkorbElementList)
		{
			String seminarBeginn = w.Seminarbeginn__c.format().replace('.20','.')+' - '+w.Seminarende__c.format().replace('.20','.');
			result.add(new SelectOption(String.valueOf(w.id), seminarBeginn+' '+w.Portfolio__r.Seminartitel__c));
		}
		return result;
	}
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Ist das Storno grundsätzlich möglich
	* @return ist storno möglich
	*/
	public boolean getIsStornoPossible()
	{
		return getSelectOptions().size()>0;
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Storno Message (Welche  Kosten fallen an?)
	* @return null
	*/
	public PageReference stornoMessage()
	{
		if(elementForStorno == 'no')
		{
			stornoMessage = 'noMessage';
			return null;
		}
		//Finde das WarenkorbElement
		for(Warenkorb_Element__c w : warenkorbElementList)
		{
			//Wenn es gefunden wurde, finde Seminarbeginn und Bilde error messages
			if(elementForStorno == String.valueOf(w.id))
			{
				if(w.Seminarbeginn__c>Date.today().addDays(7*4))
				{
					stornoMessage = '4weeks';
					return null;
				}
				else if(w.Seminarbeginn__c<=Date.today().addDays(7*4) && w.Seminarbeginn__c>Date.today().addDays(7*2))
				{
					stornoMessage = '2weeks';
					return null;
				}
				else if(w.Seminarbeginn__c<=Date.today().addDays(7*2) && w.Seminarbeginn__c>Date.today().addDays(7*1))
				{
					stornoMessage = '1weeks';
				}
				else
				{
					stornoMessage = '0weeks';
					return null;
				}
				
			}
		}
		stornoMessage = 'noMessage';
		return null;
		
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description storniert ein Seminar
	* @return null
	*/
	public PageReference sornieren()
	{
		Warenkorb_Element__c w;
		for(Warenkorb_Element__c we : warenkorbElementList)
		{
			if(String.valueOf(we.id) == elementForStorno)
			{
				w = we;
			}
		}
		w.Stornogrund__c = stornoElement.Stornogrund__c;
		w.Anderer_Stornogrund__c = stornoElement.Anderer_Stornogrund__c;
		
		w.status__c = 'Storno durch Teilnehmer';
		FAMailSender.sendStorno(w);
		update w;
		return new PageReference('/meinebestellung');
	}
	
	
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Test
	*/
	static testMethod void test()
	{
		Warenkorb_Element__c w = [SELECT Id, warenkorb__r.person__r.Benutzer__c,warenkorb__r.person__r.Benutzer__r.id FROM Warenkorb_Element__c WHERE warenkorb__r.person__r.Benutzer__c != null LIMIT 1];
		User u = w.warenkorb__r.person__r.Benutzer__r;
		System.runAs(u){
				FABestellungViewController.getInstance();
				FABestellungViewController.getInstance().getIsStornoPossible();
				FABestellungViewController.getInstance().getSelectOptions();
				FABestellungViewController.getInstance().stornoMessage();
		}
	}
}