global class callYahooFinance {
	@future(callout=true)
	public static void getNewsQuotes() {
 		
    	string TickerSymbols = '';
    	integer counter = 0;

		List<Stock_Data__c> stocks = Stock_Data__c.getall().values();
    	for (Stock_Data__c stock :  stocks) {
    		if (counter==0) {
    			TickerSymbols = stock.Name;
    		} else {
    			TickerSymbols += ',' + stock.Name;
    		}
    		counter++;
    	}

	    String url = 'http://download.finance.yahoo.com/d/quotes.csv?s=' + TickerSymbols + '&f=sl1&e=.csv';
	        	
    	Http h = new Http();
    
    	HttpRequest req = new HttpRequest();
    	req.setEndpoint(url);
    	req.setMethod('GET');
    
    	HttpResponse res = h.send(req);

    	if(res.getBody()!=null){    		
			for(string y : res.getBody().split('\r\n')){
				string[] tempString = y.split(',');
				system.debug('tempstring ' + tempString[0] + '/' + tempString[1]);
				Stock_Data__c s = Stock_Data__c.getInstance(tempString[0].substring(1,tempString[0].length()-1));
				s.Stock_Value__c = decimal.valueOf(tempString[1]);
				update s;
			}
		}
    	
	}
	
	@future(callout=true)
	public static void getQuotes()    
	{
		
		string TickerSymbol;
		integer counter = 0;
		// selected all eligible Legal Database accounts and build a string of Tickers
		Map<ID,Account> accts = new Map<ID,Account>([Select ID, TickerSymbol from Account where TickerSymbol!=null and RecordType.Name = 'PLFC Accounts']);
		for(Account b: accts.values()){
			if(counter==0){
				TickerSymbol = b.TickerSymbol;
			}else{
				TickerSymbol += ',' + b.TickerSymbol;
			}
			counter++;
		}

		//where f stands for the fields to be displayed (in this case: s - symbol; l1 - last price; c1 - change; d1 = last date)       
		// String url = 'http://quote.yahoo.com/d/quotes.csv?s='+acct.TickerSymbol+'&f=sl1c1d1&e=.csv';
		string[] myFields = new string[]{'e','l1','j1','r','j4','v'};//,'f6'
		/*
		Ticker Symbol	Primary Keysymbol = s
		Earnings per share	Earnings/Share symbol = e
		Last Trade Price	symbol = l1
		Market Capitalization	symbol = j1, reformat to currency not rounded
		P/E Ratio	symbol = r
		Profit Margin (ttm) %	EBITDA symbol = j4
		Volume	symbol = v
		Float Shares	symbol = f6
		*/
		string lookupFields = 's';		          
		for(string z: myFields)
		{
			lookupFields+=z;
		}
		String url = 'http://download.finance.yahoo.com/d/quotes.csv?s='+TickerSymbol+'&f='+lookupFields+'&e=.csv';        
		Http h = new Http();
        
		HttpRequest req = new HttpRequest();    
		req.setEndpoint(url);    
		req.setMethod('GET');       
		HttpResponse res = h.send(req);        
		system.debug(res.getBody());

		Map<string,Map<string,string>> myValues = new Map<string,Map<string,string>>();
		if(res.getBody()!=null){
			// first split the csv data by carriage return into an array
			for(string y : res.getBody().split('\r\n')){
				Map<string,string> temp = new Map<string,string>();
				// now split the rows of data by comma delimited values into an array
				string[] tempString = y.split(',');
				for(Integer x = 0; x<myFields.size(); x++){ // for every field we asked for, put that into a map for later use
					temp.put(myFields[x],tempString[x+1]);
				}
				// now put the map of values into another map with Ticker as the KEY (remove leading and trailing double quotes)
				myValues.put(tempString[0].substring(1,tempString[0].length()-1),temp);
			}
		}
		system.debug(myValues);
		for(Account a : accts.values()){ // for each Account already queried, get the Map of fields by TickerSymbol
			if(myValues.get(a.TickerSymbol)!=null){ 
				Map<string,string> temp = myvalues.get(a.TickerSymbol);
				a.Earnings_Per_Share__c = convertValue(temp.get('e'));
				a.Last_Trade_Price__c = convertValue(temp.get('l1'));
				a.Market_Capitalization__c = convertValue(temp.get('j1'));
				a.PE_Ratio__c = convertValue(temp.get('r'));
				a.EBITDA__c = convertValue(temp.get('j4'));
				a.Volume__c = convertValue(temp.get('v'));
				//a.Float_Shares__c = convertValue(temp.get('f6'));
			}
		}
		update accts.values();
	}
	
	static decimal convertValue(string val){
		try{
			decimal convertedVal;
			if(val!=null){
				if(val!='N/A'){
					if(val.lastIndexOf('M')>0){ // if value is in Millions, then multiply
						convertedVal=decimal.valueof(val.substring(0,val.lastIndexOf('M')).trim())*1000000;
					}else if( val.lastIndexOf('B')>0){ // if value is in Billions, then multiply
						convertedVal=decimal.valueof(val.substring(0,val.lastIndexOf('B')).trim())*1000000000;
					}else{
						convertedVal=decimal.valueof(val.trim());
					}
						
				}
			}
			system.debug(convertedVal);
			return convertedVal;			
		}catch(System.TypeException e){return null;} //if type conversion, return null.
	}
}