public class WebNavigationFacade {
public static List<WebNavItem> topNavigation = new List<WebNavItem>();
public static List<WebNavItem> topNavigationWithItems = new List<WebNavItem>();
public static boolean b = false;
public static List<WebNavItem> breadcrumb = new List<WebNavItem>();

    public WebNavigationFacade(){
        //lazy initialization
        if(!b)
        {
	        generateTopNavigation();
	        generateTopNavigationWithElements();
	        generateBreadcrumb();
	        b = true;
        }
    }

	//gererate Nati
    public static void generateTopNavigation()
    {
        List<WebNavItem> result = new List<WebNavItem>();
        WebNavItem item = new WebNavItem();
        //Pages layer 2
        List<Page__c> headCategory = [	Select  
        									p.Id, 
        									p.name, 
        									p.Oberseite__c, 
        									p.Name__c,
        									p.sprechende_url__c 
        								From 
        									Page__c p  
        								WHERE 
        									p.Oberseite__r.name = 'p-00001' 
        								AND 
        									Hidden__c = false 
        								ORDER BY Anordnung__c];
        
        //Generating level 2 Naviagtion (TOP)
        for(Page__c p: headCategory)
        {
            item = new WebNavItem();
            item.id = p.Id;
            item.pId = p.name;
            item.parent = p.Oberseite__c;
            item.name = p.Name__c;
            item.isCategory = true;
            if(p.Sprechende_URL__c == null || p.Sprechende_URL__c ==''){
            	item.url = '/page?pageid='+p.id;
            }else{
            	item.url = p.sprechende_url__c;
            }
            
            
            
            //FirstCategory
            if(result.size() == 0 ){
                item.isFirstCategory = true;
            }
            //LastCategory
            if((headCategory.size()-1) == result.size()){
                item.isLastCategory = true;
            }
            //Highlight the nativation left
            if(WebURLEncoder.decodeParam('pageid').equals(item.id)){
                    item.isActive = true;
                }
            
            result.add(item);
        }
        topNavigation = result;
    }
    
