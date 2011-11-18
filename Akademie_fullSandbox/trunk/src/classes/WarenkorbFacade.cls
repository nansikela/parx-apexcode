public class WarenkorbFacade 
{
	private FAPortfolioController portfolioController;
	private FASeminar currentSeminar;
	private Warenkorb_Element__c currentWarenKorbElement {get; set;}
	private static List<FASeminar>faSeminare;
	public String terminString {get; set;}
	public Boolean showReservationOptions { get; private set; }
	
	
	public WarenkorbFacade() 
	{
		showReservationOptions=false;
	}

	
	/***ORDER STEP 1 ***/
	public Portfolio2__c getPortfolioInformation()
	{
		return FAPortfolioController.getController().currentPortfolio;
	}
	
	public List<SelectOption> getTerminOptionList()
	{
		List<SelectOption> selectOptionList = new List<SelectOption>();
		
		List<FASeminar> seminarList =  FAPortfolioController.getController().SeminarList;
		for(FASeminar s : seminarList)
		{
			if(s.isAusgebucht != true)
			{
				selectOptionList.add(new SelectOption(s.id, s.datum+' - '+s.ort));
			}
			
		}
		return selectOptionList;
	}
	
	public PageReference toStep2()
	{
		return new PageReference(FAPortfolioController.getController().currentPortfolio.url__c+'/order?seminar='+terminString+'&step=1');
	}
	
	/***ORDER STEP 1 END ***/
	/***ORDER STEP 2 ***/
	
	public PageReference showReservationOptions() {
     showReservationOptions=!showReservationOptions;
     currentWarenKorbElement.Hotelreservierung__c=showReservationOptions;
     //setCurrentWarenkorbElement(currentWarenKorbElement);
     return null;
   }
	
	public FASeminar getSeminarInformation()
	{
		if(currentSeminar == null)
		{
			String seminarId = WebURLEncoder.decodeparam('seminar');
		List<FASeminar> seminarList =  FAPortfolioController.getController().SeminarList;
			for(FASeminar s: seminarList)
			{
				if(s.id== seminarId){
					currentSeminar = s;
				}
				
			}
		}
		
		return currentSeminar;
	}
	
	public Warenkorb_Element__c getCurrentWarenkorbElement()
	{
		if(currentWarenKorbElement == null)
		{
			currentWarenKorbElement = Warenkorb.generateNewWarenkorbElementForSeminar(getSeminarInformation(), FAPortfolioController.getController().currentPortfolio);
		}
		System.debug('*****currentWarenKorbElement from getter:'+currentWarenKorbElement);
		return currentWarenKorbElement;
		
	}
	
	public void setCurrentWarenkorbElement(Warenkorb_Element__c we) {
		if(we != null)
		{
			Warenkorb.getInstance().deleteElement(we.seminar__c);
			Warenkorb.getInstance().add(we);
			Warenkorb.getInstance().save();
			currentWarenkorbElement=we;
		}
		System.debug('*****currentWarenKorbElement from setter:'+currentWarenKorbElement);
	}
	
	public PageReference putItemToWarenkorb()
	{
		if(currentWarenKorbElement == null)
		{
			getcurrentWarenkorbElement();
		}
		
		
			for(Integer i = 0; i<Warenkorb.getInstance().warenkorbElementList.size(); i++)
			{
				Warenkorb_Element__c w = Warenkorb.getInstance().warenkorbElementList.get(i);
				if(w.Seminar__c != null && currentWarenKorbElement.seminar__c!= null && w.Seminar__c == currentWarenKorbElement.seminar__c)
				{
					Warenkorb.getInstance().warenkorbElementList.remove(i);
					delete w;
					
				}
				if(w.Inhouse_Seminar__c != null && currentWarenKorbElement.Inhouse_Seminar__c!= null && currentWarenKorbElement.Inhouse_Seminar__c == w.Inhouse_Seminar__c)
				{
					Warenkorb.getInstance().warenkorbElementList.remove(i);
					delete w;
				}
			}
		
		Warenkorb.getInstance().add(currentWarenKorbElement);
		 
		 Warenkorb.getInstance().save();
		return new PageReference ('/warenkorb');
	}
	
	
	/**ODER STEP 2 END ***/
	
	
	/**Warenkorb Abschliessen **/
	public PageReference finishWarenkorb()
	{
		
		FAMailSender.sendWarenkorbBestaetigung();
		Warenkorb.getInstance().finish();
		
		
		
		return new PageReference('/danke');
	}
	
	public List<FASeminar>getWarenkorbIntensiv()
	{
		List<Warenkorb_Element__c>warenkorbElemente = new List<Warenkorb_Element__c>();
		for(Integer i = 0; i< Warenkorb.getInstance().warenkorbElementList.size(); i++)
		{
			Warenkorb_Element__c we = Warenkorb.getInstance().warenkorbElementList.get(i);
			if(we.Terminblock__c != null)
			{
				Warenkorb.getInstance().warenkorbElementList.remove(i);
				warenkorbElemente.add(we);
				System.debug('+++++++++++'+i);
				i=-1;
			}
		}
		Map<id, FASeminar> seminare = new Map<id, FaSeminar>();
		for(Warenkorb_Element__c we : warenkorbElemente)
		{
			FASeminar temp;
			if(seminare.containsKey(we.Terminblock__c))
			{
				temp = seminare.get(we.Terminblock__c);
				temp.id += '-'+ String.valueOf(we.seminar__c).subString(0, 15);
			}
			else
			{
				temp = new FASeminar();
				temp.id = String.valueOf(we.seminar__c).subString(0, 15);
				temp.ort = '';
				if(we.Buchungstyp__c == 'Seminar 10 Tage reservieren')
				{
					temp.preis = '0,- Reservierung';
				}
				else
				{
					temp.preis = String.valueOf(we.Terminblock__r.Produktgruppe__r.Web_Preis__c).replace('.00', ',-');
				}
				
				seminare.put(we.Terminblock__c, temp);
			}
			
			temp.ort += we.hotel__c+' ';
			if(we.ist_Reservierung__c != null && we.ist_Reservierung__c)
			{
				if(we.Einzelzimmer__c!= null && we.Einzelzimmer__c)
				{
					temp.ort += '<br/>EZ Reservierung ';
				}
				if(we.Doppelzimmer__c!= null && we.Doppelzimmer__c)
				{
					temp.ort += '</br>DZ Reservierung ';
				}
			}
			temp.titel = we.Terminblock__r.Produktgruppe__r.name__c;
		}
		return seminare.values();
	}
	
	
	public List<FASeminar> getWarenkorbInhalt()
	{
		
		{
			faSeminare = getWarenkorbIntensiv();
			List<FASeminar>standardFaSeminare = Warenkorb.getInstance().getWarenkorbElement();
			for(Warenkorb_Element__c we : Warenkorb.getInstance().warenkorbElementList)
			{
				if(we.Buchungstyp__c == 'Seminar 10 Tage reservieren')
				{
					for(FASeminar seminar: standardFaSeminare)
					{
						if(String.valueOf(we.Seminar__c).subString(0,15) == seminar.id.subString(0, 15))
						{
							seminar.preis = '0,- Reservierung';
						}
					}
				}
				
			}
			
			faSeminare.addAll(standardFaSeminare);
		}
		return faSeminare;
	}
	
	public boolean getisWarenkorbElement()
	{
		return Warenkorb.getInstance().getIsElement();
	}
	
	public PageReference deleteElement()
	{
		String id = WebURLEncoder.decodeparam('id');
		if(id.contains('-'))
		{
			
			for(String idString : id.split('-'))
			{
				Warenkorb.getInstance().deleteElement(idString);
			}
		}
		else
		{
			Warenkorb.getInstance().deleteElement(id);
		}
		
		return new PageReference('/warenkorb');
	}
	
	public PageReference goToRegistration()
	{
		return new PageReference('/registrierung');
	}
}