@isTest
private class displayNewsController_Test {

    static testMethod void myUnitTest() {             
          News__c newsArticle =new News__c();  
          List<News__c> newsList= new List<News__c>();
          
          //Generic Article
          newsArticle.Name__c = 'Test Article';
          newsArticle.Group__c = 'Company';   
          newsArticle.Body__c = 'Body Text';          
          newsList.add(newsArticle);   

          //Body Length > 200
          News__c newsArticle2 =new News__c();  
          newsArticle2.Name__c = 'Test Article 2';
          newsArticle2.Group__c = 'Employee';   
          newsArticle2.Body__c = '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901';          
          newsList.add(newsArticle2); 

          //External Link
          News__c newsArticle3 =new News__c();  
          newsArticle3.Name__c = 'Test Article 3';
          newsArticle3.Group__c = 'Brands';   
          newsArticle3.Body__c = 'Body Text';
          newsArticle3.External_URL__c = 'http://www.yahoo.com/';         
          newsList.add(newsArticle3); 
          
          //Generic Article
          News__c newsArticle4 =new News__c();            
          newsArticle4.Name__c = 'Test Article';
          newsArticle4.Group__c = 'Industry';   
          newsArticle4.Body__c = 'Body Text';           
          newsList.add(newsArticle4); 
          
          //Generic Article
          News__c newsArticle5 =new News__c();            
          newsArticle5.Name__c = 'Test Article';
          newsArticle5.Group__c = 'Story of the Day';   
          newsArticle5.Body__c = 'Body Text';           
          newsList.add(newsArticle5); 

          //Generic Article
          News__c newsArticle6 =new News__c();            
          newsArticle6.Name__c = 'Test Article';
          newsArticle6.Group__c = 'Video of the Day';   
          newsArticle6.Body__c = 'Body Text';           
          newsList.add(newsArticle6); 
          
          //Generic Article
          News__c newsArticle7 =new News__c();            
          newsArticle7.Name__c = 'Test Article';
          newsArticle7.Group__c = 'Travel Alert';   
          newsArticle7.Body__c = 'Body Text';           
          newsList.add(newsArticle7);                                         
  
   		 insert newsList;   
   		                        
          test.startTest();  

          
     
          
          PageReference pageRef = Page.NewsHome;
          Test.setCurrentPage(pageRef);   
    	  ApexPages.standardController stdController = new ApexPages.Standardcontroller(newsArticle);        
   	      displayNewsController obj=new displayNewsController();    
          obj.getBrandNews();
          obj.getEmployeeNews();
          obj.getIndustryNews();
          obj.getCompanyNews();
          obj.getAllSectionNews();
          
          obj.getNewsCategory();
          obj.getPageTitle();
          obj.getFooter();
          obj.getBrandNewsChatter();
		  obj.getEmployeeNewsChatter();
		  obj.getCompanyNewsChatter();
		  obj.getIndustryNewsChatter();
		  obj.getNewsExchangeChatter();
		  obj.getStoryoftheDayChatter();
		  obj.getVideooftheDayChatter();                              
		  obj.getTravelChatter();
		  obj.getExpensesChatter();
//		  obj.getStockChatter();
		  obj.getInvoiceProcessingChatter();
		  obj.getEtQChatter();
		  
		  obj.getStoryOfTheDay();
		  obj.getVideoOfTheDay();
		  obj.getTravelAlert();
		  
		  obj.getCheckSotDMember();
		  obj.getCheckVotDMember();
		  obj.getCheckNewsExchangeMember();
		  obj.getCheckBrandMember();
		  obj.getCheckCompanyMember();
		  obj.getCheckEmployeeMember();
		  obj.getCheckIndustryMember();
		  obj.getCheckTravelMember();
		  obj.getCheckExpensesMember();
//		  obj.getCheckStockMember();
		  obj.getCheckInvoiceProcessingMember();
		  obj.getCheckEtQMember();
		  obj.getChatterGroup();
		  obj.setChatterGroup('12345');
		  
		  obj.redirectChatterGroup();
		  //obj.getNewsPost();
		             
          test.stopTest();                 
    }
}