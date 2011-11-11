public class NPA_PromotionWrapper{
  public Promotion__c promotions {get;set;}
  public List<InnerWrapper> allocList {get;set;}
  
  public NPA_PromotionWrapper (Promotion__c promo, List<InnerWrapper> iw){
          promotions= promo;
          allocList = iw;
  }
  
  public class InnerWrapper{
      public Promotion_Material_Item__c PLI {get;set;}
      public List<Allocations__c> Allocs {get;set;}
      
      public InnerWrapper(Promotion_Material_Item__c items, List<Allocations__c> all){
          PLI = items;
          Allocs = all;
      }
  }
}