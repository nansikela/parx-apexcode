/**
 * The Class CDHelper.
 */
public class CDHelper {
    public static String convertDateForSOQL(Date myDate){
        String resultDate = '';
        resultDate +=myDate.year()+'-';
        if(myDate.month()<10){
            resultDate +='0';
        }
        resultDate +=myDate.month()+'-';
        if(myDate.day()<10){
            resultDate +='0';
        }
        resultDate += myDate.day();
        return resultDate;
    }
  
}