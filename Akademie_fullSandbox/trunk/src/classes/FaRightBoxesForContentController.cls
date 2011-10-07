public class FaRightBoxesForContentController 
{
	public List<RightBox> rightBoxesList {get; set;}
	
	
	public FaRightBoxesForContentController()
	{
		rightBoxesList = new List<RightBox>();
		String contentId = WebURLEncoder.decodeparam('id');
		
		
		for(Box_to_Navigation__c b : [Select b.Box__r.Headline__c, b.Box__r.eMail__c, b.Box__r.Telefon__c, b.Box__r.Icon__c, b.Box__r.Content__c, b.Box__r.Farbe__c, b.Box__r.RecordTypeId, b.Box__c From Box_to_Navigation__c b WHERE Navigation__c = :contentId ORDER BY Anordnung__c])
		{
			RightBox tempbox = new RightBox();
			tempbox.headline = b.Box__r.Headline__c;
			tempbox.content = b.Box__r.Content__c;
			tempbox.eMail = b.Box__r.eMail__c;
			tempbox.phone = b.Box__r.Telefon__c;
			if(b.Box__r.Farbe__c == 'hell grau')
			{
				tempbox.color = 'bright';
			}else if(b.Box__r.Farbe__c == 'dunkel grau')
			{
				tempbox.color = 'dark';
			}else if(b.Box__r.Farbe__c == 'rosa')
			{
				tempbox.color = 'pink';
				if(b.Box__r.Icon__c == 'Chat')
				{
					tempbox.color = 'pink chatWindow';
					tempbox.content = b.Box__r.Content__c.replace('<a', '<a onclick="javascript:window.open(\'http://www.arccade.de/yalst/index.php?yinit=true&site=1-1\',\'\',\'height=550,width=530\')"');
				}
				else if(b.Box__r.Icon__c == 'PDF')
				{
					tempbox.color = 'pink pdfWindow';
				}
			}
			
			rightBoxesList.add(tempbox);
		}
		
		
		
	}
	
	
	public class RightBox{
		public  boolean isFile {get; set;}
		public String headline {get; set;}
		public String content {get; set;}
		public String phone {get; set;}
		public String eMail {get; set;}
		public String color {get; set;}
		
		public RightBox()
		{
			isFile = false;
		}
		
		public boolean getIsHeadline(){
			return isElement(headline);
		
		}
		public boolean getIsContent()
		{
			return isElement(content);
		}
		public boolean getIseMail()
		{
			return isElement(eMail);
		}
		public boolean getIsPhone()
		{
			return isElement(phone);
		}
		
		
		private boolean isElement(String element)
		{
			if(element == null)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
	}
}