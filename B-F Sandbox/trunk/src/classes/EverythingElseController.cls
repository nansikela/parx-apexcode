/*************************************************************
*Name : EverythingElseController
*Created By : Akash (Appirio Off)
*Created Date : 5th july,2011
*Modified by Raj Rao on July 25, 2011
*Purpose : To control the user links page , 
            where user can add and remove his/her favourite quick links
            
*Modified by Mike Shroyer on 10/3/2011
*Purpose : Changed the getItems() method to read Quick link categories from the DB               
****************************************************************/
public with sharing class EverythingElseController {
   String category = 'All';
   Id currentUserId = UserInfo.getUserId();     
   public String selectedLink{get;set;} 
   public String imagePath{get;set;}
   My_Links_Instructions__c linksInstructions;
   Map<id,id> mpLinkUser = new Map<id,id>();
   Map<Id,Quick_Link__c> mpQuickLink = new Map<Id,Quick_Link__c>();
   public List<Quick_Link__c> QuickLinks{get;set;}
   public String linkClass{get;set;}
   public String statusMessage{get;set;}
   public String myLinks{get;set;} 
   //-------------------------------------------------//
   // Constructor 
   //-------------------------------------------------//
   public EverythingElseController() {
     queryQuickLinks();     
     mpLinkUser = queryExistingUserLinks();
     linksInstructions = getlinksInstructions(); 
     //Check if user has any favorites. If yes then display the My Links Category
     if(mpLinkUser.size()>0){
         setCategory('My Links');
         changeCategory();
     }else{
         myLinks = 'none';
     }
   }   
   
   //-------------------------------------------------//
   // Get Instructions in custom settings
   //-------------------------------------------------//
   private My_Links_Instructions__c getlinksInstructions() {
    //First check if the user has any special privileges
    My_Links_Instructions__c linksInstructions = My_Links_Instructions__c.getValues(UserInfo.getUserId());
    if(linksInstructions != null) {
      return linksInstructions;
    }
    //Check for Task Sharing applicable to a particular profile
    linksInstructions = My_Links_Instructions__c.getValues(UserInfo.getProfileId());
    if(linksInstructions != null) {
      return linksInstructions;
    }    
    //Nothing specific to user or profile, then use the org wide defaults
    return My_Links_Instructions__c.getOrgDefaults();
  }
   
   //-------------------------------------------------//
   // return the instruction string 
   //-------------------------------------------------//
   public String getInstructions() {
         if(linksInstructions != null)
       return linksInstructions.Instruction__c;
     return '';  
   }
   //-------------------------------------------------//
   // To query All quick links 
   //-------------------------------------------------//
   private void queryQuickLinks() {
     QuickLinks = new List<Quick_Link__c>();                
     QuickLinks =  [SELECT Category__c, Name__c,Image_Link__c,Link_Location__c,External__c FROM Quick_Link__c ORDER BY Name__c];     
     for(Quick_Link__c link : QuickLinks) {
       mpQuickLink.put(link.Id,link);
     }
   } 
   //-------------------------------------------------//
   // To change the category of the links to be displayed
   // based on the selection made from drop down
   //-------------------------------------------------//
   public PageReference changeCategory() {
     if(category == 'My Links') {
       showFavourites();
     }
     else if(category == 'All') {
       QuickLinks = [SELECT Category__c, Name__c,Image_Link__c,Link_Location__c,External__c FROM Quick_Link__c ORDER BY Name__c];
     }
     else {
       QuickLinks =  [SELECT Category__c, Name__c,Image_Link__c,Link_Location__c,External__c FROM Quick_Link__c Where Category__c Includes (:category) ORDER BY Name__c];
     }
     return null;
   }
   //-------------------------------------------------//
   // To populate the category drop down    
   // to be displayed on the page
   //-------------------------------------------------//

	public List<SelectOption> getItems() {
		List<SelectOption> options = new List<SelectOption>();
		Map<String,String> uniqueOptions = new Map<String,String>();
		
		//Get all values from the DB
		for (Quick_Link__c q : [select Category__c From Quick_Link__c where Category__c <> null]) {
			//split the multi-select options and put into map
  			String[] temp = q.Category__c.split(';');
  			for(String s : temp) {
    			uniqueOptions.put(s,s);
			}	
		}		
		
		//Get the values from the Map and sort them
		List<String> sortedOptions = uniqueOptions.values();
		sortedOptions.sort();
		
		//Add values to list of Select Options
		options.add(new SelectOption('All','All'));
		for (String s : sortedOptions) {
			options.add(new SelectOption(s,s));
		}
		
		return options;
	}   
   //-------------------------------------------------//
   // To query all the user links to be displayed on the page    
   // for initialiing the page
   //-------------------------------------------------//
   private Map<id,id> queryExistingUserLinks() {
     Map<id,id> mpLinkUser = new Map<id,id>();     
     for(UserQuickLink__c link : [select id,Quick_Link_ID__c,UserId__c from UserQuickLink__c where UserId__c = :currentUserId]) {
       mpLinkUser.put(link.Quick_Link_ID__c,currentUserId);
     }
     return mpLinkUser;
   }         
           
   //-------------------------------------------------//
   // Returns the current chosen category      
   //-------------------------------------------------//
   public String getCategory() {
     return category;
   }
   //-------------------------------------------------//
   // Sets the current category      
   //-------------------------------------------------//
   public void setCategory(String s) {
     this.category = s;
   }
   //-------------------------------------------------//
   // To insert new User favourite link if it does not already exists      
   //-------------------------------------------------//
   public PageReference createUserLinks() {     
     statusMessage = 'Quick Link already exists in My Links';
     imagePath = '/img/msg_icons/warning24.png';
     if(!mpLinkUser.containsKey(selectedLink)) {
       UserQuickLink__c userLink = new UserQuickLink__c(UserId__c = currentUserId,Quick_Link_ID__c = selectedLink);
       try { 
         insert userLink;  
         mpLinkUser.put(selectedLink,currentUserId);
         statusMessage = 'Quick Link has been added to My Favs';
         imagePath = '/img/msg_icons/confirm24.png';
       }
       catch(DMLException de) {
         ApexPages.addMessages(de);
       }
     }     
     return null;
   }
   //-------------------------------------------------//
   // To populate the list of user favourite links
   // to be displayed on the page       
   //-------------------------------------------------//
   public PageReference showFavourites() {      
     QuickLinks = new List<Quick_Link__c>();
   /*  for(Id linkId : mpLinkUser.keySet()) {
       QuickLinks.add(mpQuickLink.get(linkId));
     }*/
     QuickLinks = [SELECT Category__c, Name__c,Image_Link__c,Link_Location__c,External__c FROM Quick_Link__c where Id IN :mpLinkUser.keySet() ORDER BY Name__c];
     linkClass = 'linkimg';
     return null;
   }
   //-------------------------------------------------//
   // To delete the selected link from user favourite link    
   //-------------------------------------------------//
   public PageReference deleteFavourites() {
     category = 'My Links';
     try {
       delete [select id from UserQuickLink__c where UserId__c = :currentUserId AND Quick_Link_ID__c = :selectedLink];
       mpLinkUser.remove(selectedLink);
     }
     catch(DMLException de) {
       ApexPages.addMessages(de);
     }
     showFavourites();
     return null;
   }
}