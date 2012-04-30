/**************************************************************************
 Name    : NPA_PromoMaterialAddSearchController
 Desc    : Public class to search/add products to the promotions following the client specific business logic.
 a. Custom controller with search, select, deselect products to add on current promotion. 
 b. This controller shall default SalesOrg, Brand from the Promotion. 
 c. Each promotion shall add products specific to the brand and Sales Org.
 i. Product Id, Description, Brand, SalesOrg would be used to search for products
 ii.If Id, Brand, SalesOrg exist then the query would be constructed using these parameters and if only on product is found
 the product is directly added to the selected list.
 iii.If Id, Description, Brand, SalesOrg exist then query would be constructed as follows:
 1)Or Condition between Id and Description.
 2)And Condition between Brand and SalesOrg and the step1 expression. 
 d. Based on the search results products shall be rendered in available list. 
 e. On User selection product would be added to selected list if it does not exist already, if it exist an error would be rendered
 on the UI.
 f. On successfull adding of the products user can further filter the final list to add to the promotion.  
 Approach: 
 1. Read all the existing promotion line items and construct map, whose key string would be the combination of product_number__c, Name.
 2. Read the Search Parameters.
 3. Construct the query based on the paramters and pass it to StandardSetController which inturn used for pagination.
 4. Get products based on the filter conditions.
 5. Wrap the product data using a wrapper class which can be used to identify the selected list.
 6. Next and previous buttons would be rendered based the controller gethasnext and gethasprevious conditions.
 7. Onclick event of check box on the availablelist verify whether it is added or not. If not added add to the list else 
 8. Only products that are checked in the final selected list would be added to promotion.
 
 Modification Log : 
 ---------------------------------------------------------------------------
 Developer              Date            Description
 ---------------------------------------------------------------------------
 Venkata Mani Kumar K   04/11/2011      Original Version
 *****************************************************************************/

public class NPA_PromoMaterialAddSearchController {
    /**************************************************************************
     prodid                          :       String to hold the selected ProductId of the availablelist products
     limit_to_brand                  :       Check box to limit the search criteria to brand or not.
     promotion                       :       Promotion record associated to the promotionId
     addedSet                        :       Set to hold Selected Products Id
     Id_Category                     :       String to hold Product Id from search screen
     desc_category                   :       String to hold Product Description from search screen
     ssc                             :       StandardSetController used to get the list of products based on search criteria.
     promotionlinemaps               :       Map to hold the Promotion Line Item ("Product_Number+||+ProductDescription", PromotionLineNumber)
     availableList                   :       Holds the current setcontroller records.
     addedList                       :       Selected Products from the availableList
     promotionid                     :       String to hold QueryString id
     hasprev,hasnext                 :       boolean variables to check whether setcontroller has next/previous records.
     
     **************************************************************************/

    public String prodid {
        get {
            if (prodid == null) {
                prodid = '';
            }
            return prodid;
        }
        set;
    }
    public boolean limit_to_brand {
        get {
            return limit_to_brand = limit_to_brand == null ? true : limit_to_brand;
        }
        set;
    }
    public Promotion__c promotion {
        get;
        set;
    }
    public Set < String > addedSet {
        get;
        set;
    }
    public String screenname {
        get {
            System.debug('The value of the screenname' + screenname);
            return screenname = screenname == null ? '' : screenname;
        }
        set;
    }
    public String Id_Category {
        get {
            return Id_category = Id_category == null ? '' : Id_category;
        }
        set;
    }
    public String desc_category {
        get {
            return desc_category = desc_category == null ? '' : desc_category;
        }
        set;
    }
    public ApexPages.StandardSetController ssc {
        get;
        set;
    }
    public Map < String, String > promotionlinemaps = new Map < String, String > ();
    public List < ProductData > availableList {
        get {
            if (availableList == null) availableList = new List < ProductData > ();
            return availableList;
        }
        set;
    }
    public List < ProductData > addedList {
        get;
        set;
    }
    public String promotionid = '';
    public boolean hasnext {
        get;
        set;
    }
    public boolean hasprev {
        get;
        set;
    }
    public boolean checkboxstatus {
        get {
            if (checkboxstatus == null) checkboxstatus = false;
            return checkboxstatus;
        }
        set;
    }
    public Integer listsize {
        get {
            if (addedList != null) return addedList.size();
            else return 0;
        }
        set;
    }
    public Integer availablelistsize {
        get {
            if (availableList != null) return availableList.size();
            else return 0;
        }
        set;
    }
    public boolean costError {get; set;}
    public Set < String > errorset = new Set < String > ();

