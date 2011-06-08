public class CRD_Training_Redirect_Controller {
	
	private TemplateController ctrl;
	
	public CRD_Training_Redirect_Controller(){
			
	}
	
	public CRD_Training_Redirect_Controller(TemplateController controller){
		this();
		this.ctrl = controller;
	}
	 
	public PageReference callTrainingModule(){
		PageReference url = new PageReference('/'+System_Settings.portal+'/page?pageid='+System_Settings.link05pageid+'&training=1');
		return url;
	}
}