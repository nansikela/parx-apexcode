/**
* @author Christian Deckert
* @date 18/08/2011
* @description Class orders Boxes in the right way / Adds Boxes to navigation
*/
public class BoxOrderController {
	public List<Box_to_Navigation__c> boxList {get; set;}
	String naviId;
	public List<BoxContainer> rightBoxForInsertList {get; set;}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Constructor
	*/
	public BoxOrderController()
	{
		naviId = WebURLEncoder.decodeparam('naviId');
		boxList = [SELECT box__c, box__r.name, Anordnung__c FROM Box_to_Navigation__c WHERE Navigation__c = :naviId ORDER BY Anordnung__c];
		
		Set<ID> currentBoxesSet = new Set<ID>();
		for(Box_to_Navigation__c b: boxList)
		{
			currentBoxesSet.add(b.box__c);
		}
		rightBoxForInsertList = new List<BoxContainer>();
		for(Right_Box__c b : [SELECT id, name FROM Right_Box__c WHERE ID NOT IN :currentBoxesSet])
		{
			rightBoxForInsertList.add(new BoxContainer(b));
		}
	}
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description saves new Boxes to Navigation relation
	*/
	public Pagereference saveNewBoxes()
	{
		List<Box_to_Navigation__c> insertBoxToNav = new List<Box_to_Navigation__c>();
		for(BoxContainer b : rightBoxForInsertList)
		{
			if(b.isForInsert)
			{
				Box_to_Navigation__c box2Nav = new Box_to_Navigation__c();
				box2Nav.box__c = b.box.id;
				box2Nav.navigation__c = naviId;
				insertBoxToNav.add(box2Nav);
			}
		}
		if(insertBoxToNav.size()>0)
		{
			insert insertBoxToNav;
		}
		return cancel();
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description updates current relation
	* @return returns PageReference navi Id
	*/
	public PageReference save()
	{
		update boxList;
		return cancel();
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description cancel edit
	* @return returns PageReference navi Id
	*/
	public PageReference cancel()
	{
		return new PageReference('/'+naviId);
	}
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description box container for Right_Box__c
	*/
	class BoxContainer
	{
		public Right_box__c box {get; set;}
		public boolean isForInsert {get; set;}
		
		public BoxContainer(Right_box__c box)
		{
			this.box = box;
			this.isForInsert = false;
		}
	}
	
	/**
	* @author Christian Deckert
	* @date 18/08/2011
	* @description Test methode versuch an hand einer navigation id eine Box zu speichern /Canceln
	*/
	static testMethod void test(){
		Navigation__c n = [SELECT ID FROM Navigation__c LIMIT 1];
		ApexPages.currentPage().getParameters().put('navId', n.id);
		BoxOrderController controller = new BoxOrderController();
		controller.save();
		controller.cancel();
		controller.saveNewBoxes();
	}
}