    //generate Elements layer 3 (Dropdown)
    public static void generateTopNavigationWithElements(){
        List<Page__c> subNavi = new List<Page__c>();
        WebNavItem item = new WebNavItem();
        List<WebNavItem> result;
        topNavigationWithItems = new List<WebNavItem>();
        //Jeder Hauptpunkt
        for(WebNavItem i: topNavigation)
        {
            topNavigationWithItems.add(i);
            
            
            subNavi = new List<Page__c>();
            subNavi = [	Select  
            				p.Id, 
            				p.name, 
            				p.Oberseite__c, 
            				p.Name__c ,
            				p.sprechende_url__c
            			From 
            				Page__c p  
            			WHERE 
            				p.Oberseite__r.name = :i.pId 
            			AND 
            				Hidden__c = false 
            			ORDER BY 
            				Anordnung__c];
            WebNavItem seminarKategorie;
            result = new List<WebNavItem>();
            
            //Subnatigation with Seminarkategorie
            for(Page__c p: subNavi){
                
                item = new WebNavItem();
                item.id = p.Id;
                item.pId = p.name;
                item.parent = p.Oberseite__c;
                item.name = p.Name__c;
                if(p.Sprechende_URL__c == null || p.Sprechende_URL__c ==''){
            	item.url = '/page?pageid='+p.id;
            }else{
            	item.url = p.sprechende_url__c;
            }
                
                //categories init
                if(item.name.equals('WebSeminarKategorieUebersicht')){
                    seminarKategorie = new WebNavItem();
                    seminarKategorie.name = 'Führung';
                    
                    seminarKategorie.parent = item.parent;
                    seminarKategorie.pId = item.pId;
                    seminarKategorie.Id= item.Id+'&category='+WebURLEncoder.encodeParam('Führung');
                    seminarKategorie.isFirstItem = true;
                    if(WebURLEncoder.decodeParam('category').equals('Führung')){
                        seminarKategorie.isActive = true;
                    }
                    seminarKategorie.url = '/seminare/fuehrung';
                    topNavigationWithItems.add(seminarKategorie);
                    
                    
                    seminarKategorie = new WebNavItem();
                    seminarKategorie.name = 'Strategie und Organisationsentwicklung';
                    seminarKategorie.parent = item.parent;
                    seminarKategorie.pId = item.pId;
                    seminarKategorie.Id= item.Id+'&category='+WebURLEncoder.encodeParam('Strategie und Organisationsentwicklung');
                    if(WebURLEncoder.decodeParam('category').equals('Strategie und Organisationsentwicklung')){
                        seminarKategorie.isActive = true;
                    }
                    seminarKategorie.url = '/seminare/strategie-und-organisationsentwicklung';
                    topNavigationWithItems.add(seminarKategorie);
                    
                    
                    seminarKategorie = new WebNavItem();
                    seminarKategorie.name = 'Persönlichkeitsentwicklung';
                    seminarKategorie.parent = item.parent;
                    seminarKategorie.pId = item.pId;
                    seminarKategorie.Id= item.Id+'&category='+WebURLEncoder.encodeParam('Persönlichkeitsentwicklung');
                    seminarKategorie.url = '/seminare/persoenlichkeitsentwicklung';
                    if(WebURLEncoder.decodeParam('category').equals('Persönlichkeitsentwicklung')){
                        seminarKategorie.isActive = true;
                    }
                    topNavigationWithItems.add(seminarKategorie);
                    
                    
                    seminarKategorie = new WebNavItem();
                    seminarKategorie.name = 'Fachkompetenz';
                    seminarKategorie.parent = item.parent;
                    seminarKategorie.pId = item.pId;
                    seminarKategorie.Id= item.Id+'&category='+WebURLEncoder.encodeParam('Fachkompetenz');
                    if(WebURLEncoder.decodeParam('category').equals('Fachkompetenz')){
                        seminarKategorie.isActive = true;
                    }
                    seminarKategorie.url = '/seminare/fachkompetenz';
                    topNavigationWithItems.add(seminarKategorie);
                    
                    
                    seminarKategorie = new WebNavItem();
                    seminarKategorie.name = WebConfig.AUSBILDUNGEN;
                    seminarKategorie.parent = item.parent;
                    seminarKategorie.pId = item.pId;
                    seminarKategorie.Id= item.Id+'&category='+WebURLEncoder.encodeParam(WebConfig.AUSBILDUNGEN);
                    if(WebURLEncoder.decodeParam('category').equals(WebConfig.AUSBILDUNGEN)){
                        seminarKategorie.isActive = true;
                    }
                    seminarKategorie.url = '/seminare/'+WebConfig.AUSBILDUNGEN.toLowerCase();
                    topNavigationWithItems.add(seminarKategorie);
                    
                }
                
                
                //First Item
                if(result.size()==0 && seminarKategorie==null){
                    item.isFirstItem = true;
                }
                //Last Item 
                if((result.size()+1) == subNavi.size() && seminarKategorie==null || (result.size()+2) == subNavi.size() && seminarKategorie!=null)
                {
                    item.isLastItem = true;
                }
                
                if(WebURLEncoder.decodeParam('pageid').equals(item.id)){
                    item.isActive = true;
                }
                
                if(!item.name.equals('WebSeminarKategorieUebersicht'))
                {
                    result.add(item);
                }
            }
            
            topNavigationWithItems.addAll(result);
            
            
        }
        
    }

