trigger onEinkauf on Einkauf__c (before insert) {
	onEinkaufBewegungen.init(trigger.new);
}