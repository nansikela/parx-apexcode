public with sharing class Permalink {
    
    public final String id;
    public Boolean notFound {get;set;}
    
    public Permalink() {
        notFound = false;
        id = ApexPages.currentPage().getParameters().get('id');
        system.debug(id);
    }
    
    public PageReference init() {
        PageReference pref = null;
        for(Permalink__c p : [Select ID, Name, Destination_URL__c, Source_URL__c From Permalink__c Where Active__c = true AND Name LIKE :id]) {
            
            pref = new PageReference((p.Destination_URL__c.contains('http') ? p.Destination_URL__c : 'http://'+p.Destination_URL__c));
            pref.setRedirect(true);
        }
        
        if(pref == null)
            notFound = true;
            
        return pref;
    }
    
    static testMethod void MainUnitTest() {
        String url = 'http://gigaset.force.com';
        Permalink__c p = new Permalink__c(Destination_URL__c = url, Active__c = true);
        insert p;
        
        //Test case 1: permalink not found
        Permalink ctrl = new Permalink();
        ctrl.init();
        
        system.assertEquals(true, ctrl.notFound);
        
        //Test case 2: permalink found
        p = [Select ID, Destination_URL__c, Source_URL__c, Active__c, Name From Permalink__c Where Destination_URL__C = :url limit 1];
        ApexPages.currentPage().getParameters().put('id', p.Name);
        
        ctrl = new Permalink();
        ctrl.init();
        
        system.assertEquals(false, ctrl.notFound);
    }
}