public class salesforce2magento {
	
	public static boolean inFutureContext = false;
	public static Http h = new Http();
      public static HttpRequest req = new HttpRequest();
      public static HttpResponse res = new HttpResponse();
      public static String SessionId;
      public static String CustomerId;
	
	public static void base_init() {
		req.setTimeout(60000);
            req.setMethod('POST');
            req.setEndPoint('http://devel.fwu-shop.de/index.php/api/index/index/'); 
            req.setHeader('Content-type','text/xml');
	}
	@future (callout=true)
	public static void job(list<Id> Ids, boolean PersonenAccount, boolean isFromProductTrigger) {
		salesforce2magento.inFutureContext = True; //we avoid a new run of the trigger
		base_init();
		string result = '';
		for(integer i = 0 ; i < 5 ; i ++) {
			if((result=login()) == 'ok')
				break;
		}
		if(result != 'ok') {
			systemsettings.logError('login Problem to Magento', 'Salesforce Id not created: ' + Ids, 'salesforce2magento:job', 'Insert Account');
			systemsettings.insertErrors();
		}
		else {
			if(isFromProductTrigger) {
				ProductCallout(Ids);
			}
			else {
				if(PersonenAccount)
					AccountCallout(Ids);
				else
					ContactCallout(Ids);
			}
		}
	}
	
	public static void job2(list<Id> Ids, boolean PersonenAccount, boolean isFromProductTrigger) {
		salesforce2magento.inFutureContext = True; //we avoid a new run of the trigger
		base_init();
		string result = '';
		for(integer i = 0 ; i < 5 ; i ++) {
			if((result=login()) == 'ok')
				break;
		}
		if(result != 'ok') {
			systemsettings.logError('login Problem to Magento', 'Salesforce Id not created: ' + Ids, 'salesforce2magento:job', 'Insert Account');
			systemsettings.insertErrors();
		}
		else {
			if(isFromProductTrigger) {
				ProductCallout(Ids);
			}
			else {
				if(PersonenAccount)
					AccountCallout(Ids);
				else
					ContactCallout(Ids);
			}
		}
	}
	public static string login() {
		
		String UserName = 'parx@fwu.de';
     		String Password = 'parxfwu';
	
        	string SoapXMLBody;
        	SoapXMLBody ='<?xml version=\'1.0\' encoding=\'UTF-8\'?>' +
				'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"' +
                 		' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
                 		' xmlns:xsd="http://www.w3.org/2001/XMLSchema">' +
					'<SOAP-ENV:Body>' +
						'<ns1:login xmlns:ns1="urn:Magento">' +  //SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
							'<username type="xsd:string">' + UserName + '</username>'  +
							'<apiKey type="xsd:string">'+ Password +'</apiKey>' +
						'</ns1:login>' +
					'</SOAP-ENV:Body>' +
				'</SOAP-ENV:Envelope>';		
		
        	Integer ContentLength = 0;
        	ContentLength = SoapXMLBody.length();

            req.setHeader('Content-Length',ContentLength.format());
            req.setBody(SoapXMLBody);
            System.Debug('req: '+req);
            System.Debug('req.getBody'+req.getBody());
	      
	      try{     
           		res = h.send(req);
	      }
	      catch(exception e) {return 'error'; }
            String auth = res.getBody();
         
	      System.Debug('Debug(auth:'+auth);
	            
	      XMLDom d = new XMLDom(res.getBody());
	      
	      try{     
           		SessionId =  d.getElementsByTagName('loginReturn')[0].nodeValue; 
	      }
	      catch(exception e) {return 'error';  }	
	      return 'ok';
	}
	
