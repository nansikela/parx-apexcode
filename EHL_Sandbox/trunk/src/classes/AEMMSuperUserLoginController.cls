public  class AEMMSuperUserLoginController {

    private Id applicationId;
    private Id studentId;
    private aemmsuperuserlogin__c superLogin;
    //private String aemmUrl = 'https://apply.ehl.ch/superuser.php?key=';
    private String aemmUrl = 'http://aemm.parx.ch/superuser.php?key=';
    public double forcedStatusId {get; set;}
    
    public AEMMSuperUserLoginController (ApexPages.StandardController stdController)
    {
        try
        {
            //forcedStatusId = -1;
            String message = '';
          
            Application__c app = (Application__c) stdController.getRecord();

            List<Application__c> appList = [Select a.Student__c from Application__c a where a.Id = :app.Id];
            
            if(appList.isEmpty() || appList[0].Student__c == null)
            {
                message = 'No Application found or no Student attached to application.';
            }
            else
            {
                studentId = appList[0].Student__c;
            }
            
            if(message.length() > 0)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, message));
            }
        }
        catch(System.Exception e)
        {
            System.debug('** Exception : ' + e.getMessage());
            ApexPages.addMessages(e);   
        }
    }
    
    
    public PageReference aemmLogin()
    {
        PageReference p;
        
        try
        {
            superLogin = new aemmsuperuserlogin__c();
            superLogin.Student__c = studentId;
            superLogin.Request_Date__c = Datetime.now();
            superLogin.Forced_Status_Id__c = this.forcedStatusId;
            
            try
            {
                insert superLogin;
                p = new PageReference (aemmUrl + superLogin.id);
                p.setRedirect(true);
            }
            catch(System.DMLException e)
            {
                 System.debug('** Exception : ' + e.getMessage());
                 ApexPages.addMessages(e);
            }
            return p;
           
        }
        catch(System.Exception e){
            System.debug('** Exception : ' + e.getMessage());
            ApexPages.addMessages(e);   
        }
        return p;
    }
}