    /**************************************************************************
     Constructor
     ===========
     Method Name    :    NPA_promotionCustMaterialItem_Controller 
     Description    :   a) Get Promotion record details based on Id.
                        b) Initializing hasnext to true    
     Arguments      :   void
     Return Type    :   void
     **************************************************************************/
    List < Promotion_Material_Item__c > promotionmaterials {
        get;
        set;
    }
    public NPA_PromoMaterialAddSearchController() {
        try {
            promotionid = ApexPages.CurrentPage().getParameters().get('id');
            List < Promotion__c > promotionlist = [Select p.Sales_Org__c, p.RecordTypeId, p.Promotion_Status__c, p.Internal_Order__c, p.Brand_NPA__r.Name From Promotion__c p where p.Id = : promotionid];
            if (promotionlist != null && promotionlist.size() > 0) {
                promotion = promotionlist.get(0);
                promotionmaterials = [Select p.Unit_of_Measure__c, p.Unit_Cost__c, p.Status__c, p.Promotion__c, p.Product_Custom__r.ProductCode__c, p.Product_Custom__r.Unit_Cost__c, p.Product_Custom__r.UOM__c, p.Product_Custom__r.Name, p.Product_Custom__r.Planned_Cost__c, p.Product_Custom__c, p.Planned_Cost__c, p.Name, p.Id From Promotion_Material_Item__c p where p.Promotion__c = : promotion.Id];
                hasprev = false;
                for (Promotion_Material_Item__c prline: promotionmaterials) {
                    promotionlinemaps.put(prline.product_custom__c + '||' + prline.Product_Custom__r.Name + '||' + prline.Product_Custom__r.ProductCode__c, prline.Name);
                }
                hasnext = true;
                deletedid = '';
                costError = false;
            }
        } catch (Exception e) {
            System.debug('Exception is' + e.getMessage());
        }
    }
    
    /**************************************************************************
    Wrapper class to accept Product Number from the quick add screen and auto populate descriptoin
    and status  .
    *****************************************************************************************/
    public class Direct_Add {
        public String Id_category {
            get;
            set;
        }
        public String desc_category {
            get;
            set;
        }
        public String duplicate_msg {
            get;
            set;
        }
        public integer rownum {
            get;
            set;
        }
        public Direct_Add() {
            Id_category = '';
            desc_category = '';
            duplicate_msg = '';
            rownum = 0;
        }
    }
    
    public List < Direct_Add > directaddrows {
        get {
            if (directaddrows == null) directaddrows = new List < direct_Add > ();
            return directaddrows;
        }
        set;
    }
    public List < Direct_Add > getDatagrid() {
        System.debug('the value of directaddrows' + directaddrows);
        if (directaddrows != null && directaddrows.size() < 1) {
            directaddrows = new Direct_Add[10];
            for (integer i = 0; i < 10; i++) {
                Direct_Add temp = new Direct_Add();
                temp.rownum = i + 1;
                directaddrows.add(temp);
            }
        }
        return directaddrows;
    }
    public String productnumber {
        get;
        set;
    }
    public String checkdupe = '';
    
	/**************************************************************************
	    Wrapper class to store the products available and product selected, 
	    including attributes like planned cost.
	*****************************************************************************************/
    public class ProductData {
        public product__c product {
            get;
            set;
        }
        public boolean isselected {
            get;
            set;
        }
        public integer quantity {
            get;
            set;
        }
        public String status {
            get;
            set;
        }
        public Decimal planned_cost {
            get;
            set;
        }
        public boolean grayout {
            get;
            set;
        }
        public ProductData(product__c pr) {
            isselected = false;
            product = pr;
            quantity = 0;
            grayout = false;
            planned_cost = pr.Planned_cost__c;
        }
    }
    
