trigger beforeProductLaunchDetail on Product_Launch_Detail__c (before insert) {

for (Product_Launch_Detail__c  myProductLaunchDetail : Trigger.new) {

//Product_Launch__c setIntial = ([Select id From Product_Launch__c where Product_Launch__c =:myProductLaunch.Product_Launch__c ]);
myProductLaunchDetail.Counter__c = 1 + [select count() from Product_Launch_detail__c where Product_Launch__c =:myProductLaunchDetail.Product_Launch__c];
myProductLaunchDetail.Week__c = 'Week'+myProductLaunchDetail.Counter__c;

Product_Launch__c setWeek = ([Select week__c From Product_Launch__c where id =:myProductLaunchDetail.Product_Launch__c limit 1]);
setWeek.week__c = myProductLaunchDetail.Counter__c;

update(setWeek);

}

}