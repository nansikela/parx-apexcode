public class WebTrainerFacade {
 public static List<Contact> trainerList;
  public static String pageTrainerURL;
  public static String pageTrainerDetailURL;
  public WebTrainerFacade(){
    trainerList =   [Select
            c.BildURL__c,
            c.Title,
            c.Sprechende_url__c,
            c.Name,
            c.LastName,
            c.Id
            From Contact c 
              WHERE c.Dozent__c = true 
              AND c.Anzeige_auf_website__c = true 
            ORDER BY LastName];
  }
  
  private static boolean getExistChar(String c){
    for(Contact trainer: trainerList){
      if(trainer.lastName.startsWith(c)){
        return true;
      }
    }
    return false;
  }
  
  public static boolean getExistA(){
    if(getExistChar('A')){
      return true;
    }
    if(getExistChar('Ä')){
      return true;
    }
    return false;
  }
  public static boolean getExistB(){
    return getExistChar('B');
  }
  public static boolean getExistC(){
    return getExistChar('C');
  }
  public static boolean getExistD(){
    return getExistChar('D');
  }
  public static boolean getExistE(){
    return getExistChar('E');
  }
  public static boolean getExistF(){
    return getExistChar('F');
  }
  public static boolean getExistG(){
    return getExistChar('G');
  }
  public static boolean getExistH(){
    return getExistChar('H');
  }
  public static boolean getExistI(){
    return getExistChar('I');
  }
  public static boolean getExistJ(){
    return getExistChar('J');
  }
  public static boolean getExistK(){
    return getExistChar('K');
  }
  public static boolean getExistL(){
    return getExistChar('L');
  }
  public static boolean getExistM(){
    return getExistChar('M');
  }
  public static boolean getExistN(){
    return getExistChar('N');
  }
  public static boolean getExistO(){
    if(getExistChar('O')){
      return true;
    }
    if(getExistChar('Ö')){
      return true;
    }
    return false;
  }
  public static boolean getExistP(){
    return getExistChar('P');
  }
  public static boolean getExistQ(){
    return getExistChar('Q');
  }
  public static boolean getExistR(){
    return getExistChar('R');
  }
  public static boolean getExistS(){
    return getExistChar('S');
  }
  public static boolean getExistT(){
    return getExistChar('T');
  }
  public static boolean getExistU(){
    if(getExistChar('U')){
      return true;
    }
    if(getExistChar('Ü')){
      return true;
    }
    return false;
  }
  public static boolean getExistV(){
    return getExistChar('V');
  }
  public static boolean getExistW(){
    return getExistChar('W');
  }
  public static boolean getExistXYZ(){
    if(getExistChar('X')){
      return true;
    }
    if(getExistChar('Y')){
      return true;
    }
    if(getExistChar('Z')){
      return true;
    }
    return false;
  }
  
  
  
  private List<Contact> getTrainerByChar(String c){
    if(c=='') c='A';
    List<Contact> result = new List<Contact>();
    
    for(Contact trainer: trainerList){
      if(trainer.lastName.startsWith(c)){
        result.add(trainer);
      }
    }
    return result;
  }
  
  public List<Contact> getTrainer(){
    String trainerChar = WebURLEncoder.decodeParam('trainerChar');
    if(trainerChar==null){
      trainerChar='A';
    }
    List<Contact> result = new List<Contact>();
    if(trainerChar == 'XYZ'){
      result.addAll(getTrainerByChar('X'));
      result.addAll(getTrainerByChar('Y'));
      result.addAll(getTrainerByChar('Z'));
      return result;
    }
    result.addAll(getTrainerByChar(trainerChar));
    
    if(trainerChar == 'A'){
      result.addAll(getTrainerByChar('Ä'));
    }
    if(trainerChar == 'O'){
      result.addAll(getTrainerByChar('Ö'));
    }
    if(trainerChar == 'U'){
      result.addAll(getTrainerByChar('Ü'));
    }
    
    return result;
  }
  
  
  public Contact getTrainerById(){
    String trainerID = System.currentPageReference().getParameters().get('trainerId');
    Contact result = [	Select 	c.BildURL__c, 
    							c.Title, 
    							c.Name,
    							c.Sprechende_url__c,
    							c.Website_Trainingsschwerpunkte__c, 
    							c.Website_Profil__c
    					From 
    							Contact c 
    					WHERE 	Anzeige_auf_Website__c = true 
    							AND c.ID = :trainerID];
    
    result.Website_Trainingsschwerpunkte__c = '<div id="trainingsschwerpunkte">' + result.Website_Trainingsschwerpunkte__c;
    result.Website_Trainingsschwerpunkte__c = result.Website_Trainingsschwerpunkte__c.replace('strong>', 'h3 class="first">');
    result.Website_Trainingsschwerpunkte__c = result.Website_Trainingsschwerpunkte__c.replace('<ul>','<ul class="list trainer_aspects">');
    result.Website_Trainingsschwerpunkte__c += '</div>';
    result.Website_Profil__c = '<div id="profile" style="float: left; min-width: 460px;">' + result.Website_Profil__c.replace('strong>', 'h3 style="margin-top: 10px;">');
    result.Website_Profil__c = result.Website_Profil__c.replace('<ul>','<ul class="list">');
    result.Website_Profil__c += '</div><style>.content_column span { float: left;} .content_column span table { float: left;}</style>';
    return result;
  } 
  public String getTrainerURL(){
    if(pageTrainerURL==null){
      pageTrainerURL = WebURLEncoder.getPageIdById('p-00008');
    }
    
    return '?pageid='+pageTrainerURL;
  }
  public String getTrainerDetailURL(){
    if(pageTrainerDetailURL==null){
      pageTrainerDetailURL = WebURLEncoder.getPageIdById('p-00016');
    }
    
    return '?pageid='+pageTrainerDetailURL;
  }
  
  
  public static List<Portfolio__c> getSeminarEvents(){
    String trainerid = WebURLEncoder.decodeParam('trainerId');
    List<Product2> products = new List<Product2>();
    List<Portfolio__c> result = new List<Portfolio__c>();
    products= [Select p.Portfolio__r.Sprechende_URL__c ,p.Portfolio__r.register__c,p.Portfolio__r.Englisch__c, p.Portfolio__r.Seminartitel__c, p.Portfolio__r.NEU__c, p.Portfolio__r.id, p.Portfolio__r.Name  From Product2 p WHERE p.Seminarbeginn__c > today AND p.Anzeige_auf_website__c=true AND (p.Co_Trainer__c=:trainerid OR p.Trainer__c = :trainerid) ORDER BY p.Portfolio__r.name];
    Portfolio__c item;
    Portfolio__c oldItem;
    oldItem = new Portfolio__c();
    oldItem.name = '';
    for(Product2 p: products){
      try
      {
      
      item = p.Portfolio__r;
      if(oldItem.Name!=item.Name){
      	result.add(item);
      }
      oldItem = new Portfolio__c();
      oldItem = item;
      	
      }catch(Exception e){}
    }
    
    return result;
  }
  
  public static boolean getIsSeminar(){
  	if(getSeminarEvents().size()==0) return false; else return true;
  	
  }
  
  
}