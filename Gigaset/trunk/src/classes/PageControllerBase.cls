public with sharing virtual class PageControllerBase {
    
	private ComponentControllerBase myComponentController;
	private Map<String, ComponentControllerBase>componentControllerMap; //new
	 
	public virtual ComponentControllerBase getMyComponentController() {
		return myComponentController;
	}
	
	//new getter for the hashmap
	public virtual Map<String, ComponentControllerBase> getComponentControllerMap(){
		return componentControllerMap;
	}
	//new method for putting value in the hashmap
	public virtual void setComponentControllerMap(String key, ComponentControllerBase compController){
		if(componentControllerMap == null)
			componentControllerMap = new Map<String, ComponentControllerBase>();
		componentControllerMap.put(key,compController);
	}
	 
	public virtual void setComponentController(ComponentControllerBase compController) {
		myComponentController = compController;
	}
	    
	public PageControllerBase getThis() {
		return this;
	}
     
}