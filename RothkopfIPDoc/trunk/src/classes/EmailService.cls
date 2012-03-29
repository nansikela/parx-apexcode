/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class EmailService implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        Document__c doc = new Document__c();
        doc.Meta_From_List__c = envelope.fromAddress;
        
        
        if(email.ccAddresses != null) {
        	doc.Meta_CC_List__c = '';
	        for(String s: email.ccAddresses) {
	        	if(s != null)
	               doc.Meta_CC_List__c += s + '; ';
	        } 
	        if(doc.Meta_CC_List__c.endsWith('; '))
	           doc.Meta_CC_List__c = doc.Meta_CC_List__c.substring(0, doc.Meta_CC_List__c.length() - 2);
        }
        if(email.toAddresses != null) {
            doc.Meta_To_List__c = '';
            for(String s: email.toAddresses) {
                if(s != null && s != envelope.toAddress)
                   doc.Meta_To_List__c += s + '; ';
            } 
            if(doc.Meta_To_List__c.endsWith('; '))
               doc.Meta_To_List__c = doc.Meta_To_List__c.substring(0, doc.Meta_To_List__c.length() - 2);
        }
        
        doc.Title__c = 'Email Service';
        doc.Meta_Subject__c = email.subject;
        doc.Body__c = email.htmlBody; 
        doc.PDF2Produce__c = true;
        set<String> ToAddresses = new set<String>();
        ToAddresses.addAll(email.toAddresses);
        
        for(Contact con:[select id, Email from Contact where Email =: envelope.fromAddress OR Email IN: email.toAddresses]) {
        	if(con.Email == envelope.fromAddress)
        	   doc.Meta_From__c = con.Id;
        	if(ToAddresses.contains(con.Email))
               doc.Meta_To__c = con.Id;
        }
        
        insert doc;


        return result;
    }
}