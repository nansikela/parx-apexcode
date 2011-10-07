public class WebSeminarKategorieController {
	public static List<WebSeminarKategorieAggregat> portfolioKategorienList = WebPortfolioHelper.getPortfolioRegisterUnterregister();
	public static List<WebSeminarKategorieAggregat> getAllRegister(){
	  
	  return  portfolioKategorienList;
	}
}