trigger beforeinsertUpdatePrg_ManagerNames on Tuition_Refund__c (before insert, after insert) {
//Update Program Admin from Custom Settings. Populate HR Manager from Degree Declaration record selected by user.
//HR manager is populated as a lookup field such that it can be used as a related user within the approval process 

    String prgAdmin = tuition_reimbursement__c.getInstance('Default').Program_Admin_UserName__c;
     String linkPrefix = tuition_reimbursement__c.getInstance('Default').Linkprefix__c;
    String lookupDegree;
    String lookupTRefund; 
    User programAdm = [Select Id, Name from User where UserName=:prgAdmin];    
  if(Trigger.isBefore) {
 // create a set of all the unique degree declaration lookup field ids
    Set<id> degreeDeclarationIds = new Set<id>();
    for(Tuition_Refund__c tuitionRefund : Trigger.new)
        degreeDeclarationIds.add(tuitionRefund.Degree_Declaration__c);   
 
    // query for all the degree declaration records for the unique degree declaration Ids in the records
    // create a map for a lookup / hash table for the degree declaration  info
    Map<id, Degree_Declaration__c> degrees = new Map<id, Degree_Declaration__c>([Select Manager__c,HR_Manager__c from Degree_Declaration__c Where Id in :degreeDeclarationIds]);  
 
    // iterate over the list of records being processed in the trigger and
    // set the following fields
    for(Tuition_Refund__c tuitionRefund: Trigger.new){   
              tuitionRefund.Program_Admin_Approver__c = programAdm.Id;       
              tuitionRefund.Program_Admin_Name__c = programAdm.Name;
              tuitionRefund.Linkprefix__c = linkPrefix;
              tuitionRefund.Manager__c = degrees.get(tuitionRefund.Degree_Declaration__c).Manager__c;
              tuitionRefund.HR_Manager__c = degrees.get(tuitionRefund.Degree_Declaration__c).HR_Manager__c;
      }
  }   
  if(Trigger.isAfter) {
    // Create a new list of sharing objects for Job 
    List<Tuition_Refund__Share> tuitionRefundShrs  = new List<Tuition_Refund__Share>();
 
    // Declare variables for Manager and HR Manager sharing 
    Tuition_Refund__Share managerShr;
    Tuition_Refund__Share hrmanagerShr;
    Tuition_Refund__Share prgAdminShr;
  
    for(Tuition_Refund__c createdrecord : Trigger.New) { 
      // Instantiate the sharing objects 
      managerShr = new Tuition_Refund__Share();
      hrmanagerShr = new Tuition_Refund__Share();
      prgAdminShr = new Tuition_Refund__Share();
          
      // Set the ID of record being shared 
      managerShr.ParentId = createdrecord.Id;
      hrmanagerShr.ParentId = createdrecord.Id;
      prgAdminShr.ParentId = createdrecord.Id;

      // Set the ID of user or group being granted access 
      managerShr.UserOrGroupId = createdrecord.Manager__c;
      hrmanagerShr.UserOrGroupId = createdrecord.HR_Manager__c;
      prgAdminShr.UserOrGroupId = createdrecord.Program_Admin_Approver__c;
            
      // Set the access level 
      managerShr.AccessLevel = 'read';
      hrmanagerShr.AccessLevel = 'read';
      prgAdminShr.AccessLevel = 'edit';
            
      // Set the Apex sharing reason for Manager and HR Manager 
      managerShr.RowCause = Schema.Tuition_Refund__Share.RowCause.Share_record_with_Manager_and_HR_Manager__c;
      hrmanagerShr.RowCause = Schema.Tuition_Refund__Share.RowCause.Share_record_with_Manager_and_HR_Manager__c;
      prgAdminShr.RowCause = Schema.Tuition_Refund__Share.RowCause.Share_record_with_Manager_and_HR_Manager__c;
            
      // Add objects to list for insert 
      tuitionRefundShrs.add(managerShr);
      tuitionRefundShrs.add(hrmanagerShr);
      tuitionRefundShrs.add(prgAdminShr);
    }   
    // Insert sharing records and capture save result  
    // The false parameter allows for partial processing if multiple records are passed  
    // into the operation  
    Database.SaveResult[] lsr = Database.insert(tuitionRefundShrs,false);
    // Create counter 
    Integer i=0;
    // Process the save results 
    for(Database.SaveResult sr : lsr){
      if(!sr.isSuccess()){
        // Get the first save result error 
        Database.Error err = sr.getErrors()[0];
        // Check if the error is related to a trivial access level 
        // Access levels equal or more permissive than the object's default  
        // access level are not allowed.  
        // These sharing records are not required and thus an insert exception is acceptable.  
        if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                               &&  err.getMessage().contains('AccessLevel'))){
          // Throw an error when the error is not related to trivial access level. 
          trigger.newMap.get(tuitionRefundShrs[i].ParentId).
                      addError('Unable to grant sharing access due to following exception:' + err.getMessage());
        }
      }  
      i++;
    } 
  }    
}