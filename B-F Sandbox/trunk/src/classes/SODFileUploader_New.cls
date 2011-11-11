/*********************************************************************************************************
    Name    : SODFileUploader_New
    Desc    : VF controller which drives the Upload SOD VF page.
              This controller is used to parse the uploaded file, create records in certificates 
              record object using the parsed data, send emails to unique contacts.  

    Approach: 

    Modification Log :  
--------------------------------------------------------------------------------------------------------
 Developer                                 Date             Description
--------------------------------------------------------------------------------------------------------
Raj Rao                                                   Original Version
Fayas Mansoor(Deloitte Consulting)      18/05/2011        Modularized and cleansed the code for effeciency 
Fayas Mansoor(Deloitte Consulting)      23/05/2011        Error Handling for file size more than 5 MB 
Mani Kumar  (Deloitte Consulting)       06/06/2011        Added Set code to handle unique contacts
Raj Rao                                 07/12/2011        Moved line 164 to 161 to ensure the record ownership is assigned to all records based on tsid   
*********************************************************************************************************/

public class SODFileUploader_New
{
    /*************************************************
    // Attributes
     *************************************************/ 
    string checkFileFormat;
    String controlDate;
    Date dueDate; 
    String[] filelines = new String[]{};
    List<SOD__c> sodsUpload=new List<SOD__c>();
    String tempSOXContactID ='xxxxxxx';
    String tempSODGroupID = 'yyyyyyy';
    List<User> users;
    Map<String,User> usermap;
    Id userId;
    List<String> uniqueSOXContacts = new List<String>(); // Define a new set to store unique SOX Contacts
    List<User> noneligibleownerlist= new List<User>();

    /*************************************************************************************
    
    // Class Methods
    
     *************************************************************************************/

    /*************************************************************************************
    
    // Getters and Setters
    
     ************************************************************************************/
    public transient string nameFile{get;set;}
    public transient Blob contentFile{get;set;}
    public transient Integer fileSize {get; set;}

    /**************************************************************************************

    //Method Name        : fileToSOD
    //Method Return Type : List<SOD__c> 
    //Method Description : Parse the file to create list of sod object record. 
                           
    **************************************************************************************/