	public static void AccountCallout(list<Id> AccountIds) {
	
		list<Account> Accs = new list<Account>( [select Id, KundennummerKey__c, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, salutation, firstname, lastname, PersonEmail, fax, phone, UIDN02__c, CODE02__c, Anzahl_der_Schulen__c, RBKZ02__c, MagentoId__pc, PersonBirthdate, PersonTitle from Account where id IN :AccountIds] ) ;
	 	System.Debug('Session Id account:'+SessionId);
		
		for(Account a : Accs ){
        		string SoapXMLBody;
	            
	            SoapXMLBody ='<?xml version=\'1.0\' encoding=\'UTF-8\'?>' +
					'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"' +
                   		' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
                   		' xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
                   		' xmlns:ns2="http://xml.apache.org/xml-soap"' +
                   		' xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"'+
                   		' SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
						'<SOAP-ENV:Body>' +
							'<ns1:call xmlns:ns1="urn:Magento">' +  //SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
								'<sessionId xsi:type="xsd:string">'+ SessionId+ '</sessionId>'+
								'<resourcePath xsi:type="xsd:string">customer.create</resourcePath>' +
								'<args SOAP-ENC:arrayType="ns2:Map[1]" xsi:type="SOAP-ENC:Array">'+
									'<item xsi:type="ns2:Map">' +
								            '<item>'+
								                '<key xsi:type="xsd:string">email</key>'+
								                '<value xsi:type="xsd:string">'+ a.PersonEmail +'</value>'+
								            '</item>'+
							            	'<item>'+
							                  	'<key xsi:type="xsd:string">firstname</key>'+
							                        '<value xsi:type="xsd:string">'+ a.firstname +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">lastname</key>'+
							                        '<value xsi:type="xsd:string">'+ a.lastname +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                  	'<key xsi:type="xsd:string">middlename</key>'+
							                        '<value xsi:type="xsd:string">'+ a.PersonTitle +'</value>'+
							                  '</item>'+
							                  '<item>'+
							            		'<key xsi:type="xsd:string">fwukundennummer</key>'+
							                		'<value xsi:type="xsd:string">'+ a.KundennummerKey__c +'</value>'+
							            	'</item>'+
							            	'<item>'+
							                  	'<key xsi:type="xsd:string">prefix</key>'+
							                        '<value xsi:type="xsd:string">'+ a.salutation +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">rabatt</key>'+
							                        '<value xsi:type="xsd:string">'+ a.RBKZ02__c +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">dob</key>'+
							                        '<value xsi:type="xsd:string">'+ ((a.PersonBirthdate == null)?'':String.valueOf(a.PersonBirthdate)) +'</value>'+
							                  '</item>'+ 
							                  '<item>'+
							                        '<key xsi:type="xsd:string">taxvat</key>'+
							                        '<value xsi:type="xsd:string">'+ a.UIDN02__c +'</value>'+
							                  '</item>'+   
							                  '<item>'+
							                        '<key xsi:type="xsd:string">code</key>'+
							                        '<value xsi:type="xsd:string">'+ a.CODE02__c +'</value>'+
							                  '</item>'+  
							                  '<item>'+
							                        '<key xsi:type="xsd:string">schulen</key>'+
							                        '<value xsi:type="xsd:string">'+ a.Anzahl_der_Schulen__c +'</value>'+
							                  '</item>'+    
						        		'</item>'+																	
								'</args>'+
							'</ns1:call>' +
						'</SOAP-ENV:Body>' +
					'</SOAP-ENV:Envelope>';	
			
			req.setBody(SoapXMLBody);
			System.Debug('Debug body: '+ SoapXMLBody);
			Integer ContentLength = SoapXMLBody.length();
			req.setHeader('Content-Length',ContentLength.format());
			try{ 
				res = h.send(req);
			}
			catch(exception e) {
				systemsettings.logError('unknown error while sending datas to Magento, timeout or something else', 'Account ' + a.Id, 'salesforce2magento:AccountCallout', 'Insert Account');
				continue;
			}
			
			String auth = res.getBody();
       	             
	        System.Debug('Debug(auth:'+auth);
	             
	        XMLDom d = new XMLDom(res.getBody());
	      
	     	  try{     
           		CustomerId =  d.getElementsByTagName('callReturn')[0].nodeValue; 
	        }
	     	  catch(exception e) {
	     		String error = d.getElementsByTagName('faultstring')[0].nodeValue;
	     		systemsettings.logError(error, 'Account ' + a.Id, 'salesforce2magento:AccountCallout', 'Insert Account');
	     		continue;
	     	  }
	     	  a.MagentoId__pc = CustomerId;
	     	
	     	
	     	
	     	
	        SoapXMLBody ='<?xml version=\'1.0\' encoding=\'UTF-8\'?>' +
					'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"' +
                   		' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
                   		' xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
                   		' xmlns:ns2="http://xml.apache.org/xml-soap"' +
                   		' xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"'+
                   		' SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
						'<SOAP-ENV:Body>' +
							'<ns1:call xmlns:ns1="urn:Magento">' +  //SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
								'<sessionId xsi:type="xsd:string">'+ SessionId+ '</sessionId>'+
								'<resourcePath xsi:type="xsd:string">customer_address.create</resourcePath>' +
								'<args SOAP-ENC:arrayType="ns2:Map[1]" xsi:type="SOAP-ENC:Array">'+
									'<customerId xsi:type="xsd:string">'+ CustomerId+ '</customerId>'+
									'<item xsi:type="ns2:Map">' + 
							                  '<item>'+
							                        '<key xsi:type="xsd:string">street</key>'+
							                        '<value xsi:type="xsd:string">'+ a.BillingStreet +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">postcode</key>'+
							                        '<value xsi:type="xsd:string">'+ a.BillingPostalCode +'</value>'+
							                  '</item>'+
							                  
							                  '<item>'+
							                        '<key xsi:type="xsd:string">city</key>'+
							                        '<value xsi:type="xsd:string">'+ a.BillingCity +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">region</key>'+
							                        '<value xsi:type="xsd:string">'+ a.BillingState +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">country_id</key>'+
							                        '<value xsi:type="xsd:string">'+ a.BillingCountry +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                  	'<key xsi:type="xsd:string">firstname</key>'+
							                        '<value xsi:type="xsd:string">'+ a.firstname +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">lastname</key>'+
							                        '<value xsi:type="xsd:string">'+ a.lastname +'</value>'+
							                  '</item>'+
							                   '<item>'+
							                        '<key xsi:type="xsd:string">fax</key>'+
							                        '<value xsi:type="xsd:string">'+ a.fax +'</value>'+
							                  '</item>'+
							                   '<item>'+
							                        '<key xsi:type="xsd:string">telephone</key>'+
							                        '<value xsi:type="xsd:string">'+ a.phone +'</value>'+
							                  '</item>'+   							                  						                 
							                  '<item>'+
							                        '<key xsi:type="xsd:string">SalesforceId</key>'+
							                        '<value xsi:type="xsd:string">'+ a.Id +'</value>'+
							                  '</item>'+ 
							            '</item>'+																	
								'</args>'+
							'</ns1:call>' +
						'</SOAP-ENV:Body>' +
					'</SOAP-ENV:Envelope>';	
			
			req.setBody(SoapXMLBody);
			System.Debug('Debug body: '+ SoapXMLBody);
			ContentLength = SoapXMLBody.length();
			req.setHeader('Content-Length',ContentLength.format());
			try{ 
				res = h.send(req);
			}
			catch(exception e) {
				systemsettings.logError('unknown error while sending datas to Magento, timeout or something else', 'Account ' + a.Id, 'salesforce2magento:AccountCallout', 'Insert Account');
				continue;
			}
			
			auth = res.getBody();
       	             
	            System.Debug('Debug(auth:'+auth);
	             
	            d = new XMLDom(res.getBody());
	      
	     		try{     
           			CustomerId =  d.getElementsByTagName('callReturn')[0].nodeValue; 
	      	}
	     		catch(exception e) {
	     			String error = d.getElementsByTagName('faultstring')[0].nodeValue;
	     			systemsettings.logError(error, 'Account ' + a.Id, 'salesforce2magento:AccountCallout', 'Insert Account');
	     			continue;
	     		}

		}
		systemsettings.insertErrors();
		if(!Accs.isEmpty())
			update Accs;
	}
	
