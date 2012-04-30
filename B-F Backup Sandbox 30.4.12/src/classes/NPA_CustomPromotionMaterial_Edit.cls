/*****************************************************************************************
 Name    : NPA_CustomPromotionMaterial_Edit
 Desc    : Public class to edit the material item.
 Approach:
          Use standard controller to perform edit operation on the Promotion Material Item. 
 Modification Log : 
 ---------------------------------------------------------------------------
 Developer              Date            Description
 ---------------------------------------------------------------------------
 Venkata Mani Kuamr     04/11/2011      Original Version
 ******************************************************************************************/


public class NPA_CustomPromotionMaterial_Edit {
    private Promotion_Material_Item__c pmItem;
    public NPA_CustomPromotionMaterial_Edit(ApexPages.StandardController controller) {
        pmItem = (Promotion_Material_Item__c) controller.getRecord();
    }
    public PageReference save(){
        if(pmItem.Planned_Cost__c>0){
            update pmItem;
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Planned Cost should be greater than zero.'));
            return null;
        }
        return new Pagereference('/'+pmItem.Id);
    }
   /*****************************************************************************************
     Method
     ===========
     Method Name    :    Cancel 
     Description    :   a) Used to return the control to the promotion of the selected Promotion Material Item
     Arguments      :   void
     Return Type    :   PageReference
     ******************************************************************************************/
    
    public PageReference cancel(){
        System.debug('The value of the promotion is'+ ApexPages.currentPage().getParameters().get('promotion') );
        PageReference pr  = new PageReference(   ApexPages.currentPage().getParameters().get('promotion') );
        return pr;
    }

}