    List<SOD__c> fileToSOD(String[] filelines)
    {
        List<SOD__c> sodRecords=new List<SOD__c>();
        SOD__c s = new SOD__c();                  
        for (Integer i=0;i<filelines.size();i++)
        {
            //Parse String inputvalues and assign values to variables
            if(i==0){            
                s.Name = filelines[i].substring(0,50).trim();// SOX Contact
                s.SOX_Contact_ID__c = filelines[i].substring(50,57).trim();
                s.SOD_Group_ID__c = filelines[i].substring(60,110).trim();
                s.User_Id_s__c = filelines[i].substring(164,171).trim();
                s.User_Name_s__c = filelines[i].substring(171,224).trim();
                s.Business_Process_Owner__c = filelines[i].substring(274,424).trim();
                s.Certified_Complete__c = 'No';
                s.Control_Date__c = filelines[i].substring(682,696).trim();
                s.Due_Date__c = DueDate(filelines[i].substring(682,696).trim());
                //store UniqueID in the following format SoXContatID_GroupID_ControlDate
                s.UniqueID__c = filelines[i].substring(50,57).trim()+'_'+filelines[i].substring(60,110).trim()+'_'+filelines[i].substring(682,696).trim();
                //change ownership to SoxContactID by querying the User Object where tsid = soxContactId; 
                s.tsid__c=filelines[i].substring(50,57).trim();                   
            }
            else{
                //same SOX ContactID and SODGroupID
                if(tempSOXContactID.equals(filelines[i].substring(50,57).trim()) && tempSODGroupID.equals(filelines[i].substring(60,110).trim())){
                    //Append the User IDs and User Names
                    s.User_Id_s__c += '\n'+filelines[i].substring(164,171).trim();
                    s.User_Name_s__c += '\n'+filelines[i].substring(171,224).trim();
                }
                else{
                    sodRecords.add(s);
                    s= new SOD__c();
                    s.Name = filelines[i].substring(0,50).trim();// SOX Contact
                    s.SOX_Contact_ID__c = filelines[i].substring(50,57).trim();
                    s.SOD_Group_ID__c = filelines[i].substring(60,110).trim();
                    s.User_Id_s__c = filelines[i].substring(164,171).trim();
                    s.User_Name_s__c = filelines[i].substring(171,224).trim();
                    s.Business_Process_Owner__c = filelines[i].substring(274,424).trim();
                    s.Certified_Complete__c = 'No';
                    s.Control_Date__c = filelines[i].substring(682,696).trim();
                    controlDate=s.Control_Date__c;
                    s.Due_Date__c = DueDate(filelines[i].substring(682,696).trim());
                    dueDate=s.Due_Date__c;
                    //store UniqueID in the following format SoXContatID_GroupID_ControlDate
                    s.UniqueID__c = filelines[i].substring(50,57).trim()+'_'+filelines[i].substring(60,110).trim()+'_'+filelines[i].substring(682,696).trim();
                    //change ownership to SoxContactID by querying the User Object where tsid = soxContactId; 
                    s.tsid__c=filelines[i].substring(50,57).trim();
                } 
            }    
            //Assign SOXContactID and SODGroupID to temporary variables
            tempSOXContactID = filelines[i].substring(50,57).trim();
            tempSODGroupID = filelines[i].substring(60,110).trim();
            if(i==(filelines.size()-1)){
                sodRecords.add(s);
            }
        }// end for loop

        Set<String> TSID=new Set<string>();
        
        for(SOD__c sod:sodRecords)
        {
            if(!TSID.contains(sod.tsid__c))
                TSID.add(sod.tsid__c);
        }
        Map<id,id> profileid_licenseid= new Map<id,id>();
        Map<id,String> licenseid_licenseName= new Map<id,String>();
        
        List<Profile> profiles=[Select p.Name,p.UserLicenseId, p.Id From Profile p];
        List<UserLicense> userLicense=[Select u.Name, u.Id From UserLicense u];
        
        for(Profile p:profiles)
        {
            profileid_licenseid.put(p.id,p.UserLicenseId);
        }
        
        for(UserLicense ul:userLicense)
        {
            licenseid_licenseName.put(ul.id,ul.Name);
        }
        
        users= [Select u.TSID__c, u.ProfileId, u.Id, u.Email, u.FirstName,u.LastName  From User u where u.TSID__c IN :TSID];
        //usermap = new Map<Id,User>([Select u.TSID__c, u.ProfileId, u.Id, u.Email, u.FirstName,u.LastName  From User u where u.TSID__c IN :TSID]);
        usermap  = new Map<String,User>();
        for(User u: users){
            usermap.put(u.TSID__c,u);
        }
        
        System.debug('The list of users '+ UserMap);
        // Set to hold all license types that do not qualify a user to be an owner of record
        Set<String> noneligibleUserLicenses=new Set<string>();
        noneligibleUserLicenses.add('Chatter Free');
        Set<String> uniqueSOXContactsSet = new Set<String>(); // Define a new set to store unique SOX Contacts
        // To assign ownership of SOD records and also find non eligible owners due to license issues if any
        
        uniqueSOXContacts.clear();
        System.debug('The size of the uniqueSOXContacts ------> 1 ---'+ uniqueSOXContacts.size());
        for(SOD__c sod:sodRecords)
        {
            if(usermap.containsKey(sod.TSID__c)){
                User u = usermap.get(sod.tsid__c);
                sod.OwnerId=u.Id;
                    if(!noneligibleUserLicenses.contains(licenseid_licenseName.get(profileid_licenseid.get(u.ProfileId))))
                    {
                        if(!uniqueSOXContactsSet.contains(u.Id)){
//                            sod.OwnerId=u.Id; moved to line 161 to ensure all records are assigned ownership based on TSID
                            uniqueSOXContacts.add(u.email);
                            uniqueSOXContactsSet.add(u.Id);
                            System.debug('The unique emailid added to the list is  &&&& email id &&&&----> '+ u.Id);
                            System.debug('The List after added new email id ----->'+ uniqueSOXContactsSet.add(u.email));
                            System.debug('The size of the list is' + uniqueSOXContacts.size());
                            
                        }
                    }
                    else
                    {
                        noneligibleownerlist.add(u);
                    }
        }
        }
        System.debug('The size of the uniqueSOXContacts ------> 2 ---'+ uniqueSOXContacts.size());
        return sodRecords;
    }
    
    /**************************************************************************************

    //Method Name        : insertRecord
    //Method Return Type : Pagereference 
    //Method Description : Master method that is invoked from VF page(UploadData).
                           Insert record(s) returned from filetoSOD method.
                           
    ***************************************************************************************/    
    
