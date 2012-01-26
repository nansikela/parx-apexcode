trigger ContactForceRecordType on Contact (before insert) {
	private string contactRecordTypeID ='012P0000000Cp6z';
	
	for (contact c : Trigger.new){
		c.RecordTypeId = contactRecordTypeID;
	}
	
}