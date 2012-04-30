public class promotionActivityGanttController {

    public promotionActivityGanttController(ApexPages.StandardController controller) {

    }


    public List<Promotion_Activity__c> PromotionActivities;
    
    public List<Promotion_Activity__c> getPromotionActivities()
    {
     getFilter();
     PromotionActivities = Database.query(Filter + ' ORDER BY Promotion_Type__c, Begin_Date__c');
     //PromotionActivities = [SELECT Name, Brand__r.Name, Market__r.Name, Begin_Date__c, End_Date__c, Promotion_Type__c FROM Promotion_Activity__c];
     return PromotionActivities;
    }
    
    public PageReference refresh() {
        getFilter();
        return null;
    }
    
    public date startDate;
    public string Filter;
    public string getFilter()
    {
        startDate = date.parse('1/1/2005');
        Filter = 'SELECT Name, Brand__r.Name, Market__r.Name, Begin_Date__c, End_Date__c, Promotion_Type__c FROM Promotion_Activity__c WHERE Begin_Date__c != :startDate';
        if(selBrand!=null&&selBrand!='ALL'){
            Filter += ' AND Brand__c = \''+selBrand+'\'';
        }
        if(selMarket!=null&&selMarket!='ALL'){
            Filter += ' AND Market__c = \''+selMarket+'\'';
        }
        system.debug(selType);
        return Filter;
    } 
    
    public string selBrand {get;set;}
    public List<SelectOption> getBrandsList() 
    {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('ALL','ALL'));
        for(Brand__c y :[Select b.Name, b.Id From Brand__c b WHERE Id IN (SELECT Brand__c FROM Promotion_Activity__c) ORDER BY b.Name]) {
            optionList.add(new SelectOption(y.Id,y.Name));
        }
        return optionList;
    }
    
    public string selMarket {get;set;}
    public List<SelectOption> getMarketsList() 
    {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('ALL','ALL'));
        for(Market__c y :[Select m.Name, m.Id From Market__c m WHERE Id IN (SELECT Market__c FROM Promotion_Activity__c) ORDER BY m.Name]) {
            optionList.add(new SelectOption(y.Id,y.Name));
        }
        return optionList;
    }
    
    public string selType {get;set;}

}