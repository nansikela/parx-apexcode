public class DE_Authorization_Controller {
public User currentUser {get; set;}

public DE_Authorization_Controller(){
	currentUser = getUserDetails();
}

public DE_Authorization_Controller(DETemplateController controller){
	currentUser = getUserDetails();
}

public List<schema.fieldsetmember> getFields() {  
        return SObjectType.User.FieldSets.DE_Authorization_Questions.getFields();  
    }  

private User getUserDetails() {  
        String query = 'SELECT ';  
        for(Schema.FieldSetMember f : this.getFields()) {  
            query += f.getFieldPath() + ', ';  
        }  
        query += 'Id, Name FROM User WHERE Id=\'';
        query += Userinfo.getUserId();
        query += '\' LIMIT 1';  
        return Database.query(query);  
}

public Pagereference goToIntroduction(){
	// TODO: add questionsPage to SystemSettings.getPageId('DE_Authorization_Introduction',portal,isPro);
	return new Pagereference(Page.page.getUrl() + '?pageid=' + 'a0AL0000000BC2v');
}

public Pagereference goToQuestions(){
	// TODO: add questionsPage to SystemSettings.getPageId('DE_Authorization_Questions',portal,isPro);
	return new Pagereference(Page.page.getUrl() + '?pageid=' + 'a0AL0000000BC30');
}

public Pagereference goToConditions(){
	//update currentUser;
	// TODO: add questionsPage to SystemSettings.getPageId('DE_Authorization_Terms_and_Conditions',portal,isPro);
	return new Pagereference(Page.page.getUrl() + '?pageid=' + 'a0AL0000000BC35');
}

public Pagereference goToConclusion(){
	// TODO: add questionsPage to SystemSettings.getPageId('DE_Authorization_Conclusion',portal,isPro);
	return new Pagereference(Page.page.getUrl() + '?pageid=' + 'a0AL0000000BC3A');
}

}