    /**************************************************************************
    Method Name : Cancel
    Description : Used to return back user to the promotion when user hits cancel button.
    Arguments   : void
    *****************************************************************************************/
    public PageReference cancel() {
        PageReference pr = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
        pr.setRedirect(true);
        return pr;
    }
    public string previousid = '';
    public Map < String, ProductData > productmap = new Map < String, ProductData > ();
    public String deselectedid = '';
    /**************************************************************************
    Method Name : construct_Query
    Description : Method used to construct search query for both quick add section and search 
                  based on the criteria.
    Arguments   : void
    *****************************************************************************************/
    Id productRecType = null;
    public String construct_Query() {
        Map < String, String > orcondition = new Map < String, String > ();
        Map < String, String > andcondition = new Map < String, String > ();
        Map<String,Schema.RecordTypeInfo> rtMapByName  = Schema.SObjectType.Product__c.getRecordTypeInfosByName();
        if(rtMapByName.containsKey('POS - US')){
            productRecType = rtMapByName.get('POS - US').getRecordTypeId();
        }
        String baseQuery = 'Select p.Name,p.UOM__c ,p.Unit_Cost__c, p.Planned_Cost__c, p.Id,p.ProductCode__c,tolabel(p.Status__c) From Product__c p';
        String whereclause = ' where p.Mark_for_Deletion__c  = false AND p.RecordTypeId=:productRecType';
        try {
            if (((Id_Category != null) && (Id_Category.trim() != '')) && ((desc_Category != null) && (desc_Category.trim() != ''))) {
                andcondition.put('Id', Id_Category);
                andcondition.put('description', desc_Category);
            }
            if (Id_Category != null && ((desc_category == null) || (desc_Category == ''))) {
                orcondition.put('Id', Id_Category);
            }
            if (desc_category != null && ((Id_Category == null) || (Id_Category == ''))) {
                orcondition.put('description', desc_Category.trim());
            }
            if (promotion != null) {
                if (promotion.Brand_NPA__c != null) {
                    andcondition.put('Brand', promotion.Brand_NPA__c);
                }
                if (promotion.Sales_Org__c != null) {
                    andcondition.put('SalesOrg', promotion.Sales_Org__c);
                }
            }
            System.debug('The value of the map is' + orcondition + '___________' + andcondition);
            if (orcondition.size() > 0) {
                System.debug('In orcondition++++');
                if (orcondition.get('Id') != null && orcondition.get('Id') != '') {
                    whereclause = whereclause + ' AND p.ProductCode__c like ' + '\'' + '%' +  orcondition.get('Id') + '%' + '\'';
                } else if (orcondition.get('description') != null && orcondition.get('description') != '') {
                    whereclause = whereclause + ' AND p.Name like ' + '\'' + '%' + orcondition.get('description') + '%' + '\'';
                }
            } else {
                whereclause = ' where p.ProductCode__c like ' + '\'' + '%' +  andcondition.get('Id') + '%' + '\'';
                whereclause = whereclause + ' and p.Name like ' + '\'' + '%' + andcondition.get('description') + '%' + '\'';
            }
            if ((limit_to_brand) && (andcondition.get('Brand') != null)) {
                whereclause = whereclause + ' and p.Brand__c = ' + '\'' + andcondition.get('Brand') + '\'';
            }
            if (andcondition.get('SalesOrg') != null) {
                whereclause = whereclause + ' and p.Sales_Org__c = ' + '\'' + andcondition.get('SalesOrg') + '\'';
            }
            String sortby = ' order by p.ProductCode__c LIMIT 9999';
            
            System.debug('The value of the where clause is' + basequery + whereclause);
            if (whereclause != '') {
                return basequery + whereclause + sortby;
            } else {
                return basequery + sortby;
            }
        } catch (Exception e) {
            System.debug('The exception is ' + e.getMessage());
            return '';
        }
    }
    /**************************************************************************
    Method Name : search
    Description : Method used to create the StandardSetController from the constructed query. 
    Arguments   : void
    Return Type : Page Reference( This method is returning null so that page would be refreshed, 
                  so that all getter methods shall be invoked).
    *****************************************************************************************/
    public PageReference search() {
        System.debug('The query is ' + construct_Query());
        ssc = new ApexPages.StandardSetController(Database.getQueryLocator(construct_Query()));

        if (ssc != null && ssc.getRecords().size() > 0) {

            if (ssc.getHasNext()) {
                hasnext = true;
            } else {
                hasnext = false;
            }
            availablelist_render = true;
        } else {
            availablelist_render = false;
        }

        return null;
    }
    /**************************************************************************
    Method Name : getListofProducts
    Description : Method used to construct list ProductData records wrapping with products 
                  retrieved from StandardSetController. 
    Arguments   : void
    Return Type : List of ProductData
    *****************************************************************************************/
    public List < ProductData > getListofProducts() {
        String keystring = '';
        availableList = new List < ProductData > ();
        productmap = new Map < String, ProductData > ();
        if (ssc != null) {
            for (product__c pr: (List < product__c > ) ssc.getRecords()) {
                keystring = pr.id + '||' + pr.Name + '||' + pr.ProductCode__c;
                ProductData prdt = new ProductData(pr);
                if (addedSet != null && addedSet.size() > 0) {
                    if (addedSet.contains(pr.Id)) {
                        prdt.isselected = true;
                    }
                }
                if (!promotionlinemaps.containsKey(keystring)) {
                    prdt.grayout = false;
                } else {
                    prdt.grayout = true;
                }
                availableList.add(prdt);
            }
            if (ssc.getRecords().size() == 1) {
                add_specific_item();
                hasnext = false;
                hasprev = false;
            }
            if (ssc.getHasNext()) {
                hasnext = true;
            } else {
                hasnext = false;
            }
            if (ssc.getHasPrevious()) {
                hasprev = true;
            } else {
                hasprev = false;
            }
            availablelist_render = true;
        } else {
            availableList = null;
            availablelist_render = false;
        }
        return availableList;
    }
    /**************************************************************************
    Method Name : clear
    Description : Method used to clear the Id and Description fields on the search tab. 
    Arguments   : void
    Return Type : void
    *****************************************************************************************/
    
