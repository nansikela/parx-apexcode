/**
 * @author Christian Deckert
 * @date 19/08/2011
 * @description Trainer Detail View Controller
 * @author Christian Deckert
 * @version 1.0
 */
public class FATrainerDetailController {

	public static  String name {get; set;}
	public static String titel {get; set;}
	public static String bild {get; set;}
	public static String schwerpunkt {get; set;}
	public static String profil {get; set;}
	public static List<Portfolio2__c>portfolioList {get; set;}
	/**
	 * @author Christian Deckert
	 * @date 19/08/2011
	 * @description Gibt Trainer Id aus URL zurück
	 * @author Christian Deckert
	 * @return Trainer Id aus URL
	 */
	public String getTrainerID()
	
	{
		return System.currentPageReference().getParameters().get('trainerId');
	}
	
	 /**
	 * @author Christian Deckert
	 * @date 19/08/2011
	 * @description Trainer Detail View Controller
	 * @author Christian Deckert
	 */
	 public FATrainerDetailController() {
	 	 if(name == null)
		 {
			 getTrainer();
		 }
		
	 }
	/**
	 * @author Christian Deckert
	 * @date 19/08/2011
	 * @description TrainerInformationen
	 * @author Christian Deckert
	 * @return Contact trainer
	 */
	private Contact getTrainer(){
    String trainerID = System.currentPageReference().getParameters().get('trainerId');
    Contact result = [Select 	c.BildURL__c, 
    							c.Title, 
    							c.Name,
    							c.Sprechende_url__c,
    							c.Website_Trainingsschwerpunkte__c, 
    							c.Website_Profil__c
    					From 
    							Contact c 
    					WHERE 	Anzeige_auf_Website__c = true 
    							AND c.ID = :trainerID];
    
    System.debug('***RESULT:'+result);
    result.Website_Trainingsschwerpunkte__c = '<div id="trainingsschwerpunkte">' + result.Website_Trainingsschwerpunkte__c;
    result.Website_Trainingsschwerpunkte__c = result.Website_Trainingsschwerpunkte__c.replace('strong>', 'h3 class="first">');
    result.Website_Trainingsschwerpunkte__c = result.Website_Trainingsschwerpunkte__c.replace('<ul>','<ul class="list trainer_aspects">');
    result.Website_Trainingsschwerpunkte__c += '</div>';
    result.Website_Profil__c = '<div id="profile" style="float: left; min-width: 460px;">' + result.Website_Profil__c.replace('strong>', 'h3 style="margin-top: 10px;">');
    result.Website_Profil__c = result.Website_Profil__c.replace('<ul>','<ul class="list">');
    // TODO I have tried a local solution here, it should be useful to put style information into css file
    result.Website_Profil__c += '</div><style>.content_column span h2 { float: left;} .content_column span table { float: left;}</style>';
    name = result.name;
    titel = result.title;
    bild = result.BildURL__c;
    profil = result.Website_Profil__c;
    schwerpunkt = result.Website_Trainingsschwerpunkte__c;
    
    System.debug('****PROFIL:'+profil);
    return result;
  } 
  /**
	 * @author Christian Deckert
	 * @date 19/08/2011
	 * @description Semianre an denen der Trainer beteilig ist
	 * @author Christian Deckert
	 * @return Liste an Portfolios 2
	 */
  public List<Portfolio2__c> getTrainerSeminars()
  {
  	if(portfolioList== null)
  	{
  		portfolioList = new List<Portfolio2__c>();
  		for(Trainer_Portfolio_Beziehung__c b : [Select t.Trainer__c, t.Portfolio__r.id, t.Portfolio__r.URL__c, t.Portfolio__r.Neu__c, t.Portfolio__r.Englisch__c, t.Portfolio__r.Live__c, t.Portfolio__r.Seminartitel__c, t.Portfolio__r.Name, t.Portfolio__c From Trainer_Portfolio_Beziehung__c t WHERE t.Portfolio__r.Live__c = true AND t.Trainer__c = :getTrainerID() ORDER BY t.Portfolio__r.name])
  		{
  			portfolioList.add(b.Portfolio__r);
  		}
  	}
  	return portfolioList;
  }
  
  /**
	 * @author Christian Deckert
	 * @date 19/08/2011
	 * @description werden Seminare angezeigt?
	 * @author Christian Deckert
	 * @return boolean
	 */
  public boolean getIsTrainerSeminars()
  {
  	if(getTrainerSeminars().size()>0)
  	{
  		return true;
  	}
  	else
  	{
  		return false;
  	}
  }
  
  
  static testMethod void testFaHelper() {
  	
  	Contact c =  [Select 	c.id
    					From 
    							Contact c WHERE Anzeige_auf_Website__c = true  LIMIT 1 ];
    ApexPages.currentPage().getParameters().put('trainerId',c.id);
  	FATrainerDetailController controller = new FATrainerDetailController();
  	controller.getTrainerSeminars();
  }

}