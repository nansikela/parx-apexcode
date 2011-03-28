public class CRD_Training_Redirect_Controller {
	
	private TemplateController ctrl;
	
	public CRD_Training_Redirect_Controller(){
			
	}
	
	public CRD_Training_Redirect_Controller(TemplateController controller){
		this.ctrl = controller;
	}
	 
	public PageReference callTrainingModule(){
		
		//'/'+System_Settings.portal+'/page?pageid='+System_Settings.TrainingId+
		PageReference url = new PageReference('/'+System_Settings.portal+'/page?pageid='+System_Settings.getPageId('Link05')+'&training=1');
		
		return url;
	}
}