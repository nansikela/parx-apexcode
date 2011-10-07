public class InhouseEinsatzTriggerTest {
	
	static testMethod void testStep1() 
    {
    	List<Dozenteneinsatz_Inhouse__c>produktList = [SELECT ID FROM Dozenteneinsatz_Inhouse__c LIMIT 10];
    	update produktList;
    }

}