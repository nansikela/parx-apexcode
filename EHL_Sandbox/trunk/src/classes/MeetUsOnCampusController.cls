public class MeetUsOnCampusController {

    public List<SelectOption> CampainOptionList { get; set; }
    public List<SelectOption> SchoolOptionList { get; set; }
    public List<SelectOption> counter { get; set; }
    public Lead leadForInsert {get; set;}
    public CampaignMember member {get; set;}
    public boolean isThankyou {get; set;}
    
    public MeetUsOnCampusController ()
    {
        leadForInsert = new Lead();
        leadForInsert.status = 'Open';
        leadForInsert.Company = 'Private';
        CampainOptionList = new List<SelectOption>();
        for(Campaign c: [SELECT ID, name FROM Campaign LIMIT 100])
        {
            CampainOptionList.add(new SelectOption(String.valueOf(c.id), c.name));
        }
        SchoolOptionList = new List<SelectOption>();
        for(Account a: [SELECT Industry, Id, name FROM Account WHERE Industry = 'Education, Teaching, University' LIMIT 10])
        {
        	SchoolOptionList.add(new SelectOption(String.valueOf(a.id), a.name));
        }
        member = new CampaignMember();
        counter = new List<SelectOption>();
        for(Integer i = 0; i<10; i++)
        {
            String is = String.valueOf(i);
            counter.add(new SelectOption(is, is));
        }
        isThankyou = false;
    }    
    
    public PageReference save()
    {
        insert leadForInsert;
        member.LeadId = leadForInsert.id;
        insert member;
        isThankyou = true;
        return null;
    }    

}