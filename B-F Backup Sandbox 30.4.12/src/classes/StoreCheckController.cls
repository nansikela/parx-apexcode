/* Class Name : StoreCheckController
* Description: Controller that loads and saves all data referring to StoreCheck records
* Created By : Germany Consultant
* Created On : 05/03/12
*
* Modification Log :  
* ----------------------------------------------------------------------------------------------------------------------------
* Developer       		Date			Description
* ----------------------------------------------------------------------------------------------------------------------------
* Michael Mickiewicz 	05/03/2012		Create the whole business logic for the Store Check Interface. Including field-level-
*										access, read-only mode and new-record-mode. 
*/ 
public with sharing class StoreCheckController {
    
    public ID recordID {get;set;}
    public Account a {get;set;}
    public Store_Check__c record {get;set;}
    public Outlet_Visit__c lastVisitedOutletVisit {get;set;}
    public Boolean isReadOnly {get;set;}	//Necessary to identify, if interface is in read-only of read-write mode
    public list<Product__c> products {get;set;}
    public list<Store_Check_Item__c> sci_header {get;set;} //Required as a dummy list for fixed-table-header-workaround
    public list<Store_Check_Item__c> selected_sci {get;set;}
    public list<Outlet_Visit_Item__c> lastOVIs {get;set;}
    
    private Boolean isNewRecord;	//Necessary to identify, if interface is opened in new or edit mode
    
    
    public StoreCheckController(ApexPages.StandardController ctrl){
        isReadOnly = false;
        recordID = ctrl.getRecord().ID;
        isNewRecord = false;
        
        //Branch for distinction if interface is in new or in edit mode
        if(recordID == null) {
            record = new Store_Check__c(Account__c = ((Store_Check__c)ctrl.getRecord()).Account__c);
            isNewRecord = true;
        } else {
            record = [Select ID, 
                        Account__c, 
                        Last_Visit_SR__c,  
                        Last_Outlet_Visit__c,
                        SR__c, 
                        SC_By__c, 
                        SC_Date__c, 
                        Rating_Grade__c,
                        Notes_Comment_about_shelf_situation__c, 
                        All_pricing_labels_available__c, 
                        sales_campaign_with_2_pl_realized__c,
                        Sales_campaign_labels_tended__c, 
                        Gaps_in_shelf_closed__c, 
                        enough_products_in_the_shelf_available__c,
                        Gift_promo_packs_in_shelf_available__c,
                        Gift_promo_packs_addit_avail_in_shelf__c, 
                        JD_Cola_Ginger_available_in_shelf__c,
                        JD_Cola_Ginger_avail_in_chiller_cab__c,
                        JD_Cola_Ginger_available_in_tray__c,
                        JD_Cola_Ginger_avail_as_single_can__c,
                        JD_Cola_Ginger_avail_as_in_multi_pack__c,
                        B_F_listing_complete_realized_practiced__c,
                        Data_maintenance_in_SF_complete_correct__c,
                        Targ_for_follow_up_visit_maintained_SF__c,
                        Remarks_after_discussion__c,
                        Addit_notes_comments_about_cust_acc__c,
                        Product_first_SCP__c,
                        Product_second_SCP__c,
                        Product_third_SCP__c,
                        Location_first_SCP__c,
                        Location_second_SCP__c,
                        Location_third_SCP__c,
                        Ground_Area_First_SCP__c,
                        Ground_Area_Second_SCP__c,
                        Ground_Area_Third_SCP__c,
                        Space_First_SCP__c,
                        Space_Second_SCP__c,
                        Space_Third_SCP__c,
                        Number_of_bottles_display_First_SCP__c,
                        Number_of_bottles_display_Second_SCP__c,
                        Number_of_bottles_display_Third_SCP__c,
                        Notes_comments_about_secondary_placement__c
                    From Store_Check__c 
                    Where ID = :recordID limit 1];
        }
        
        //Query all needed account information
        a = [Select ID, Billingcity, Billingstreet, Market__c From Account Where ID = :record.Account__c limit 1];
        
        //Query LAST outlet visit information
        list<Outlet_Visit__c> ovs;
        if(isNewRecord) 
            ovs = [Select Id, Name, Met_With__c, Visit_Date__c, Visit_Comments__c, OwnerId  From Outlet_Visit__c Where Last_Visit__c = true and Account__c = :record.Account__c limit 1];
        else
            ovs = [Select Id, Name, Met_With__c, Visit_Date__c, Visit_Comments__c, OwnerId  From Outlet_Visit__c Where Id = :record.Last_Outlet_Visit__c limit 1];
        
        if(ovs.size() > 0) {
            lastVisitedOutletVisit = ovs.get(0);
            if(isNewRecord) {
                record.Last_Outlet_Visit__c = lastVisitedOutletVisit.Id;
                record.SR__c = lastVisitedOutletVisit.OwnerId;
                record.Last_Visit_SR__c = lastVisitedOutletVisit.Visit_Date__c;
            }
            lastOVIs = [Select Id, Available__c, Bottle_Price_Special__c, Bottle_Price__c, Facing__c, Shelf__c, Custom_Product__c, Product__r.Name From Outlet_Visit_Item__c Where Available__c = true and Outlet_Visit__c = :lastVisitedOutletVisit.ID];
        }   
        
 		//Filling list for pageblocktable of outlet visit items
        sci_header = new list<Store_Check_Item__c>();
        if(recordID != null)
            selected_sci = [Select Product__c, Product__r.Name, Price__c, Special_Price__c, Facings_shelf__c, OOS_with__c, Shelf_from_bottom__c, Store_Check__c From Store_Check_Item__c Where Store_Check__c = :recordID];
        else {
            selected_sci = new list<Store_Check_Item__c>();
            for(Outlet_Visit_Item__c ovi : [Select Id, Available__c, Bottle_Price_Special__c, Bottle_Price__c, Facing__c, Shelf__c, Custom_Product__c, Product__r.Name, Product__c From Outlet_Visit_Item__c Where Outlet_Visit__c = :record.Last_Outlet_Visit__c AND Available__c = true]) {
                selected_sci.add(new Store_Check_Item__c(Product__c = ovi.Custom_Product__c, Outlet_Visit_Item__c = ovi.Id));
            }
        }
        
        if (!Schema.sObjectType.Store_Check_Item__c.fields.Facings_GAM__c.isUpdateable() && !Schema.sObjectType.Store_Check_Item__c.fields.Facings_shelf__c.isUpdateable() && !Schema.sObjectType.Store_Check_Item__c.fields.OOS_with__c.isUpdateable() && !Schema.sObjectType.Store_Check_Item__c.fields.Shelf_from_bottom__c.isUpdateable()){
              isReadOnly = true;
        }
        
        set<ID> selectedProductIDs = new set<ID>();
        for(Store_Check_Item__c sci : selected_sci)
            if(!selectedProductIDs.contains(sci.Product__c))
                selectedProductIDs.add(sci.Product__c);
                
        products = [Select ID, Name From Product__c Where RecordType.Name = 'Wet Goods' AND ID NOT IN :selectedProductIDs AND Market__c = :a.Market__c order by Name asc];
        
        if(selected_sci == null)
            selected_sci = new list<Store_Check_Item__c>();
    }
    

    public PageReference selectItem() {
        String id = ApexPages.currentPage().getParameters().get('productID');
        
        Integer i = 0;
        
        for(Product__c p : products){ 
            if(p.ID == id)
                break;
            i++;
        }
        
        products.remove(i);
        Outlet_Visit_Item__c ovi;
        
        for(Outlet_Visit_Item__c o : [Select Id, Available__c, Bottle_Price_Special__c, Bottle_Price__c, Facing__c, Shelf__c, Custom_Product__c, Product__r.Name, Product__c From Outlet_Visit_Item__c Where Product__c = :id AND  Outlet_Visit__c = :record.Last_Outlet_Visit__c limit 1])
            ovi = o;
            
        if(id != null && id != '') {
            Store_Check_Item__c sci = new Store_Check_Item__c(Product__c = id, Store_Check__c = recordID);
            if(ovi != null)
                sci.Outlet_Visit_item__c = ovi.Id;
            selected_sci.add(sci);
        }
        
        return null;
    }
    
    
    public PageReference deselectItem() {
        String id = ApexPages.currentPage().getParameters().get('productID');
        system.debug(id);
        Integer i = 0;
        
        for(Store_Check_Item__c sci : selected_sci) {
            if(sci.Product__c == id)
                break;
            i++;
        }
        
        if(i < selected_sci.size()) {
            selected_sci.remove(i);
            set<ID> selectedProductIDs = new set<ID>();
            for(Store_Check_Item__c sci : selected_sci)
                if(!selectedProductIDs.contains(sci.Product__c))
                    selectedProductIDs.add(sci.Product__c);
            
            products = [Select ID, Name From Product__c Where RecordType.Name = 'Wet Goods' AND ID NOT IN :selectedProductIDs order by Name asc];
        
        } else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.sc_error_sc_not_found));
        
        return null;
    }
    
    
    public PageReference save() {
        
        try{
            upsert record; 
            recordID = record.ID;
            
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.sc_error_sc_cannot_be_updated));
            return null;
        }
        try{
            if(selected_sci.size() > 0) {
                for(Store_Check_Item__c item : selected_sci)
                    if(item.Store_Check__c == null)
                        item.Store_Check__c = recordID;
                upsert selected_sci;
            }
        }catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.sc_error_sci_cannot_be_saved));
            return null;
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.sc_info_saved));
        return cancel();
    }
    
    
    public PageReference cancel() {
        return new PageReference('/'+record.Account__c);
    }
    
    
    
    
    public static testMethod void MainTest() {
    	RecordType rt = [Select ID From RecordType Where sObjectType = 'Product__c' AND DeveloperName = 'Wet_Goods' limit 1]; 
    	
        Market__c market = new Market__c(Market_Code__c = 'GER', Name = 'Germany', Off_Channel__c = '2', On_Channel__c = '3');
        insert market;
        
    	Account account1 = new Account(Name = 'Test Account 1', Market__c = market.Id, Channel__c = 'Off', BillingCountry = 'DE');
        insert account1;
    
    	Brand__c brand1 = new Brand__c(Name = 'Jack Daniel\'s');
    	insert brand1;
    	
        Brand__c brand2 = new Brand__c(Name = 'Herradura');
        insert brand2;
        
        Product__c product1 = new Product__c(Brand__c = brand1.ID, RecordTypeID = rt.ID, Market__c = market.Id);
        insert product1;
                
        Product__c product2 = new Product__c(Brand__c = brand2.ID, RecordTypeID = rt.ID, Market__c = market.Id);
        insert product2; 
        
        Store_Check__c obj = new Store_Check__c(Account__c = account1.Id);
        insert obj;
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(obj);
        StoreCheckController ctrl = new StoreCheckController(stdCtrl);
        
        ID productID = ctrl.products.get(ctrl.products.size()-1).Id;
        ApexPages.currentPage().getParameters().put('ProductID', productID);
        ctrl.selectItem();
       
        ctrl.save();
        
        ctrl = new StoreCheckController(stdCtrl);
        ApexPages.currentPage().getParameters().put('ProductID', productID);
        ctrl.deselectItem();
        
        ctrl.cancel();
        
        obj = new Store_Check__c(Account__c = account1.Id);
        
        stdCtrl = new ApexPages.StandardController(obj);
        ctrl = new StoreCheckController(stdCtrl);
    }
}