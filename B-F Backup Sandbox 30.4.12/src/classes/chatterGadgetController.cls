public with sharing class chatterGadgetController{
    public string id { set; }
   
public string getId() {
    return ApexPages.currentPage().getParameters().get('id');
    }
  
}