    public void clear() {
        Id_Category = '';
        desc_category = '';
    }
    /**************************************************************************
    Method Name : next
    Description : Method calls the StandardSetController next method. 
    Arguments   : void
    Return Type : void
    *****************************************************************************************/
    public void next() {
        ssc.next();
        if (ssc.getHasNext()) {
            setprev_next_true();
        } else {
            hasnext = false;
            hasprev = true;
        }
    }
    /**************************************************************************
    Method Name : previous
    Description : Method calls the StandardSetController previous method. 
    Arguments   : void
    Return Type : void
    *****************************************************************************************/
    public void previous() {
        ssc.previous();
        if (ssc.getHasPrevious()) {
            setprev_next_true();
        } else {
            hasprev = false;
            hasnext = true;
        }
    }
    /**************************************************************************
    Method Name : setprev_next_true
    Description : Method used to set flags which shall enable previous and next buttons. 
    Arguments   : void
    Return Type : void
    **************************************************************************/
    
    public void setprev_next_true() {
        hasprev = true;
        hasnext = true;
    }
    /**************************************************************************
    Method Name : deselectaddedlist
    Description : Method used to perform add or delete products to the selected list.
                    a.) When user selects the check box in the availableList
                        i.) Call addproduct() and pass product id.
                    b.) When user unselects the check box in the availableList
                        i.) Call deleteproduct(); 
    Arguments   : void
    Return Type : PageReference (this method returns null to refresh the page and call the getter methods.)
    **************************************************************************/
    
