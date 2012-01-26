public class OverviewApplicationController {
    
    //variable
    public String sApplicationId{get; set;}
    private Id idRTeducationSQ, idRTeducationLQ, idRTeducationTS, idRTAddress_CPA,
                idRTadditionalIE, idRTadditionalM, idRTpe_WE, idRTpe_ECK;
    Date Date_of_Test;
    Application__c oApplication;
    Opportunity oOpportunity;
    Contact oContact;
    Address__c oAddress;
    Education__c oEducationLQ;
    Education__c oEducationSQ;
    Education__c oEducationSATone;
    Product2 oProduct;
    Account oSchool;
    Selection__c oSelection;
    list<Education__c> listAllEducation;                                        // All Education
    list<Education__c> listEducationSQ = new list<Education__c>();              // RecordType = School Qualifcation
    list<Education__c> listEducationSQ_SecSchool = new list<Education__c>();    // RecordType = School Qualifcation AND Education__c = Secondary School AND Diploma_Date__c !=null
    list<Education__c> listEducationSQ_SecSchool_DDnull = new list<Education__c>(); // RecordType = School Qualifcation AND Education__c = Secondary School AND Diploma_Date__c ==null
    list<Education__c> listEducationSQ_HE = new list<Education__c>();           // RecordType = School Qualifcation AND Education__c = Higher Education
    list<Education__c> listEducationLQ = new list<Education__c>();              // RecordType = Language Qualification
    list<Education__c> listEducationLQ_EN = new list<Education__c>();           // RecordType = Language Qualification AND Language = English
    list<Education__c> listEducationLQ_FR = new list<Education__c>();           // RecordType = Language Qualification AND Language = French
    list<Education__c> listEducationTS = new list<Education__c>();              // RecordType = Test Scores
    list<Selection__c> listSelection = new list<Selection__c>();                // All Selection
    list<Additional__c> listAdditional = new list<Additional__c>();                 // All Additional
    list<Additional__c> listAdditional_IE = new list<Additional__c>();              // RecordType = International Exposure
    list<Additional__c> listAdditional_M = new list<Additional__c>();               // RecordType = Miscellaneous
    list<Profile_Experience__c> listProfileExperience = new list<Profile_Experience__c>();      // All ProfileExperience
    list<Profile_Experience__c> listProfileExperience_WE = new list<Profile_Experience__c>();   // RecordType = Work Experience
    list<Profile_Experience__c> listProfileExperience_ECK = new list<Profile_Experience__c>();  // RecordType = Extra Curricular Knowledge
    
    //Constructor
    public OverviewApplicationController(){}
    
    // Placeholder
    public void doNothing(){}
    
    // Begin: Operation to Excecute
    public void init(){
        list<Contact> listContactTemp = new list<Contact>();
        list<Opportunity> listOppTemp = new list<Opportunity>();
        list<Address__c> listAddTemp = new list<Address__c>();
        
        setRecordType();
        this.sApplicationId = ApexPages.currentPage().getParameters().get('id');
        oApplication = [select Id, Name, Type_of_Math_Course__c, Predicted_GPA__c, Opportunity__c, Math_Grade__c, Final_GPA__c, OwnerId, 
                                Application_Submit_Date__c, Application_Status__c, Application_Start_Date__c, Application_Phase__c, Student__c,
                                    Application_Code__c, Applicant_under_18__c, Visa_Required__c, Age_at_Start_of_Programme__c from Application__c where Id=:this.sApplicationId];
        
        // Begin : get Information (Reference) from Opportunity
        listOppTemp = [select Id, Name, Pricebook2Id from Opportunity where Id=:oApplication.Opportunity__c];
        if(!listOppTemp.isEmpty()){
            oOpportunity =  listOppTemp.get(0);
            if(oOpportunity.Pricebook2Id != null){
                try {
                    OpportunityLineItem oOpportunityLineItem = [select Id, PricebookEntryId from OpportunityLineItem where OpportunityId=:oOpportunity.Id limit 1];
                    PricebookEntry oPricebookEntry = [select Id, Product2Id from PricebookEntry where Id=:oOpportunityLineItem.PricebookEntryId limit 1];
                    oProduct = [select Id, Product_Period__c, Product_Language__c, Name from Product2 where Id=:oPricebookEntry.Product2Id limit 1];
                }
                catch(System.Exception e){
                     System.debug('***** Exception occured: ' + e);
                }
            }
        }
        // End : get Information (Reference) from Opportunity
        
        // Begin : All Information about Student
        listContactTemp = [select Id, Swiss_Permit__c, Nationality_4__c, Nationality_3__c, Nationality_2__c, Nationality_1__c, Name, LastName, Gender__c, 
                        FirstName, Student_Name__c, Email_Private__c, Date_of_Expiry__c, Country_of_Birth__c, Birthdate 
                            from Contact where Id=:oApplication.Student__c];            
        if(!listContactTemp.isEmpty()){
            oContact =  listContactTemp.get(0);
            // Begin : Addressinformation
            listAddTemp = [select Id, Country__c from Address__c where Contact__c=:oContact.Id and RecordTypeId=:idRTAddress_CPA limit 1];  
            if(!listAddTemp.isEmpty())
                oAddress = listAddTemp.get(0);
            // End : Addressinformation
            listAllEducation = [select Id, Name, Education__c, Years_of_Study__c, RecordTypeId, Test_Score__c, School_Name__c, SAT_1_Writing_Score__c, SAT_1_Verbal_Critical_Reading_Scor__c, 
                                SAT_1_Math_Score__c, SAT_1_Test_taken__c, Qualification__c, Main_Language_of_Instruction__c, Language__c, Language_Level__c, Diploma_Name__c, SAT_1_Date_of_Test__c,
                                Language_Learned_By__c, Field_of_Study__c, Diploma_Date__c, Date_of_Test__c, Date_Until__c, Date_From__c, SAT_1_Total_Score__c, School_Name__r.Country_Preferred__c,
                                School_Name__r.Street_Name_Nr_Preferred__c, School_Name__r.City_English__c, Diploma_Name__r.Diploma_Name_English__c 
                                from Education__c where Student__c=:oContact.Id];
            
            // Begin: Convert Edcuation 
            splitEducation();
            splitLanguageQualification();
            splitEducationSQ_Education();
            // End: Convert Edcuation 
            
            listProfileExperience = [select Id, RecordTypeId, Weeks_Worked__c, Position_Held__c, Hours_per_Week_Worked__c, Date_Until__c, Date_From__c, 
                                    Country_English__c, Company__c, City__c, Activity_Type__c from Profile_Experience__c where Contact__c=:oContact.Id];
            splitProfileExperience();
        }
        // End : All Information about Student
        
        listSelection = [select Id, Total_Personal_Potential__c, Total_Academic_Potential__c, Selection_Date__c, Scores_Total__c, 
                            Scores_Motivation_MO__c, Scores_Leadership_Potential_LP__c, Scores_Interpersonal_Skills_IS__c, Scores_Academic_Potential_AP__c, 
                            Quality_of_Essay__c, Motivation_for_EHL__c, Location__c, Application__c, Application_Total_Score__c 
                            from Selection__c where Application__c=:oApplication.Id];
        // Maybe we need Records -> clear the if Statements
        if(!listSelection.isEmpty())
            oSelection = listSelection.get(0);
        if(!listEducationTS.isEmpty())
            oEducationSATone = listEducationTS.get(0);
        listAdditional = [select Id, Type_of_Activity__c, Date_Until__c, Date_From__c, Country__c, RecordTypeId, Miscellaneous__c
                        from Additional__c where Application__c=:oApplication.Id];
        splitAdditional();

    }
    // End: Operation to Excecute 
    
    //get-set for Objects
    public Address__c getOAddress(){
    if(oAddress == null) oAddress = new Address__c();   
        return oAddress;    
    }
    public void setOAddress(Address__c oAdd){
        if(oAddress == null) oAddress = new Address__c();
        oAddress = oAdd;
    }
    public Application__c getOApplication(){
    if(oApplication == null) oApplication = new Application__c();   
        return oApplication;    
    }
    public void setOApplication(Application__c oApp){
        if(oApplication == null) oApplication = new Application__c();
        oApplication = oApp;
    }
    public Account getOSchool(){
    if(oSchool == null) oSchool = new Account();    
        return oSchool; 
    }
    public void setOSchool(Account oAcc){
        if(oSchool == null) oSchool = new Account();
        oSchool = oAcc;
    }
    public Opportunity getOOpportunity(){
    if(oOpportunity== null) oOpportunity = new Opportunity();   
        return oOpportunity;    
    }
    public void setOOpportunity(Opportunity oOpp){
        if(oOpportunity == null) oOpportunity = new Opportunity();
        oOpportunity = oOpp;
    }
    public Contact getOContact(){
    if(oContact== null) oContact = new Contact();   
        return oContact;    
    }
    public void setOContact(Contact oCon){
        if(oContact == null) oContact = new Contact();
        oContact = oCon;
    }
    public Product2 getOProduct(){
    if(oProduct == null) oProduct = new Product2(); 
        return oProduct;    
    }
    public void setOProduct(Product2 oPro){
        if(oProduct == null) oProduct = new Product2();
        oProduct = oPro;
    }
    public Selection__c getOSelection(){
    if(oSelection == null) oSelection = new Selection__c(); 
        return oSelection;  
    }
    public void setOSelection(Selection__c oSel){
        if(oSelection == null) oSelection = new Selection__c();
        oSelection = oSel;
    }
    public Education__c getOEducationSATone(){
    if(oEducationSATone == null) oEducationSATone = new Education__c(); 
        return oEducationSATone;    
    }
    public void setOEducationSATone(Education__c oEd){
        if(oEducationSATone == null) oEducationSATone = new Education__c();
        oEducationSATone = oEd;
    }
    // get-set for Lists
    public list<Education__c> getListAllEducation(){
            return listAllEducation;
    }
    public list<Education__c> getListEducationLQ(){
    if(listEducationLQ == null) listEducationLQ = new list<Education__c>(); 
        return listEducationLQ; 
    }
    public void setListEducationLQ(list<Education__c> listEd){
        if(listEducationLQ == null) listEducationLQ = new list<Education__c>();
        listEducationLQ = listEd;
    }
    public list<Education__c> getListEducationLQ_EN(){
    if(listEducationLQ_EN == null) listEducationLQ_EN = new list<Education__c>();   
        return listEducationLQ_EN;  
    }
    public void setListEducationLQ_EN(list<Education__c> listEd){
        if(listEducationLQ_EN == null) listEducationLQ_EN = new list<Education__c>();
        listEducationLQ_EN = listEd;
    }
    public list<Education__c> getListEducationLQ_FR(){
    if(listEducationLQ_FR == null) listEducationLQ_FR = new list<Education__c>();   
        return listEducationLQ_FR;  
    }
    public void setListEducationLQ_FR(list<Education__c> listEd){
        if(listEducationLQ_FR == null) listEducationLQ_FR = new list<Education__c>();
        listEducationLQ_FR = listEd;
    }
    public list<Education__c> getListEducationSQ(){
    if(listEducationSQ == null) listEducationSQ = new list<Education__c>(); 
        return listEducationSQ; 
    }
    public void setListEducationSQ(list<Education__c> listEd){
        if(listEducationSQ == null) listEducationSQ = new list<Education__c>();
        listEducationSQ = listEd;
    }
    public list<Education__c> getListEducationSQ_SecSchool(){
    if(listEducationSQ_SecSchool == null) listEducationSQ_SecSchool = new list<Education__c>(); 
        return listEducationSQ_SecSchool;   
    }
    public void setListEducationSQ_SecSchool(list<Education__c> listEd){
        if(listEducationSQ_SecSchool == null) listEducationSQ_SecSchool = new list<Education__c>();
        listEducationSQ_SecSchool = listEd;
    }
    public list<Education__c> getListEducationSQ_SecSchool_DDnull(){
    if(listEducationSQ_SecSchool_DDnull == null) listEducationSQ_SecSchool_DDnull = new list<Education__c>();   
        return listEducationSQ_SecSchool_DDnull;    
    }
    public void setListEducationSQ_SecSchool_DDnull(list<Education__c> listEd){
        if(listEducationSQ_SecSchool_DDnull == null) listEducationSQ_SecSchool_DDnull = new list<Education__c>();
        listEducationSQ_SecSchool_DDnull = listEd;
    }
    public list<Education__c> getListEducationSQ_HE(){
    if(listEducationSQ_HE == null) listEducationSQ_HE = new list<Education__c>();   
        return listEducationSQ_HE;  
    }
    public void setListEducationSQ_HE(list<Education__c> listEd){
        if(listEducationSQ_HE == null) listEducationSQ_HE = new list<Education__c>();
        listEducationSQ_HE = listEd;
    }
    public list<Education__c> getListEducationTS(){
    if(listEducationTS == null) listEducationTS = new list<Education__c>(); 
        return listEducationTS; 
    }
    public void setListEducationTS(list<Education__c> listEd){
        if(listEducationTS == null) listEducationTS = new list<Education__c>();
        listEducationTS = listEd;
    }
    public list<Selection__c> getListSelection(){
    if(listSelection == null) listSelection = new list<Selection__c>(); 
        return listSelection;   
    }
    public void setListSelection(list<Selection__c> listEd){
        if(listSelection == null) listSelection = new list<Selection__c>();
        listSelection = listEd;
    }
    public list<Additional__c> getListAdditional_IE(){
    if(listAdditional_IE == null) listAdditional_IE = new list<Additional__c>();    
        return listAdditional_IE;   
    }
    public void setListAdditional_IE(list<Additional__c> listAdd){
        if(listAdditional_IE == null) listAdditional_IE = new list<Additional__c>();
        listAdditional_IE = listAdd;
    }
    public list<Additional__c> getListAdditional_M(){
    if(listAdditional_M == null) listAdditional_M = new list<Additional__c>();  
        return listAdditional_M;    
    }
    public void setListAdditional_M(list<Additional__c> listAdd){
        if(listAdditional_M == null) listAdditional_M = new list<Additional__c>();
        listAdditional_M = listAdd;
    }
    public list<Profile_Experience__c> getListProfileExperience_WE(){
    if(listProfileExperience_WE == null) listProfileExperience_WE = new list<Profile_Experience__c>();  
        return listProfileExperience_WE;    
    }
    public void setListProfileExperience_WE(list<Profile_Experience__c> listPE){
        if(listProfileExperience_WE == null) listProfileExperience_WE = new list<Profile_Experience__c>();
        listProfileExperience_WE = listPE;
    }
    public list<Profile_Experience__c> getListProfileExperience_ECK(){
    if(listProfileExperience_ECK == null) listProfileExperience_ECK = new list<Profile_Experience__c>();    
        return listProfileExperience_ECK;   
    }
    public void setListProfileExperience_ECK(list<Profile_Experience__c> listPE){
        if(listProfileExperience_ECK == null) listProfileExperience_ECK = new list<Profile_Experience__c>();
        listProfileExperience_ECK = listPE;
    }
    //End getter and setter 
    
    
    
//////////////////////++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//////////////////   Intern Class ++++++++++++++++++++++++++++++++++++++++++++++
////////////////////////////////////////////////////////////////////////////////
private void setRecordType(){
    idRTeducationSQ = [select id, Name from RecordType where IsActive=true and SobjectType='Education__c' and Name= 'School Qualification' limit 1].id;
    idRTeducationLQ = [select id, Name from RecordType where IsActive=true and SobjectType='Education__c' and Name= 'Language Qualification' limit 1].id;
    idRTeducationTS = [select id, Name from RecordType where IsActive=true and SobjectType='Education__c' and Name= 'Test Scores' limit 1].id;
    idRTadditionalIE = [select id, Name from RecordType where IsActive=true and SobjectType='Additional__c' and Name= 'International Exposure' limit 1].id;
    idRTadditionalM = [select id, Name from RecordType where IsActive=true and SobjectType='Additional__c' and Name= 'Miscellaneous' limit 1].id;   
    idRTpe_WE = [select id, Name from RecordType where IsActive=true and SobjectType='Profile_Experience__c' and Name= 'Work Experience' limit 1].id; 
    idRTpe_ECK = [select id, Name from RecordType where IsActive=true and SobjectType='Profile_Experience__c' and Name= 'Extra Curricular Activities' limit 1].id;
    idRTAddress_CPA = [select id, Name from RecordType where IsActive=true and SobjectType='Address__c' and Name= 'Contact Permanent Address' limit 1].id;      
}

private void splitEducation(){
    if(!listAllEducation.isEmpty()){
        for(Education__c oEducationTEMP : listAllEducation){
            if(oEducationTEMP.RecordTypeId == idRTeducationSQ)
                listEducationSQ.add(oEducationTEMP);
            else if (oEducationTEMP.RecordTypeId == idRTeducationLQ)
                listEducationLQ.add(oEducationTEMP);
            else if (oEducationTEMP.RecordTypeId == idRTeducationTS)
                listEducationTS.add(oEducationTEMP);
        }   
    }
}

private void splitLanguageQualification(){
    if(!listEducationLQ.isEmpty()){
        for(Education__c oEducationTEMP : listEducationLQ){
            if(oEducationTEMP.Language__c == 'English')
                listEducationLQ_EN.add(oEducationTEMP);
            else if(oEducationTEMP.Language__c == 'French')   
                listEducationLQ_FR.add(oEducationTEMP); 
        }
    }
}

private void splitEducationSQ_Education (){
    if(!listEducationSQ.isEmpty()){
        for(Education__c oEducationTEMP : listEducationSQ){
            if(oEducationTEMP.Education__c == 'Secondary School'){
                if(oEducationTEMP.Diploma_Date__c != null)
                    listEducationSQ_SecSchool.add(oEducationTEMP);
                else listEducationSQ_SecSchool_DDnull.add(oEducationTEMP);
            }
            else if(oEducationTEMP.Education__c == 'Higher Education') 
                listEducationSQ_HE.add(oEducationTEMP);
        }       
    }
}

private void splitAdditional(){
    if(!listAdditional.isEmpty()){
        for(Additional__c oAddiTEMP : listAdditional){
            if(oAddiTEMP.RecordTypeId == idRTadditionalIE)  
                listAdditional_IE.add(oAddiTEMP);
            else if(oAddiTEMP.RecordTypeId == idRTadditionalM)  
                listAdditional_M.add(oAddiTEMP);
        }
    }
}

private void splitProfileExperience(){
    if(!listProfileExperience.isEmpty()){
        for(Profile_Experience__c oPE : listProfileExperience){
            if(oPE.RecordTypeId == idRTpe_WE)   
                listProfileExperience_WE.add(oPE);
            else if(oPE.RecordTypeId == idRTpe_ECK) 
                listProfileExperience_ECK.add(oPE);
        }   
    }   
}
// End Class
}