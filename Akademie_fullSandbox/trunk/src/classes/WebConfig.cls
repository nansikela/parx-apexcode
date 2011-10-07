public class WebConfig {
	public static Integer portfolioYear = 2011;
	public static String getPortfolioYear()
	{
		return String.valueOf(portfolioYear);
	}
	
	public static String AUSBILDUNGEN {get; set;}
	
	static
	{
		AUSBILDUNGEN = 'Ausbildungen';
	}
	
}