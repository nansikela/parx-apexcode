trigger afterUpdateProductLaunchDetail on Product_Launch_Detail__c (after update) {

reorderProductLaunchDetails realign = new reorderProductLaunchDetails(); 

for (Product_Launch_Detail__c  myProductLaunchDetail : Trigger.new) {


realign.myUpdate(myProductLaunchDetail.Product_Launch__c);

//Checking the Sync Flag
Product_Launch__c myFlagReset = [SELECT sync__c FROM Product_Launch__c where Id = :myProductLaunchDetail.Product_Launch__c limit 1];

myFlagReset.sync__c = true;

update(myFlagReset);


//}

//Product_Launch_Detail__c theNewRecord = new Product_Launch_Detail__c();
	
//system.debug(myProductLaunchDetail.Product_Launch__c);
	
//theNewRecord.Product_Launch__c = myProductLaunchDetail.Product_Launch__c;
//theNewRecord.Survey_Date__c = myProductLaunchDetail.Survey_Date__c + 7;


//insert (theNewRecord);


	

	
}


}