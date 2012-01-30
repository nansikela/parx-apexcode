public class FAAttachment {
	
	
	private Attachment aAttachment;
	
	public FAAttachment()
	{
		for(Attachment a : [SELECT ID, Body,ContentType FROM Attachment WHERE ID = : ApexPages.currentPage().getParameters().get('id')])
		{
			aAttachment = a;
		}
	}
	
	public String getContentType()
	{
		return aAttachment.ContentType;
	}
	
	public String getFile()
	{
		return aAttachment.body.toString();
	} 

}