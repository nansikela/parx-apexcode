global class certificationCheck{   
    Webservice static boolean checkCertification(String recordId){
    List<Attachment> att = [Select Id from Attachment where ParentId =: recordId limit 1];
    SOD__c cert = [Select Certified_Complete__c,Compliance_Method__c from SOD__c where Id =: recordId];

        // check if attachment exists or Compliance Method not null
        if(att.size() > 0 || cert.Compliance_Method__c != null){
            //update Certified_Complete field value to Yes           
            if(cert.Certified_Complete__c != 'Yes'){
                    cert.Certified_Complete__c = 'Yes';
                    update cert;
            }           
            return true;
        }else{
            return false;
        }       
    }
}