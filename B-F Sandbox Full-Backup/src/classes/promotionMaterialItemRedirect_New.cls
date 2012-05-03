public with sharing class promotionMaterialItemRedirect_New {
	
	public ID recordID {get;set;}
  
	public promotionMaterialItemRedirect_new ()
	{
		recordID = null;
		String id = ApexPages.currentPage().getParameters().get('Id');
		if(id != null && id != '')
			recordID = id;
	}
     
	public PageReference Redirect()
	{
		if(recordID == null)
			return null;

		Profile p = [Select Name From Profile Where ID = :UserInfo.getProfileId() limit 1];
		PageReference ref = Page.promotionMaterialItem;
			
		if(p != null && p.Name.contains('DEU'))
			ref = Page.promotionMaterialItem_DEU;
				
		ref.getParameters().put('id',recordID);
		return ref;
	}
}