	public static void ContactCallout(list<Id> ContactIds) {
		List<Contact> Contacts = new List<Contact>( [select Id, AccountId, firstname, lastname, salutation, email, fax, phone, mobilePhone, mailingCity, MailingCountry, MailingPostalCode, MailingStreet, Newsletter__c, Birthdate, title from Contact where id IN :ContactIds] ) ;
		list<String> AccountIds = new list<String>();
		for(Contact c:Contacts) {
			AccountIds.add(c.AccountId);
		}
		map<Id, Account> Accs = new map<Id, Account>( [select Id, KundennummerKey__c, Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, UIDN02__c, CODE02__c, RBKZ02__c, Anzahl_der_Schulen__c from Account where id IN :AccountIds] ) ;
	 	System.Debug('Session Id account:'+SessionId);
		
		for(Contact c : Contacts ){
        		string SoapXMLBody;
	            
	            SoapXMLBody ='<?xml version=\'1.0\' encoding=\'UTF-8\'?>' +
					'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"' +
                   		' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
                   		' xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
                   		' xmlns:ns2="http://xml.apache.org/xml-soap"' +
                   		' xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"'+
                   		' SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
						'<SOAP-ENV:Body>' +
							'<ns1:call xmlns:ns1="urn:Magento">' +  //SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
								'<sessionId xsi:type="xsd:string">'+ SessionId+ '</sessionId>'+
								'<resourcePath xsi:type="xsd:string">customer.create</resourcePath>' +
								'<args SOAP-ENC:arrayType="ns2:Map[1]" xsi:type="SOAP-ENC:Array">'+
									'<item xsi:type="ns2:Map">' +
										'<item>'+
								                '<key xsi:type="xsd:string">email</key>'+
								                '<value xsi:type="xsd:string">'+ c.Email +'</value>'+
								            '</item>'+
							            	'<item>'+
							                  	'<key xsi:type="xsd:string">firstname</key>'+
							                        '<value xsi:type="xsd:string">'+ c.firstname +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">lastname</key>'+
							                        '<value xsi:type="xsd:string">'+ c.lastname +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                  	'<key xsi:type="xsd:string">middlename</key>'+
							                        '<value xsi:type="xsd:string">'+ c.Title +'</value>'+
							                  '</item>'+
							                  '<item>'+
							            		'<key xsi:type="xsd:string">fwukundennummer</key>'+
							                		'<value xsi:type="xsd:string">'+Accs.get(c.AccountId).KundennummerKey__c +'</value>'+
							            	'</item>'+
							            	'<item>'+
							                  	'<key xsi:type="xsd:string">prefix</key>'+
							                        '<value xsi:type="xsd:string">'+ c.salutation +'</value>'+
							                  '</item>'+
							            	'<item>'+
							                        '<key xsi:type="xsd:string">dob</key>'+
							                        '<value xsi:type="xsd:string">'+ ((c.Birthdate==null)?'':String.valueOf(c.Birthdate)) +'</value>'+
							                  '</item>'+  
							                  '<item>'+
							                        '<key xsi:type="xsd:string">rabatt</key>'+
							                        '<value xsi:type="xsd:string">'+ Accs.get(c.AccountId).RBKZ02__c +'</value>'+
							                  '</item>'+ 	
							                  '<item>'+
							                        '<key xsi:type="xsd:string">taxvat</key>'+
							                        '<value xsi:type="xsd:string">'+ Accs.get(c.AccountId).UIDN02__c +'</value>'+
							                  '</item>'+   
							                  '<item>'+
							                        '<key xsi:type="xsd:string">code</key>'+
							                        '<value xsi:type="xsd:string">'+ Accs.get(c.AccountId).CODE02__c +'</value>'+
							                  '</item>'+  
							                  '<item>'+
							                        '<key xsi:type="xsd:string">schulen</key>'+
							                        '<value xsi:type="xsd:string">'+ Accs.get(c.AccountId).Anzahl_der_Schulen__c +'</value>'+
							                  '</item>'+    				                 
							            '</item>'+																	
								'</args>'+
							'</ns1:call>' +
						'</SOAP-ENV:Body>' +
					'</SOAP-ENV:Envelope>';	
			
			req.setBody(SoapXMLBody);
			System.Debug('Debug body: '+ SoapXMLBody);
			Integer ContentLength = SoapXMLBody.length();
			req.setHeader('Content-Length',ContentLength.format());
			try{ 
				res = h.send(req);
			}
			catch(exception e) {
				systemsettings.logError('unknown error while sending datas to Magento, timeout or something else', 'Kontakt ' + c.Id, 'salesforce2magento:AccountCallout', 'Insert Kontakt');
				continue;
			}
			
			String auth = res.getBody();
       	             
	            System.Debug('Debug(auth:'+auth);
	             
	            XMLDom d = new XMLDom(res.getBody());
	      
	     		try{     
           			CustomerId =  d.getElementsByTagName('callReturn')[0].nodeValue; 
	      	}
	     			catch(exception e) {
	     				String error = d.getElementsByTagName('faultstring')[0].nodeValue;
	     				systemsettings.logError(error, 'Kontakt ' + c.Id, 'salesforce2magento:AccountCallout', 'Insert Kontakt');
	     				continue;
	     		}
	     		c.MagentoId__c = CustomerId;
	     		
	     		SoapXMLBody ='<?xml version=\'1.0\' encoding=\'UTF-8\'?>' +
					'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"' +
                   		' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
                   		' xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
                   		' xmlns:ns2="http://xml.apache.org/xml-soap"' +
                   		' xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"'+
                   		' SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
						'<SOAP-ENV:Body>' +
							'<ns1:call xmlns:ns1="urn:Magento">' +  //SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"
								'<sessionId xsi:type="xsd:string">'+ SessionId+ '</sessionId>'+
								'<resourcePath xsi:type="xsd:string">customer_address.create</resourcePath>' +
								'<args SOAP-ENC:arrayType="ns2:Map[1]" xsi:type="SOAP-ENC:Array">'+
									'<customerId xsi:type="xsd:string">'+ CustomerId+ '</customerId>'+
									'<item xsi:type="ns2:Map">' + 
									 	'<item>'+
							                        '<key xsi:type="xsd:string">company</key>'+
							                        '<value xsi:type="xsd:string">'+ Accs.get(c.AccountId).Name +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">street</key>'+
							                        '<value xsi:type="xsd:string">'+ c.MailingStreet +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">postcode</key>'+
							                        '<value xsi:type="xsd:string">'+ c.MailingPostalCode +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">city</key>'+
							                        '<value xsi:type="xsd:string">'+ c.MailingCity +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">region</key>'+
							                        '<value xsi:type="xsd:string">'+ c.MailingState +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">country_id</key>'+
							                        '<value xsi:type="xsd:string">'+ c.MailingCountry +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                  	'<key xsi:type="xsd:string">firstname</key>'+
							                        '<value xsi:type="xsd:string">'+ c.firstname +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">lastname</key>'+
							                        '<value xsi:type="xsd:string">'+ c.lastname +'</value>'+
							                  '</item>'+
							                   '<item>'+
							                        '<key xsi:type="xsd:string">fax</key>'+
							                        '<value xsi:type="xsd:string">'+ c.fax +'</value>'+
							                  '</item>'+
							                  '<item>'+
							                        '<key xsi:type="xsd:string">telephone</key>'+
							                        '<value xsi:type="xsd:string">'+ c.phone +'</value>'+
							                  '</item>'+  
							                  '<item>'+
							                        '<key xsi:type="xsd:string">mobil</key>'+
							                        '<value xsi:type="xsd:string">'+ c.MobilePhone +'</value>'+
							                  '</item>'+ 
							                  '<item>'+
							                        '<key xsi:type="xsd:string">SalesforceId</key>'+
							                        '<value xsi:type="xsd:string">'+ c.Id +'</value>'+
							                  '</item>'+  
							            '</item>'+																	
								'</args>'+
							'</ns1:call>' +
						'</SOAP-ENV:Body>' +
					'</SOAP-ENV:Envelope>';	
			
			req.setBody(SoapXMLBody);
			System.Debug('Debug body: '+ SoapXMLBody);
			ContentLength = SoapXMLBody.length();
			req.setHeader('Content-Length',ContentLength.format());
			try{ 
				res = h.send(req);
			}
			catch(exception e) {
				systemsettings.logError('unknown error while sending datas to Magento, timeout or something else', 'Contact ' + c.Id, 'salesforce2magento:contactCallout', 'Insert Contact');
				continue;
			}
			
			auth = res.getBody();
       	             
	            System.Debug('Debug(auth:'+auth);
	             
	            d = new XMLDom(res.getBody());
	      
	     		try{     
           			CustomerId =  d.getElementsByTagName('callReturn')[0].nodeValue; 
	      	}
	     		catch(exception e) {
	     			String error = d.getElementsByTagName('faultstring')[0].nodeValue;
	     			systemsettings.logError(error, 'Contact ' + c.Id, 'salesforce2magento:ContactCallout', 'Insert Contact');
	     			continue;
	     		}
		}
		systemsettings.insertErrors();
		if(!Contacts.isEmpty())
			update Contacts;
	}
	
