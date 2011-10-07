public class WebPortfolioHelper {

 

//Generate Overview of Register and Unterregister
public static List<WebSeminarKategorieAggregat> getPortfolioRegisterUnterregister(){
    List<WebSeminarKategorieAggregat> aggregatList = new List<WebSeminarKategorieAggregat>();
    List<sObject> qresult = [	Select 
    								
    								p.Register__c register, 
    								p.Unterregister__c unterregister
    							From 
    								Portfolio__c p 
    							WHERE 
    								Anzeige_auf_website__c = true 
    							AND  
    								p.Portfolio_Jahr__c >='2010' 
    							AND Portfolio_Typ__c = 'Offene Seminare'
    							GROUP BY 
    								Unterregister__c, Register__c, 
    								Anzeige_auf_website__c 
    							ORDER BY 
    								min(p.Ausgabenummer__c)  ];
    AggregateResult ar = null;
    Integer iterator = 1;
    String preEncode;    
    String registerBefore;



    for(sObject query: qresult){
        WebSeminarKategorieAggregat aggregat = new WebSeminarKategorieAggregat();
        aggregat.register = String.valueOf(query.get('register'));
        aggregat.unterregister = String.valueOf(query.get('unterregister'));
        
         
        
        aggregat.registerUrl = WebURLEncoder.getPageIdById('p-00007')+'&category='+WebURLencoder.encodeParam(String.valueOf(query.get('register')));
        
        aggregat.unterregisterUrl = WebURLencoder.encodeParam(String.valueOf(query.get('unterregister')));
        aggregat.registerbefore = registerBefore;
        
        if(registerBefore == null || !registerBefore.equals(String.valueOf(query.get('register')))){
            iterator++;
        }
        aggregat.registerNumber = iterator;
         aggregatList.add(aggregat);
        registerBefore = String.valueOf(query.get('register'));
    }
     
    return aggregatList;
}

}