public class PageContentRandom
{
    public static List<PageToItem__c>getItems(List<PageToItem__c> items)
    {
        List<PageToItem__c> resultList = new List<PageToItem__c>();
        //Find RandomItems
        Map<String, Integer> contentBlockMaxWahrscheinlichkeit = new Map<String, Integer>();
        List<PageToItem__c> wechselndePageToItemList = new List<PageToItem__c>();
        for(PageToItem__c c: items)
        {
            //Get MaxFromWahrscheinlichkeit
            if(c.ContentBlockItem__r.Ist_Wechselnder_Inhalt__c)
            {
                if(contentBlockMaxWahrscheinlichkeit.containsKey(c.Display_in_ContentBlock__c))
                {
                    contentBlockMaxWahrscheinlichkeit.put(c.Display_in_ContentBlock__c, contentBlockMaxWahrscheinlichkeit.get(c.Display_in_ContentBlock__c)+ Integer.valueOf(c.ContentBlockItem__r.wahrscheinlichkeit__c));
                }
                else
                {
                    contentBlockMaxWahrscheinlichkeit.put(c.Display_in_ContentBlock__c, Integer.valueOf(c.ContentBlockItem__r.wahrscheinlichkeit__c));
                }
                wechselndePageToItemList.add(c);
            }
            else //Add all items that are not Ist_Wechselnder_Inhalt__c to resultList
            {
                resultList.add(c);
            }
        }
        
        
        //random
        Map<String, Integer>randMax = new Map<String, Integer>();
        for(String key : contentBlockMaxWahrscheinlichkeit.keySet())
        {
            randMax.put(key , Math.mod(DateTime.now().millisecond(), contentBlockMaxWahrscheinlichkeit.get(key)));
        }
        
        //Find right ContentBlock
        for(PageToItem__c c: wechselndePageToItemList )
        {
            if(randMax.containsKey(c.Display_in_ContentBlock__c))
            {
                
                Integer tempWahrscheinlichkeit = randMax.get(c.Display_in_ContentBlock__c)-Integer.valueOf(c.ContentBlockItem__r.wahrscheinlichkeit__c);
                System.debug('*****************tempWahrscheinlichkeit :'+tempWahrscheinlichkeit );
                if(tempWahrscheinlichkeit <= 0)
                {
                    randMax.remove(c.Display_in_ContentBlock__c);
                    resultList.add(c);
                    System.debug('**************c.Display_in_ContentBlock__c:'+c.Display_in_ContentBlock__c);
                    
                }
                else
                {
                    randMax.put(c.Display_in_ContentBlock__c, tempWahrscheinlichkeit);
                }
            }
        }
        
        //Add Items to result
        return resultList;
    }
}