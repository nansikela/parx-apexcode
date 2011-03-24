public class CRD_PM_Redirect_Controller {
	
	public PageReference callPM(){
		return new PageReference(InterfaceLinks.generatePictureURL());
	}
}