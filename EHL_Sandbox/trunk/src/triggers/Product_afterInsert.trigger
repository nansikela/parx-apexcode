trigger Product_afterInsert on Product2 (after insert) {
	//automatically add product to pricebook Currencies CHF, EUR, USD. Standard and list price 0.-
	//pricebook matching> 	Bachelor Program--> Bachelor Programs, Preparatory Programs
	//						Master Program --> Master Programs
	//						Diploma Programs --> Diploma Programs
	
	
	//PROGRAM RECORDTYPE PRODUCT
	String RECORDTYPE_PROGRAM = '012200000004y0dAAA'; //Program
	
	//FAMILIY
	String PRODUCT_BACHELOR = 'Bachelor Programs';
	String PRODUCT_PREPARATORY = 'Preparatory Programs';
	String PRODUCT_MASTER = 'Master Programs';
	String PRODUCT_DIPLOMA = 'Diploma Programs';
	
	//PRICEBOOK ID
	String PRICEBOOK_BACHELOR = '01s200000001RCUAA2';
	String PRICEBOOK_MASTER = '01s200000001RsaAAE';
	String PRICEBOOK_DIPLOMA = '01s200000001RCPAA2';
	
	ProductPriceHandler handler = new ProductPriceHandler(RECORDTYPE_PROGRAM, PRODUCT_BACHELOR, PRODUCT_PREPARATORY, PRODUCT_MASTER, PRODUCT_DIPLOMA, PRICEBOOK_BACHELOR, PRICEBOOK_MASTER, PRICEBOOK_DIPLOMA);
	
	List<Product2> programProductList = new List<Product2>();
	
	//autonaming for Program product
	for(Product2 p : Trigger.new){		
		if(p.RecordTypeId == RECORDTYPE_PROGRAM){
			programProductList.add(p);
		}
	}
	
	if(!programProductList.isEmpty()){
		handler.insertPricebookEntry(programProductList);
	}
}