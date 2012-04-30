trigger beforeinsertUpdateProgramAdminName on Degree_Declaration__c (before insert, after insert) {
  String prgAdmin = tuition_reimbursement__c.getInstance('Default').Program_Admin_UserName__c;
  String linkPrefix = tuition_reimbursement__c.getInstance('Default').Linkprefix__c;
 // System.debug('prgAdmin:' + prgAdmin);
  User programAdm = [Select Id, Name from User where UserName=:prgAdmin]; 

  if(Trigger.isBefore) { 
    for(Degree_Declaration__c createdrecord : Trigger.New) { 
      createdrecord.Program_Admin_Approver__c = programAdm.Id;
      createdrecord.Program_Admin_Name__c = programAdm.Name;
      createdrecord.Linkprefix__c = linkPrefix;
    }
  }        

  if(Trigger.isAfter) {
    // Create a new list of sharing objects for Job 
    List<Degree_Declaration__Share> degreeShrs  = new List<Degree_Declaration__Share>();
 
    // Declare variables for Manager and HR Manager sharing 
    Degree_Declaration__Share managerShr;
    Degree_Declaration__Share hrmanagerShr;
    Degree_Declaration__Share prgAdminShr;
  
    for(Degree_Declaration__c createdrecord : Trigger.New) { 
      // Instantiate the sharing objects 
      managerShr = new Degree_Declaration__Share();
      hrmanagerShr = new Degree_Declaration__Share();
      prgAdminShr = new Degree_Declaration__Share();
          
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
      prgAdminShr.AccessLevel = 'read';
            
      // Set the Apex sharing reason for Manager and HR Manager 
      managerShr.RowCause = Schema.Degree_Declaration__Share.RowCause.Share_record_with_Manager_and_HR_Manager__c;
      hrmanagerShr.RowCause = Schema.Degree_Declaration__Share.RowCause.Share_record_with_Manager_and_HR_Manager__c;
      prgAdminShr.RowCause = Schema.Degree_Declaration__Share.RowCause.Share_record_with_Manager_and_HR_Manager__c;
      
            
      // Add objects to list for insert 
      degreeShrs.add(managerShr);
      degreeShrs.add(hrmanagerShr);
      degreeShrs.add(prgAdminShr);
      
    }   
    // Insert sharing records and capture save result  
    // The false parameter allows for partial processing if multiple records are passed  
    // into the operation  
    Database.SaveResult[] lsr = Database.insert(degreeShrs,false);
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
          trigger.newMap.get(degreeShrs[i].ParentId).
                      addError('Unable to grant sharing access due to following exception:' + err.getMessage());
        }
      }  
      i++;
    } 
  }
}