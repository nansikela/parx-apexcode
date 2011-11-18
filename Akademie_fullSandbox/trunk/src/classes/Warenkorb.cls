public class Warenkorb{
		public Warenkorb__c warenkorb {get; set;}
		public List<Warenkorb_Element__c> warenkorbElementList {get; set;}
		
		
		//Singelton
		private static Warenkorb singelton;
		public static Warenkorb getInstance()
		{
			if(singelton == null)
			{
				Person__c currentPerson = FAHelper.getCurrentPerson();
				List<Warenkorb__c> warenkorbTemp = [Select w.Status__c, w.Person__c, (Select Id, Warenkorb__c,  Status_code__c,  Buchungstyp__c, Terminblock__c, Terminblock__r.name, Terminblock__r.Produktgruppe__c, Terminblock__r.Produktgruppe__r.Web_Preis__c, Terminblock__r.Produktgruppe__r.Name__c, Terminblock__r.Produktgruppe__r.Name,  ez_Preis__c, hotel__c, dz_Preis__c, ist_Reservierung__c, Status__c, Bestelltermin__c, Entscheidung_Vorgesetzter__c, Portfolio__c, Portfolio__r.name, Portfolio__r.web_preis__c, Portfolio__r.seminartitel__c, Seminar__c, Inhouse_Seminar__c, Hotelreservierung__c, Einzelzimmer__c, Doppelzimmer__c  From Warenkorb_Elemente__r) From Warenkorb__c w WHERE Person__c = :CurrentPerson.id AND Status__c = 'Gestartet'];
				if(warenkorbTemp.size()>0)
				{
					singelton = new Warenkorb(warenkorbTemp.get(0));
				}
				else
				{
					singelton = new Warenkorb(currentPerson);
				}
			}
			return singelton;
		}
		
		public static Warenkorb getInstance(String warenkorbId)
		{
			if(singelton == null)
			{
				List<Warenkorb__c> warenkorbTemp = [Select w.Status__c, w.Person__c, (Select Id, Warenkorb__c,  Status_code__c,  Buchungstyp__c,  ez_Preis__c, hotel__c, dz_Preis__c, ist_Reservierung__c, Status__c, Bestelltermin__c, Entscheidung_Vorgesetzter__c, Portfolio__c, Portfolio__r.name, Portfolio__r.web_preis__c, Portfolio__r.seminartitel__c, Seminar__c, Inhouse_Seminar__c, Hotelreservierung__c, Einzelzimmer__c, Doppelzimmer__c  From Warenkorb_Elemente__r WHERE Status_Code__c = 200) From Warenkorb__c w WHERE ID =:warenkorbId AND Status__c = 'Abgeschlossen'];
				System.debug('****warenkorbTemp:'+warenkorbTemp);
			if(warenkorbTemp.size()>0)
				{
					singelton = new Warenkorb(warenkorbTemp.get(0));
				}
				
			}
			return singelton;
		}
		
		//konstruktor
		private Warenkorb()
		{
			warenkorb = new Warenkorb__c();
			warenkorb.status__c = 'Gestartet';
			warenkorbElementList = new List<Warenkorb_Element__c>();
		}
		private Warenkorb(Warenkorb__c warenkorbDB)
		{
			this();
			this.warenkorb = warenkorbDB;
			
			for(Warenkorb_Element__c we : warenkorbDB.Warenkorb_Elemente__r)
			{
				warenkorbElementList.add(we);
			}
		}
		private Warenkorb(Person__c currentPerson)
		{
			this();
			this.warenkorb.Person__c = currentPerson.id;
		}
		
		public void save()
		{
			upsert warenkorb;
			
			for(Warenkorb_Element__c we : warenkorbElementList)
			{
				if(we!= null && we.warenkorb__c == null)
				{
					we.warenkorb__c = warenkorb.id;
				}
			}
			
			upsert warenkorbElementList;
		}
		
		
		public Integer countElements()
		{
			return warenkorbElementList.size();
		}
		
		public boolean getIsElement()
		{
			if(countElements()>0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		//putNewProductToWarenkorb
		
		public void add(Product2 p)
		{
			Warenkorb_Element__c we = new Warenkorb_Element__c();
			we.warenkorb__c = this.warenkorb.id;
			we.Seminar__c = p.id;
			we.Status_Code__c = 100; // code für neu im Warenkorb
			
			warenkorbElementList.add(we);
		}
		
		public Warenkorb_Element__c getWarenkorbElement(String seminarId)
		{
			for(Warenkorb_Element__c we : warenkorbElementList)
			{
				System.debug('we.seminar__c:'+we.seminar__c);
				if((we.seminar__c != null && we.seminar__c == seminarId) || (we.inhouse_seminar__c != null && we.inhouse_seminar__c == seminarId))
				{
					return we;
				}
			}
			return null;
		}
		
		public List<FASeminar> getWarenkorbElement()
		{
			List<FASeminar> elementeList = new List<FASeminar>();
			Set<ID> product2IDSet = new Set<ID>();
			Set<ID> inhouseProductIDSet = new Set<ID>();
			for(Warenkorb_Element__c we : warenkorbElementList)
			{
				
					 product2IDSet.add(we.id);
				
			}
			System.debug('****product2IDSet:'+product2IDSet);
			if(product2IDSet.size()>0)
			{
				elementeList.addAll(FASeminar.getInformationByWaForProduct2(product2IDSet));
			}
			
			
			return elementeList;
		}
		
		public void deleteElement(String id)
		{
			
			List<Warenkorb_Element__c> weForDelete = new List<Warenkorb_Element__c>();
			for(Warenkorb_Element__c we : warenkorbElementList)
			{
				if( (we.seminar__c != null && String.valueOf(we.seminar__c).subString(0, 15) == id.subString(0,15)) || (we.inhouse_seminar__c != null && String.valueOf(we.inhouse_seminar__c)== id))
				{
					weForDelete.add(we);
				}
			}
			
			
			
			if(weForDelete.size()>0)
			{
				delete weForDelete;
			}
			if(countElements()-weForDelete.size()== 0)
			{
				delete this.warenkorb;
			}
			
		}
		public static Warenkorb_Element__c generateNewWarenkorbElementForSeminar(FASeminar seminar, Portfolio2__c portfolio)
		{
			Warenkorb_Element__c warenkorbelement = new Warenkorb_Element__c();
			warenkorbelement.Status_Code__c = 100; // Status Code für neu im Warenkorb
			warenkorbelement.Warenkorb__c = getInstance().warenkorb.id;
			if(seminar.isInhouse)
			{
				warenkorbelement.inhouse_seminar__c = seminar.id;
			}
			else
			{
				warenkorbelement.seminar__c = seminar.id;
			}
			warenkorbelement.portfolio__c = portfolio.id;
			return warenkorbelement;
		}
		public void add(Warenkorb_Element__c we)
		{
			warenkorbElementList.add(we);
		}
		
		public void finish()
		{
			for(Warenkorb_Element__c we : warenkorbElementList)
			{
				//IF User is not part of the Genehmigungsverfahren Approve Request
				if(FAhelper.getCurrentPerson().Genehmigungsverfahren_ausgeschlossen__c != null && FAhelper.getCurrentPerson().Genehmigungsverfahren_ausgeschlossen__c)
				{
					we.Status_code__c = 300; //Bestellung vollständig abgeschlossen, da keine Genehmigung notwenig war
				}
				else
				{
					we.Status_code__c = 200; //Approval Prozess gestartet
				}
				
				we.bestelltermin__c = DateTime.now();
			}
			warenkorb.status__c = 'Abgeschlossen';
			upsert  warenkorb;
			upsert warenkorbElementList;
		}
	}