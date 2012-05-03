trigger afterDeleteProductLaunchDetail on Product_Launch_Detail__c (after delete) {

reorderProductLaunchDetails myRecord = new reorderProductLaunchDetails(); 

for (Product_Launch_Detail__c  myProductLaunchDetail : Trigger.old) {
	
	
	


myRecord.myDelete(myProductLaunchDetail.Product_Launch__c);

//system.debug('In the Trigger');	
	
//List<Product_Launch_Detail__c> reorder = [SELECT Id, Counter__c, week__c,Survey_Date__c FROM Product_Launch_Detail__c where Product_Launch__c =:myProductLaunchDetail.Product_Launch__c ORDER BY Survey_Date__c ASC];

//system.debug(reorder);	

//Integer i = 1;

//for(Product_Launch_Detail__c FL1 : reorder){



//FL1.Counter__c = i;
//FL1.Week__c = 'Week'+i; 	
	
//i = i + 1;

//}

//update(reorder);

//How to return back to Product Launch Detail


//}

}
}