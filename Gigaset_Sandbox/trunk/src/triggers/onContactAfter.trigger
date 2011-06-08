trigger onContactAfter on Contact (after delete, after insert, after undelete, 
after update) {

    list<Id> accountids = new list<Id>();
    if (trigger.isAfter) {
        if (trigger.isDelete) {
            for (Contact c: trigger.old) {
                if (c.Gigaset_Pro__c) accountids.add(c.AccountId);
            }
        }
        if (trigger.isInsert || trigger.isUnDelete) {
            for (Contact c: trigger.new) {
                if (c.Gigaset_Pro__c) accountids.add(c.AccountId);
            }
        }
        if (trigger.isUpdate) {
            for (Contact c: trigger.new) {
                //if (c.Gigaset_Pro__c != trigger.oldMap.get(c.id).Gigaset_Pro__c) 
                accountids.add(c.AccountId);
            }
        }
    }
    
    if (!accountids.isEmpty()) changeAccounts.ChangeAccounts(accountids);
    
}