public class ProductPriceHandler {
		
		
	private String RECORDTYPE_PROGRAM;
    
    private String PRODUCT_BACHELOR;
	private String PRODUCT_PREPARATORY;
	private String PRODUCT_MASTER;
	private String PRODUCT_DIPLOMA;
	
	//PRICEBOOK ID
	private String PRICEBOOK_BACHELOR;
	private String PRICEBOOK_MASTER;
	private String PRICEBOOK_DIPLOMA;
	
	//CURRENCY
	private String EUR = 'EUR';
	private String CHF = 'CHF';
	private String USD = 'USD';
    
    public ProductPriceHandler(String programId, String pBach, String pPrep, String pMas, String pDip, String prBach, String prMas, String prDip){
    	RECORDTYPE_PROGRAM = programId;
    	PRODUCT_BACHELOR = pPrep;
		PRODUCT_PREPARATORY = pBach;
		PRODUCT_MASTER = pMas;
		PRODUCT_DIPLOMA = pDip;
		PRICEBOOK_BACHELOR = prBach;
		PRICEBOOK_MASTER = prMas;
		PRICEBOOK_DIPLOMA = prDip;
    }
    
    
    //returns true if an exception occured
 	//gets a list of only program
    public Boolean insertPricebookEntry(List<Product2> productList){
        Boolean hasError = false;
        try{
        	List<PricebookEntry> pricebookEntryToInsert = new List<PricebookEntry>();
        	
        	List<PricebookEntry> pricebookStandardEntryToInsert = new List<PricebookEntry>();
        	
        	List<PriceBook2> priceBookList = [Select p.Id From Pricebook2 p where p.IsStandard = true];
        	
        	if(!priceBookList.isEmpty()){
        		
        		Id standardPricebook = priceBookList[0].Id;
        		
	        	for(Product2 p : productList){
	        		PricebookEntry pEntryCHF = new PricebookEntry();
	    			pEntryCHF.UseStandardPrice = false;
	    			pEntryCHF.UnitPrice = 0;
	    			pEntryCHF.Product2Id = p.Id;
	    			pEntryCHF.IsActive = true;
	    			pEntryCHF.CurrencyIsoCode = CHF;
	    			PricebookEntry pEntryCHFStd = new PricebookEntry();
	    			pEntryCHFStd.Pricebook2Id = standardPricebook;
	    			pEntryCHFStd.UseStandardPrice = false;
	    			pEntryCHFStd.UnitPrice = 0;
	    			pEntryCHFStd.Product2Id = p.Id;
	    			pEntryCHFStd.IsActive = true;
	    			pEntryCHFStd.CurrencyIsoCode = CHF;
	    			
	    			PricebookEntry pEntryEUR = new PricebookEntry();
	    			pEntryEUR.UseStandardPrice = false;
	    			pEntryEUR.UnitPrice = 0;
	    			pEntryEUR.Product2Id = p.Id;
	    			pEntryEUR.IsActive = true;
	    			pEntryEUR.CurrencyIsoCode = EUR;
	    			PricebookEntry pEntryEURStd = new PricebookEntry();
	    			pEntryEURStd.Pricebook2Id = standardPricebook;
	    			pEntryEURStd.UseStandardPrice = false;
	    			pEntryEURStd.UnitPrice = 0;
	    			pEntryEURStd.Product2Id = p.Id;
	    			pEntryEURStd.IsActive = true;
	    			pEntryEURStd.CurrencyIsoCode = EUR;
	    			
	    			PricebookEntry pEntryUSD = new PricebookEntry();
	    			pEntryUSD.UseStandardPrice = false;
	    			pEntryUSD.UnitPrice = 0;
	    			pEntryUSD.Product2Id = p.Id;
	    			pEntryUSD.IsActive = true;
	    			pEntryUSD.CurrencyIsoCode = USD;
	    			PricebookEntry pEntryUSDStd = new PricebookEntry();
	    			pEntryUSDStd.Pricebook2Id = standardPricebook;
	    			pEntryUSDStd.UseStandardPrice = false;
	    			pEntryUSDStd.UnitPrice = 0;
	    			pEntryUSDStd.Product2Id = p.Id;
	    			pEntryUSDStd.IsActive = true;
	    			pEntryUSDStd.CurrencyIsoCode = USD;
	        		
	        		if(p.Family == PRODUCT_BACHELOR || p.Family == PRODUCT_PREPARATORY){
	        			//insert in bachelor pricebook	
	    				pEntryCHF.Pricebook2Id = PRICEBOOK_BACHELOR;
	    				pricebookEntryToInsert.add(pEntryCHF);
	    				
	    				pEntryEUR.Pricebook2Id = PRICEBOOK_BACHELOR;
	    				pricebookEntryToInsert.add(pEntryEUR);
	    				
	    				pEntryUSD.Pricebook2Id = PRICEBOOK_BACHELOR;
	    				pricebookEntryToInsert.add(pEntryUSD);
	    				
	    				//add standard  pricebook
	    				pricebookStandardEntryToInsert.add(pEntryCHFStd);
	    				pricebookStandardEntryToInsert.add(pEntryEURStd);
	    				pricebookStandardEntryToInsert.add(pEntryUSDStd);
	    				
	        		}else if(p.Family == PRODUCT_MASTER){
	        			//insert in master pricebook
	        			pEntryCHF.Pricebook2Id = PRICEBOOK_MASTER;
	    				pricebookEntryToInsert.add(pEntryCHF);
	    				
	    				pEntryEUR.Pricebook2Id = PRICEBOOK_MASTER;
	    				pricebookEntryToInsert.add(pEntryEUR);
	    				
	    				pEntryUSD.Pricebook2Id = PRICEBOOK_MASTER;
	    				pricebookEntryToInsert.add(pEntryUSD);
	        		
	        			//add standard  pricebook
	    				pricebookStandardEntryToInsert.add(pEntryCHFStd);
	    				pricebookStandardEntryToInsert.add(pEntryEURStd);
	    				pricebookStandardEntryToInsert.add(pEntryUSDStd);
	    				
	        		}else if(p.Family == PRODUCT_DIPLOMA){
	        			//insert in diploma pricebook
	        			pEntryCHF.Pricebook2Id = PRICEBOOK_DIPLOMA;
	    				pricebookEntryToInsert.add(pEntryCHF);
	    				
	    				pEntryEUR.Pricebook2Id = PRICEBOOK_DIPLOMA;
	    				pricebookEntryToInsert.add(pEntryEUR);
	    				
	    				pEntryUSD.Pricebook2Id = PRICEBOOK_DIPLOMA;
	    				pricebookEntryToInsert.add(pEntryUSD);
	    				
	    				//add standard  pricebook
	    				pricebookStandardEntryToInsert.add(pEntryCHFStd);
	    				pricebookStandardEntryToInsert.add(pEntryEURStd);
	    				pricebookStandardEntryToInsert.add(pEntryUSDStd);
	        		}
	        	}
	        	
	        	try{
	        		insert pricebookStandardEntryToInsert;
	        		insert pricebookEntryToInsert;	
	        	}catch(System.DMLException e){
		        	System.debug('***** Exception occured: ' + e);
            		hasError = true;
	        	}
        	}else{
        		System.debug('***** Standard Pricebook not found');
	        	hasError = true;
        	}
            
        }catch(System.Exception e){
            System.debug('***** Exception occured: ' + e);
            hasError = true;
        }
        
        return hasError;
    }
}