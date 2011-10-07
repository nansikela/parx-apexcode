public class InhouseProduct_Prefill {
    public InhouseProduct_Prefill(ApexPages.StandardController controller) {
    }
     public PageReference doEdit() {
       Pagereference newpage = new Pagereference ('/a0H/e?nooverride=1');
       newpage.getParameters().putAll(ApexPages.currentPage().getParameters());
       newpage.getParameters().remove('save_new');
       newpage.getParameters().put('Name', '[Wird automatisch berechnet]');
       //newpage.setRedirect(false);
       return newpage;
   }  
}