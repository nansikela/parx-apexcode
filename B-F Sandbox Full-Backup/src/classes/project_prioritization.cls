public class project_prioritization {
    public Id projectRtId;
    public Id getProjectRtId()
    { 
    Map<String,Schema.RecordTypeInfo> rtMapByName  = Schema.SObjectType.Project_Opportunity__c.getRecordTypeInfosByName();
        //Id shiptoRecType;
        //Map<String,Schema.RecordTypeInfo> promoRTMap = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName();
        if(rtMapByName.containsKey('PM - Evaluated')){
            projectRtId = rtMapByName.get('PM - Evaluated').getRecordTypeId();
            return projectRtId;
        } else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Cannot find the record type specified.'));
            return null;
        }
    }   
    public PageReference refresh() {
        getFilter();
        return null;
    }
    
    public string Filter;
    public string getFilter()
    {
        getProjectRtId();
        Filter = 'SELECT Name, Brand__r.Name, Market__r.Name, Achievement__c, Attractiveness__c, X5_Yr_NPV__c, Category__c, Start_Date__c, End_Date__c FROM Project_Opportunity__c WHERE RecordTypeId = \''+projectRtId+'\'';
        if(selBrand!=null&&selBrand!='ALL'){
            Filter += ' AND Brand__c = \''+selBrand+'\'';
        }
        if(selMarket!=null&&selMarket!='ALL'){
            Filter += ' AND Market__c = \''+selMarket+'\'';
        }
        if(selCategory!=null&&selCategory!='ALL'){
            Filter += ' AND Category__c = \''+selCategory+'\'';
        }
        return Filter;
    } 
    
    public List<Project_Opportunity__c> Projects;
    public List<Project_Opportunity__c> Pipeline;
    
    public List<Project_Opportunity__c> getProjects()
    {
     getFilter();
     Projects = Database.query(Filter);
     return Projects;
    }
    
    public List<Project_Opportunity__c> getPipeline()
    {
     getFilter();
     Pipeline = Database.query(Filter + 'ORDER BY Category__c, Start_Date__c');
     return Pipeline;
    }
    
    public string selBrand {get;set;}
    public List<SelectOption> getBrandsList() 
    {
        getProjectRtId();
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('ALL','ALL'));
        for(Brand__c y :[Select b.Name, b.Id From Brand__c b WHERE Id IN (SELECT Brand__c FROM Project_Opportunity__c WHERE RecordTypeId = :projectRtId) ORDER BY b.Name]) {
            optionList.add(new SelectOption(y.Id,y.Name));
        }
        return optionList;
    }
    
    public string selMarket {get;set;}
    public List<SelectOption> getMarketsList() 
    {
        getProjectRtId();
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('ALL','ALL'));
        for(Market__c y :[Select m.Name, m.Id From Market__c m WHERE Id IN (SELECT Market__c FROM Project_Opportunity__c WHERE RecordTypeId = :projectRtId) ORDER BY m.Name]) {
            optionList.add(new SelectOption(y.Id,y.Name));
        }
        return optionList;
    }
    
    public string selCategory {get;set;}
    public List<SelectOption> getCategoryList() 
    {
        getProjectRtId();
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('ALL','ALL'));
        for(Project_Opportunity__c y :[SELECT Category__c FROM Project_Opportunity__c WHERE RecordTypeId = :projectRtId ORDER BY Category__c]) {
            Boolean found = false;
            for(Integer i=0; i< optionList.size(); i++){
                if(y.Category__c == optionList[i].getValue()){ 
                    found = true;
                    break;
                }
            }
            if (!found){
                optionList.add(new SelectOption(y.Category__c,y.Category__c));
            }
        }
        return optionList;
    }
    
}