    public Pagereference insertRecord()
    {

        //check if user has selected a file
        try{
        if(fileSize>5242000){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                    'Size of file to attach cannot be greater than 5MB'));
                return null;
            }
            nameFile=contentFile.toString();
            filelines = nameFile.split('\n');
            checkFileFormat = filelines[0].substring(424,427).trim();
        }catch(Exception e){
            if(nameFile == null){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Select file to Upload !');
                ApexPages.addMessage(errormsg);
            }
        }
        try{
            sodsUpload=fileToSOD(filelines);
        
        }catch(Exception e){
            //if checkFileFormat is null we will assume that the file format is incorrect
            if(checkFileFormat== null){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Incorrect file format !');
                ApexPages.addMessage(errormsg);
            }else{
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured ! '+e);
                ApexPages.addMessage(errormsg);
            }
        }
        try{
            insert sodsUpload;
            //Display number of records uploaded
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,sodsUpload.size() +' records have been uploaded');
            ApexPages.addMessage(errormsg);
            sendOwnerEmails();
            if(noneligibleownerlist.size()>0)
                sendNonEligibleOwnerListEmail();
        }
        catch(Exception e)
        {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Data Insertion failed, Check if duplicate record(s) currently exist in the system');
            ApexPages.addMessage(errormsg);
        }
        return null;
    }

    /**************************************************************************************
    
    //Method Name        : DueDate
    //Method Return Type : Date 
    //Method Description : Method to calculate due date
                           
    ***************************************************************************************/

    Date DueDate(String theDate){
        Date dueDate;
        //parse the Month year string
        String theMonth = theDate.substring(0,theDate.indexOf(' '));
        String theYear = theDate.substring(theDate.indexOf(' ')+1); 
        //check month and format date to first of that month
        Map<String,String> months=new Map<string,string>();
        months.put('january','1/1/' + theYear);
        months.put('february','2/1/' + theYear);
        months.put('march','3/1/' + theYear);
        months.put('april','4/1/' + theYear);
        months.put('may','5/1/' + theYear);
        months.put('june','6/1/' + theYear);
        months.put('july','7/1/' + theYear);
        months.put('august','8/1/' + theYear);
        months.put('september','9/1/' + theYear);
        months.put('october','10/1/' + theYear);
        months.put('november','11/1/' + theYear);
        months.put('december','12/1/' + theYear);
        theDate=months.get(theMonth.toLowerCase());
        dueDate=Date.parse(theDate);
        dueDate=dueDate.addMonths(2).addDays(-1);
        
        return dueDate;
    }

    /**************************************************************************************
    
    //Method Name        : sendOwnerEmails
    //Method Return Type : Void 
    //Method Description : Method to send emails to contacts.
                           
    ***************************************************************************************/

    void sendOwnerEmails(){
        
        Messaging.SingleEmailMessage message = mailTextSetup();
        // BCC has 25 limit and 10 sendMail per transcation hence 250
        
        
        if(uniqueSOXContacts.size()<=250 && message!=null)
        {
            Messaging.reserveSingleEmailCapacity(uniqueSOXContacts.size());
            String[] addr25=new String[25];
            String[] cc = new String[1];
            cc[0] = 'nancy_burns@b-f.com';
            String[] addrRest=new String[Math.MOD(uniqueSOXContacts.size(),25)];
            //BCC addr has a limit of 25
            Integer i=0,size=uniqueSOXContacts.size();
            while(size!=0)
            {
                if(size<25)
                {   
                    for(Integer k=0;k<size;k++)
                    addrRest[Math.MOD(k,25)]=uniqueSOXContacts.get(i++);
                    message.setBccAddresses(addrRest);
                    message.setCcAddresses(cc);
                    Messaging.sendEmail(new Messaging.Email[] {message});
                    size=size-Math.MOD(size,25);
                }
                else
                {
                    for(Integer j=0;j<25;j++)
                    addr25[j]=uniqueSOXContacts.get(i++);
                    message.setBccAddresses(addr25);
                    message.setCcAddresses(cc);
                    Messaging.sendEmail(new Messaging.Email[] {message});
                    size=size-25;
                }
            }       
//            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,'Emails Sent to '+uniqueSOXContacts());
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.INFO,'Emails have been sent to all SOX Contacts');
            ApexPages.addMessage(errormsg);
        }
        else
        {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Emails failed! Check configuration!');
            ApexPages.addMessage(errormsg);
        }
        uniqueSOXContacts.clear();
    }

    /**************************************************************************************

    //Method Name        : mailTextSetup
    //Method Return Type : String 
    //Method Description : This method populates the content of mail with appropriate data

    ***************************************************************************************/
    
    Messaging.SingleEmailMessage mailTextSetup()
    {
        //Custom setting data
        List<SOD_Email__c> emailDetails=SOD_Email__c.getall().values();
        List<Email_placeholders__c> placeholders=Email_placeholders__c.getall().values();
        List<SOD_Email_Subject__c> subject=SOD_Email_Subject__c.getall().values();

        Map<String,String> linetoBody=new Map<string,string>();
        Map<String,String> placeholderorder=new Map<string,string>();
        Id sodid;
        String ph='';       
        ApexPages.Message errormsg;
        Messaging.SingleEmailMessage singleMail= new Messaging.SingleEmailMessage();
        // Subject of mail set
        //singleMail.setSubject(subject[0].Subject__c);
        List<OrgWideEmailAddress> owa = [select id, Address from OrgWideEmailAddress LIMIT 1];
        if(owa.size()>0)
            singleMail.setOrgWideEmailAddressId(owa[0].id);
        String emailBody='';
        // Mail Body ordering 
        for(SOD_Email__c em:emailDetails)
        {
            linetoBody.put(em.Name,em.Email_Body__c);
        }
        // Ordering the placeholder
        
        for(Email_placeholders__c em:placeholders)
        {
            placeholderorder.put(em.Name,em.fieldAPIName__c);
        }
        // Mail body preparation
        for(Integer i=1;i<=emailDetails.size();i++)
        {
            emailBody+=linetoBody.get('Line'+i);
        }
        String[] splitemailBody=emailBody.split(':placeholder:',0);
        //Preparing the query
        
        for(Email_placeholders__c e:placeholders)
        {
            ph=ph+e.fieldAPIName__c+',';
        }
        ph=ph.substring(0,ph.length()-1);
        
        if(sodsUpload.size()>0)
            sodid=sodsUpload.get(0).Id;
        else
            {
            errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'No records to be inserted');
            ApexPages.addMessage(errormsg);
            return null;    
            }
            
        String qryString='SELECT id,'+ph+' FROM SOD__c WHERE id=:sodid LIMIT 1';
        //querying for placeholder data
        List<SOD__c> sod=Database.query(qryString) ;
        
        // Subject of mail set        
        singleMail.setSubject(subject[0].Subject__c + ' ' + sod[0].get(placeholderorder.get('Placeholder1')));
        
        emailBody='';
        //preparing the email body with data in place of placeholders
        if(placeholders.size()==splitemailBody.size()-1)
        {
            for(Integer i=1;i<splitemailBody.size();i++)
            {
                emailBody+=splitemailBody[i-1]+sod[0].get(placeholderorder.get('Placeholder'+i));   
            }
            emailBody=emailBody+splitemailBody[splitemailBody.size()-1];
            singleMail.setHTMLBody(emailBody);
            return singleMail;
        }
        else
        { //email configuration error
            errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'Emails are not configured correctly!');
            ApexPages.addMessage(errormsg);
        }
        return null;
        
    }


    /**************************************************************************************

    //Method Name        : uniqueSOXContacts
    //Method Return Type : String 
    //Method Description : Returns a string with all the mail ids(seperated with comma) to 
                           whom the mail has been send.

    ***************************************************************************************/

    String uniqueSOXContacts(){
        String myUniqueSOXContacts=' ';
        for(String s : uniqueSOXContacts) {
            myUniqueSOXContacts+= s +',';
        }    
        myUniqueSOXContacts=myUniqueSOXContacts.substring(0,myUniqueSOXContacts.length()-1);
        return myUniqueSOXContacts;
    }

    /**************************************************************************************

    //Method Name        : getuploadedSODs
    //Method Return Type : List<SOD__c> 
    //Method Description : To return the list of sod recorded inserted into the system.

    ***************************************************************************************/
    /*
    public List<SOD__c> getuploadedSODs()
    {
        if (sodsUpload!= NULL)
            if (sodsUpload.size() > 0)
                return sodsUpload;

            else
                return null;                    
        else
            return null;
    }*/            

    /**************************************************************************************

    //Method Name        : sendNonEligibleOwnerListEmail
    //Method Return Type : void 
    //Method Description : Method sends a list of non eliglible owners to Nancy Burns

    ***************************************************************************************/

    void sendNonEligibleOwnerListEmail()
    {
        String emailBody;
        List<String> toAddresses=new List<string>();
        // List of users to whom this mail has to be send
        toAddresses.add('nancy_burns@b-f.com');
        Messaging.Singleemailmessage singleEmail=new Messaging.Singleemailmessage();
        singleEmail.setToAddresses(toAddresses);
        singleEmail.setSubject('Non Eligible Owner List');
        emailBody='Hello,<br><br>Please Note, the following users could not assigned as'+
                  ' Certification Record contacts by the system.Please check their'+
                  ' access level and remediate as needed.<br>';
        // populating the body with a list of non eligible owners
        for(User u:noneligibleownerlist)
        {
            emailBody+='<br>'+u.FirstName+' '+u.LastName+' : '+u.Email;
        }
        singleEmail.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.Email[] {singleEmail});
        noneligibleownerlist.clear();
    }
}