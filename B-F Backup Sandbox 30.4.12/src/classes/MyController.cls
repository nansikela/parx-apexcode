public class MyController {

Account account;



public PageReference save() {
	update account;
return null;
}

public String getName() {
	return 'MyController';
}

public Account getAccount() {
	if(account == null)
	account = [ select id, name from Account
	           where id = :ApexPages.currentPage().getParameters().get('id')];
//	           where ownerId = :ApexPages.currentPage().getParameters().get('ownerId')];
	return account;           
}

}