    public PageReference deselectaddedlist() {
        deletedid = '';
        for (ProductData pr: availableList) {
            if (pr.product.id == prodid) {
                System.debug('The product selected is' + pr);
                if (pr.isselected) {
                    addproduct(pr.product.id);
                    break;
                } else {
                    deleteproduct();
                    deletedid = pr.product.id + '||' + pr.product.Name + '||' + pr.product.ProductCode__c;
                    break;
                }
            }
        }
        integer i = 0;
        String keystring = '';
        return null;
    }
   /**************************************************************************
    Method Name : removeDuplicate
    Description : Method used to remove the duplicates.
    Arguments   : void
    Return Type : void
    **************************************************************************/
    public void removeDuplicate(String keystring) {
        if (errorset != null && errorset.contains(keystring)) errorset.remove(keystring);
    }
   /**************************************************************************
    Method Name : add_specific_item
    Description : Method used to automatically add product to selectedList and availablelist
                  when only one product is fetched based on search criteria
    Arguments   : void
    Return Type : void
    **************************************************************************/    
    public void add_specific_item() {
        String keystring = '';
        System.debug('+++++++++++deletedid is +++++++++++' + deletedid);
        if (ssc.getRecords().size() == 1 && !ssc.gethasNext() && !ssc.gethasPrevious()) {
            ProductData prdt = availableList[0];
            keystring = prdt.product.id + '||' + prdt.product.Name + '||' + prdt.product.ProductCode__c;
            if (!promotionlinemaps.containsKey(keystring)) {
                if (deletedid != keystring) {
                    availableList[0].isselected = true;
                    addproduct(prdt.product.id);
                }
            }
            hasnext = false;
            hasprev = false;
        }
    }
    /**************************************************************************
    Method Name : addproduct
    Description : Method used to add specific product to SelectList with the productid passed.
    Arguments   : void
    Return Type : void
    **************************************************************************/
    public void addproduct(String productid) {
        String keystring = '';
        for (ProductData pr: availableList) {
            if (addedList == null || addedList.size() == 0) {
                addedList = new List < ProductData > ();
            }
            if (addedSet == null || addedSet.size() == 0) {
                addedSet = new Set < String > ();
            }
            if (pr.isselected && pr.product.Id == productid) {
                keystring = pr.product.id + '||' + pr.product.Name + '||' + pr.product.ProductCode__c;
                if (!promotionlinemaps.containsKey(keystring)) {
                    if (!addedSet.contains(pr.product.Id)) {
                        addedSet.add(pr.product.Id);
                        addedList.add(pr);
                        System.debug('Product is added 3');
                    }
                }
            }
        }
    }
    
    /**************************************************************************
    Method Name : deleteproduct
    Description : Method used to deleteproduct
    Arguments   : void
    Return Type : void
    **************************************************************************/
    public void deleteproduct() {
        string keystring = '';
        for (ProductData pr: availableList) {
            if (pr.product.Id == prodid) {
                keystring = pr.product.id + '||' + pr.product.Name + '||' + pr.product.ProductCode__c;
                break;
            }
        }
        if (addedSet != null) {
            if (addedSet.contains(prodid)) {
                List < ProductData > result = delete_LineItems(prodid);
                if (result.size() == 0) {
                    addedList.clear();
                } else {
                    addedList = result;
                }
            }
        }
    }
    public String deletedid = '';
    
    /**************************************************************************
    Method Name : delete_LineItems
    Description : Method used to delete records from the addedlist.
    Arguments   : String
    Return Type : List<ProductData>
    **************************************************************************/
    public List < ProductData > delete_LineItems(String ProdId) {
        List < ProductData > tempdata = addedList;
        integer i = 0;
        String keystring = '';
        if (addedSet.contains(prodid)) {
            for (ProductData pr: tempdata) {
                if (pr.product.Id == prodid) {
                    tempdata[i].isselected = false;
                    addedSet.remove(prodid);
                    keystring = pr.product.id + '||' + pr.product.Name + '||' + pr.product.ProductCode__c;
                    removeDuplicate(keystring);
                }
                i++;
            }
        }
        System.debug('The tempdata is +++++' + tempdata);
        List < ProductData > resultset = new List < ProductData > ();
        for (ProductData pr: tempdata) {
            if (pr.isselected) {
                resultset.add(pr);
            }
        }
        return resultset;
    }
    
