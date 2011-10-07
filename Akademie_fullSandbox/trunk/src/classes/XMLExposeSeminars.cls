public class XMLExposeSeminars 
{
	public String getXML() {
	    XmlStreamWriter w = new XmlStreamWriter();
	    w.writeStartDocument('utf-8', '1.0');
	    w.writeStartElement(null, 'informationUpdateBatch', null);
	    w.writeAttribute(null, null, 'version', '1.2');
	    w.writeAttribute(null, null, 'instituteID', '13670');
	    
		    w.writeStartElement(null, 'educations', null);	
		    	for(Portfolio__c p : [Select p.id, p.Dauer_in_Tagen__c, p.Zielgruppe__c, p.Suchbegriffe_SEM__c, p.Methode__c, p.Teilnehmerhinweis__c, p.Seminarbeschreibung__c, p.Inhalte__c, p.Preis__c, p.Sprechende_URL__c, p.Seminartitel__c, p.Ende__c, p.Beginn__c, p.Intro__c, (Select Trainer__c, Trainer__r.firstname, Trainer__r.lastname, Co_Trainer__c, Co_Trainer__r.Firstname, Co_Trainer__r.Lastname, Seminarort__r.BillingCity, Seminarbeginn__c, Seminarende__c From Seminare__r WHERE Seminarbeginn__c >today AND Seminarort__c != null) From Portfolio__c p WHERE Portfolio_Jahr__c = '2011' AND Anzeige_auf_website__c = true AND ist_Intensivprogramm__c = false])
		    	{
		    		w.writeStartElement(null, 'education', null);
		    		w.writeAttribute(null, null, 'uniqueIdentifier', p.id);
		    			w.writeStartElement(null, 'educationName', null);
		    			w.writeCharacters(p.Seminartitel__c);
		    			w.writeEndElement();
		    			
		    			w.writeStartElement(null, 'length', null);
		    			//Dauer in Tage
		    			String dauer = String.valueOf(p.Dauer_in_Tagen__c);
		    			if(dauer != null)
		    			{
		    				dauer = dauer.replace('.0', '');
			    			if(dauer == '1')
			    			{
			    				dauer = '1 Tag';
			    			}
			    			else
			    			{
			    				dauer+= ' Tage';
			    			}
			    			w.writeCharacters(dauer);
		    			}
		    			
		    			w.writeEndElement();
		    			w.writeStartElement(null, 'specificLength', null);
		    			w.writeAttribute(null, null, 'unit', 'd');
		    			if(p.Dauer_in_Tagen__c != null)
		    			{
		    				w.writeCharacters(String.valueOf(p.Dauer_in_Tagen__c));
		    			}
		    			w.writeEndElement();
		    			
		    			w.writeStartElement(null, 'link', null);
		    				w.writeCharacters('http://www.die-akademie.de'+p.sprechende_Url__c);
		    			w.writeEndElement();
		    			
		    		
			    		w.writeStartElement(null, 'qualification', null);
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'description', null);
			    		if(p.Intro__c != null)
			    		{
			    			w.writeCharacters(p.Intro__c);
			    		}
			    		
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'degree', null);
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'continuing', null);
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'detailedCost', null);
			    		if(p.Preis__c != null)
			    		{
			    			w.writeCharacters(String.valueOf(p.Preis__c).replace('.', ',').replace(',00', ',-'));
			    		}
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'specificPrice', null);
			    		w.writeAttribute(null, null, 'vat', '19.0');
			    		w.writeAttribute(null, null, 'vatIncluded', 'false');
			    		w.writeAttribute(null, null, 'currency', 'EUR');
			    		if(p.Preis__c != null)
			    		{
			    			w.writeCharacters(String.valueOf(p.Preis__c));
			    		}
			    		
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'technicalPrerequisites', null);
			    		w.writeEndElement();
			    		
			    		
			    		w.writeStartElement(null, 'customField1', null);
			    		w.writeAttribute(null, null, 'headline', 'Inhalte');
			    		if(p.Inhalte__c != null){
			    			w.writeCData(p.Inhalte__c);
			    		}
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'customField2', null);
			    		w.writeAttribute(null, null, 'headline', 'Methode');
			    		if(p.Methode__c != null){
			    			w.writeCData(p.Methode__c);
			    		}
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'customField3', null);
			    		w.writeAttribute(null, null, 'headline', 'Zielgruppe');
			    		if(p.Methode__c != null){
			    			String zielgruppe = p.Zielgruppe__c;
			    			if(p.Teilnehmerhinweis__c != null)
			    			{
			    				zielgruppe+= '<br />'+p.Teilnehmerhinweis__c;
			    			}
			    			w.writeCData(zielgruppe);
			    		}
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'keywords', null);
			    		if(p.Suchbegriffe_SEM__c != null){
			    			w.writeCharacters(p.Suchbegriffe_SEM__c);
			    		}
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'educationTypes', null);
				    		w.writeStartElement(null, 'educationType', null);
				    			w.writeAttribute(null, null, 'educationTypeID', '134');
				    			w.writeAttribute(null, null, 'mainType', 'true');
				    		w.writeEndElement();
			    		w.writeEndElement();
			    		
			    		w.writeStartElement(null, 'educationPlaces', null);
				    		for(Product2 p2 : p.Seminare__r)
				    		{
					    		w.writeStartElement(null, 'place', null);
					    		if(p2.Seminarort__c != null)
					    		{
					    			w.writeCharacters(p2.Seminarort__r.BillingCity);
					    		}
					    		w.writeEndElement();
				    		}
			    		w.writeEndElement();
			    		
			    		
			    		w.writeStartElement(null, 'educationStartDates', null);
				    		for(Product2 p2 : p.Seminare__r)
				    		{
					    		w.writeStartElement(null, 'startDate', null);
					    			w.writeAttribute(null, null, 'startDate', String.valueOf(p2.Seminarbeginn__c));
					    			w.writeAttribute(null, null, 'endDate', String.valueOf(p2.Seminarende__c));
					    			if(p2.Seminarort__c != null)
					    			{
					    				w.writeAttribute(null, null, 'place', p2.Seminarort__r.BillingCity);
					    			}
					    			String trainer = '';
					    			trainer+= p2.Trainer__r.firstname+' '+p2.Trainer__r.lastname;
					    			if(p2.Co_Trainer__c != null)
					    			{
					    				trainer+= ' und ';
					    				trainer+= p2.Co_Trainer__r.firstname+' '+p2.Co_Trainer__r.lastname;
					    			}
					    			w.writeAttribute(null, null, 'lecturer', trainer);
					    		w.writeEndElement();
				    		}
			    		w.writeEndElement();
		    		w.writeEndElement();
		    	}
		    	
		    w.writeEndElement();
	    w.writeEndElement();
	    return w.getXmlString();
	}
	
	public static testmethod void test()
	{
		XMLExposeSeminars x = new XMLExposeSeminars();
		x.getXML();
	} 
}