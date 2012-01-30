public class WebCoachingLandingPage {

    public static List<Seminar_to_Portfolio__c > getNextCOTermine() {
        List<Seminar_to_Portfolio__c > result = new List<Seminar_to_Portfolio__c >();
                
        result.addAll(getSeminarByCode('PE101', 1));
        result.addAll(getSeminarByCode('FO210', 1));
        result.addAll(getSeminarByCode('FO402', 1));

        return result;
    }
    
     public static List<Seminar_to_Portfolio__c > getNextPETermine() {
        List<Seminar_to_Portfolio__c > result = new List<Seminar_to_Portfolio__c >();
        
        result.addAll(getSeminarByCode('PE101', 3));
        
        return result;
    }
    
    public static List<Seminar_to_Portfolio__c > getNextPMTermine() {
        List<Seminar_to_Portfolio__c > result = new List<Seminar_to_Portfolio__c >();
        
        result.addAll(getSeminarByCode('FO210', 3));
        
        return result;
    }
    
    public static List<Seminar_to_Portfolio__c > getNextFUTermine() {
        List<Seminar_to_Portfolio__c > result = new List<Seminar_to_Portfolio__c >();
        
        result.addAll(getSeminarByCode('FO402', 3));
        
        return result;
    }
    
    
    private static List<Seminar_to_Portfolio__c> getSeminarByCode(String code, Integer limited)
    {
        return [Select  s.Seminar__r.Seminarende__c, 
                        s.Seminar__r.Seminarbeginn__c, 
                        s.Seminar__r.Trainer__r.firstname, 
                        s.Seminar__r.Trainer__r.Lastname, 
                        s.Seminar__r.Trainer__r.Titel_Anrede__c, 
                        s.Seminar__r.Trainer__r.Sprechende_Url__c ,
                        s.Seminar__r.Co_Trainer__r.firstname, 
                        s.Seminar__r.Co_Trainer__r.Lastname,  
                        s.Seminar__r.Co_Trainer__r.Titel_Anrede__c, 
                        s.Seminar__r.Co_Trainer__r.Sprechende_Url__c, 
                        s.Seminar__c, 
                        s.Portfolio__r.Live__c, 
                        s.Portfolio__r.url__c, 
                        s.Portfolio__r.Seminartitel__c, 
                        s.Portfolio__r.Name, 
                        s.Portfolio__c, 
                        s.Ort__c, 
                        s.Id 
                From    Seminar_to_Portfolio__c s 
                WHERE   Portfolio__r.name = :code AND Seminar__r.Seminarbeginn__c > today 
                ORDER BY s.Seminar__r.Seminarbeginn__c LIMIT :limited];
    }
    
    
    static testMethod void test() {
        WebCoachingLandingPage.getNextCOTermine();
        WebCoachingLandingPage.getNextPETermine();
        WebCoachingLandingPage.getNextPMTermine();
        WebCoachingLandingPage.getNextFUTermine();
    }
}