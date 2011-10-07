public with sharing class XWebTest {
	 public XWebTest(){
			
		}
		
	
	
	public static List<Contact> getContacts(){
		
		
		
		return [Select firstname, lastname FROM Contact Limit 10];
		
	}
	
	public static void setInsertContact(){
		
		Contact c = new Contact();
		c.firstname = 'test';
		c.LastName = 'Test';
		insert c;
	}
	public static testMethod void Test(){
		getContacts();
		setInsertContact();
	}
	
}