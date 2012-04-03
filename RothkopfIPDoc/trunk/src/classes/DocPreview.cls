public with sharing class DocPreview{
	public String myDocId {get;set;}
	public list<ContentVersion> Files {get;set;}

    
    /*public list<ContentVersion> getFiles() {

    	system.debug('my Id:' + myDocId);
    	if(myDocId == null)
    	   return null;
        return [select title, FileType, ContentDocumentId from ContentVersion where isLatest = true AND FirstPublishLocationId =: myDocId];
    }*/
    
    public PageReference updateView() {
    	system.debug('my Id1:' + myDocId);
        Files = new list<ContentVersion>();
    	
        if(myDocId == null)
           return null;
        Files = [select title, FileType, ContentDocumentId from ContentVersion where isLatest = true AND FirstPublishLocationId =: myDocId];
  
    	return null;
    }

}