    //generates Breadcrumb
    public static void generateBreadcrumb()
    {
        String pageId = WebURLEncoder.decodeParam('pageid');
        List<WebNavItem> result = new List<WebNavItem>();
        WebNavItem item;
        item = new WebNavItem();
        item.isLastCategory = true;
        //finding Toplevel Navigations
        for(Integer i = 0; i<10; i++)
        {
            Page__c p = [Select  p.Id, p.name, p.sprechende_url__c, p.Oberseite__c, p.Name__c From Page__c p  WHERE p.id=:pageId ORDER BY Anordnung__c];
            
            item.id = '?pageid='+p.Id;
            item.pId = p.name;
            item.parent = p.Oberseite__c;
            item.name = p.Name__c;
            if(p.Sprechende_URL__c == null || p.Sprechende_URL__c ==''){
            	item.url = '/page?pageid='+p.id;
            }else{
            	item.url = p.sprechende_url__c;
            }
            
            if(item.name.equals('WebSeminarKategorieUebersicht'))
            {
                item.name=WebURLEncoder.decodeParam('category');
                item.id=item.id+'&category='+WebURLEncoder.decodeParam('category');
                if(item.name == 'Führung'){
                	item.url = '/seminare/fuehrung';
                }
                if(item.name == 'Fachkompetenz'){
                	item.url = '/seminare/fachkompetenz';
                }
                if(item.name == 'Coaching' || item.name == WebConfig.AUSBILDUNGEN){
                	item.url = '/seminare/'+WebConfig.AUSBILDUNGEN.toLowerCase();
                }
                if(item.name == 'Persönlichkeitsentwicklung'){
                	item.url = '/seminare/persoenlichkeitsentwicklung';
                }
                if(item.name == 'Strategie und Organisationsentwicklung'){
                	item.url = '/seminare/strategie-und-organisationsentwicklung';
                }
            }
            
            if(item.name.equals('Trainer im Detail')){
                String trainerId = WebURLEncoder.decodeParam('trainerId');
                Contact trainer = [Select c.Name, c.Id From Contact c WHERE c.Id = :trainerId];
                item.name = trainer.name;
            }
            
            //no parent = first item
            if(item.parent==null)item.isFirstCategory = true;
            result.add(item);
            pageId = item.parent;
            if(pageId==null) break;
            item = new WebNavItem();
        }
        
        //generates Breadcrumb
        for(Integer i = (result.size()-1); i>-1;i--)
        {
            breadcrumb.add(result.get(i));
        }
    }




	//getter
    public static List<WebNavItem> getTopNavigation()
    {
        
        return topNavigation;
    }
    //getter
    public static List<WebNavItem> getTopNavigationWithItems()
    {
        return topNavigationWithItems;
    }
    //getter
    public static List<WebNavItem> getBreadcrumbNav()
    {
        return breadcrumb;
    }
    
    private static List<WebNavItem> getLeftNavigation()
    {
        List<WebNavItem> result = new List<WebNavItem>();
        boolean isRightCategory;
        //highlighting Nav left
        for(WebNavItem i:topNavigationWithItems)
        {
            if(i.isCategory)
            {
                isRightCategory = false;
            }
            if(i.isCategory && breadcrumb.get(1).Id.contains(i.id))
            {
                isRightCategory = true;
            }
            if(isRightCategory)
            {
                result.add(i);
            }
        }
        return result;
    }
    //Name of layer 2 for pages layer 3 or 4
    public static String getLeftNavigationHeadline()
    {
    	String returnVal = '';
        try{
        	returnVal =  getLeftNavigation().get(0).name;
        }catch(Exception e)
        {
        	returnVal = 'Seminarübersicht';
        }
        System.debug('************returnVal:'+returnVal);
        return returnVal;
    }
    
    //generates left Nav
    public static List<WebNavItem> getLeftNavigatonItems()
    {
        List<WebNavItem> result = new List<WebNavItem>();
        boolean isFirst = true;
        for(WebNavItem i: getLeftNavigation())
        {
            if(breadcrumb.size()>2&& i.name == breadcrumb.get(2).name)
            {
                i.isActive = true;
            }
            if(!isFirst)
            {
                result.add(i);
            }
        isFirst = false;
        }
        return result;
    }
}