	public static void ProductCallout(list<Id> ProductIds) {
		list<Product2> Prods = new list<Product2>([select Id, Name, RESB01__c, BESB01__c, GESB01__c from Product2 where id IN :ProductIds]);
		map<Id, Einkauf__c> EBmap = new map<Id, Einkauf__c>();
		list<Einkauf__c> EBlist = new list<Einkauf__c>([select id, Artikel__c, CreatedDate from Einkauf__c where Artikel__c IN: ProductIds AND BWSL22__c = '03']);
		for(Einkauf__c e:EBlist) {
			if(!EBmap.containsKey(e.Artikel__c) || EBmap.get(e.Artikel__c).CreatedDate < e.CreatedDate)
				EBmap.put(e.Artikel__c, e);
		}
		
		
		for(Product2 p:Prods) {
			string SoapXMLBody;
	            if(p.GESB01__c == null || p.RESB01__c == null || p.BESB01__c == null) 
	            	continue;
	            SoapXMLBody ='<?xml version=\'1.0\' encoding=\'UTF-8\'?>' +
					'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"' +
                   		' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
                   		' xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
                   		' xmlns:ns2="http://xml.apache.org/xml-soap"' +
                   		' xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"'+
                   		' SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
						'<SOAP-ENV:Body>' +
							'<ns1:call xmlns:ns1="urn:Magento">' + 
								'<sessionId xsi:type="xsd:string">'+ SessionId+ '</sessionId>'+
								'<resourcePath xsi:type="xsd:string">product.update</resourcePath>' +
								'<args SOAP-ENC:arrayType="ns2:Map[1]" xsi:type="SOAP-ENC:Array">'+
							          	'<value xsi:type="xsd:string">'+ p.Name +'</value>'+	           	
				           				'<item xsi:type="ns2:Map">' +
										'<item>'+
						                 			'<key xsi:type="xsd:string">qty</key>'+
						                       		'<value xsi:type="xsd:int">'+ ((p.GESB01__c - p.RESB01__c < 0)?0:(p.GESB01__c - p.RESB01__c)) +'</value>'+
						                 		'</item>'+
										'<item>'+
						                 			'<key xsi:type="xsd:string">liefertermin</key>'+
						                       		'<value xsi:type="xsd:string">'+ ((EBmap.containsKey(p.Id)&&(p.GESB01__c - p.RESB01__c < 0)&&(p.BESB01__c>0))?string.valueOf(EBmap.get(p.Id).CreatedDate+7):'') +'</value>'+
						                 		'</item>'+
						           	 	'</item>'+											
								'</args>'+
							'</ns1:call>' +
						'</SOAP-ENV:Body>' +
					'</SOAP-ENV:Envelope>';	
			
			req.setBody(SoapXMLBody);
			System.Debug('Debug body: '+ SoapXMLBody);
			Integer ContentLength = SoapXMLBody.length();
			req.setHeader('Content-Length',ContentLength.format());
			try{ 
				res = h.send(req);
			}
			catch(exception e) {
				systemsettings.logError('unknown error while sending datas to Magento, timeout or something else', 'Produkt ' + p.Id, 'salesforce2magento:=ProductCallout', 'Update Product');
				continue;
			}
			
			String auth = res.getBody();
       	             
	            System.Debug('Debug(auth:'+auth);
	             
	            XMLDom d = new XMLDom(res.getBody());
	      
	     		try{        			
           			if((CustomerId=d.getElementsByTagName('callReturn')[0].nodeValue )!= 'true') {
           				systemsettings.logError('unknown error while reading response from Magento, response: ' + CustomerId, 'Produkt ' + p.Id, 'salesforce2magento:=ProductCallout', 'Update Product');
           			}
	      	}
	     			catch(exception e) {
	     				String error = d.getElementsByTagName('faultstring')[0].nodeValue;
	     				systemsettings.logError(error, 'Produkt ', 'salesforce2magento:ProductCallout', 'Update Product');
	     				continue;
	     			}
		}
		systemsettings.insertErrors();
	}
	
