public class ErrorFinderController {
    public String failingPageResponse { get; set; }
     
    public void fetchFailingPage() {
       try {
       		PageReference ref = new PageReference('http://gigaset.default.cs8.force.com/crd/page?pageid=a0AL0000000Ap2GMAS');
           // Make a call to failing sites page here
           failingPageResponse = ref.getContent().toString();
       } catch (Exception e) {
           failingPageResponse = e.getTypeName() + ' : ' + e.getMessage() ;
       }      
    }  
}