    /**************************************************************************
    Method Name : lastrecordadd
    Description : Method used to add last record to addedlist when user clicks “Enter-Key” after entering product-id.
    Arguments   : void
    Return Type : void
    **************************************************************************/
    public void lastrecordadd() {
        if (directaddrows != null && directaddrows.size() > 0) {
            for (integer i = 0; i < directaddrows.size(); i++) {
                if (directaddrows[i] != null) {
                    if ((directaddrows[i].Id_category != null && directaddrows[i].Id_category != '') && (directaddrows[i].duplicate_msg == null || directaddrows[i].duplicate_msg == '')) {
                        productnumber = '' + directaddrows[i].rownum;
                    }
                }
            }
            if (productnumber != null && productnumber != '') checkid();
        }
    }
	
	/**************************************************************************
    Method Name : checkid
    Description : Method used to add records to the added list through “Direct Add” functionality.
					a)	Productnumber(row number) would be sent from UI to the controller.
					b)	This row number used to identify the product id added.
					c)	Check whether the same product id exist in the Promotion Material Items.
					d)	If exist displays message as duplicate.
					e)	If product id is not found in the query results then display message as “Invalid”
					f)	If product id is valid and not duplicate then add the product to the addedlist. 
    Arguments   : void
    Return Type : PageReference
    **************************************************************************/
    public PageReference checkid() {
        Set < String > validids = new Set < String > ();
        String id = '';
        boolean dupefound = false;
        Integer idtocheck = 0;
        String keystring = '';
        System.debug('The value of the productnumber is' + productnumber + directaddrows);
        if (addedList == null || addedList.size() == 0) {
            addedList = new List < ProductData > ();
        }
        if (addedSet == null || addedSet.size() == 0) {
            addedSet = new Set < String > ();
        }
        if (productnumber != null && directaddrows != null) {
            for (integer i = 0; i < directaddrows.size(); i++) {
                if (directaddrows[i] != null && directaddrows[i].rownum == Integer.valueOf(productnumber)) {
                    idtocheck = i;
                }
            }
        }
        if (productnumber.trim() != '') {
            System.debug('The value of the producnumber ************' + productnumber);
            if (directaddrows[idtocheck].Id_category != null && directaddrows[idtocheck].Id_category == '') {
                directaddrows[idtocheck].duplicate_msg = '';
                directaddrows[idtocheck].desc_category = '';
                String key1 = '';
                keystring = prod_selectedList_location.get(productnumber);
                String productid = '';
                for (ProductData pr: addedList) {
                    key1 = pr.product.id + '||' + pr.product.Name + '||' + pr.product.ProductCode__c;
                    if (key1.equalsIgnorecase(keystring)) {
                        productid = pr.product.id;
                        break;
                    }
                }
                addedList = delete_LineItems(productid);
            }
            for (String key: promotionlinemaps.keySet()) {
                String[] keystrings = key.split('\\|\\|');
                System.debug(keystrings + '___________' + directaddrows[idtocheck].Id_category + '=====' + key);
                if (directaddrows[idtocheck].Id_category != '' && keystrings[2].equalsIgnorecase(directaddrows[idtocheck].Id_category)) {
                    dupefound = true;
                    directaddrows[idtocheck].duplicate_msg = 'Duplicate, Already exists';
                    break;
                }
            }
            if (!dupefound) {
                id = directaddrows[idtocheck].Id_category;
            }
            if (id != null && id != '') {
                //List < Product__c > prods = [Select p.Name, p.UOM__c, p.Unit_Cost__c, p.Planned_Cost__c, p.Id, p.Product__c, tolabel(p.Status__c) From product__c p where p.Brand__c =:promotion.Brand_NPA__c and p.Sales_Org__c =:promotion.Sales_Org__c and  p.Product__c = : id];
                List < Product__c > prods = [Select p.Name, p.UOM__c, p.Unit_Cost__c, p.Planned_Cost__c, p.Id, p.ProductCode__c, tolabel(p.Status__c) From product__c p where p.Sales_Org__c = : promotion.Sales_Org__c and p.ProductCode__c = : id];
                System.debug(prods.size() + '+++++++++');
                if (prods.size() > 0) {
                    for (Product__c prod: prods) {
                        if (!addedSet.contains(prod.Id)) {
                            keystring = prod.id + '||' + prod.Name + '||' + prod.ProductCode__c;
                            addedSet.add(prod.Id);
                            ProductData pr = new ProductData(prod);
                            pr.isSelected = true;
                            addedList.add(pr);
                            System.debug('Product is added 4');
                            directaddrows[idtocheck].duplicate_msg = 'Product Code is Valid';
                            directaddrows[idtocheck].desc_category = pr.product.Name;
                            prod_selectedList_location.put(productnumber, keystring);
                        } else {
                            directaddrows[idtocheck].duplicate_msg = 'Product is already added';
                        }
                    }
                } else {
                    directaddrows[idtocheck].duplicate_msg = 'Product Code is Invalid. Enter a correct Product Code';
                    System.debug('###########invalid id');
                }
            }
        } else {
            System.debug('________________________The value is nullify______________________');
            directaddrows[idtocheck].duplicate_msg = '';
            directaddrows[idtocheck].desc_category = '';
        }
        return null;
    }
    