	static testMethod void test(){
		//for person account
		list<Id> Ids ;
		String PersonAccId = testData.creationPersonAccount();
		Ids = new list<Id>();
		Ids.add(PersonAccId);
		AccountCallout(Ids);
		
		//for firm account (with contact)
		String AccId = testData.creationAccount();
		String ContactId = testData.creationContact(AccId);
		Ids = new list<Id>();
		Ids.add(ContactId);
		ContactCallout(Ids);
		
		Product2 p = new Product2(Name='Test',IsActive=true, PDKZ01__c=2, ProductCode = '01234', GESB01__c = 20, RESB01__c = 10 ,BESB01__c = 10);
        	Medienart__c m=new Medienart__c(Name='55',MALTXT__c='VHS');
	  	insert m;
        	p.MEDA01__c = m.Id;
	  	p.Auslieferung_geplant__c = system.today();
        	insert p;
        	EinkaufBestellung__c EB = new EinkaufBestellung__c ();
        	insert EB;
		Einkauf__c e = new Einkauf__c(Bestellung__c = EB.Id, Artikel__c = p.Id, EKPR22__c = 10, MENG22__c = 10, BWSL22__c = '03');
		Ids = new list<Id>();
		Ids.add(p.Id);
		ProductCallout(Ids);
		insert e;
		ProductCallout(Ids);
	}
}