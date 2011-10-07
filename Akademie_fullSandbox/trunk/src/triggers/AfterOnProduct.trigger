trigger AfterOnProduct on Product2 (after update) {
	
	/*
	 * This trigger detects a change in the product field "fotoprotokoll hochgeladen" 
	 * and then performs the following operations for all affected products (attention: ONLY for specific opportunity phases):
	 * - fetch all opportunities with current product set
	 * - fetch contacts referenced by these opportunities
	 * - Send a customized mail to each of those contacts and log an activity for the sent mail
	 */

	String STATUS_GAST = 'Gast';
	String STATUS_RECHNUNG = 'Rechnung';
	
	//String MAIL_TEMPLATEID='00XS0000000IZ0A'; // Sandbox
	String MAIL_TEMPLATEID='00X20000001Edlw';
	
	
	try{
		List<EmailTemplate> emailTemplate = [SELECT e.Subject, e.Body From EmailTemplate e WHERE e.id=:MAIL_TEMPLATEID];
		
		if(!emailTemplate.isEmpty()){
		
			String MAIL_SUBJECT = emailTemplate[0].Subject;
			String MAIL_BODY = emailTemplate[0].Body;
			
			//only select products where fotoprotokoll was set in this update
			List<Product2> productList = new List<Product2>();  //MASTER PRODUCT LIST
			
			for(Product2 p : Trigger.new) {
				if(p.Fotoprotokoll_hochgeladen__c != null && Trigger.oldMap.get(p.Id).Fotoprotokoll_hochgeladen__c == null){
					productList.add(p);
				}
			}
			
			Map<id,id> contactOpportunityMap = new Map<id,id>();
			
			List<Opportunity> oppList = [SELECT o.Id, o.Seminarteilnehmer__c From Opportunity o WHERE o.Seminar__c in :productList AND o.StageName IN (:STATUS_GAST,:STATUS_RECHNUNG)];
		
			List<Id> contactIdList = new List<Id>();
			
			System.debug('****** test oppList '+ oppList.size());
				
			for(Opportunity o : oppList){
				contactIdList.add(o.Seminarteilnehmer__c);
				contactOpportunityMap.put(o.Seminarteilnehmer__c, o.id);
				
			}
		
			List<Contact> teilnehmerListe = [Select c.firstname, c.lastname, c.Briefanrede__c, c.Kontakt_Nr__c, c.Email from Contact c where c.Id in :contactIdList];
		
			List<Messaging.SingleEmailMessage> mailListe = new List<Messaging.SingleEmailMessage>();
			
			List<Task> tasksToInsert = new List<Task>();		
				
			System.debug('****** test product list '+ productList.size());		
			
			for(Product2 product : productList) {

				if(product.Fotoprotokoll_hochgeladen__c != null && Trigger.oldMap.get(product.Id).Fotoprotokoll_hochgeladen__c == null){
					STRING customMailBody;
					STRING loginLink;
					String usernameEncoded;
					String kontaktNrEncoded;
					String contactSalutation = '';
										
					for(Contact contact : teilnehmerListe){
						if(contact.Email != null){				
							customMailBody = MAIL_BODY;
							usernameEncoded = EncodingUtil.urlEncode(contact.firstName + ' ' + contact.lastName, 'UTF-8');
							kontaktNrEncoded = EncodingUtil.urlEncode(contact.Kontakt_Nr__c, 'UTF-8');
							loginLink = 'http://www.arccade.de/arccade/arccadownloads.hei?user=' + usernameEncoded +'&passwd=' +kontaktNrEncoded;
							
							if(contact.Briefanrede__c == null){
								contactSalutation = '';
							}
							else{
								contactSalutation = contact.Briefanrede__c;
							}
							
							
							customMailBody = customMailBody.replace('###SALUTATION###', contactSalutation);
							customMailBody = customMailBody.replace('###LOGINLINK###', loginLink);
							customMailBody = customMailBody.replace('###SEMINAR###', product.name);				
							customMailBody = customMailBody.replace('###SACHBEARBEITER###', userinfo.getName());				

				
							Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
							
							String[] toAddresses = new String[] {contact.email}; // contact.email
							String[] bccAddresses = new String[] {'cbrede@die-akademie.de'};
							
							mail.setToAddresses(toAddresses);
							mail.setBccAddresses(bccAddresses);
							mail.setSenderDisplayName(userinfo.getName());
							mail.setSubject(MAIL_SUBJECT);
							mail.setPlainTextBody(customMailBody);
							mail.setBccSender(false);
							mail.setUseSignature(false);
							
							mailListe.add(mail);
							
							//log a task for sent email (add to opportunity)
							Task t = new Task();
							t.Subject = 'E-Mail: ' + MAIL_SUBJECT;
							t.ActivityDate = date.today();
							t.isReminderSet = false;
							t.priority = 'Normal';
							t.status = 'Abgeschlossen';
							t.description = 'Thema: ' + MAIL_SUBJECT + '\n' + 'Text:\n' + customMailBody;
							if(contactOpportunityMap.containsKey(contact.id)){
								t.WhatId = contactOpportunityMap.get(contact.id);
							}
							
							t.WhoId = contact.id;
									
							tasksToInsert.add(t);
							
						} //end if no email
					}//end for loop contact
				} //end if fotoprotokoll newly set
			}	//end for loop over product
			
			try{
				insert tasksToInsert;
			}
			catch(system.dmlexception e){
			
				System.debug('*****Error when trying to insert tasks: '+ e.getMessage());
			}
			
			Messaging.SendEmailResult[] mailresults = Messaging.sendEmail(mailListe);
			System.debug('*****Email sent: '+ mailresults);
			
			for(Messaging.SendEmailResult res : mailresults){
				Messaging.SendEmailError[] errorList = res.getErrors();
				if(!errorList.isEmpty()){
					//TODO: define what happens
					for(Messaging.SendEmailError error : errorList){
						System.debug('*****Error in sending email has occured: ' + error.getMessage());
					}	
				}
			}
		}
		else{
			System.debug('*****No template found');	
		}
	}catch(System.Exception e){
		System.debug('*****Final exception occured: ' + e);	
	}
}