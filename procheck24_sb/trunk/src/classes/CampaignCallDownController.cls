/**

Last update 2010-07-15
labs@salesforce.com

* with sharing added
* squashed bugs around single / multiple updates
* added limits to SOQL -- 100 for Campaigns 1000 for Campaign Members
* fixed custom settings manager
* updated Static Resources 

*/
global with sharing class CampaignCallDownController{
    
    //setup appropriate variables
    private Boolean             hasCampaignID = false;
    //C.Vidal
    public Boolean              bearbeiterCheckbox {get;set;}
    private string              thisCampaign;
    private Lead[]              lead; 
    private Contact[]           contact;
    private transient CampaignMember[]    members; //the members for that campaign
    private Lead[]              relevantLeads; 
    private List<leadPlusTaskPlusContact>   leadPlusTasks;
    private Map<String, Boolean>            callDownColumns;    
    private List<Campaign>      activeCampaigns;
    public String               camp { get;set; } //campaign ID
    public String               status{ get;set; } //status ID
    private Map<String, String> cStatusMap;
    private boolean             cStatusMapIsSet;
    public string               campBackup;
    public string               backRef{ get; set; }
    public list<SelectOption>   owners;
    //C.Vidal: bearbeiters
    public list<SelectOption>   bearbeiters;
    public string               ownerId{ get; set; }
    public string               bearbeiterId{ get; set; }
    public static Id			recentRecordId	{get; set;}
    public String				bearbeiterVisible { get; private set; }
    
    /**
    *Constructor
    */
    public CampaignCallDownController(){
    	// controlls the stylesheet for visibility of bearbeiter selection and checkbox
    	// none: not visible
    	// inline: visible
    	bearbeiterVisible='none';
        //C.Vidal: checkbox
        bearbeiterCheckbox = true;
        
        relevantLeads = new Lead[ 0 ];
        leadPlusTasks = new leadPlusTaskPlusContact[]{};
        callDownColumns = new Map<String, Boolean>();
        
        //get columns settings and set to Map
        if( ApexPages.currentPage().getUrl() != null ){
            camp = ApexPages.currentPage().getUrl().substring( 1 );
        }
        campBackup = camp;
        backRef = '/apex/CampaignCallDownSettings?var=/' + camp;
        cStatusMap = new Map<String, String>();
        cStatusMapIsSet = false;
        owners = new list<SelectOption>();
        bearbeiters = new list<SelectOption>();
        //C.Vidal
        //if(camp == null)
        camp = ApexPages.currentPage().getParameters().get('campaignId');
        campaignRefresh();
        
    }
    
    /**
    *Return if has campaign id
    *@return hasCampaignID boolean flag
    */
    public Boolean gethasCampaignID(){
        return hasCampaignID;
    }
    
    //C.Vidal
    public List<SelectOption> getbearbeiters(){
        return bearbeiters;
    }
    
    /**
    *Return the list of owners
    *@return owners
    */
    public List<SelectOption> getowners(){
        return owners;
    }
    
    public void setowners( List<SelectOption> l ){
        owners = l;
    }
    
    /**
    * Returns activities for record
    *@return activities list<Task> list
    */
    public list<Task> getRecordActivities() {
    	if (recentRecordId!=null) return [SELECT Id, Subject, ActivityDate, Description FROM Task WHERE WhoId=:recentRecordId ORDER BY ActivityDate DESC limit 10];
    	//else return [SELECT Id, Subject, ActivityDate, Description FROM Task WHERE WhoId='00Qc0000000xrqEEAQ' ORDER BY ActivityDate limit 10];
    	else return new list<Task>();
    }
    
    @RemoteAction
    global static String getRecordMitgliedsinfo(String rId) {
    	if (rId!=null) return getMemberinfo(rId);
    	//else return [SELECT Id, Subject, ActivityDate, Description FROM Task WHERE WhoId='00Qc0000000xrqEEAQ' ORDER BY ActivityDate limit 10];
    	else return '';
    }
    
    /**
    *Update all status and log , retuen page reference for redirection
    *@return null
    */
    public PageReference updateAll(){
        List<leadPlusTaskPlusContact> cleanRecords = new List<leadPlusTaskPlusContact>();
    
         for( leadPlusTaskPlusContact current :leadPlusTasks ){
          //status
          boolean updated = false;
          if(current.statusUpdate != null && current.statusUpdate != current.memStatus){
            //update status
            CampaignMember cm = [Select Id, Status From CampaignMember Where id = :current.MemberId limit 1];
            cm.status = current.statusUpdate;
            update cm;
            
            updated = true;
          }
          
          // MRO: moved this from leadPlusTaskPlusContact Ctor
          Task t = new Task();
          t.ActivityDate = System.today();
          t.WhoId = current.ID;
          t.Status = 'Abgeschlossen';
          t.Subject = '';
          t.Description = '';
          t.CampaignId__c=camp;
          t.CampaignName__c=thisCampaign;
          if ( current.ID == null ){
              t.WhatId = camp;
          }
            
          Task followup = new Task();
          //followup.ActivityDate = System.today();
          followup.WhoId = current.ID;
          followup.Status = 'Offen';
          followup.Subject = '';
          followup.Description = '';
          followup.CampaignId__c=camp;
          followup.CampaignName__c=thisCampaign;
          if ( current.ID == null ){
              followup.WhatId = camp;
          }
          t.Description = current.memo;
          followup.Subject = current.followupTaskSubject;
          if (current.followupActivityDate != null && current.followupActivityDate != ''){
          	try {
          		String[] dateArray = current.followupActivityDate.split('\\.');
          		followup.ActivityDate = Date.newInstance(Integer.valueOf(dateArray[2]), Integer.valueOf(dateArray[1]), Integer.valueOf(dateArray[0]));
          		current.activityDateErrorMessage = '';
          	}
          	catch (Exception ex){
          		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Sie haben bei mindestens einem Eintrag ein falsches Datumsformat verwendet.\n' +
          		'Es wurde deswegen kein Eintrag gespeichert!\n' +
          		'Bitte suchen Sie auf dieser Seite nach Fehlermeldungen und beheben Sie bitte die Fehler.');
           		ApexPages.addMessage(myMsg);
           		current.activityDateErrorMessage = 'Falsches Datumsformat';
          	}
          }
          else if (current.followupActivityDate != null && current.followupActivityDate == ''){
          	current.activityDateErrorMessage = '';
          }
          
          if (! ApexPages.hasMessages()){
          //current.followup.ActivityDate = Date.today();
          if (updated || (t.Description != '' && t.Description != null) || (followup.Subject!=null && followup.Subject!='' && followup.ActivityDate!=null)) {
          //log a call
            if (t.Description != '' && t.Description != null) {
            	t.Subject = 'Anruf: '+this.getCampaignName();
            	insert t;
            
	            if (followup.Subject!=null && followup.Subject!='' && followup.ActivityDate!=null) {
	            	if (current.followupdesc) followup.Description=t.Description;
	            	followup.Subject = followup.Subject + ' ' +this.getCampaignName();
	            	insert followup;
	            }
            }
            updated = true;
          }
          if (!updated) {
            cleanRecords.add(current);
          }
          }      

         }
         if (! ApexPages.hasMessages()){ 
         	leadPlusTasks = cleanRecords;
         }
        return null;
    }
    
    /**
    *Filter Owners for leads
    */
    private void filterOwner(){
        if( ownerId == null || ownerId == '--ALL--' || leadPlusTasks.size() < 1 )
          return;
        else{
            list<leadPlusTaskPlusContact> newLptList = new list<leadPlusTaskPlusContact>();
            for( leadPlusTaskPlusContact lpt : leadPlusTasks ){
                if( lpt.ownerId == ownerId )
                  newLptList.add(lpt);
            }
            leadPlusTasks = newLptList;
        }
    }
    
    /**
    * return mitgliedsinfo from CampaignMember
    */
    private static String getMemberinfo(String rId) {
    	CampaignMember cm=[SELECT Id, ContactId, LeadId, Mitgliedsinfo__c FROM CampaignMember WHERE LeadId=:rId OR ContactId=:rId];
		if (cm!=null && cm.Mitgliedsinfo__c!=null)
			return cm.Mitgliedsinfo__c;
    	return 'Keine bestehende Mitglieder Information vorhanden!';
    }
    
    /**
    *Refresh campaign list
    *@return page reference
    */
    public PageReference campaignRefresh(){
        //bearbeiterCheckbox = true;
        Map<String, String>ownerMap = new Map<String, String>();
        //C.Vidal: bearbeiterMap
        Map<String, String>bearbeiterMap = new Map<String, String>();
        relevantLeads.clear(); leadPlusTasks.clear(); 
        cStatusMapIsSet = false;
        if ( camp != null && camp.length( ) >3 ){
            //set some variable values
            hasCampaignID = true;           
            try{
            //C.Vidal: change as dynamic query and add the param bearbeiter.
             String query = 'select Id, ContactId, LeadId, Status, CampaignId, Mitgliedsinfo__c, Campaign.Name, ' +
                    'Lead.Id, Lead.Salutation, Lead.Title, Lead.Name, Lead.isConverted, Lead.Company, Lead.Phone, Lead.Telefon_2__c, Lead.MobilePhone, ' +
                    'Lead.Street, Lead.State, Lead.PostalCode, Lead.Country, Lead.City, Lead.Fax, ' +
                    'Lead.Email, Lead.OwnerId, Lead.Owner.FirstName, Lead.Owner.LastName, Lead.Owner.Name, Lead.Owner.Id, ' +
                    'Contact.ID, Contact.AccountId, Contact.Salutation, Contact.Title, Contact.Name, ' +
                    'Contact.Phone, Contact.Telefon_2__c, Contact.MobilePhone, Contact.MailingStreet, Contact.MailingState, Contact.MailingPostalCode, ' +
                    'Contact.MailingCountry, Contact.MailingCity, Contact.Fax, Contact.Email, Contact.OwnerId,' +
                    'Contact.Owner.FirstName, Contact.Owner.LastName, Contact.Owner.Id, Contact.Account.name, Bearbeiter__c ' +
                    'from CampaignMember where CampaignId = :camp ';
                    if( status != null && status == '--ALL--' ) {
                    	// Filter the initial list
                    	query += ' AND Status != \'Erledigt mit Kontakt\' AND Status != \'Erledigt ohne Kontakt\'';
                    }
                    else if( status != null && status != '--ALL--' ) {
                       query += ' AND Status = :status ';
                    }
                    if( bearbeiterCheckbox) {
                       User u = [select Email, Alias, Name from user where Id =: UserInfo.getUserId()];
                       query += ' AND Bearbeiter__c = \'' + u.Alias  + '\' ';
                    }
                    else if( bearbeiterId != null && bearbeiterId != '--ALL--' ) {
                       query += ' AND Bearbeiter__c = :bearbeiterId ';
                    }
                    query += ' limit 100';
                members = database.query(query);    
               /* if( status == null || status == '--ALL--' )
                    members = [select Id, ContactId, LeadId, Status, CampaignId, Campaign.Name,
                    Lead.Id, Lead.Salutation, Lead.Title, Lead.Name, Lead.Company, Lead.Phone, 
                    Lead.Street, Lead.State, Lead.PostalCode, Lead.Country, Lead.City, Lead.Fax, 
                    Lead.Email, Lead.OwnerId, Lead.Owner.FirstName, Lead.Owner.LastName, Lead.Owner.Id,
                    Contact.ID, Contact.AccountId, Contact.Salutation, Contact.Title, Contact.Name, 
                    Contact.Phone, Contact.MailingStreet, Contact.MailingState, Contact.MailingPostalCode, 
                    Contact.MailingCountry, Contact.MailingCity, Contact.Fax, Contact.Email, Contact.OwnerId,
                    Contact.Owner.FirstName, Contact.Owner.LastName, Contact.Owner.Id, Contact.Account.name, Bearbeiter__c
                    from CampaignMember where CampaignId = :camp LIMIT 1000];
                else
                  members = [ select Id, ContactId, LeadId, Status, CampaignId, Campaign.Name,
                  Lead.Id, Lead.Salutation, Lead.Title, Lead.Name, Lead.Company, Lead.Phone, 
                  Lead.Street, Lead.State, Lead.PostalCode, Lead.Country, Lead.City, Lead.Fax, 
                  Lead.Email, Lead.OwnerId, Lead.Owner.FirstName, Lead.Owner.LastName, Lead.Owner.Id,
              Contact.ID, Contact.AccountId, Contact.Salutation, Contact.Title, Contact.Name, 
              Contact.Phone, Contact.MailingStreet, Contact.MailingState, Contact.MailingPostalCode,
               Contact.MailingCountry, Contact.MailingCity, Contact.Fax, Contact.Email, Contact.OwnerId,
              Contact.Owner.FirstName, Contact.Owner.LastName, Contact.Owner.Id, Contact.Account.name, Bearbeiter__c
              from CampaignMember where CampaignId = :camp and Status = :status LIMIT 1000];*/
            }catch( Exception e ){
                ApexPages.addMessages( e );
            }
            if( members.size() > 0 )            
                thisCampaign = members[ 0 ].Campaign.Name;
            else
                thisCampaign ='';
                    
                //loop through all leads, add relevent leads and their status
            for ( CampaignMember m : members ){
                leadPlusTaskPlusContact lpt = new leadPlusTaskPlusContact( m, getcStatusMap( camp ), camp, thisCampaign );
                leadPlusTasks.add( lpt );
                
                //C.Vidal: null fixed.
                ownerMap.put( lpt.ownerId, (lpt.ownerFirstName!=null?lpt.ownerFirstName:'') + ' ' + (lpt.ownerLastName!=null?lpt.ownerLastName:'') );
                //C.Vidal: BearbeiterMap
                if (!bearbeiterCheckbox)
                	bearbeiterMap.put( lpt.Bearbeiter, (lpt.ownerFirstName!=null?lpt.ownerFirstName:'') + ' ' + (lpt.ownerLastName!=null?lpt.ownerLastName:'') );
            }
                
            //set owners
            owners = ownerMapToSelectOption( ownerMap );
            //C.Vidal
            if (!bearbeiterCheckbox)
            	bearbeiters = bearbeiterMapToSelectOption( bearbeiterMap);
            //filter for owner
            filterOwner();
            if( leadPlusTasks.size() > 1 )
                quickSort( 'NAME',0, leadPlusTasks.size()-1 );
        }else{ 
            hasCampaignID=false;
            camp=this.campBackup;
        }
        return null;
    }
    
    //C.Vidal
    private List<SelectOption> bearbeiterMapToSelectOption( Map<String, String> ownerMap ){
        List<SelectOption> returnVal=new List<SelectOption>();
        Set<String> keys = new Set<String>();
        keys = ownerMap.keySet();
        returnVal.add( new SelectOption( '--ALL--', '--ALL--' ));
        for(User u:[select Email, Name, Alias from User where Alias IN: ownerMap.keySet()]) {
            returnVal.add( new SelectOption(u.Alias, u.Name));
        }
        
        return returnVal;
    }
    
    /**
    *With a map of owners and return a list of select option
    *@param ownerMap
    *@return returnVal
    */
    private List<SelectOption> ownerMapToSelectOption( Map<String, String> ownerMap ){
        List<SelectOption> returnVal=new List<SelectOption>();
        Set<String> keys = new Set<String>();
        keys = ownerMap.keySet();
        returnVal.add( new SelectOption( '--ALL--', '--ALL--' ));
        for ( String s: keys ){
            returnVal.add( new SelectOption(s, ownerMap.get( s )));
        }
        
        return returnVal;
    }
    
    /**
    *Sort by name
    *@return null
    */
    public PageReference sortByName(){
        if( leadPlusTasks.size() > 1 )
            quickSort( 'NAME',0, leadPlusTasks.size()-1 );
        return null;
    }

    /**
    *Sort by title
    *@return null
    */
    public PageReference sortByTitle(){
        if( leadPlusTasks.size() > 1 )
            quickSort( 'TITLE',0, leadPlusTasks.size()-1 );
        return null;
    }   

    /**
    *Sort by Company
    *@return PageReference = null
    */
    public PageReference sortByCompany(){
        if( leadPlusTasks.size() > 1 )
            quickSort( 'COMPANY',0, leadPlusTasks.size()-1 );
        return null;
    } 
  
    /**
    *Sort by Status
    *@return PageReference = null
    */
    public PageReference sortByStatus(){
        if( leadPlusTasks.size() > 1 )
            quickSort( 'STATUS',0, leadPlusTasks.size()-1 );
        return null;
    } 
    
    /**
    *Implementation of Quick sort
    *@param key
    *@param left
    *@param right
    */
    private void quickSort( String key, integer left, integer right ){
      integer index = partition( key, left, right );
      if ( left < index - 1 )
        quickSort( key, left, index - 1 );
      if (index < right )
        quickSort( key, index, right );
    }
    
    /**
    *Aux method for implement Quick Sort
    *@param key
    *@param left
    *@param right
    *@return i
    */
    private integer partition( String key, integer left, integer right ){
      integer i = left, j = right;
      leadPlusTaskPlusContact tmp;
      leadPlusTaskPlusContact pivot = leadPlusTasks[( left + right ) / 2 ];
      while ( i <= j ){
        while ( compare( key, leadPlusTasks[ i ], pivot ))
          i++;
        while ( compare( key, pivot,leadPlusTasks[ j ]))
          j--;
        if ( i <= j ){
          tmp = leadPlusTasks[ i ];
          leadPlusTasks[  i] = leadPlusTasks[ j ];
          leadPlusTasks[ j ] = tmp;
          i++;
          j--;
        }
      }
      return i;
  }
    
    /**
    *Compare 2 leads
    *@sortKey
    *leadPlusTaskPlusContact
    *leadPlusTaskPlusContact
    *@return Boolean
    */
    private boolean compare( string sortKey, leadPlusTaskPlusContact r1, leadPlusTaskPlusContact r2 ){
       if( sortKey=='TITLE' )
         return r1.TITLE < r2.TITLE;
       else if( sortKey == 'COMPANY' )
         return r1.COMPANY < r2.COMPANY;
       else if( sortKey == 'STATUS')
         return r1.memStatus < r2.memStatus;
       else 
         return r1.NAME < r2.NAME;
    }
    
    /**
    *Return a status map
    *@param cId
    *@return cStatusMap
    */
    public Map<String,String> getcStatusMap( string cId ){
        if( !cStatusMapIsSet ){
            CampaignMemberStatus[] cStatus = [ Select Label From CampaignMemberStatus where campaignId =: cId ]; 
            cStatusMap.clear();
            for ( CampaignMemberStatus s:cStatus )
                cStatusMap.put( s.Label, '' );
            cStatusMapIsSet = true;
        }  
        return cStatusMap;
    }
    
    /**
    *Return campaign items
    *@return options
    */
    public List<SelectOption> getcampaignItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption( '1', 'SELECT' ));
        for( Campaign c:getactiveCampaigns()){
            options.add( new SelectOption( c.ID, c.Name ));
        }
        return options;
    }
   
    /**
    *Return status items option list 
    *@return options
    */
    public List<Selectoption> getstatusItems(){
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '--ALL--', '--ALL--' ));
        if ( camp == null || camp == '1' ){
            return options;
            }
        else    {
            for ( String k : getcStatusMap( camp ).keySet())
                options.add( new SelectOption( k, k ));
            return options;
        }
             
    }

    /**
    *Return a list of campaigns options
    *@return activeCampaigns
    */
    public List<Campaign> getactiveCampaigns(){
        if( activeCampaigns == null ){
            activeCampaigns = [ Select Name, Id From Campaign where isActive = true order by name LIMIT 100];
        }
        return activeCampaigns;
    }
    
    /**
    *Return the name
    *@retutn callDownColumns.get('Name')
    */
    public Boolean getName(){
        return callDownColumns.get( 'Name' );
    }
    
    /**
    *Return the campaign name
    */
    public String getCampaignName(){
        if ( hasCampaignID ){
            return thisCampaign;
        } else{
            return 'Keine Kampagne ausgewählt';
        }   
    }
        
    /**
    *Return lead Plus Task
    */
    public List<leadPlusTaskPlusContact> getLeadPlusTasks(){
        return leadPlusTasks;   
    }

    
    /**
    * Inner class to wrap Lead or Contact sobject.
    */
    public class leadPlusTaskPlusContact{
        //variable for each piece of the combined record

        public String memo {get; set;} // primitive field instead of whole task to reduce size of viewstate 
        public String followupTaskSubject {get; set;} // primitive field instead of whole task to reduce size of viewstate 
        public String followupActivityDate {get; set;} // primitive field instead of whole task to reduce size of viewstate
        public String activityDateErrorMessage { get; set; }
        
        
        public Boolean followupdesc { get; set; } // checkbox that controlls description of followup
        public String memStatus      {get; set;}
        public Map<String, String> localCStatusMap;
        public string ID             {get; set;}
        public string NAME           {get; set;}
        public string TITLE          {get; set;}
        public string SALUTATION     {get; set;}
        public string PHONE          {get; set;}
        public string PHONE2          {get; set;}
        public string MOBILE		{ get; set; }
        public string COMPANY        {get; set;}
        public boolean isAContact    {get; set;}
        public string cORl           {get; set;}
        public string statusUpdate   {get; set;}
        public string memberID       {get; set;}
        public string ADDRESS        {get; set;}
        public string EMAIL          {get; set;}
        public string FAX            {get; set;}
        public string ownerFirstName {get; set;}
        public string ownerLastName  {get; set;}
        //C.Vidal: bearbeiter
        public string Bearbeiter  {get; set;}
        public string ownerId        {get; set;}
        public string accountName    {get; set;}
        public string callType       {get; set;}
    
        /**
        *Constructor
        *@param m is a campaign member
        *@param statusMap a map of atatuses
        *@param camp id of campaign
        */  
        public leadPlusTaskPlusContact( CampaignMember m, Map<String, String> statusMap, string camp, string campname ){
            //C.Vidal: fixed mismatch between contact and lead with the help field isconverted.
            if ( m.Lead.id != null && m.Lead.IsConverted == false){
                cORl = 'lead';
                //l=incomingLead;
                ID = m.Lead.Id;
                NAME = m.Lead.Name;
                TITLE = m.Lead.Title;
                SALUTATION=m.Lead.Salutation;
                PHONE = m.Lead.Phone;
                PHONE2 = m.Lead.Telefon_2__c;
                MOBILE = m.Lead.MobilePhone;
                COMPANY = m.Lead.Company;
                if( m.Lead.Street != null ){
                    ADDRESS = m.Lead.Street + '<br>';
                    if(m.Lead.City != null){
                        ADDRESS += ', ' +m.Lead.City;
                    }
                    if(m.Lead.State != null){
                        ADDRESS += ', ' +m.Lead.State;
                    }
                    if(m.Lead.PostalCode != null){
                        ADDRESS += ', ' +m.Lead.PostalCode;
                    }
                    if(m.Lead.Country != null){
                        ADDRESS += '<br>'+m.Lead.Country;
                    }
                }   
                else
                    ADDRESS=' ';
                 
                    if(m.Lead.Email != null){
                        EMAIL = '<a href="mailto:' + m.Lead.Email+'">' + m.Lead.Email + ' </a>';    
                    }else{
                        EMAIL =' ';
                    }
                    FAX=m.Lead.Fax;
                    ownerFirstName = m.Lead.Owner.FirstName; ownerLastName = m.Lead.Owner.LastName; 
                    if(ownerLastName==null) ownerLastName=m.Lead.Owner.Name;
                    ownerId = m.Lead.OwnerId; 
            }else{
                cORl = 'contact';
           
                if( m.Contact.MailingStreet != null ){
                    ADDRESS = m.Contact.MailingStreet + '<br>';
                    if(m.Contact.MailingCity != null){
                        ADDRESS += ', '+m.Contact.MailingCity;
                    }
                    if(m.Contact.MailingState != null){
                        ADDRESS += ', '+m.Contact.MailingState;
                    }
                    if(m.Contact.mailingPostalCode != null){
                        ADDRESS += ', '+m.Contact.mailingPostalCode;
                    }
                    if(m.Contact.MailingCountry != null){
                        ADDRESS += '<br>' + m.Contact.MailingCountry;
                    }
               }else{
                    ADDRESS = ' ';
               }
                
               ID               = m.Contact.Id;
               NAME             = m.Contact.Name;
               TITLE            = m.Contact.Title;
               SALUTATION       = m.Contact.Salutation;
               PHONE            = m.Contact.Phone;
               PHONE2 			= m.Contact.Telefon_2__c;
               MOBILE 			= m.Contact.MobilePhone;
               if(m.Contact.Email != null){
                    EMAIL = '<a href="mailto:' + m.Contact.Email + '">' + m.Contact.Email + '</a>';     
               }else{
                    EMAIL = ' ';
               }
               
               FAX              = m.Contact.Fax;
               ownerFirstName   = m.Contact.Owner.FirstName; ownerLastName = m.Contact.Owner.LastName; 
               ownerId          = m.Contact.OwnerId;
               if ( m.Contact.Account.name != null )
                    COMPANY = m.Contact.Account.name;
               else
                  COMPANY = '';
            }
            
            memo = '';
            followupTaskSubject = '';
            activityDateErrorMessage = '';
            
            // MRO: moved tasks to updateAll()
            
            followupdesc=true;
            memberID = m.ID;
            memStatus = m.Status;
            //C.Vidal: Bearbeiter
            Bearbeiter = m.Bearbeiter__c;
            localCStatusMap = statusMap;
        }
        
        public String getMemo(){
        	return memo;
        }
        public void setMemo(String m){
        	memo = m;
        }
        
		public String getFollowupTaskSubject(){
        	return followupTaskSubject;
        }
        public void setFollowupTaskSubject(String s){
        	if (followupdesc)
        		followupTaskSubject = s;
        }
        
        public String getFollowupActivityDate(){
        	return followupActivityDate;
        }
        public void setFollowupActivityDate(String d){
        	if (followupdesc)
        		followupActivityDate = d;
        }
        
        /**
        *Return member status
        *@return memStatus
        */
        public String getmemStatus(){
            return memStatus;
        }

        /**
        *Return a list of members status values
        */
        public List<SelectOption> getmemStatusValue(){
            List<SelectOption> options = new List<SelectOption>();
            options.add( new SelectOption( memStatus, memStatus )); 
            for( String k: localCStatusMap.keySet()){
                if( k != memStatus )
                    options.add( new SelectOption( k, k ));
            }
            return options;
        }
   
    }
}