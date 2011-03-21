public with sharing virtual class ComponentControllerBase {

	public String key{ get;
		set{
			if(value != null){
				Key = value;
				if(pageController != null)
					pageController.setComponentControllerMap(Key, this);
			}
		}
	}
 
	public PageControllerBase pageController { get;
		set {
			if (value != null) {
				pageController = value;
				pageController.setComponentController(this);
			}
		}
	}
}