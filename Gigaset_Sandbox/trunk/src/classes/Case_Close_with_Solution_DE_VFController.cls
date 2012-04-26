public with sharing class Case_Close_with_Solution_DE_VFController {
    
    public Id CaseId{get;set;}
    public list<FAQ_Artikeltyp__kav> FAQ_Artikeltyp{
        get {
    	    system.debug('CaseId:' + CaseId);
	        list<Id> KnowledgeArticleIds = new list<Id>();
	        for(CaseArticle CaseArticles:[select KnowledgeArticleId from CaseArticle where CaseId =: CaseId]) {
	            KnowledgeArticleIds.add(CaseArticles.KnowledgeArticleId);
	        }
	        return [Select UrlName, Title, Summary, KnowledgeArticleId, Body__c From FAQ_Artikeltyp__kav f where PublishStatus = 'Online' AND KnowledgeArticleId IN: KnowledgeArticleIds];
        }
    	set;
    }
    
    @isTest(SeeAllData=true) 
    public static void testing() {
    	Case_Close_with_Solution_DE_VFController CC = new Case_Close_with_Solution_DE_VFController();
    	Case c = [select id from Case limit 1];
    	CC.CaseId = c.Id;
    	list<FAQ_Artikeltyp__kav> art = new list<FAQ_Artikeltyp__kav>();
    	art = CC.FAQ_Artikeltyp;
    }
}