trigger Education_afterInsertUpdate on Education__c (after insert, after update, after delete) {
	/*
	* Adds Education information to corresponding application (linked via Contact)
	* Education must have RT_LANGUAGE_QUALIFICATION recordtype and language must be english
	* qualification and score should not be empty
	*/
	
	/*
	* if recordtype is RT_SCHOOL_QUALIFICATION and education == SECSCHOOL and diploma date is not empty
	* write SIUS_Locality__c of corresponding contact
	* update application owner based on map
	*/
	
	/*
	* if recordtype is RT_SCHOOL_QUALIFICATION and education == SECSCHOOL and diploma date is not empty
	* write diploma to corresponding application> education -- contact -- application
	* write school to corresponding application> education -- contact -- application
	*/
	
	/*
	* after deletion, delete data in contact and application
	*/
	
	String RT_SCHOOL_QUALIFICATION = '01220000000HEvBAAW';
	String RT_LANGUAGE_QUALIFICATION = '01220000000HF0aAAG';
	String ENGLISH = 'English';
	String SECSCHOOL = 'Secondary School';
	
	//ownership application
	String DEFAULT_OWNER = '005200000015HKW'; //Marte NEGAARD MULLER
	
	Map<String,String> ownerMap = new Map<String, String>();
	
		//CH --> Cantons
		ownerMap.put('AG', '005200000015Gim'); //Carvi Stucki-Wick
		ownerMap.put('AR', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('AI', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('BL', '005200000015Gim'); //Carvi Stucki-Wick
		ownerMap.put('BS', '005200000015Gim');  //Carvi Stucki-Wick
		ownerMap.put('BE', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('FR', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('GE', '005200000015Gim'); //Carvi Stucki-Wick
		ownerMap.put('GL', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('GR', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('JU', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('LU', '005200000015Gim'); //Carvi Stucki-Wick
		ownerMap.put('NE', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('NW', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('OW', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('SH', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('SZ', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('SO', '005200000015Gim'); //Carvi Stucki-Wick
		ownerMap.put('SG', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('TI', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('TH', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('UR', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('VD', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('VS', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('ZU', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('ZH', '005200000015HKv'); //Isabelle Dufault
		
		//Countries
		ownerMap.put('FRANCE', '005200000015Gim'); //Carvi Stucki-Wick
		ownerMap.put('SINGAPORE', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('GREAT BRITAIN', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('HONG KONG', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('GERMANY', '005200000015Gca');  //Yannick Lee Jacquier
		ownerMap.put('INDIA', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('SPAIN', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('AUSTRALIA', '005200000015Gim'); //Carvi Stucki-Wick
		ownerMap.put('ITALY', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('THAILAND', '005200000015Gca'); //Yannick Lee Jacquier
		//ownerMap.put('BELGIUM', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('SOUTH KOREA', '005200000015Gim'); //Carvi Stucki-Wick
		//ownerMap.put('NETHERLANDS', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('JAPAN', '005200000015Gim'); //Carvi Stucki-Wick
		ownerMap.put('PORTUGAL', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('INDONESIA', '005200000015Gca'); //Yannick Lee Jacquier
		//ownerMap.put('SWEDEN', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('TAIWAN', '005200000015Gim'); //Carvi Stucki-Wick
		ownerMap.put('AUSTRIA', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('SRI LANKA', '005200000015Gca'); //Yannick Lee Jacquier
		//ownerMap.put('LUXEMBURG', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('NEW ZEALAND', '005200000015Gim'); //Carvi Stucki-Wick
		//ownerMap.put('NORWAY', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('PHILIPPINES', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('DENMARK', '005200000015Gca'); //Marte Negaard Muller
		ownerMap.put('VIETNAM', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('IRELAND', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('FIJI', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('MONACO', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('NEPAL', '005200000015Giw'); //Ikerne Azpilicueta
		//ownerMap.put('FINLAND', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('MALAYSIA', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('LICHTENSTEIN', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('MALTA', '005200000015Giw'); //Ikerne Azpilicueta
		//ownerMap.put('BULGARIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('CHINA', '005200000015Gca'); //Yannick Lee Jacquier
		ownerMap.put('BRAZIL', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('MEXICO', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('COLOMBIA', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('CHILE', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('PERU', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('ARGENTINA', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('COSTA RICA', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('VENEZUELA', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('URUGUAY', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('EL SALVADOR', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('JAMAICA', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('BOLIVIA', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('ECUADOR', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('BARBADOS', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('HONDURAS', '005200000015Giw'); //Ikerne Azpilicueta
		ownerMap.put('UNITED STATES', '005200000015HKv'); //Isabelle Dufault
		ownerMap.put('CANADA', '005200000015HKv'); //Isabelle Dufault
		/*ownerMap.put('RUSSIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('MOROCCO', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('ROMANIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('HUNGARY', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('UAE', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('EGYPT', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('GREECE', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('SOUTH AFRICA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('TURKEY', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('TUNISIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('CYPRUS', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('KENYA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('POLAND', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('LEBANON', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('SERBIA & MONTENEGRO', '005200000015HKW');  //Marte Negaard Muller
		ownerMap.put('ISRAEL', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('UKRAINE', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('MAURITIUS', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('CZECH REPUBLIC', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('MADAGASCAR', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('SLOVAKIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('PAKISTAN', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('LATVIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('CONGO', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('MOLDOVA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('NIGERIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('GEORGIA', '005200000015HKW'); //Marte Negaard Muller 
		ownerMap.put('IRAN', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('CROATIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('BAHRAIN', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('AZERBEIJAN', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('ALGERIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('LITHUANIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('CHAD', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('ALBANIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('KUWAIT', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('ARMENIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('MALI', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('BELARUSSIA', '005200000015HKW');  //Marte Negaard Muller
		ownerMap.put('MOZAMBIQUE', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('ESTONIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('SAUDI ARABIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('KAZAKHSTAN', '005200000015HKW');  //Marte Negaard Muller
		ownerMap.put('JORDAN', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('MONGOLIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('SLOVENIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('TOGO', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('ANGOLA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('NAMIBIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('SYRIA', '005200000015HKW'); //Marte Negaard Muller
		ownerMap.put('ZIMBABWE', '005200000015HKW'); //Marte Negaard Muller*/
		
		
	try{
		List<Application__c> appList = new List<Application__c>();
		Map<Id,Contact> contactMap;
		Map<Id, Application__c> appMap = new Map<Id, Application__c>();
		Map<Id, Application__c> appsToUpdate = new Map<Id, Application__c>();
		
		List<Contact> contactToUpdate = new List<Contact>();
		List<Id> contactIdList = new List<Id>(); //used for language qualification
		
		List<Education__c> allEducationList;

		if(!Trigger.isDelete){
			allEducationList = Trigger.new;
		}else{
			allEducationList = Trigger.old;
		}
		
		for(Education__c e : allEducationList){
			if(e.Student__c != null){
				contactIdList.add(e.Student__c);
			}
		}
		
		//get all corresponding applications
		appList = [Select a.changedOwner__c, a.Secondary_School__c, a.Secondary_Diploma__c, a.Score__c, a.English_Qualification__c, a.Student__c From Application__c a where a.Student__c in :contactIdList];
		
		//get all corresponding contact
		contactMap = new Map<Id,Contact>([Select c.Id, c.SIUS_Locality__c from Contact c where c.Id in :contactIdList]);
		
		
		//create map that maps from studentId to application
		for(Application__c a : appList){
			appMap.put(a.Student__c, a);
		}
		
		System.debug('**** contactMap: ' + contactMap.size());
		System.debug('**** appList: ' + appList.size());
			
		if(Trigger.isInsert){
			//***************** INSERT
			for(Education__c e : Trigger.new){
				
				//***************** LANGUAGE
				if(e.RecordTypeId == RT_LANGUAGE_QUALIFICATION 
						&& e.Student__c != null 
						&& appMap.containsKey(e.Student__c) 
						&& e.Language__c == ENGLISH
						&& e.Qualification__c != null
						&& e.Test_Score__c != null)
				{
					Application__c app = appMap.get(e.Student__c);
					System.debug('**** INSERT Application to Update (Language): ' + app.Id);
					
					app.Score__c = e.Test_Score__c;
					app.English_Qualification__c = e.Qualification__c;
					appsToUpdate.put(app.Id, app);
				}
				
				if(e.RecordTypeId == RT_SCHOOL_QUALIFICATION
						&& e.Student__c != null
						&& contactMap.containsKey(e.Student__c)
						&& e.Education__c == SECSCHOOL
						&& e.Diploma_Date__c != null
						&& e.SIUS_Locality__c != null)
				{
					//***************** SCHOOL --> CONTACT
					Contact c = contactMap.get(e.Student__c);
					System.debug('**** INSERT Contact to Update (SIUS_Locality__c): ' + e.SIUS_Locality__c);
					c.SIUS_Locality__c = e.SIUS_Locality__c;
					contactToUpdate.add(c);
					
					//***************** OWNER --> APPLICATION (only if now sius code before)
					if(appMap.containsKey(e.Student__c)) {
						Application__c app = appMap.get(e.Student__c);
						if(!app.changedOwner__c) {
							String key = '';
							Integer len = 0;
							if(e.SIUS_Locality__c.endsWith(')')) {
								//search for canton
								len = e.SIUS_Locality__c.length();
								if(len > 3){
									key = e.SIUS_Locality__c.substring(len - 3, len - 1).toUpperCase();
								}
							} else {
								key = e.SIUS_Locality__c.toUpperCase();
							}
							if(ownerMap.containsKey(key)) {
								app.OwnerId = ownerMap.get(key);
							} else {
								app.OwnerId = DEFAULT_OWNER;
							}
							app.changedOwner__c = true;				
							appsToUpdate.put(app.Id, app);
						}
					}
				}
				
				//handle diploma in applicaton if diploma has changed
				if(e.RecordTypeId == RT_SCHOOL_QUALIFICATION
						&& e.Student__c != null
						&& appMap.containsKey(e.Student__c)
						&& e.Education__c == SECSCHOOL
						&& e.Diploma_Date__c != null
						&& e.Diploma_Name__c != null)
				{
					//***************** SCHOOL --> APPLICATION
					Application__c app = appMap.get(e.Student__c);
					if(appsToUpdate.containsKey(app.Id)) {
						app = appsToUpdate.get(app.Id);
					}
					System.debug('**** INSERT Application to Update (Secondary School): ' + app.Id);
					app.Secondary_Diploma__c = e.Diploma_Name__c;
					app.Secondary_School__c = e.School_Name__c;					
					appsToUpdate.put(app.Id, app);
						
					
				}
			}
		
		}else if(Trigger.isUpdate){
			//***************** UPDATE
			for(Education__c e : Trigger.new){
				
				Education__c eOld = Trigger.oldMap.get(e.Id);
				
				if(e.RecordTypeId == RT_LANGUAGE_QUALIFICATION
					&& appMap.containsKey(e.Student__c))
				{
					Application__c ap = appMap.get(e.Student__c);
					if(eOld.Language__c == ENGLISH && e.Language__c != ENGLISH && ap.English_Qualification__c == eOld.Qualification__c && ap.Score__c == eOld.Test_Score__c){						
						//language is not english anymore, delete data
						System.debug('**** UPDATE language is not english anymore, delete data');
						ap.Score__c = null;
						ap.English_Qualification__c = null;						
						appsToUpdate.put(ap.Id, ap);
					}else if(e.Language__c == ENGLISH && e.Qualification__c != null && e.Test_Score__c != null && (ap.Score__c != e.Test_Score__c || ap.English_Qualification__c != e.Qualification__c)){
						//qualification or score changed, update app
						ap.Score__c = e.Test_Score__c;
						ap.English_Qualification__c = e.Qualification__c;						
						appsToUpdate.put(ap.Id, ap);			
					}					
				}			
				
				if(e.RecordTypeId == RT_SCHOOL_QUALIFICATION
						&& contactMap.containsKey(e.Student__c))
				{
					Contact c = contactMap.get(e.Student__c);
					if(eOld.Education__c == SECSCHOOL && e.Education__c != SECSCHOOL && c.SIUS_Locality__c == eOld.SIUS_Locality__c){
						//secondary school deleted
						c.SIUS_Locality__c = null;
						contactToUpdate.add(c);
					}
					
					else if(eOld.Diploma_Date__c != null && e.Diploma_Date__c == null && c.SIUS_Locality__c == eOld.SIUS_Locality__c){
						//diploma date deleted
						c.SIUS_Locality__c = null;
						contactToUpdate.add(c);
					}					
					
					else if(e.Education__c == SECSCHOOL && e.Diploma_Date__c != null && c.SIUS_Locality__c != e.SIUS_Locality__c){
						System.debug('**** UPDATE SIUS_Locality__c, has changed');
						c.SIUS_Locality__c = e.SIUS_Locality__c;
						contactToUpdate.add(c);
						
						//***************** OWNER --> APPLICATION (only if now sius code before)
						if(appMap.containsKey(e.Student__c)) {
							Application__c app = appMap.get(e.Student__c);
							if(!app.changedOwner__c) {
								String key = '';
								Integer len = 0;
								if(e.SIUS_Locality__c.endsWith(')')) {
									//search for canton
									len = e.SIUS_Locality__c.length();
									if(len > 3){
										key = e.SIUS_Locality__c.substring(len - 3, len - 1).toUpperCase();
									}
								} else {
									key = e.SIUS_Locality__c.toUpperCase();
								}
								if(ownerMap.containsKey(key)) {
									app.OwnerId = ownerMap.get(key);
								} else {
									app.OwnerId = DEFAULT_OWNER;
								}
								app.changedOwner__c = true;							
								appsToUpdate.put(app.Id, app);
							}
						}
					}
				}				
				
				//handle diploma in applicaton if diploma has changed
				if(e.RecordTypeId == RT_SCHOOL_QUALIFICATION
					&& appMap.containsKey(e.Student__c))
				{
					Application__c ap = appMap.get(e.Student__c);
					if(appsToUpdate.containsKey(ap.Id)) {
						ap = appsToUpdate.get(ap.Id);
					}
					if(eOld.Education__c == SECSCHOOL && e.Education__c != SECSCHOOL && ap.Secondary_Diploma__c == eOld.Diploma_Name__c && ap.Secondary_School__c == eOld.School_Name__c){
						//secondary school deleted
						ap.Secondary_Diploma__c = null;
						ap.Secondary_School__c = null;		
						appsToUpdate.put(ap.Id, ap);
					}
					
					else if(eOld.Diploma_Date__c != null && e.Diploma_Date__c == null && ap.Secondary_Diploma__c == eOld.Diploma_Name__c && ap.Secondary_School__c == eOld.School_Name__c){
						//diploma date deleted
						ap.Secondary_Diploma__c = null;
						ap.Secondary_School__c = null;
						appsToUpdate.put(ap.Id, ap);
					}
					
					else if(e.Education__c == SECSCHOOL && e.Diploma_Date__c != null && (ap.Secondary_Diploma__c != e.Diploma_Name__c || ap.Secondary_School__c != e.School_Name__c)){
						ap.Secondary_Diploma__c = e.Diploma_Name__c;
						ap.Secondary_School__c = e.School_Name__c;		
						appsToUpdate.put(ap.Id, ap);
					}
					
				}						
			}
			
			
		}else{
			//***************** DELETE
			for(Education__c e : Trigger.old){
				if(e.RecordTypeId == RT_LANGUAGE_QUALIFICATION 
						&& e.Student__c != null 
						&& appMap.containsKey(e.Student__c) 
						&& e.Language__c == ENGLISH
						&& e.Qualification__c != null
						&& e.Test_Score__c != null)
				{
					Application__c app = appMap.get(e.Student__c);
					System.debug('**** DELETE Application information to Delete (Language): ' + app.Id);
					if((app.Score__c == e.Test_Score__c)&&(app.English_Qualification__c == e.Qualification__c)){
						app.Score__c = null;
						app.English_Qualification__c = null;
						appsToUpdate.put(app.Id, app);
					}
					
				}
				
				if(e.RecordTypeId == RT_SCHOOL_QUALIFICATION
						&& e.Student__c != null
						&& contactMap.containsKey(e.Student__c)
						&& e.Education__c == SECSCHOOL
						&& e.Diploma_Date__c != null
						&& e.SIUS_Locality__c != null)
				{
					//handle contact
					Contact c = contactMap.get(e.Student__c);
					if(e.SIUS_Locality__c == c.SIUS_Locality__c){
						System.debug('**** DELETE Contact information to Delete (SIUS_Locality__c): ' + c.Id);
						c.SIUS_Locality__c = null;
						contactToUpdate.add(c);
					}
					
				}
				
				//handle diploma in applicaton if diploma has changed
				if(e.RecordTypeId == RT_SCHOOL_QUALIFICATION
						&& e.Student__c != null
						&& appMap.containsKey(e.Student__c)
						&& e.Education__c == SECSCHOOL
						&& e.Diploma_Date__c != null
						&& e.Diploma_Name__c != null)
				{
					Application__c app = appMap.get(e.Student__c);
					if((app.Secondary_Diploma__c == e.Diploma_Name__c)&&(app.Secondary_School__c == e.School_Name__c)){
						System.debug('**** DELETE Application information to delete (Secondary School): ' + app.Id);
						app.Secondary_Diploma__c = null;
						app.Secondary_School__c = null;
						appsToUpdate.put(app.Id, app);
					}
					
				}
			}
			
		}
		
		update appsToUpdate.values();
		update contactToUpdate;
			
		
	}catch(System.Exception e){
		System.debug('**** Exception occured: ' + e);
	}
}