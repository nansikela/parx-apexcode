public class OpinionLeaderHelper {
	
	public static void onUpsert(set<ID> contactIDs) {
		try {
			list<Account> accs = new list<Account>();
			map<ID, ID> contactAccountMap = new map<ID,ID>();
			String mailBody = '';
			list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();
			
			for(AccountContactRole acr : [Select AccountID, Account.KAM_supervising_OPL__c, ContactID, Contact.KAM_supervising_OPL__r.Name From AccountContactRole Where ContactID IN :contactIDs]) {
				//Collect all account ids for later proceedings
				contactAccountMap.put(acr.AccountID, acr.ContactID);
				
				accs.add(acr.Account);
				//Change the appropriate field in the account with the value of the contact's KAM
				if(accs.size()>0)
					accs.get(accs.size()-1).KAM_supervising_OPL__c = acr.Contact.KAM_supervising_OPL__r.Name;
			}
			
			system.debug(accs.size()+ ' accounts to update!');
			system.debug(accs);
			
			update accs;
			
			list<AccountContactRole> acrs = [Select AccountID, Account.KAM_supervising_OPL__c, Account.Name, ContactID, Contact.KAM_supervising_OPL__r.Name, Contact.Name From AccountContactRole Where AccountID IN :contactAccountMap.keySet()];
			contactAccountMap.clear();
			
			for(AccountContactRole acr : acrs) {
				
				//Check for more than one primary contact on every account. This is solved with a map, because if the map contains already an account ID as a key, a contact was already assigned!
				if(!contactAccountMap.containsKey(acr.AccountID))
					contactAccountMap.put(acr.AccountID, acr.ContactID);
				else {
					//If so, prepare an email for sending to admins!
					system.debug('create entry for Email!');
					mailBody += 'Contact "'+ acr.Contact.Name + '" (' + acr.ContactID + ') cannot be a further opinion leader on the account "' + acr.Account.Name + '" (' + acr.AccountID + ')\n';
				}
			}
			
			//If any conflicts of duplicated primary contacts were recognized, send the emails
			if (mailBody != ''){
				Messaging.SingleEmailMessage mail = sendMailToAdmin(mailBody);
				mails.add(mail);
			}
			if(mails.size() > 0) {
				Messaging.sendEmail(mails);
				system.debug('Email sent!');
			}
		} catch(Exception e) {
			system.debug(e.getStackTraceString());
		}
	}
	
	public static void onDelete(set<ID> contactIDs) {
		try {
			list<Account> accs = new list<Account>();
			list<AccountContactRole> acrs = [Select Account.KAM_supervising_OPL__c, Contact.Name From AccountContactRole Where ContactID IN :contactIDs];
		
			for(AccountContactRole acr : acrs) {
				acr.Account.KAM_supervising_OPL__c = null;
				accs.add(acr.Account);
			}
			
			system.debug(accs.size()+ ' accounts to update!');
			system.debug(accs);
			
			update accs;
			
		} catch(Exception e) {
			system.debug(e.getstackTraceString());
		}	
	}
	
	private static Messaging.SingleEmailMessage sendMailToAdmin(String mailBody) {
		list<User> users = [Select ID, Email From User Where ID =: UserInfo.getUserId() AND Profile.Name = 'System Administrator'];
		if(users.size() == 0)
			return null;
			
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		list<String> toAddresses = new list<String>();
		for(User u : users)
			toAddresses.add(u.Email);
		
		mail.setToAddresses(toAddresses);
		mail.setSubject('[WARNING] Contact is set as second opinion leader');
		mail.setBccSender(false);
		mail.setUseSignature(false);
		mail.setPlainTextBody(mailBody);
		return mail;	
	}
}