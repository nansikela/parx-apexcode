public class WebNavItem {
  
  public String Id {get; set;}
  public String pId {get; set;}
  public String parent {get; set;}
  public String name {get; set;}
  public String url {get;set;}
  
  public boolean isFirstCategory  {get; set;}
  public boolean isLastCategory  {get; set;}
  public boolean isFirstItem  {get; set;}
  public boolean isLastItem {get; set;}
  public boolean isFirstPage {get; set;}
  public boolean isLastPage {get; set;}
  public boolean isActive {get; set;}
  public boolean isCategory {get; set;}
  
  //Constructor
  
  
  
  public WebNavItem(){
    this.init();
  }
  //Init
  private void init(){
    this.isFirstCategory = false;
    this.isLastCategory = false;
    this.isFirstItem = false;
    this.isLastItem = false;
    this.isFirstPage = true;
    this.isLastPage = false;
    this.isActive = false;
    this.isCategory = false;
  }
  
}