@isTest
private class Test_chatterGadgetController {
   // Methods for testing
   
    static testMethod void getIdTest() {
        PageReference pageRef = Page.ChatterGadget;
        pageRef.getParameters().put('id', 'good');
        Test.setCurrentPage(pageRef);
      
        chatterGadgetController controller = new chatterGadgetController();
        //String nextPage = controller.getId().getUrl();

        // Verify that page fails without parameters  
        String id = controller.getId();
        System.assertEquals('good', id);

        // Add parameters to page URL  
    
        //ApexPages.currentPage().getParameters().put('id', 'good');
      
        // Instantiate a new controller with all parameters in the page  
    
        //controller = new chatterGadgetController(); 
        //nextPage = controller.getId().getUrl();

        // Verify that the success page displays  
    
        //System.assertEquals('/apex/chattergadget?id=good', nextPage);
    }

}