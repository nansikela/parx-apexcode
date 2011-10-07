public class FAInsertUserController {
public PageReference insertUser()
	{
		/*User u = new User();
		Contact c = [SELECT id,LastName, eMail From Contact WHERE ID = :WebURLEncoder.decodeParam('Uid') ];
		
		u.LastName = c.LastName;
        u.Alias = c.Email;
        u.Username = c.Email;
        u.ContactId = c.id;
        u.CommunityNickname = c.Email;
        u.ProfileId = '00e20000001QIo8';
        u.LanguageLocaleKey = 'de_de';
        u.LocaleSidKey = 'de_de';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.EmailEncodingKey = 'UTF-8';
        //insert u;*/
		return new PageReference('http://www.google.com');
	}
	
}