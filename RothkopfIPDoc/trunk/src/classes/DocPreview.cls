public with sharing class DocPreview{
    public list<ContentVersion> getFiles() {
        return [select title, FileType, ContentDocumentId from ContentVersion where isLatest = true];
    }

}