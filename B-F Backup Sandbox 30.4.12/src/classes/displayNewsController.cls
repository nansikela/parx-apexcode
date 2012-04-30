public class displayNewsController {
    public String redirectChatterGroup { get; set; }
    public DateTime StockUpdatedDate { get; set; }

    String newsSection = ApexPages.currentPage().getParameters().get('section'); 
    String chatterGroup = '';
    
    public String getNewsCategory() {
        return ApexPages.currentPage().getParameters().get('section');
    }
    
    public List<Stock_Data__c> getStockData() {
    	List<Stock_Data__c> returnList = new List<Stock_Data__c>(); 	
	    List<Stock_Data__c> stockData = Stock_Data__c.getall().values();
        
        for (Stock_Data__c stock : stockData) {
            returnList.add(stock);
        }
        
        StockUpdatedDate = stockData.get(0).LastModifiedDate; 
        return returnList;
    }
    
    public double getArticleList() {
       	return news_settings__c.getInstance().Article_List__c;
    }  
    public Integer articleLimit = getArticleList().intValue();
    
    public String getPageTitle() {
        return news_settings__c.getInstance().Page_Title__c;
    }
    
    public String getFooter() {
        return news_settings__c.getInstance().Footer__c;
    }   

    public String getBrandNewsChatter() {
        return news_settings__c.getInstance().Brand_News_Chatter__c;
    }     
    
    public String getEmployeeNewsChatter() {
        return news_settings__c.getInstance().Employee_News_Chatter__c;
    }     

    public String getCompanyNewsChatter() {
        return news_settings__c.getInstance().Company_News_Chatter__c;
    }     

    public String getIndustryNewsChatter() {
        return news_settings__c.getInstance().Industry_News_Chatter__c;
    }     

    public String getNewsExchangeChatter() {
        return news_settings__c.getInstance().News_Exchange_Chatter__c;
    }     

    public String getStoryoftheDayChatter() {
        return news_settings__c.getInstance().Story_of_the_Day_Chatter__c;
    }     
 
     public String getVideooftheDayChatter() {
        return news_settings__c.getInstance().Video_of_the_Day_Chatter__c;
    }     
    
    public String getTravelChatter() {
        return news_settings__c.getInstance().Travel_Chatter__c;
    }  
        
    public String getExpensesChatter() {
        return news_settings__c.getInstance().Expenses_Chatter__c;
    }     

/* public String getStockChatter() {
      return news_settings__c.getInstance().Stock_Chatter__c;
   }    
*/
    public String getInvoiceProcessingChatter() {
        return news_settings__c.getInstance().Invoice_Processing_Chatter__c;
    }     
    
    public String getEtQChatter() {
        return news_settings__c.getInstance().EtQ_Chatter__c;
    }     
    
    public List<News__c> getCompanyNews() {
        return [SELECT id, name__c,external_url__c, CreatedDate FROM News__c WHERE Group__c = :'Company' ORDER BY LastModifiedDate Desc limit :articleLimit];
   }
   
    public List<News__c> getAllSectionNews() {
        return [SELECT id, name__c,external_url__c, LastModifiedDate FROM News__c WHERE Group__c = :newsSection ORDER BY LastModifiedDate Desc];
   }   

   public List<News__c> getBrandNews() {
        return [SELECT id, name__c,external_url__c, CreatedDate FROM News__c WHERE Group__c = :'Brands' ORDER BY LastModifiedDate Desc limit :articleLimit];
   }
   
   public List<News__c> getEmployeeNews() {
        return [SELECT id, name__c,external_url__c, CreatedDate FROM News__c WHERE Group__c = :'Employee' ORDER BY LastModifiedDate Desc limit :articleLimit];
   }   

    public List<News__c> getIndustryNews() {
        return [SELECT id, name__c,external_url__c, CreatedDate FROM News__c WHERE Group__c = :'Industry' ORDER BY LastModifiedDate Desc limit :articleLimit];
   }  
   
   public List<News__c> getFeatured() {
        return [SELECT id, name__c,external_url__c FROM News__c WHERE Featured__c = true ORDER BY LastModifiedDate Desc limit :articleLimit];
   }  

   public News__c getBreakingNews() {
   		List<News__c> breakingNews = [SELECT id, name__c,external_url__c FROM News__c WHERE Breaking_News__c = true ORDER BY LastModifiedDate Desc limit 1];
   		
   		if (breakingNews.isEmpty()) { 
        	return null;
   		} else {
   			return breakingNews.get(0);
   		}
   }  
   
   public News__c getStoryOfTheDay() {
        return [SELECT id, name__c,external_url__c,thumbnail_url__c FROM News__c WHERE Group__c = :'Story of the Day' ORDER BY LastModifiedDate Desc limit 1];
   }

   public News__c getVideoOfTheDay() {
        return [SELECT id, name__c,external_url__c,thumbnail_url__c FROM News__c WHERE Group__c = :'Video of the Day' ORDER BY LastModifiedDate Desc limit 1];
   }          

   public List<News__c> getTravelAlert() {
        return [SELECT id, name__c,external_url__c FROM News__c WHERE Group__c = :'Travel Alert' ORDER BY LastModifiedDate Desc];
   }   
       
    public News__c getNewsPost() {
        return [SELECT id, name__c, source__c,content__c,Body__c,createddate FROM News__c WHERE id = :ApexPages.currentPage().getParameters().get('id')];
    }

    public String getCheckSotDMember(){
        return checkForChatterMembership(getStoryoftheDayChatter());
    }
    
    public String getCheckVotDMember(){
        return checkForChatterMembership(getVideooftheDayChatter());
    }
    
    public String getCheckNewsExchangeMember(){
        return checkForChatterMembership(getNewsExchangeChatter());
    }
    
    public String getCheckBrandMember(){
        return checkForChatterMembership(getBrandNewsChatter());
    }
    
    public String getCheckCompanyMember(){
        return checkForChatterMembership(getCompanyNewsChatter());
    }
    
    public String getCheckEmployeeMember(){
        return checkForChatterMembership(getEmployeeNewsChatter());
    }   

    public String getCheckIndustryMember(){
        return checkForChatterMembership(getIndustryNewsChatter());
    }    
    
    public String getCheckTravelMember(){
        return checkForChatterMembership(getTravelChatter());
    }     
    
    public String getCheckExpensesMember(){
        return checkForChatterMembership(getExpensesChatter());
    }         
    
/*    public String getCheckStockMember(){
        return checkForChatterMembership(getStockChatter());
    }
*/    
    public String getCheckInvoiceProcessingMember(){
        return checkForChatterMembership(getInvoiceProcessingChatter());
    }
    
    public String getCheckEtQMember(){
        return checkForChatterMembership(getEtQChatter());
    }
    
    public String checkForChatterMembership(ID cg) {
        String currentUser = UserInfo.getUserId();
        String grpMemberId;
        String showHideJoinLink;
        List<CollaborationGroupMember> oM = [SELECT MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId = :cg];
        for(CollaborationGroupMember grpM : oM){
            grpMemberId = grpM.MemberId ;
            if(grpMemberId.equals(currentUser)){
                showHideJoinLink ='display:none';                
                //showHideJoinLink ='';             
            }
        }
        return showHideJoinLink;
    }
    
 
        public PageReference redirectChatterGroup() {
            String selectedChatterGroup = getChatterGroup(); 
            PageReference pageRef = new PageReference('/_ui/core/chatter/groups/GroupProfilePage?g='+selectedChatterGroup);
            pageRef.setRedirect(true);
            return pageRef;
        }
                
        public String getChatterGroup() {
            return chatterGroup;
        }

        public void setChatterGroup(String s) {
            this.chatterGroup = s;
        }

}