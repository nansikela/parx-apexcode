public class CRD_Training_Redirect_Controller {
	
	private TemplateController ctrl;
	
	public CRD_Training_Redirect_Controller(){
		
	}
	
	public CRD_Training_Redirect_Controller(TemplateController controller){
		this.ctrl = controller;
	}
	
	public PageReference callTrainingModule(){
		PageReference url = new PageReference('/'+System_Settings.portal+'/page?pageid=a0AL00000008nQ8MAI&training=1');
		
		//PageReference url = new PageReference('/'+SystemSettings.portal+'/page?pageid='+SystemSettings.TrainingId);
		return url;
	}
}