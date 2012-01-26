trigger segmentation_updateContactSegmList on segmentation__c (after insert, after update, after delete) {

	/*
	 * Whenever a segmentation is updated, the segmentation data on the contact should also be updated.
	 * This happens by recalculating the data on the contact related to a segm.
	 *
	 */
	 
	// Definition of RT ID's
	String RT_CONTACTAOI	= '0122000000050Kl';
	String RT_CONTACTCAT	= '012200000005007';
	String RT_MARKETPREFS 	= '01220000000500C';
	String RT_MEMBERSHIP	= '01220000000501F';

	list<id> contactIdList = new List<id>();
	list<Segmentation__c> allSegmentationsList = new List<Segmentation__c>();
	list<Contact> allContactsList = new List<Contact>();
	List<Segmentation__c > newSegmentationsList;
	
	// Incoming segmentations
	if(Trigger.isDelete){
		newSegmentationsList = Trigger.old;
	}
	else{
		newSegmentationsList = Trigger.new;
	}
	
	// generate list of contacts having segmentations
	for (Segmentation__c seg : newSegmentationsList){
	
		if(seg.Contact__c != null ){
		
			contactIdList.add(seg.Contact__c);
		
		}
	}
	
	// Get all contact objects
	allContactsList = [SELECT 
							c.Id, 
							c.Contacts_Membership__c, 
							c.Contacts_Marketing_Preferences__c, 
							c.Contacts_Categories__c, 
							c.Contacts_Areas_of_Interest__c 
						FROM 
							Contact c 
						WHERE
							c.id IN :contactIdList
						];
	
	
	// Get all segmentations of all contacts 
	allSegmentationsList = [SELECT 
								s.Type__c, 
								s.Subtype__c, 
								s.RecordTypeId, 
								s.Marketing_Sub_Preferences__c, 
								s.Marketing_Preferences__c, 
								s.Interest_Area__c, 
								s.Contact__c 
							FROM 
								Segmentation__c s
							WHERE
								Contact__c IN :contactIdList
							];
	
	
	// Foreach of the contacts, loop through its segmentations and concatenate the strings
	for (Contact con : allContactsList){
	
		String categoriesString 			= '';
		String areasOfInterestString 		= '';
		String marketingPreferencesString 	= '';
		String membershipString 			= '';
		
		Boolean isFirstContactCat 	= true;
		Boolean isFirstContactAOI 	= true;
		Boolean isFirstMarketPrefs 	= true;
		Boolean isFirstMembership	= true;
		
		for (Segmentation__c segm : allSegmentationsList){
		
		// TODO: Handle empty subselections, no semicolon at end of list
		
			// Filter to all segm. of a specific contact
			if(segm.contact__c == con.id){
				
				if(segm.RecordTypeId == RT_CONTACTCAT){
				
					if(!isFirstContactCat){
						categoriesString = CategoriesString + '; ';
					}				
					if(segm.Type__c != null && segm.Subtype__c != null){
						categoriesString = CategoriesString + segm.Type__c + ' (' + segm.Subtype__c + ')';
						isFirstContactCat = false;
					}
					else if(segm.Type__c != null){
						categoriesString = CategoriesString + segm.Type__c;
						isFirstContactCat = false;
					}
					
				}
				else if(segm.RecordTypeId == RT_CONTACTAOI){
					
					if(!isFirstContactAOI){
						areasOfInterestString = areasOfInterestString + '; ';
					}					
					if(segm.Interest_Area__c != null){
						areasOfInterestString = areasOfInterestString + segm.Interest_Area__c;
						isFirstContactAOI = false;
					}
					
				}
				else if(segm.RecordTypeId == RT_MARKETPREFS){
					
					if(!isFirstMarketPrefs){
						marketingPreferencesString = marketingPreferencesString + '; ';
					}						
					if(segm.Marketing_Preferences__c != null && segm.Marketing_Sub_Preferences__c != null){
						marketingPreferencesString = marketingPreferencesString + segm.Marketing_Preferences__c + ' (' + segm.Marketing_Sub_Preferences__c + ')';
						isFirstMarketPrefs = false;
					}
					else if(segm.Marketing_Preferences__c != null){
						marketingPreferencesString = marketingPreferencesString + segm.Marketing_Preferences__c ;
						isFirstMarketPrefs = false;
					}
					
				}
				else if(segm.RecordTypeId == RT_MEMBERSHIP){
					
					if(!isFirstMembership){
						membershipString = membershipString + '; ';
					}						
					if(segm.Type__c != null && segm.Subtype__c != null){
						membershipString = membershipString + segm.Type__c + ' (' + segm.Subtype__c + ')';
						isFirstMembership = false;
					}
					else if(segm.Type__c != null){
						membershipString = membershipString + segm.Type__c;
						isFirstMembership = false;
					}
				}
				// If other RT, do nothing
			
			}
			
		}
		
		con.Contacts_Membership__c 				= membershipString; 
		con.Contacts_Marketing_Preferences__c	= marketingPreferencesString; 
		con.Contacts_Categories__c				= categoriesString; 
		con.Contacts_Areas_of_Interest__c		= areasOfInterestString; 
	}
	
	update allContactsList;
	
	
	
	
}