public class CampaignStatusEdit {

    public Campaign searchObject { get; set; }
    public Campaign newStatus { get; set; }
    public List<CampaignContainer> campaignContainerList {get; set;}
    public String query {get;set;}
    public CampaignStatusEdit ()
    {
        
        searchObject    = new Campaign();
        searchObject.status = '';
        newStatus               = new Campaign();
        campaignContainerList = new List<CampaignContainer>();
    }
    
    public PageReference doSOQL()
    {
        //build query
        query = 'SELECT name, StartDate, EndDate, Type, Status FROM Campaign WHERE name<>\'\' ';
        
        if(searchObject.StartDate != null)
        {
                Date theStartDate = Date.newinstance(searchObject.StartDate.year(),searchObject.StartDate.month(),searchObject.StartDate.day());
            System.debug(theStartDate);
            query+= ' AND startdate>=' + CDHelper.convertDateForSOQL(theStartDate)+' ';
        }
        if(searchObject.EndDate != null)
        {
                Date theEndDate = Date.newinstance(searchObject.EndDate.year(),searchObject.EndDate.month(),searchObject.EndDate.day());
            query+= ' AND EndDate<=' + CDHelper.convertDateForSOQL(theEndDate)+' ';
        }
        if(searchObject.Status != null)
        {
            query+= ' AND Status=\'' + searchObject.Status+'\' ';
        }
        
        if(searchObject.type != null)
        {
            query+= ' AND type=\'' + searchObject.type+'\' ';
        }
        query+= ' ORDER BY StartDate';
        System.debug('**********query:'+query);
        campaignContainerList = new List<CampaignContainer>();
        for(Campaign c: Database.query(query))
        {
            campaignContainerList.add(new CampaignContainer(c));
        }
        
        return null;
    }
    
    public PageReference saveNewStatus()
    {
        if(newStatus.Status != null)
        {
                List<Campaign> selectedCampainList = new List<Campaign>();
                for(CampaignContainer c: campaignContainerList)
                {
                        if(c.selected)
                        {
                                c.campaign.status = newStatus.status;
                                selectedCampainList.add(c.campaign);
                        }
                }
                update selectedCampainList;
                
                doSOQL();
        }
        
        return null;
    }
    
    public boolean getIsResult()
    {
        if(campaignContainerList.size()>0)
        {
                return true;
        }
        else
        {
                return false;
        }
    }
    
    public class CampaignContainer{
        public Campaign campaign {get; set;}
        public boolean selected {get; set;}
        
        public CampaignContainer(Campaign c)
        {
            campaign = c;
            selected = false;
        }
    }
}