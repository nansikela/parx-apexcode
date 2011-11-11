/*****************************************************************************************
 Name    : NPA_CustomPromotionClone
 Desc    : Public class to clone a promotion along with PromotionLineItems.
           a) Using Visual force the select promotion information is first copied into a new instance 
           b) All the fields of the Visual force page is populated with the selected promotion.
           c) After update of fields the new instance is saved and then lineitems from original object would be copied.
 Approach: 
            a) Controller contains one promotion instance to hold the selected promotion information.
            b) Show all the fields associated to the standard edit page layout in the clone page.
            c) Populate the fields from the new promotion instance which is not saved to Database.
            d) On click of save new promotion instance would be saved to Database with updated fields.
            e) Copy all the Lines from old promotion to the new instance.
 Modification Log : 
 ---------------------------------------------------------------------------
 Developer              Date            Description
 ---------------------------------------------------------------------------
 Achin Suman            04/11/2011      Original Version
 ******************************************************************************************/

public class NPA_CustomPromotionClone {
    public Promotion__c clonepromo {get;set;}
    // Map to store required attribute of fields displayed on the page
    public Map<String,Boolean> fieldMap {get;set;}
   /*****************************************************************************************
     Constructor
     ===========
     Method Name    :    NPA_CustomPromotionClone 
     Description    :   a) Get Promotion record details based on Id.
                         
     Arguments      :   void
     Return Type    :   void
     ******************************************************************************************/
         
    public NPA_CustomPromotionClone(ApexPages.StandardController controller) {
        clonepromo=[Select (Select Name,Promotion__c,Quantity__c,Product_Custom__c,Status__c,Planned_Cost__c,
                               Unit_of_Measure__c,Product_Description__c from Promotion_Material_Items__r),
                        p.Tertile__c, p.Sales_Org__c,p.CreatedDate , p.RecordTypeId, p.Premise_Indicator_Code__c, 
                        p.Promotion_Status__c, p.Promotion_Start_Date__c, p.Promotion_Premise__c, p.Promotion_Number__c, 
                        p.Promotion_End_Date__c, p.Name, p.Mark_for_Delete__c, p.Internal_Order__c, p.GTM_Channel_Description__c, p.GTM_Channel_Code__c, 
                        p.Freeze_Date__c, p.Fiscal_Year__c, p.Brand_NPA__c From Promotion__c p where p.Id =: controller.getId()][0];
        System.debug('The promotion is '+clonepromo);
        
        fieldMap = new Map<String,Boolean>();
        // Get all the custom setting values and populate the fields map 
        for(Promotion_Clone_Fields__C field: Promotion_Clone_Fields__C.getall().values()){
            fieldMap.put(field.Name, field.Required_Field__c);
        }
    }
   /*****************************************************************************************
     Method 
     ===========
     Method Name    :    custom_clone 
     Description    :   a) Inserts the new promotion instance and copy the lines from the old
                            promotion to new instance.
                        b) Returns the PageReference newly created record.
                         
     Arguments      :   void
     Return Type    :   PageReference
     ******************************************************************************************/
    
    public PageReference custom_clone(){
    try{
            Promotion__c clonedpromo = clonepromo.clone(false,true);
            System.debug('The new cloned is'+clonedpromo);
            clonedPromo.Promotion_Status__c = 'Created';
            insert clonedpromo;
            final String pliStatus = '0';
            List<Promotion_Material_Item__c> lineitems = new List<Promotion_Material_Item__c>();
            if(clonepromo.Promotion_Material_Items__r.size() > 0)
            {
                //lineitems = clonepromo.Promotion_Material_Items__r.clone();
                for(Promotion_Material_Item__c pmi : clonepromo.Promotion_Material_Items__r)    
                {
                    Promotion_Material_Item__c li = new Promotion_Material_Item__c(promotion__c=clonedpromo.Id,status__c=pliStatus,
                                                        Product_Custom__c=pmi.Product_Custom__c,Quantity__c=pmi.Quantity__c,
                                                        Planned_Cost__c=pmi.planned_cost__c,unit_of_measure__c=pmi.unit_of_measure__c,
                                                        Product_Description__c=pmi.Product_Description__c);
                    lineitems.add(li);
                }     
                insert lineitems;
            }
            PageReference pr = new PageReference('/'+clonedpromo.Id);
            return pr;
        }
        catch(Exception e)
        {
            System.debug('the apex messages are '+ ApexPages.getMessages().size());
            
            String errorMsg = ''; 
            ApexPages.Message myMsg;
            if(e.getMessage().contains('IO_Fiscal_Tertile__c')){
                
                errorMsg = 'Duplicate: Another Promotion exists for the selected Internal Order for the specified Tertile and Fiscal Year.' ;
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg);
                ApexPages.addMessage(myMsg);
            }
            return null;    
        }
        
    }
   /*****************************************************************************************
     Method
     ===========
     Method Name    :    Cancel 
     Description    :   a) Used to return the control to the inital promotion selected without 
                            performing any operation.
     Arguments      :   void
     Return Type    :   PageReference
     ******************************************************************************************/
    
    
    public PageReference cancel(){
       PageReference pr = new PageReference('/'+clonepromo.Id);
       return pr;
    }
    
    
}