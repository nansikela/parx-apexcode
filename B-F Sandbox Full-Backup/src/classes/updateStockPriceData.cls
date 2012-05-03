global class updateStockPriceData implements Schedulable
{ 
 global void execute(SchedulableContext ctx)
 {
    //call a future method so we can do callouts within a schedule    
    callYahooFinance.getQuotes();
    callYahooFinance.getNewsQuotes();
 }
}