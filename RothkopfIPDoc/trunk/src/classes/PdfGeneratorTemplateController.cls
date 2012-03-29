public with sharing class PdfGeneratorTemplateController {
    public String getBody() {
        /// UNSECURE!!  it's possible to access to the document body through an external website (if the id is known). We should add a key as parameter to authenticate the request.
        String id = ApexPages.currentPage().getParameters().get('id');
        return [select body__c from Document__c where id =: id].body__c;
    }
}