    public Map < String, String > prod_selectedList_location = new Map < String, String > ();
    
    /**************************************************************************
    Method Name : close
    Description : Method used to successfully create Material items based on the added list and associate them to promotion.
    Arguments   : void
    Return Type : PageReference
    **************************************************************************/
    public PageReference close() {
        lastrecordadd();
        if (addedList != null && addedList.size() > 0) {
            List < Promotion_Material_Item__c > lineitems = new List < Promotion_Material_Item__c > ();
            for (ProductData prd: addedList) {
                if (prd.isselected) {
                    Promotion_Material_Item__c newline = new Promotion_Material_Item__c();
                    newline.Product_Custom__c = prd.product.id;
                    newline.Promotion__c = promotionid;
                    newline.Status__c = '0';
                    if(prd.planned_cost>0){
                        newline.Planned_Cost__c = prd.planned_cost;
                    }else{
                        costError = true;
                        return null;
                    }
                    newline.Unit_of_Measure__c = prd.product.UOM__c;
                    newline.Product_Description__c = prd.product.Name;
                    System.debug('The value of the new line is ' + newline);
                    lineitems.add(newline);
                }
            }
            try{
            	insert lineitems;
            } catch(Exception e){
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
	            	'An error occurred while creating Promotion Material Items.'));
	            return null;
	        }
            PageReference pr = new PageReference('/' + promotionid);
            pr.setRedirect(true);
            return pr;
        } else {
            return null;
        }
    }
    
    public boolean availablelist_render {
        get {
            System.debug('the availablelist is' + availablelist_render);
            return availablelist_render;
        }
        set;
    }
    
    public boolean selectledlist_render {
        get;
        set;
    }
    
    public String tableft {
        get;
        set;
    }
    
    /**************************************************************************
    Method Name : hideavailablelist
    Description : Method used to set rendering variable, based on this available list will be visible.
    Arguments   : void
    Return Type : void
    **************************************************************************/
    public void hideavailablelist() {
        System.debug('The method is called');
        System.debug('the Tableft is in the hideavailablelist' + tableft);
        availablelist_render = false;
    }
    
    /**************************************************************************
    Method Name : showavailablelist
    Description : Method used to show search results as available list.
    Arguments   : void
    Return Type : void
    **************************************************************************/
    public void showavailablelist() {
        System.debug('the Tableft is in the showavailablelist' + tableft);
        if (availableList != null && availableList.size() > 0) {
            availablelist_render = true;
        }
        if (addedList != null && addedList.size() > 0) {
            selectledlist_render = true;
        }
    }
    
    /**************************************************************************
    Method Name : clear_directaddrows
    Description : Method to clear old rows and makes it available for additional 
    			  rows. All the added list would be untouched.
    Arguments   : void
    Return Type : void
    **************************************************************************/
    public void clear_directaddrows() {
        if (directaddrows != null && directaddrows.size() > 0) {
            for (Direct_Add ad: directaddrows) {
                if (ad != null) {
                    ad.desc_category = '';
                    ad.duplicate_msg = '';
                    ad.Id_category = '';
                }
            }
        }
    }
}