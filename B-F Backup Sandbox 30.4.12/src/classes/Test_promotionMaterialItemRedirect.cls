/**********************************************************************************************
    Name    : Test_promotionMaterialItemRedirect

    Desc    : Test class to cover promotionMaterialItemRedirect_Controller 


    Modification Log :  
--------------------------------------------------------------------------------------------------------
 Developer                                 Date             Description
--------------------------------------------------------------------------------------------------------                                            Original Version
Jishad(Deloitte Consulting)      		1-Aug-2011        Created
 ***********************************************************************************************/
@istest
private class Test_promotionMaterialItemRedirect
{
    public static testmethod void Test_promotionmethod()
    {
    Id promotionRecTypeId=null;
    Map<String,Schema.RecordTypeInfo> promoRTMapByName = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName();
    if(promoRTMapByName.containsKey('National Promotion - US')){
        promotionRecTypeId = promoRTMapByName.get('National Promotion - US').getRecordTypeId();
    }
      Supplier__c supp = new Supplier__c(Name='B-F');
            insert supp;
            
    
    Date dt = system.today()+1;
    Date futureDt = system.today()+1;
      List<Brand__c> brandList = new List<Brand__c>{
                new Brand__c(Name='Brand1',Supplier__c=supp.Id),new Brand__c(Name='Brand2',Supplier__c=supp.Id)};
            insert brandList;
            
            List<Internal_Order__c> ioList = new List<Internal_Order__c>{
                new Internal_Order__c(Name='IO1',Description__c='IO1',Internal_Order_Number__c='IO1'),
                new Internal_Order__c(Name='IO2',Description__c='IO2',Internal_Order_Number__c='IO2')};
            insert ioList;
     List<Promotion__c> promoList = new List<Promotion__c>{
                new Promotion__c(RecordTypeId=promotionRecTypeId,Promotion_Start_Date__c=dt,Brand_NPA__c=brandList[0].Id,
                Promotion_End_Date__c=dt,Freeze_Date__c=futureDt, Internal_Order__c=ioList[0].Id,Promotion_Status__c='Active',
                Promotion_Premise__c='On Premise'),
                 new Promotion__c(Promotion_Start_Date__c=dt,Brand_NPA__c=brandList[0].Id,
                Promotion_End_Date__c=dt,Freeze_Date__c=futureDt, Internal_Order__c=ioList[1].Id,Promotion_Status__c='Active',
                Promotion_Premise__c='On Premise')};
                
    insert promoList;
    
        
    Promotion_Material_Item__c pmi=new Promotion_Material_Item__c();
    List<Promotion_Material_Item__c> pmilist=new List<Promotion_Material_Item__c>();
    pmi.promotion__c=promolist.get(0).id;
    pmilist.add(pmi);
    pmilist.add(new Promotion_Material_Item__c(promotion__c=promolist.get(1).id));
    
    database.insert(pmilist);
    
    PageReference pageRef = Page.promotionmaterialitem;
    Test.SetCurrentpage(pageRef);
    ApexPages.StandardController stdCon = new ApexPages.StandardController(pmi);
    promotionMaterialItemRedirect_Controller  pmicntlr=new promotionMaterialItemRedirect_Controller(stdCon);
    pmicntlr.Redirect();
    
    stdCon = new ApexPages.StandardController(pmilist.get(1));
    pmicntlr=new promotionMaterialItemRedirect_Controller(stdCon);
    pmicntlr.Redirect();
     
    }
    
}