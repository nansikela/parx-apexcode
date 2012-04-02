trigger onRechnung on Rechnung__c (before insert) {
	onRechnung.onInsert(trigger.new, false); 
}