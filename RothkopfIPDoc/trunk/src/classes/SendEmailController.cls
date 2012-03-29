public with sharing class SendEmailController {

    public String EmailTo{get;set;}
    public String EmailCC{get;set;}
    public String EmailBCC{get;set;}
    public String Subject{get;set;}
    public String Body{get;set;}
    public Boolean hasSignature{get;set;}
    public Boolean addAutoBCC{get;set;}

    public list<ContentVersion> CVList {get;set;}
    public string AlertSuccessErrorAfterSend{get;set;}
    public String DeleteId {get;set;}
    public String selectedTemplate{get;set;}
    
    private list<String> CVIds = new list<String>();
    private map<String, list<String>> roleMapEmailMapping = new map<String, list<String>>();
    private map<String, list<String>> profileMapEmailMapping = new map<String, list<String>>();
    private map<String, map<String, String>> FieldSchema = new map<String, map<String, String>>();
    private map<String,String> keyPrefixMap = new Map<String,String>{};
    
        
    public SendEmailController() {
        keyFieldMapping();  

        CVList = new list<ContentVersion>();
        Map<String, SObjectField> UserSchema = Schema.sObjectType.User.fields.getMap();
        Map<String, SObjectField> OrganizationSchema = Schema.sObjectType.Organization.fields.getMap();

        fillFieldSchema(UserSchema, 'user', ' where Id = \'' + UserInfo.getUserId() + '\'');
        fillFieldSchema(OrganizationSchema, 'organization', '');
        
        String RecordsId = ApexPages.currentPage().getParameters().get('Records');

        if(RecordsId != null && RecordsId != '') {
            CVIds = new list<String>();
            CVIds = RecordsId.split(',');
            if(CVIds.size() > 10) {
                AlertSuccessErrorAfterSend = 'You cannot select more than 10 Files.';
            }
            else { 
                CVList = [select PathOnClient, FirstPublishLocationId from ContentVersion where Id IN: CVIds];
                if(CVList.size() == 1)
                    assignToCC();
            }
        }
        else {
            AlertSuccessErrorAfterSend = 'Please select at least one File!';
        }
        selectedTemplate = '--None--';
    }
    
    private void assignToCC() {
    	system.debug('contentdocId:' +  CVList.get(0).FirstPublishLocationId);
    	try {
    		Document__c doc = [select Meta_To_List__c, Meta_CC_List__c, Meta_From_List__c from Document__c where Id =: CVList.get(0).FirstPublishLocationId];
    		EmailTo = (doc.Meta_From_List__c != null?(doc.Meta_From_List__c + ';'):'') + (doc.Meta_To_List__c != null?doc.Meta_To_List__c:'');
    		EmailCC = doc.Meta_CC_List__c != null?doc.Meta_CC_List__c:'';
    		if(EmailTo.endsWith(';'))
    		   EmailTo = EmailTo.substring(0, EmailTo.length() - 1);
    	}
    	catch(exception e) {}
    }
    
    public list<SelectOption> getTemplates() {        
        List<SelectOption> options = new List<SelectOption>();
        selectedTemplate = null;
        options.add(new SelectOption('--None--', '--None--')); 
        for(EmailTemplate ET:[select id, Name from EmailTemplate]) {
            options.add(new SelectOption(ET.id, ET.Name)); 
        }
        return options;
    } 
    
    public String ReplacePlaceholder(String Placeholder) {
        Placeholder = Placeholder.trim();
        if(Placeholder.contains('.')) {
            String temp = Placeholder.substring(2, Placeholder.length() - 1).toLowerCase();
            String Obj = temp.split('\\.')[0];
            String Field = temp.split('\\.')[1];
            System.debug('Obj:' + Obj);
            System.debug('Field:' + Field);
            System.debug('containskey:' + FieldSchema.keySet());
            
            if(FieldSchema.containsKey(Obj) && FieldSchema.get(Obj).containsKey(Field))
                Placeholder = FieldSchema.get(Obj).get(Field);
        }
        return Placeholder;
    }
    
    public void rerenderTemplate() {
        Subject = '';
        Body = '';
        Integer j = 0;
        
        if(selectedTemplate != '--None--') {
            EmailTemplate ET = [select Body, Subject from EmailTemplate where Id =:selectedTemplate];
            Subject = String.escapeSingleQuotes(ET.Subject);
            Body = String.escapeSingleQuotes(ET.Body!=null?ET.Body.replace('\n', '<br/>'):'');
        }
        for(Integer i = 0; i < Subject.length() -2 ; i++) {
            if(Subject.substring(i, i+2) == '{!') {
                //found {!, we are looking now for }
                if(Subject.indexOf('}', i+2) > i+2)
                    j = Subject.indexOf('}', i+2);
                String Placeholder = Subject.substring(i, j+1);
                
                system.debug('variable:' + Placeholder);
                Placeholder = ReplacePlaceholder(Placeholder);
                Subject = Subject.substring(0, i) + Placeholder + Subject.substring(j+1);
            }
                
        }
        
        for(Integer i = 0; i < Body.length() -2 ; i++) {
            if(Body.substring(i, i+2) == '{!') {
                //found {!, we are looking now for }
                if(Body.indexOf('}', i+2) > i+2)
                    j = Body.indexOf('}', i+2);
                String Placeholder = Body.substring(i, j+1);
                
                system.debug('variable:' + Placeholder);
                Placeholder = ReplacePlaceholder(Placeholder);
                Body = Body.substring(0, i) + Placeholder + Body.substring(j+1);
            }
                
        }
        system.debug('test3:' + Body);
    }
    
    public void fillFieldSchema(Map<String, SObjectField> Schema, String Obj, String Condition) {
        String query = 'select ';
        for(String s:Schema.keySet()) {
            query += s + ',';
        }
        query = query.substring(0, query.length()-1);
        query += ' from '+Obj+ Condition + ' limit 1';
        FieldSchema.put(Obj, new map<String, String>());
        sObject u = database.query(query);
        for(String s:Schema.keySet()) {
            FieldSchema.get(Obj).put(s, String.valueOf(u.get(s)));
        } 
        system.debug('FieldSchema:' + FieldSchema);
    }
    
    private void keyFieldMapping() {
        map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Set<String> keyPrefixSet = gd.keySet();
        for(String sObj : keyPrefixSet){
                Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
                if(r.getKeyPrefix() != null)
                  keyPrefixMap.put(r.getKeyPrefix(),r.getName());  
        }
    }

    
    public void removeFile() {
        if(DeleteId != null ) {
            integer j = 0;
            for(ContentVersion CV:CVList) {
                if(CV.Id == DeleteId)
                    break;
                j++;
            }
            if(!CVList.isEmpty())
                CVList.remove(j);
            
        }
    }
    
    
    
    public void Object2Email(String[] toAddresses, String[] ccAddresses, String[] bccAddresses ) {
        list<String> profileEmailMapping = new list<String>();
        list<String> roleEmailMapping = new list<String>();
        system.debug('to addresses:' + toAddresses);
        if(toAddresses != null) {
            for(String s:toAddresses) {
                system.debug('s part:' + s);
                if(s.contains('\',\'')) {
                    s = s.substring(s.indexOf('{')+2, s.lastIndexOf('}')-1);
                    system.debug('s part inside:' + s);
                    if(s.split('\',\'')[0].toLowerCase() == 'profile') {
                        system.debug('s part inside2:' + s.split('\',\'')[0]);
                        profileEmailMapping.add(s.split('\',\'')[1]);
                    }
                    else if(s.split('\',\'')[0].toLowerCase() == 'role')
                        roleEmailMapping.add( s.split('\',\'')[1]);
                }
            }
        }
        if(ccAddresses != null) {
            for(String s:ccAddresses) {
                if(s.contains('\',\'')) {
                    s = s.substring(s.indexOf('{')+2, s.lastIndexOf('}')-1);
                    if(s.split('\',\'')[0].toLowerCase() == 'profile')
                        profileEmailMapping.add(s.split('\',\'')[1]);
                    else if(s.split('\',\'')[0].toLowerCase() == 'role')
                        roleEmailMapping.add( s.split('\',\'')[1]);
                }
            }
        }
        if(bccAddresses != null) {
            for(String s:bccAddresses) {
                if(s.contains('\',\'')) {
                    s = s.substring(s.indexOf('{')+2, s.lastIndexOf('}')-1);
                    if(s.split('\',\'')[0].toLowerCase() == 'profile')
                        profileEmailMapping.add(s.split('\',\'')[1]);
                    else if(s.split('\',\'')[0].toLowerCase() == 'role')
                        roleEmailMapping.add( s.split('\',\'')[1]);
                }
            }
        }
        if(!profileEmailMapping.isEmpty()) {
            for(User u:[select profile.Name, email from User where profile.Name IN: profileEmailMapping]) {
                if(!profileMapEmailMapping.containsKey(u.profile.Name))
                    profileMapEmailMapping.put(u.profile.Name, new list<String>());
                profileMapEmailMapping.get(u.profile.Name).add(u.email);
            }
        }
        if(!roleEmailMapping.isEmpty()) {
            for(User u:[select UserRole.Name, email from User where UserRole.Name IN: roleEmailMapping]) {
                if(!roleMapEmailMapping.containsKey(u.UserRole.Name))
                    roleMapEmailMapping.put(u.UserRole.Name, new list<String>());
                roleMapEmailMapping.get(u.UserRole.Name).add(u.email);
            }
        }
        system.debug('profiles:' + profileMapEmailMapping);
    }
    
    public list<String> CleaningAddresses(list<String> Addresses) {
        list<String> FinalAddresses = new list<String>();
        list<String> Addresses2workOn = new list<String>();
        for(String s:Addresses) {
            if(!s.contains('\',\''))
                FinalAddresses.add(s);
            else
                Addresses2workOn.add(s);
        }
        for(String s:Addresses2workOn) {
            s = s.substring(2, s.length() - 2);
            if(s.split('\',\'')[0] == 'role') {
                if(roleMapEmailMapping.containsKey(s.split('\',\'')[1]))
                    FinalAddresses.addAll(roleMapEmailMapping.get(s.split('\',\'')[1]));
            }
            else {
                if(profileMapEmailMapping.containsKey(s.split('\',\'')[1]))
                    FinalAddresses.addAll(profileMapEmailMapping.get(s.split('\',\'')[1]));
            }
        }
        system.debug('final Addresses:' + FinalAddresses);
        return FinalAddresses;
    }
    
    public void SendEmail() {
        if(EmailTo != null && EmailTo != '') {
            // First, reserve email capacity for the current Apex transaction to ensure   
            // that we won't exceed our daily email limits when sending email after the current transaction is committed. 
            Messaging.reserveSingleEmailCapacity(2);
            
            // Processes and actions involved in the Apex transaction occur next, which conclude with sending a single email.   
            // Now create a new single email message object that will send out a single email to the addresses in the To, CC & BCC list.   
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // Strings to hold the email addresses to which you are sending the email. 
            String[] toAddresses = EmailTo.split(';');
            String[] ccAddresses = (EmailCC==null||EmailCC=='')?null:EmailCC.split(';') ; 
            String[] bccAddresses = (EmailBCC==null||EmailBCC=='')?null:EmailBCC.split(';') ; 
            
            Object2Email(toAddresses, ccAddresses, bccAddresses );
            if(toAddresses != null)
                toAddresses = CleaningAddresses(toAddresses);
            if(ccAddresses != null)
                ccAddresses = CleaningAddresses(ccAddresses);
            if(bccAddresses != null)
                bccAddresses = CleaningAddresses(bccAddresses);
            
            // Assign the addresses for the To and CC lists to the mail object.     
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            mail.setBCcAddresses(bccAddresses);
            // Specify the address used when the recipients reply to the email.
            User u = [select id, email from User where Id =: UserInfo.getUserId()];
            mail.setReplyTo(u.email);
            
            // Specify the name used as the display name.    
            mail.setSenderDisplayName(UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
            
            // Specify the subject line for your email address. 
            mail.setSubject(Subject);
            
            // Set to True if you want to BCC yourself on the email.  
            mail.setBccSender(addAutoBCC);
            
            // Optionally append the salesforce.com email signature to the email. 
            // The email address of the user executing the Apex Code will be used. 
            mail.setUseSignature(hasSignature);
            
            // Specify the text content of the email.   
            mail.setHtmlBody(Body);
            
            // Send the email you have created. 
            //
            list<Messaging.EmailFileAttachment> EFAList = new list<Messaging.EmailFileAttachment>();
            list<Id> CVIds = new list<Id>();
            for(ContentVersion CV:CVList) {
                CVIds.add(CV.Id);
            }
            Messaging.EmailFileAttachment EFA;
            for(ContentVersion CV:[select VersionData, PathOnClient, ContentDocumentId from ContentVersion where Id IN: CVIds ]) {
                EFA = new Messaging.EmailFileAttachment();
                EFA.setFileName(CV.PathOnClient);
                EFA.setBody(CV.VersionData);
                EFA.setInline(false);
                EFAList.add(EFA);
            }
            
            mail.setFileAttachments(EFAList);
            
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                AlertSuccessErrorAfterSend = 'Your message has been sent';
            }
            catch(exception e) {
                AlertSuccessErrorAfterSend = e.getMessage();
            }

        }
    }
  
}