@RestResource(urlMapping='/Wombat/*')
global class wombat_Sync {
	public final static Integer twoBillion = 2000000000;
		
	@HttpPost
	global static void updateServer(String sessionID, String ownerId, List<List<String>> clientData) {
		integer numberOfColumns = 0;
		
		List<wombat_Transaction_Items__c> transactionItems = new List<wombat_Transaction_Items__c>();
		List<Wombat_Mobile_Config__c> wmc = null;
		List<String> objectColumns = new List<string>();
		List<Account> accounts = new List<Account>();
		List<Asset__c> assets = new List<Asset__c>();
		List<Asset_Move__c> assetMoves = new List<Asset_Move__c>();
		List<Contact> contacts = new List<Contact>();
		List<Account_Wholesaler__c> accountWholesalers = new List<Account_Wholesaler__c>();
		List<Venue__c> venues = new List<Venue__c>();
		List<Order__c> orders = new List<Order__c>();
		List<Order_Item__c> orderItems = new List<Order_Item__c>();
		List<Outlet_Visit__c> outletVisits = new List<Outlet_Visit__c>();
		List<Outlet_Visit_Item__c> outletVisitItems = new List<Outlet_Visit_Item__c>();
		List<Event> events = new List<Event>();
		List<Promotion__c> promotions = new List<Promotion__c>();
		List<Group_Promotions__c> deals = new List<Group_Promotions__c>();
		List<Group_Promotion_Item__c> dealItems = new List<Group_Promotion_Item__c>();
		
		List<SOBJECT> deletedItems = null;
		
		List<List<String>> accountData = new List<List<String>>();
		List<List<String>> assetData = new List<List<String>>();
		List<List<String>> assetMoveData = new List<List<String>>();
		List<List<String>> accountWholesalerData = new List<List<String>>();
		List<List<String>> contactData = new List<List<String>>();
		List<List<String>> venueData = new List<List<String>>();
		List<List<String>> orderData = new List<List<String>>();
		List<List<String>> orderItemData = new List<List<String>>();
		List<List<String>> outletVisitData = new List<List<String>>();
		List<List<String>> outletVisitItemData = new List<List<String>>();
		List<List<String>> eventData = new List<List<String>>();
		List<List<String>> promotionData = new List<List<String>>();
		List<List<String>> dealData = new List<List<String>>();
		List<List<String>> dealItemData = new List<List<String>>();
		
		List<wombat_Sync_Audit__c> auditLog = new List<wombat_Sync_Audit__c>();
		
		Schema.DescribeSObjectResult accountDescribe = Account.SObjectType.getDescribe();
		Schema.DescribeSObjectResult assetDescribe = Asset__c.SObjectType.getDescribe();
		Schema.DescribeSObjectResult assetMoveDescribe = Asset_Move__c.SObjectType.getDescribe();
		Schema.DescribeSObjectResult contactDescribe = Contact.SObjectType.getDescribe();
		Schema.DescribeSObjectResult accountWholesalerDescribe = Account_Wholesaler__c.SObjectType.getDescribe();
		Schema.DescribeSObjectResult venueDescribe = Venue__c.SObjectType.getDescribe();
		Schema.Describesobjectresult orderDescribe = Order__c.SObjectType.getDescribe();
		Schema.DescribeSObjectResult orderItemsDescribe = Order_Item__c.SObjectType.getDescribe();
		Schema.DescribeSObjectResult outletVisitDescribe = Outlet_Visit__c.SObjectType.getDescribe();
		Schema.DescribeSObjectResult outletVisitItemsDescribe = Outlet_Visit_Item__c.SObjectType.getDescribe();
		Schema.DescribeSObjectResult eventDescribe = Event.SObjectType.getDescribe();
		Schema.DescribeSObjectResult promotionDescribe = Promotion__c.SObjectType.getDescribe();
		Schema.DescribeSObjectResult dealDescribe = Group_Promotions__c.SObjectType.getDescribe();
		Schema.DescribeSObjectResult dealItemDescribe = Group_Promotion_Item__c.SObjectType.getDescribe();
		
		wombat_Transaction_Items__c wti;
		boolean success = true;
		
		updateAuditLog(auditLog, sessionID, 'Started synchronisation @ ' + DateTime.now().format());
		
		Savepoint sp = Database.setSavepoint();
		try {
			
			string objectName; Integer rowType = 0; Integer position;
			for(List<String> o: clientData) {
				objectName = o[0].toLowerCase();
				if (objectName == 'account') {
					accountData.add(o);
				} else if (objectName == 'asset__c') {
					assetData.add(o);
				} else if (objectName == 'asset_move__c') {
					assetMoveData.add(o);
				} else if (objectName == 'account_wholesaler__c') {
					accountWholesalerData.add(o);
				} else if (objectName == 'contact') {
					contactData.add(o);
				} else if (objectName == 'venue__c') {
					venueData.add(o);
				} else if (objectName == 'event') {
					eventData.add(o);
				} else if (objectName == 'order__c') {
					orderData.add(o);
				} else if (objectName == 'order_item__c') {
					orderItemData.add(o);
				} else if (objectName == 'outlet_visit__c') {
					outletVisitData.add(o);
				} else if (objectName == 'outlet_visit_item__c') {
					outletVisitItemData.add(o);
				} else if (objectName == 'promotion__c') {
					promotionData.add(o);
				} else if (objectName == 'group_promotions__c') {
					dealData.add(o);
				} else if (objectName == 'group_promotion_item__c') {
					dealItemData.add(o);
				}
			}
			
			if (!accountData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Updating Account data');				
				for(List<String> o: accountData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}

						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
						transactionItems.add(wti);
	
						Account a = updateAccount(sessionID, ownerId, rowType, auditLog, accountDescribe, objectColumns, o);
						if (a != null) { accounts.add(a); }
					}
				}
			
				if (!accounts.isEmpty()) {
					updateAuditLog(auditLog, sessionID, 'Upserting account data');
					upsert accounts;
				}
			}
			
			// loop through all associated account objects and update account__c with new Id
			// not required now as AUS does not allow reps to create Accounts.
			// may need to add this functionality for other markets.

			if (!venueData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Venues');
				for(List<String> o: venueData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}
	
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
	
						transactionItems.add(wti);
						
						Venue__c a = updateVenue(sessionID, ownerId, rowType, auditLog, venueDescribe, objectColumns, o);
						if (a != null) { venues.add(a); }
						
					}				
				}
				if (!venues.isEmpty()) {
					updateAuditLog(auditLog, sessionID, 'Upserting venue data to server');
					upsert venues;
					for(Venue__c v: venues) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Venue__c' && w.ClientRowID__c == v.Legacy_Code__c) {
								w.ServerRowID__c = v.Id;
							}
						}
						
						for(List<String> o: assetMoveData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}
							} else {
								position = getFieldPosition(objectColumns, 'Venue__c');
								if (position >= 0) {
									if (o[position] == (v.Legacy_Code__c + '.0')) {
										o[position] = v.Id;
									}
								}
							}
						}
						for(List<String> o: contactData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}												
							} else {
								position = getFieldPosition(objectColumns, 'Venue__c');
								if (position >= 0) {
									if (o[position] == (v.Legacy_Code__c + '.0')) {
										o[position] = v.Id;
									}
								}							
							}
						}
						
						for(List<String> o: outletVisitData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}																			
							} else {
								position = getFieldPosition(objectColumns, 'Venue__c');							
								if (position >= 0) {
									if (o[position] == (v.Legacy_Code__c + '.0')) {
										o[position] = v.Id;
									}
								}							
							}
						}
					}
				}
			}			

			if (!contactData.isEmpty()) {				
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Contacts');
				for(List<String> o: contactData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}
	
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
	
						transactionItems.add(wti);
						
						Contact a = updateContact(sessionID, ownerId, rowType, auditLog, contactDescribe, objectColumns, o);
						if (a != null) { contacts.add(a); }
						
					}								
				}
				if (!contacts.isEmpty()) {
					upsert contacts;
					for(Contact c: contacts) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Contact' && w.ClientRowID__c == c.Legacy_Code__c) {
								w.ServerRowID__c = c.Id;
							}
						}
	
						for(List<String> o: assetMoveData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}
							} else {
								position = getFieldPosition(objectColumns, 'Contact__c');
								if (position >= 0) {
									if (o[position] == (c.Legacy_Code__c + '.0')) {
										o[position] = c.Id;
									}
								}
							}
						}
						for(List<String> o: orderData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}												
							} else {
								position = getFieldPosition(objectColumns, 'Contact__c');
								if (position >= 0) {
									if (o[position] == (c.Legacy_Code__c + '.0')) {
										o[position] = c.Id;
									}
								}							
							}						
						}
						for(List<String> o: eventData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}
							} else {
								position = getFieldPosition(objectColumns, 'WhoId');
								if (position >= 0) {
									if (o[position] == (c.Legacy_Code__c + '.0')) {
										o[position] = c.Id;
									}
								}
							}
						}
					}
				}
			}			
			
			if (!assetMoveData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update AssetMove');
				for(List<String> o: assetMoveData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}
						
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
						
						transactionItems.add(wti);
						
						Asset_Move__c a = updateAssetMove(sessionID, ownerId, rowType, auditLog, assetMoveDescribe, objectColumns, o);
						if (a != null) {
							assetMoves.add(a);
						}
					}
				}
				
				if (!assetMoves.isEmpty()) {
					updateAuditLog(auditLog, sessionID, 'Upserting Asset Move data to salesforce');
					upsert assetMoves;
					for(Asset_Move__c m: assetMoves) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Asset_Move__c' && w.ClientRowID__c == m.Legacy_Code__c) {
								w.ServerRowID__c = m.Id;
							}
						}					
					}
					
				}
			}
			if (!eventData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Event (Calendar)');
				for(List<String> o: eventData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}

						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
					
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
					
						transactionItems.add(wti);

						Event a = updateEvent(sessionID, ownerId, rowType, auditLog, eventDescribe, objectColumns, o);
						if (a != null) { events.add(a); }						
					}
				}
			}
			if (!events.isEmpty()) {
				upsert events;
				for(Event ev: events) {
					for(wombat_Transaction_Items__c w: transactionItems) {
						if (w.Object_API_Name__c == 'Event' && w.ClientRowID__c == ev.Legacy_Code__c) {
							w.ServerRowID__c = ev.Id;
						}
					}					
				}
			}
			if (!assetData.isEmpty() && assetDescribe.isUpdateable() == true) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Assets');
				
				for(List<String> o: assetData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}
	
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
						
						transactionItems.add(wti);
	
						Asset__c a = updateAsset(sessionID, ownerId, rowType, auditLog, assetDescribe, objectColumns, o);
						if (a != null) { assets.add(a); }
					}				
				}
				
				if (!assets.isEmpty()) {
					updateAuditLog(auditLog, sessionID, 'Updating server with asset data. Number of assets to update ' + assets.size());
					for(Asset__c a: assets) {
						updateAuditLog(auditLog, sessionID, 'AssetType: ' + a.Asset_Type__c + ', Asset_Model: ' + a.Asset_Model__c + ', fridgeInFill: ' + a.Fridge_In_Fill__c);
					}
					upsert assets;
				}
			}			

			if (!accountWholesalerData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Account Wholesalers');
				
				for(List<String> o: accountWholesalerData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}
	
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
						transactionItems.add(wti);
	
						Account_Wholesaler__c a = updateAccountWholesaler(sessionID, ownerId, rowType, auditLog, accountWholesalerDescribe, objectColumns, o);
						if (a != null) { accountWholesalers.add(a); }
					}								
				}
				if (!accountWholesalers.isEmpty()) {
					upsert accountWholesalers;
					for(Account_Wholesaler__c aw: accountWholesalers) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Account_Wholesaler__c' && w.ClientRowID__c == aw.Legacy_Code__c) {
								w.ServerRowID__c = aw.Id;
							}
						}
	
						for(List<String> o: orderData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}												
							} else {
								position = getFieldPosition(objectColumns, 'Wholesalers__c');
								if (position >= 0) {
									if (o[position] == (aw.Legacy_Code__c + '.0')) {
										o[position] = aw.Id;
									}
								}							
							}												
						}
						
						for(List<String> o: dealData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}
							} else {
								position = getFieldPosition(objectColumns, 'Account_Wholesaler__c');
								if (position >= 0) {
									if (o[position] == (aw.Legacy_Code__c + '.0')) {
										o[position] = aw.Id;
									}
								}
							}
						}
					}
				}
			}			

			if (!orderData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Orders');
				
				for(List<String> o: orderData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}
	
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
						transactionItems.add(wti);
	
						Order__c a = updateOrder(sessionID, ownerId, rowType, auditLog, orderDescribe, objectColumns, o);
						if (a != null) { orders.add(a); }
					}												
				}
				
				if (!orders.isEmpty()) {
					upsert orders;
					for(Order__c ord: orders) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Order__c' && w.ClientRowID__c == ord.Legacy_Code__c) {
								w.ServerRowID__c = ord.Id;
							}
						}
	
						for(List<String> o: orderItemData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}												
							} else {
								position = getFieldPosition(objectColumns, 'Order__c');
								if (position >= 0) {
									if (o[position] == (ord.Legacy_Code__c + '.0')) {
										updateAuditLog(auditLog, sessionID, 'Updating order item with order__c from ' + ord.Legacy_Code__c + ' to ' + ord.Id);
										o[position] = ord.Id;
										
										System.debug('Changing order id on line item to ' + ord.Id);
									}
								}							
							}																		
						}
					}
				}
			}			

			if (!orderItemData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Order Items');
				
				for(List<String> o: orderItemData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}
	
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
						transactionItems.add(wti);
	
						Order_Item__c a = updateOrderItems(sessionID, ownerId, rowType, auditLog, orderItemsDescribe, objectColumns, o);
						if (a != null) { orderItems.add(a); }
					}																
				}
				if (!orderItems.isEmpty()) {
					upsert orderItems;
					for (Order_Item__c oi: orderItems) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Order_Item__c' && w.ClientRowID__c == oi.Legacy_Code__c) {
								w.ServerRowID__c = oi.Id;
							}
						}					
					}
					for(Order__c ord: orders) {
						ord.Status__c = 'Process Order';
					}
					update orders;
				}
			}			

			if (!outletVisitData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update OutletVisits');
				
				for(List<String> o: outletVisitData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}
	
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
						transactionItems.add(wti);
	
						Outlet_Visit__c a = updateOutletVisit(sessionID, ownerId, rowType, auditLog, outletVisitDescribe, objectColumns, o);
						if (a != null) { outletVisits.add(a); }
					}												
				}
				if (!outletVisits.isEmpty()) {
					updateAuditLog(auditLog, sessionID, 'Updating server with outlet visits');
					upsert outletVisits;
					for(Outlet_Visit__c ov: outletVisits) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Outlet_Visit__c' && w.ClientRowID__c == ov.Legacy_Code__c) {
								w.ServerRowID__c = ov.Id;
							}
						}
	
						updateAuditLog(auditLog, sessionID, 'Updating outlet visit item data with header record keys');
						for(List<String> o: outletVisitItemData) {
							if (o[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = o.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(o[i]);
								}												
							} else {
								position = getFieldPosition(objectColumns, 'Outlet_Visit__c');
								if (position >= 0) {
									if (o[position] == (ov.Legacy_Code__c + '.0')) {
										o[position] = ov.Id;
									}
								}							
							}																		
						}
					}
				}
			}			

			if (!outletVisitItemData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Outlet Visit Items');
				
				for(List<String> o: outletVisitItemData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}
	
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
											
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
						transactionItems.add(wti);
	
						Outlet_Visit_Item__c a = updateOutletVisitItem(sessionID, ownerId, rowType, auditLog, outletVisitItemsDescribe, objectColumns, o);
						if (a != null) { outletVisitItems.add(a); }
					}																
				}
				if (!outletVisitItems.isEmpty()) {
					updateAuditLog(auditLog, sessionID, 'Updating server with OutletVisitItems. [' + outletVisitItems.size() + ' items]');
					upsert outletVisitItems;
					for(Outlet_Visit_Item__c ovi: outletVisitItems) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Outlet_Visit_Item__c' && w.ClientRowID__c == ovi.Legacy_Code__c) {
								w.ServerRowID__c = ovi.Id;
							}
						}					
					}
				}
			}
			
			if (!promotionData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Promotions');

				for(List<String> o: promotionData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}					
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}

						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];						
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
										
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = wti.ClientRowID__c;
							}
						}
						transactionItems.add(wti);

						Promotion__c a = updatePromotion(sessionID, ownerId, rowType, auditLog, promotionDescribe, objectColumns, o);
						if (a != null) { promotions.add(a); }
					}																
				}
				if (!promotions.isEmpty()) {
					updateAuditLog(auditLog, sessionID, 'Updating server with Promotions. [' + promotions.size() + ' items]');
					upsert promotions;
					
					for(Promotion__c o: promotions) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Promotion__c' && w.ClientRowID__c == o.Legacy_Code__c) {
								w.ServerRowID__c = o.Id;
							}
						}					
					}
				}
				
			}			
			
			if (!dealData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Deals');
				
				for(List<String> o: dealData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}
					} else {
						position = getFieldPosition(objectColumns, 'Flags');
						System.debug('position of Flags column: ' + position);
						if (position >= 0) {
							rowType = Integer.valueOf(o[position]);
						}

						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = o[position];
							}
						}
						
						transactionItems.add(wti);
						
						Group_Promotions__c a = updateDeal(sessionID, ownerId, rowType, auditLog, dealDescribe, objectColumns, o);
						if (a != null) { deals.add(a); }
					}
				}
				
				if (!deals.isEmpty()) {
					updateAuditLog(auditLog, sessionID, 'Updating server with Deals. [' + deals.size() + ' items]');
					upsert deals;
					
					for(Group_Promotions__c o: deals) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Group_Promotions__c' && w.ClientRowID__c == o.Legacy_Code__c) {
								w.ServerRowID__c = o.Id;
							}
						}

						updateAuditLog(auditLog, sessionID, 'Updating deal item data with header record keys');
						for(List<String> oi: dealItemData) {
							if (oi[1] == 'header') {
								objectColumns.clear();
								numberOfColumns = oi.size();
								for(integer i = 0; i < numberOfColumns; i++) {
									objectColumns.add(oi[i]);
								}												
							} else {
								position = getFieldPosition(objectColumns, 'Group_Promotion__c');
								if (position >= 0) {
									
									if (oi[position] == (o.Legacy_Code__c + '.0')) {
										oi[position] = o.Id;
									}
								}							
							}																		
						}
					}					
				}
			}
			
			if (!dealItemData.isEmpty()) {
				updateAuditLog(auditLog, sessionID, 'Preparing data to update Deal Items');
				
				for (List<String> o: dealItemData) {
					if (o[1] == 'header') {
						objectColumns.clear();
						numberOfColumns = o.size();
						for(integer i = 0; i < numberOfColumns; i++) {
							objectColumns.add(o[i]);
						}
					} else {
						position = getFieldPosition(objectColumns, 'Id');
						wti = new wombat_Transaction_Items__c();
						wti.wombat_Sync_Session__c = sessionID;
						wti.Object_API_Name__c = o[0];
						wti.Row_Type__c = rowType;
						wti.ClientRowID__c = o[position];
						wti.ServerRowID__c = o[position];
						
						if (rowType == 1) {
							position = getFieldPosition(objectColumns, 'Client_ID');
							if (position >= 0) {
								wti.ClientRowID__c = o[position];
								wti.ServerRowID__c = o[position];
							}
						}
						
						transactionItems.add(wti);
						
						Group_Promotion_Item__c a = updateDealItem(sessionID, ownerId, rowType, auditLog, dealItemDescribe, objectColumns, o);
						if (a != null) { dealItems.add(a); }
					}
				}
				
				if (!dealItems.isEmpty()) {
					updateAuditLog(auditLog, sessionID, 'Updating server with Deal Items. [' + dealItems.size() + ' items]');
					upsert dealItems;
					
					for(Group_Promotion_Item__c o: dealItems) {
						for(wombat_Transaction_Items__c w: transactionItems) {
							if (w.Object_API_Name__c == 'Group_Promotion_Item__c' && w.ClientRowID__c == o.Legacy_Code__c) {
								w.ServerRowID__c = o.Id;
							}
						}
					}
				}
			}
			
			updateAuditLog(auditLog, sessionID, 'Inserting ' + transactionItems.size() + ' transaction items for this session.');
			insert transactionItems;
			
			
		} catch(Exception ex) {
			Database.rollback(sp);
			
			success = false;
			updateAuditLog(auditLog, sessionID, 'Exception raised updating server with client data.\n' + ex.getMessage());
		} finally {
			updateAuditLog(auditLog, sessionID, 'Updating wombat_Sync_Session as completed');
			List<wombat_Sync_Session__c> wss = [SELECT InProgress__c, SessionStart__c, SessionFinish__c FROM Wombat_Sync_Session__c WHERE Id = :sessionID];
			if (!wss.isEmpty()) {
				wss[0].InProgress__c = false;
				wss[0].SessionFinish__c = DateTime.now();
				wss[0].Status__c = (success == true ? 'Success' : 'Fail');
				
				update wss;
			}
			
			updateAuditLog(auditLog, sessionID, 'Completed synchronisation @ ' + DateTime.now().format());
			
			insert auditLog;				
		}
				
	}

	private static void updateAuditLog(List<wombat_Sync_Audit__c> auditLog, String sessionID, String message) {
		wombat_Sync_Audit__c wsa = new wombat_Sync_Audit__c();
		wsa.wombat_Sync_Session__c = sessionId;
		wsa.Message__c = message;
		
		auditLog.add(wsa);
	}
	private static integer getFieldPosition(List<String> columns, string fieldName) {
		if (columns == null || columns.size() == 0) { return -1; }
		
		integer position = 0;
		integer numberOfColumns = columns.size();
		for (integer i = 0; i < numberOfColumns; i++) {
			if (columns[i].toLowerCase() == fieldName.toLowerCase()) {
				position = i;
				break;
			}
		}

		return position;
	}
	
	private static Event updateEvent(string sessionId, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.Describesobjectresult R, List<String> columns, List<String> objData) {
		if (objData == null) { return null; }
		
		Event a;
		if (rowType == 1 && R.isCreateable() == true) {
			a = updateEventFields(null, ownerId, columns, objData);
		} else {
			Integer position = getFieldPosition(columns, 'Id');
			a = [SELECT Id FROM Event WHERE Id = :objData[position] LIMIT 1];
			if (rowType == 3 && R.isDeletable() == true) {
				delete a;
				return null;
			} else if(rowType == 2 && R.isUpdateable() == true) {
				a = updateEventFields(a, ownerId, columns, objData);
			}
		}
		
		return a;
	}
	private static Event updateEventFields(Event a, string ownerId, List<String> columns, List<String> objData) {
		if (a == null) { a = new Event(); a.IsAllDayEvent = false; a.OwnerId = ownerId; }
		
		integer position = 0;
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.Legacy_Code__c = null; } else { a.Legacy_Code__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'WhoId');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.WhoId = null; } else { a.WhoId = objData[position]; }
		} 
		position = getFieldPosition(columns, 'WhatId');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.WhatId = null; } else { a.WhatId = objData[position]; }
		}
		position = getFieldPosition(columns, 'Description');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.Description = null; } else { a.Description = objData[position]; }
		}
		position = getFieldPosition(columns, 'ActivityDate');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null' || objData[position].trim() == '') {
				a.ActivityDate = Date.Today();
			} else {
				a.ActivityDate = Date.valueOf(objData[position]);
			}
		}
		position = getFieldPosition(columns, 'ActivityDateTime');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null' || objData[position].trim() == '') {
				a.ActivityDateTime = DateTime.now();
			} else {
				a.ActivityDateTime = DateTime.valueOf(objData[position]);
			}
		}
		position = getFieldPosition(columns, 'DurationInMinutes');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				a.DurationInMinutes = 60;
			} else {
				a.DurationInMinutes = Integer.valueOf(objData[position]);
			}
		} else {
			a.DurationInMinutes = 60;
		}
		position = getFieldPosition(columns, 'RecordTypeId');
		if (position >= 0) {
			if (objData[position] != null || objData[position] != 'null') {
				if (objData[position].trim() != '') { a.RecordTypeId = objData[position]; }
			}
		}
		position = getFieldPosition(columns, 'Subject');
		if (position >= 0) {
			if (objData[position] != null || objData[position] != 'null') {
				if (objData[position].trim() != '') { a.Subject = objData[position]; }
			}
		}
		
		return a;
	}
	private static Account updateAccount(string sessionId, String ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<String> acc) {
		if (acc == null) { return null; }

		System.debug('[updateAccount] rowType: ' + rowType);
		
		Account a;
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			a = updateAccountFields(null, sessionId, auditLog, columns, acc);
		} else {
			Integer position = getFieldPosition(columns, 'Id');
			
			updateAuditLog(auditLog, sessionId, 'Updating Account id: ' + acc[position]);
			List<Account> accts = [SELECT Id FROM Account WHERE Id = :acc[position]];
			if (accts == null || accts.size() == 0) {
				throw new wombat_Exception('Account ' + acc[position] + ' not found');
			} else {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems.put(acc[position], a);
					delete accts;	
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					a = updateAccountFields(accts[0], sessionId, auditLog, columns, acc);	
				
					System.debug('[updateAccount] account fields updated. id: ' + a.Id);				
				}					
				
			}
		}

		return a;		
	}
	private static Account updateAccountFields(Account a, string sessionId, List<wombat_Sync_Audit__c> auditLog, List<String> columns, List<String> acc) {
		if (a == null) { a = new Account(); }
		
		System.debug('[updateAccountFields] length of clientdata: ' + acc.size());
		integer position = 0;
		position = getFieldPosition(columns, 'Name');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Name: ' + acc[position]);
			if (acc[position] != null && acc[position] != 'null') { a.Name = acc[position]; }
		}
		position = getFieldPosition(columns, 'AccountNumber');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Updating Account - AccountNumber: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.AccountNumber = null; } else { a.AccountNumber = acc[position]; }
		}
		position = getFieldPosition(columns, 'LMAA_Number__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Updating Account - LMAA Number: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.LMAA_Number__c = null; } else { a.LMAA_Number__c = acc[position]; }
		}
		
		position = getFieldPosition(columns, 'Account_Licence_Number__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Account licence Number: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Account_Licence_Number__c = null; } else { a.Account_Licence_Number__c = acc[position]; }
		}
		
		position = getFieldPosition(columns, 'Account_Licence_Type__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Account Licence Type: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Account_Licence_Type__c = null; } else { a.Account_Licence_Type__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'Account_Type__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Account Type: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Account_Type__c = null; } else { a.Account_Type__c = acc[position]; }
		}
		
		position = getFieldPosition(columns, 'Channel__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Channel: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Channel__c = null; } else { a.Channel__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'On_Segment__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - On Segment: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.On_Segment__c = null; } else { a.On_Segment__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'Off_Segment__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - OffSegment: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Off_Segment__c = null; } else { a.Off_Segment__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'Banner_Group__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Banner Group: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Banner_Group__c = null; } else { a.Banner_Group__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'Banner_Sub_Group__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Banner Sub Group: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Banner_Sub_Group__c = null; } else { a.Banner_Sub_Group__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'Status__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Status: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Status__c = null; } else { a.Status__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'Legal_Entity__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Legal Entity: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Legal_Entity__c = null; } else { a.Legal_Entity__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'Phone');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Phone: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Phone = null; } else { a.Phone = acc[position]; }
		}

		position = getFieldPosition(columns, 'Fax');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Fax: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Fax = null; } else { a.Fax = acc[position]; }
		}
		
		position = getFieldPosition(columns, 'E_Mail_Address__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Email: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.E_Mail_Address__c = null; } else { a.E_Mail_Address__c = acc[position]; }
		}
		
		position = getFieldPosition(columns, 'Website');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Website: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Website = null; } else { a.Website = acc[position]; }
		}

		position = getFieldPosition(columns, 'Last_Visit_Date__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Last Visit Date: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Last_Visit_Date__c = null; } else { a.Last_Visit_Date__c = Date.valueOf(acc[position]); }
		} 

		position = getFieldPosition(columns, 'Region__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Region: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Region__c = null; } else { a.Region__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'Sales_Region__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Sales Region: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Sales_Region__c = null; } else { a.Sales_Region__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'ShippingStreet');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Shipping Street: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.ShippingStreet = null; } else { a.ShippingStreet = acc[position]; }
		}

		position = getFieldPosition(columns, 'Shipping_Suburb__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Shipping Suburb: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Shipping_Suburb__c = null; } else { a.Shipping_Suburb__c = acc[position]; }
		}

		position = getFieldPosition(columns, 'ShippingCity');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Shipping City: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.ShippingCity = null; } else { a.ShippingCity = acc[position]; }
		}

		position = getFieldPosition(columns, 'ShippingPostalCode');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Shipping Postal Code: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.ShippingPostalCode = null; } else { a.ShippingPostalCode = acc[position]; }
		}

		position = getFieldPosition(columns, 'ShippingState');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Shipping State: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.ShippingState = null; } else { a.ShippingState = acc[position]; }
		}

		position = getFieldPosition(columns, 'ShippingCountry');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - ShippingCountry: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.ShippingCountry = null; } else { a.ShippingCountry = acc[position]; }
		}

		position = getFieldPosition(columns, 'Order_Type__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Order Type: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Order_Type__c = false; } else { a.Order_Type__c = Boolean.valueOf(acc[position]); }
		}

		position = getFieldPosition(columns, 'Market__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Account - Market: ' + acc[position]);
			if (acc[position] == null || acc[position] == 'null') { a.Market__c = null; } else { a.Market__c = acc[position]; }
		}
				
		return a;		
	}

	private static Asset__c updateAsset(string sessionId, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }
		
		Integer position = getFieldPosition(columns, 'Id');
		
		Asset__c a = null;
		if (rowType == 1 && R.isCreateable() == true) {
			
		} else {
			a = [SELECT Id, Name FROM Asset__c WHERE Id = :objData[position] LIMIT 1];
			if (a != null) {
				updateAuditLog(auditLog, sessionId, 'Updating Assets [' + a.Id + '] ' + a.Name + ', rowType: ' + rowType + ', isupdateable: ' + R.isUpdateable());
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems.add(a);
					updateAuditLog(auditLog, sessionId, 'Deleting Asset [' + a.Id + '] ' + a.Name);
					delete a;
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					updateAuditLog(auditLog, sessionId, 'Preparing data to update Asset [' + a.Id + '] ' + a.Name);
					a = updateAssetFields(a, sessionId, auditLog, columns, objData);
				}
			}
		}
		
		return a;
	}
	private static Asset__c updateAssetFields(Asset__c a, string sessionId, List<wombat_Sync_Audit__c> auditLog, List<String> columns, List<string> objData) {
		integer position = 0;
		
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Client_ID: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Legacy_Code__c = null; } else { a.Legacy_Code__c = objData[position]; }
		}	
		
		position = getFieldPosition(columns, 'Account__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Account__c: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null') { a.Account__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Agreement__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Agreement__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Agreement__c = null; } else { a.Agreement__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Asset_Model__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Asset_Model__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Asset_Model__c = null; } else { a.Asset_Model__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Active__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Active__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Active__c = null; } else { a.Active__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Asset_Tag__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Asset_Tag__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Asset_Tag__c = null; } else { a.Asset_Tag__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Asset_Type__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Asset_Type__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Asset_Type__c = null; } else { a.Asset_Type__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Comments__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Comments__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Comments__c = null; } else { a.Comments__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'External_Branding__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'External_Branding__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.External_Branding__c = null; } else { a.External_Branding__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Fridge_Details_Incorrect__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Fridge_Details_Incorrect__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Fridge_Details_Incorrect__c = false; } else { a.Fridge_Details_Incorrect__c = Boolean.valueOf(objData[position]); }
		}
		position = getFieldPosition(columns, 'Fridge_In_Fill__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Fridge_In_Fill__c: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null') {  
				if (objData[position].trim().length() > 0) {
					a.Fridge_In_Fill__c = objData[position]; 		
					if (a.Asset_Model__c == null) {
						List<Fridge_In_Fills__c> infills = [SELECT Asset_Model__c FROM Fridge_In_Fills__c WHERE Id =:a.Fridge_In_Fill__c];
						if (infills != null && infills.size() > 0) {
							updateAuditLog(auditLog, sessionId, 'Updating Asset_Model from null -> ' + infills[0].Asset_Model__c + ', for FridgeInFill: ' + a.Fridge_In_Fill__c);
							a.Asset_Model__c = infills[0].Asset_Model__c;
							if (a.Asset_Type__c == null) {
								List<Asset_Models__c> models = [SELECT Asset_Type__c FROM Asset_Models__c WHERE Id =:a.Asset_Model__c];
								if (models != null && models.size() > 0) {
									updateAuditLog(auditLog, sessionId, 'Updating Asset_Type fro null -> ' + models[0].Asset_Type__c + ', for Model: ' + a.Asset_Model__c);
									a.Asset_Type__c = models[0].Asset_Type__c;
								}
								updateAuditLog(auditLog, sessionId, 'AssetModel: ' + a.Asset_Model__c);								
							}
						}
					}			
				} 
			}
		}
		position = getFieldPosition(columns, 'Fridge_Sighted__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Fridge_Sighted__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Fridge_Sighted__c = false; } else { a.Fridge_Sighted__c = Boolean.valueOf(objData[position]); }
		}
		position = getFieldPosition(columns, 'Internal_Branding__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Internal_Branding__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Internal_Branding__c = null; } else { a.Internal_Branding__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Is_Active__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Is_Active__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Is_Active__c = true; } else { a.Is_Active__c = Boolean.valueOf(objData[position]); }
		}
		position = getFieldPosition(columns, 'Last_Sighted__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Last_Sighted__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Last_Sighted__c = Date.Today(); } else { a.Last_Sighted__c = Date.valueOf(objData[position]); }
		}
		position = getFieldPosition(columns, 'Placement_Date__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Placement_Date__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Placement_Date__c = Date.Today(); } else { a.Placement_Date__c = Date.valueOf(objData[position]); }
		}
		position = getFieldPosition(columns, 'Serial__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Serial__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Serial__c = null; } else { a.Serial__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Venue__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Venue__c: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null' && objData[position].trim().length() > 0) { a.Venue__c = objData[position]; }
		}
		
		return a;
	}
	
	private static Asset_Move__c updateAssetMove(string sessionId, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }
		
		Integer position = 0;	
		Asset_Move__c a = null;
		if (rowType == 1 && R.isCreateable() == true) {
			position = getFieldPosition(columns, 'Name');
			updateAuditLog(auditLog, sessionId, 'Preparing data for new AssetMove: ' + objData[position]);
			a = updateAssetMoveFields(null, sessionId, auditLog, rowType, columns, objData);			
		} else {
			position = getFieldPosition(columns, 'Id');
			List<Asset_Move__c> l = [SELECT Id, Name FROM Asset_Move__c WHERE Id = :objData[position]];
			if (l == null || l.size() == 0) {
				throw new wombat_Exception('Could not find Asset_Move record with Id: ' + objData[position]);
			} else {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems.add(a);
					updateAuditLog(auditLog, sessionId, 'Deleting Asset Move [' + a.Id + '] ' + a.Name);
					delete a;
					return null;		
				} else if (rowType == 2 && R.isUpdateable()) {
					updateAuditLog(auditLog, sessionId, 'Preparing data to update Asset Move [' + a.Id + '] ' + a.Name);
					a = updateAssetMoveFields(a, sessionId, auditLog, rowType, columns, objData);
				}
			}
		}
		
		return a;
	}
	private static Asset_Move__c updateAssetMoveFields(Asset_Move__c a, string sessionId, List<wombat_Sync_Audit__c> auditLog, Integer rowType, List<String> columns, List<string> objData) {
		integer position = 0;

		if (a == null) { a = new Asset_Move__c(); }
		
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.Legacy_Code__c = null; } else { a.Legacy_Code__c = objData[position]; }
		}
		
		if (rowType == 1) {
		position = getFieldPosition(columns, 'New_Account__c');		
			updateAuditLog(auditLog, sessionId, 'Updating Account__c: ' + objData[position]);
			if (position >= 0) { 
				if (objData[position] != null && objData[position] != 'null') { a.New_Account__c = objData[position]; } 
			}			
		}
		
		position = getFieldPosition(columns, 'New_Venue_Lookup__c');		
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating New_Venue_Lookup: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.New_Venue_Lookup__c = null; } else { a.New_Venue_Lookup__c = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Contact__c');		
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Contact__c: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null') { a.Contact__c = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Asset_Type__c');		
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Asset Type: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Asset_Type__c = null; } else { a.Asset_Type__c = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Model__c');		
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating model: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Model__c = null; } else { a.Model__c = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Asset_Sub_Type__c');		
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Asset SubType: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Asset_Sub_Type__c = null; } else { a.Asset_Sub_Type__c = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Fridge_In_Fill__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Updating Fridge In Fill: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Fridge_In_Fill__c = null; } else { a.Fridge_In_Fill__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Internal_Branding__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Updating Internal: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Internal_Branding__c = null; } else { a.Internal_Branding__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'External_Branding__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Updating External: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.External_Branding__c = null; } else { a.External_Branding__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Asset__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Updating Asset: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null' && objData[position].trim().length() > 0) { a.Asset__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Enter_Serial__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Updating Enter Serial: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { a.Enter_Serial__c = null; } else { a.Enter_Serial__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Pick_Up_Date__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.Pick_Up_Date__c = null; } else { a.Pick_Up_Date__c = Date.valueOf(objData[position]); }
		}
		position = getFieldPosition(columns, 'Fridge_Depot__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.Fridge_Depot__c = null; } else { a.Fridge_Depot__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Reason__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.Reason__c = null; } else { a.Reason__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Requested_Placement_Date__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.Requested_Placement_Date__c = null; } else { a.Requested_Placement_Date__c = Date.valueOf(objData[position]); }
		}
		position = getFieldPosition(columns, 'RecordTypeId');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Updating RecordType: ' + objData[position]);
			if (objData[position] != null || objData[position] != 'null') { a.RecordTypeId = objData[position]; }
		}
		position = getFieldPosition(columns, 'Terms_Conditions__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { a.Terms_Conditions__c = false; } else { a.Terms_Conditions__c = Boolean.valueOf(objData[position]); }
		}
		return a;
	}
	
	private static Venue__c updateVenue(string sessionId, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }

		Integer position = 0;
		
		Venue__c v = null;
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			position = getFieldPosition(columns, 'Name');
			updateAuditLog(auditLog, sessionId, 'Preparing data for new Venue: ' + objData[position]);
			v = updateVenueFields(null, rowType, columns, objData);
		} else {
			position = getFieldPosition(columns, 'Id');
			v = [SELECT Id, Name FROM Venue__c WHERE Id = :objData[position] LIMIT 1];
			if (v != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems.add(v);
					updateAuditLog(auditLog, sessionId, 'Deleting Venue [' + v.Name + '] with id: ' + v.Id);
					delete v;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					updateAuditLog(auditLog, sessionId, 'Preparing data to update Venue ' + v.Name);
					v = updateVenueFields(v, rowType, columns, objData);					
				}					
			}
		}
		
		return v;		
	}
	private static Venue__c updateVenueFields(Venue__c v, Integer rowType, List<String> columns, List<string> objData) {
		integer position = 0;

		if (v == null) { v = new Venue__c(); }
		
		position = getFieldPosition(columns, 'Name');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Name = null; } else { v.Name = objData[position]; } 
		}
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { v.Legacy_Code__c = null; } else { v.Legacy_Code__c = objData[position]; }
		}
		
		if (rowType == 1) {
		position = getFieldPosition(columns, 'Account__c');		
			if (position >= 0) { 
				if (objData[position] != null && objData[position] != 'null') { v.Account__c = objData[position]; } 
			}			
		}
		
		position = getFieldPosition(columns, 'Channel__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Channel__c = null; } else { v.Channel__c = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Segment__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Segment__c = null; } else { v.Segment__c = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Area_Type__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Area_Type__c = null; } else { v.Area_Type__c = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Notes__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Notes__c = null; } else { v.Notes__c = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Is_Active__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Is_Active__c = false; } else { v.Is_Active__c = Boolean.valueOf(objData[position]); } 
		}
		
		return v;
	}

	private static Contact updateContact(string sessionId, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }

		Integer position = 0;
		
		System.debug('[updateContact] rowType: ' + rowType);
		
		Contact c = null;
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			position = getFieldPosition(columns, 'FirstName');
			updateAuditLog(auditLog, sessionId, 'Preparing data for new Contact ' + objData[position]);
			c = updateContactFields(null, rowType, sessionId, auditLog, columns, objData);
		} else {
			position = getFieldPosition(columns, 'Id');
			c = [SELECT Id, Name, Legacy_Code__c FROM Contact WHERE Id = :objData[position] LIMIT 1];		
			if (c != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems.add(c);
					updateAuditLog(auditLog, sessionId, 'Deleting Contact [' + c.Id + '] ' + c.Name);
					delete c;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					updateAuditLog(auditLog, sessionId, 'Preparing data to update Contact ' + c.Name);
					c = updateContactFields(c, rowType, sessionId, auditLog, columns, objData);					
				}					
			}
		}
		
		return c;		
	}
	
	private static Contact updateContactFields(Contact c, Integer rowType, string sessionId, List<wombat_Sync_Audit__c> auditLog, List<String> columns, List<string> objData) { 
		if (c == null) { c = new Contact(); }
		
		integer position = 0;
		if (rowType == 1) {
			position = getFieldPosition(columns, 'AccountId');
			if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'AccountId : ' + objData[position]);
				if (objData[position] != null && objData[position] != 'null') { c.AccountId = objData[position]; } 
			}			
		}
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
				updateAuditLog(auditLog, sessionId, 'Client_ID : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.Legacy_Code__c = null; } else { c.Legacy_Code__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Venue__c');
		if (position >= 0) { 
			if (objData[position] != null && objData[position] != 'null' && objData[position].trim().length() > 0) { 
				updateAuditLog(auditLog, sessionId, 'Venue__c : ' + objData[position]);
				c.Venue__c = objData[position]; 
			} 
		}
		
		position = getFieldPosition(columns, 'FirstName');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'FirstName : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.FirstName = null; } else { c.FirstName = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'LastName');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'LastName : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.LastName = null; } else { c.LastName = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Salutation');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'Salutation : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.Salutation = null; } else { c.Salutation = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Title');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'Title : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.Title = null; } else { c.Title = objData[position]; } 
		}
				
		position = getFieldPosition(columns, 'Phone');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'Phone : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.Phone = null; } else { c.Phone = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Fax');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'Fax : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.Fax = null; } else { c.Fax = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'MobilePhone');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'Mobile : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.MobilePhone = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Email');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'Email : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.Email = null; } else { c.Email = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Is_Fridge_Contact__c');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'Is Fridge Contact : ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { c.Is_Fridge_Contact__c = false; } else { c.Is_Fridge_Contact__c = Boolean.valueOf(objData[position]); } 
		}
		
		position = getFieldPosition(columns, 'Preferred_Contact_Method__c');
		if (position >= 0) { 
				updateAuditLog(auditLog, sessionId, 'Preferred Contact Method : ' + objData[position]);
			if (objData[position] != null || objData[position] != 'null') { c.Preferred_Contact_Method__c = objData[position]; } 
		}
		
		return c; 
	}

	private static Account_Wholesaler__c updateAccountWholesaler(string sessionId, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }

		Integer idposition = getFieldPosition(columns, 'Id');
		
		System.debug('[updateContact] rowType: ' + rowType);
				
		Account_Wholesaler__c aw = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			aw = updateAccountWholesalerFields(null, columns, objData);
		} else {
			aw = [SELECT Id, Name FROM Account_Wholesaler__c WHERE Id = :objData[idposition] LIMIT 1];		
			if (aw != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems.add(aw);
					delete aw;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					aw = updateAccountWholesalerFields(aw, columns, objData);					
				}					
			}
		}				
		
		return aw;
	}
	private static Account_Wholesaler__c updateAccountWholesalerFields(Account_Wholesaler__c w, List<String> columns, List<string> objData) {
		if (w == null) { w = new Account_Wholesaler__c(); }

		integer position = 0;
		position = getFieldPosition(columns, 'Wholesaler__c');
		if (position >= 0) { w.Wholesaler__c = objData[position]; }
		
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { w.Legacy_Code__c = w.Id; } else { w.Legacy_Code__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Account__c');
		if (position >= 0) { w.Account__c = objData[position]; }
				
		position = getFieldPosition(columns, 'Wholesaler_Account_Number__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Wholesaler_Account_Number__c = null; } else { w.Wholesaler_Account_Number__c = objData[position]; } 
		}
				
		position = getFieldPosition(columns, 'Wholesaler_Account_Name__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Wholesaler_Account_Name__c = null; } else { w.Wholesaler_Account_Name__c = objData[position]; } 
		}
				
		position = getFieldPosition(columns, 'Delivery_Day_1__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Delivery_Day_1__c = null; } else { w.Delivery_Day_1__c = objData[position]; } 
		}
				
		position = getFieldPosition(columns, 'Delivery_Day_2__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Delivery_Day_2__c = null; } else { w.Delivery_Day_2__c = objData[position]; }
		}
				
		position = getFieldPosition(columns, 'Allow_Order__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Allow_Order__c = null; } else { w.Allow_Order__c = Boolean.valueOf(objData[position]); } 
		}
				
		position = getFieldPosition(columns, 'Is_Active__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Is_Active__c = null; } else { w.Is_Active__c = Boolean.valueOf(objData[position]); } 
		}

		position = getFieldPosition(columns, 'Notes__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Notes__c = null; } else { w.Notes__c = objData[position]; } 
		}
		
		return w;
	}

	public static Order__c updateOrder(string sessionID, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.Describesobjectresult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }

		Integer position = 0;
		
		System.debug('[updateContact] rowType: ' + rowType);
				
		Order__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			string name = 'new order';
			position = getFieldPosition(columns, 'Wholesaler_Name__c');
			if (position >= 0) { name = objData[position]; }
			updateAuditLog(auditLog, sessionID, 'Preparing data for new order for ' + name);
			o = updateOrderFields(null, columns, objData);
		} else {
			position = getFieldPosition(columns, 'Id');
			o = [SELECT Id, Account__c, Order_Date__c, Account_Name__c FROM Order__c WHERE Id = :objData[position] LIMIT 1];				
		
			if (o != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems.add(o);
					updateAuditLog(auditLog, sessionID, 'Deleting order ' + o.Id + ' for Account: ' + o.Account_Name__c);
					delete o;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					updateAuditLog(auditLog, sessionID, 'Preparing data to update order ' + o.Id + ' for Account ' + o.Account_Name__c);
					o = updateOrderFields(o, columns, objData);					
				}					
			}
		}				
		
		return o;		
	}
	private static Order__c updateOrderFields(Order__c o, List<String> columns, List<string> objData) {
		if (o == null) { o = new Order__c(); }
				
		integer position;
		position = getFieldPosition(columns, 'Account__c');
		if (position >= 0) {
			if (objData[position] != null && objData[position] != 'null') { o.Account__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { o.Legacy_Code__c = null; } else { o.Legacy_Code__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Contact__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Contact__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					o.Contact__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(columns, 'Wholesalers__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Wholesalers__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					o.Wholesalers__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(columns, 'Order_Date__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Order_Date__c = Date.today();
			} else {
				if (objData[position].trim().length() > 0) {
					o.Order_Date__c = Date.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(columns, 'Order_Type__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Order_Type__c = 'In-Direct';
			} else {
				if (objData[position].trim().length() > 0) {
					o.Order_Type__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(columns, 'Delivery_Instructions__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { o.Delivery_Instructions__c = null; } else { o.Delivery_Instructions__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Notes__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Notes__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					o.Notes__c = objData[position];
				}
			}
		}
		
		return o;
	}
	
	private static Order_Item__c updateOrderItems(string sessionId, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }
		
		Integer idposition = getFieldPosition(columns, 'Id');
		
		System.debug('[updateContact] rowType: ' + rowType);
		
		Order_Item__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			o = updateOrderItemFields(null, sessionId, auditLog, columns, objData);
		} else {
			o = [SELECT Id, Order__c, Product__c, Carton__c, Unit__c, Discount__c, Carton_Bonus__c, Unit_Bonus__c FROM Order_Item__c WHERE Id = :objData[idposition] LIMIT 1];				
		
			if (o != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems.add(o);
					delete o;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					o = updateOrderItemFields(o, sessionId, auditLog, columns, objData);					
				}					
			}
		}		
						
		return o;
	}
	private static Order_Item__c updateOrderItemFields(Order_Item__c oi, string sessionId, List<wombat_Sync_Audit__c> auditLog, List<String> columns, List<string> objData) {
		if (oi == null) { oi = new Order_Item__c();  }

		integer position = 0;
		position = getFieldPosition(columns, 'Order__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Order__c = ' + objData[position]);
			oi.Order__c = objData[position];
		} else {
			updateAuditLog(auditLog, sessionId, 'Could not find column Order__c in order items');
		}
		
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { oi.Legacy_Code__c = null; } else { oi.Legacy_Code__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Product__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { oi.Product__c = null; } else { oi.Product__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Carton__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { 
				oi.Carton__c = null; 
			} else { 
				if (objData[position].trim().length() > 0) {
					oi.Carton__c = Integer.valueOf(objData[position]); 					
				}
			}
			
		}
		
		position = getFieldPosition(columns, 'Unit__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { 
				oi.Unit__c = null; 
			} else { 
				if (objData[position].trim().length() > 0) {
					oi.Unit__c = Integer.valueOf(objData[position]); 					
				}
			}
		}
		
		position = getFieldPosition(columns, 'Carton_Bonus__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				oi.Carton_Bonus__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					oi.Carton_Bonus__c = Integer.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(columns, 'Unit_Bonus__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				oi.Unit_Bonus__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					oi.Unit_Bonus__c = Integer.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(columns, 'Discount__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				oi.Discount__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					oi.Discount__c = Decimal.valueOf(objData[position]);
				}
			}
		}
				
		return oi;
	}

	private static Outlet_Visit__c updateOutletVisit(string sessionID, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }
		
		Integer position = getFieldPosition(columns, 'Id');
		System.debug('[updateOutletVisit] rowType: ' + rowType);
		System.debug('[updateOutletVisit] columns: ' + columns);
		System.debug('[updateOutletVisit] objData: ' + objData);
		Outlet_Visit__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			updateAuditLog(auditLog, sessionID, 'Preparing data for new Outlet Visit');
			o = updateOutletVisitFields(null, sessionID, auditLog, columns, objData);
		} else {
			
			string oId = objData[position];
			System.debug('[updateOutletVisit] oId: ' + oId);
			o = [SELECT Id, Account__c, AccountName__c, Visit_Date__c FROM Outlet_Visit__c WHERE Id = :oId LIMIT 1];				
		
			if (o != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems(o);
					updateAuditLog(auditLog, sessionID, 'Deleting Outlet Visit ' + o.Id + ' for Account ' + o.AccountName__c);
					delete o;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					updateAuditLog(auditLog, sessionID, 'Preparing data to update Outlet Visit ' + o.Id + ' for Account ' + o.AccountName__c);
					o = updateOutletVisitFields(o, sessionID, auditLog, columns, objData);					
				}					
			}
		}		
						
		return o;		
	}
	
	private static Outlet_Visit__c updateOutletVisitFields(Outlet_Visit__c ov, String sessionID, List<wombat_Sync_Audit__c> auditLog, List<String> columns, List<string> objData) {
		if (ov == null) { ov = new Outlet_Visit__c(); ov.Status__c = 'New'; }
		
		integer position = 0;
		position = getFieldPosition(columns, 'Account__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionID, 'Account data: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null') { ov.Account__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { ov.Legacy_Code__c = null; } else { ov.Legacy_Code__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Venue__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ov.Venue__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					ov.Venue__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(columns, 'Met_With__c');
		if (position >= 0) {
			if (objData[position] != null && objData[position] != 'null') { ov.Met_With__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Visit_Date__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ov.Visit_Date__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					ov.Visit_Date__c = Date.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(columns, 'Visit_Comments__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ov.Visit_Comments__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					ov.Visit_Comments__c = objData[position];
				}
			}
		}
		
		return ov;
	}
	
	private static Outlet_Visit_Item__c updateOutletVisitItem(string sessionID, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<String> objData) {
		if (objData == null) { return null; }
				
		Integer position = getFieldPosition(columns, 'Id');
		System.debug('[updateOutletVisitItem] rowType: ' + rowType);
		System.debug('[updateOutletVisitItem] objdata: ' + objData);
		System.debug('[updateOutletVisitItem] columns: ' + columns);
		Outlet_Visit_Item__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			updateAuditLog(auditLog, sessionID, 'Preparing data for new OutletVisitItem');
			o = updateOutletVisitItemFields(null, sessionID, auditLog, columns, objData);
		} else {
			string oId = objData[position];
			System.debug('[updateOutletVisitItem] oId: ' + oId);
			o = [SELECT Id, Outlet_Visit__c, Channel__c, Product__c FROM Outlet_Visit_Item__c WHERE Id = :objData[position] LIMIT 1];				
		
			if (o != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems.add(o);
					updateAuditLog(auditLog, sessionID, 'Deleting Outlet Visit Item ' + o.Id + ' for Outlet Visit ' + o.Outlet_Visit__c);
					delete o;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					updateAuditLog(auditLog, sessionID, 'Preparing data to update Outlet Visit Item ' + o.Id + ' for Outlet Visit ' + o.Outlet_Visit__c);
					o = updateOutletVisitItemFields(o, sessionID, auditLog, columns, objData);					
				}					
			}
		}		
						
		return o;				
	}
	private static Outlet_Visit_Item__c updateOutletVisitItemFields(Outlet_Visit_Item__c ovi, String sessionID, List<wombat_Sync_Audit__c> auditLog, List<String> columns, List<string> objData) {
		if (ovi == null) { ovi = new Outlet_Visit_Item__c(); }
		
		integer position;
		position = getFieldPosition(columns, 'Outlet_Visit__c');
		if (position >= 0) {
			if (objData[position] != null && objData[position] != 'null') {
					updateAuditLog(auditLog, sessionID, 'OutletVisit__c = ' + objData[position]);
					ovi.Outlet_Visit__c = objData[position];
			} else {
				updateAuditLog(auditLog, sessionID, 'OutletVisit__c is null');
			}	
		}
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { ovi.Legacy_Code__c = null; } else { ovi.Legacy_Code__c = objData[position]; }
		}
		position = getFieldPosition(columns, 'Shelf_Category_Item__c');
		if (position >= 0) {
			if (objData[position] != null || objData[position] != 'null') { ovi.Shelf_Category_Item__c = objData[position]; }			
		}
		
		position = getFieldPosition(columns, 'Available__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.Available__c = false;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.Available__c = Boolean.valueOf(objData[position]);
				}
			}			
		}
		
		position = getFieldPosition(columns, 'Position__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.Position__c = false;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.Position__c = Boolean.valueOf(objData[position]);
				}
			}			
		}
		
		position = getFieldPosition(columns, 'BackBarVisit__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.BackBarVisit__c = false;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.BackBarVisit__c = Boolean.valueOf(objData[position]);
				}
			}
		}
				
		position = getFieldPosition(columns, 'CocktailCount__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.CocktailCount__c = 0;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.CocktailCount__c = Integer.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(columns, 'Bottle_Price__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.Bottle_Price__c = 0;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.Bottle_Price__c = Decimal.valueOf(objData[position]);
				}
			}
		}	
		position = getFieldPosition(columns, 'PriceTypeFlag__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.PriceTypeFlag__c = false;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.PriceTypeFlag__c = Boolean.valueOf(objData[position]);
				}
			}
		}			
		return ovi;
	}

	private static Promotion__c updatePromotion(string sessionID, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }
		
		Integer position = getFieldPosition(columns, 'Id');
		System.debug('[promotion] rowType: ' + rowType);
		System.debug('[promotion] columns: ' + columns);
		System.debug('[promotion] objData: ' + objData);
		Promotion__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			updateAuditLog(auditLog, sessionID, 'Preparing data for new Promotion');
			o = updatePromotionFields(null, sessionID, auditLog, columns, objData);
		} else {
			
			string oId = objData[position];
			System.debug('[updatePromotion] oId: ' + oId);
			o = [SELECT Id, Name, Account__c, AccountName__c FROM Promotion__c WHERE Id = :oId LIMIT 1];				
		
			if (o != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems(o);
					updateAuditLog(auditLog, sessionID, 'Deleting Promotion ' + o.Id + ' for Account ' + o.AccountName__c);
					delete o;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					updateAuditLog(auditLog, sessionID, 'Preparing data to update Promotion ' + o.Id + ' for Account ' + o.AccountName__c);
					o = updatePromotionFields(o, sessionID, auditLog, columns, objData);					
				}					
			}
		}		
						
		return o;		
	}
	
	private static Promotion__c updatePromotionFields(Promotion__c o, String sessionID, List<wombat_Sync_Audit__c> auditLog, List<String> columns, List<string> objData) {
		if (o == null) { o = new Promotion__c(); }
		
		integer position = 0;
		position = getFieldPosition(columns, 'Account__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionID, 'Account data: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null') { o.Account__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { o.Legacy_Code__c = null; } else { o.Legacy_Code__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'RecordTypeId');
		if (position >= 0) {
			if (objData[position] != null || objData[position] != 'null') { o.RecordTypeId = objData[position]; } 
		}
		
		position = getFieldPosition(columns, 'Name');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { o.Name = ''; } else { o.Name = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Venue__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Venue__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					o.Venue__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(columns, 'Contact__c');
		if (position >= 0) {
			if (objData[position] != null && objData[position] != 'null') { o.Contact__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Promotion_Start_Date__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Promotion_Start_Date__c = Date.Today();
				if (objData[position].trim().length() > 0) {
					o.Promotion_Start_Date__c = Date.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(columns, 'Promotion_End_Date__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Promotion_End_Date__c = Date.Today();
			} else {
				if (objData[position].trim().length() > 0) {
					o.Promotion_End_Date__c = Date.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(columns, 'Additional_Mechanics__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { o.Additional_Mechanics__c = null; } else { o.Additional_Mechanics__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Promotion_Activity__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionID, 'Promotion_Activity__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Promotion_Activity__c = null; } else { o.Promotion_Activity__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Draw_Date__c');
		if (position >= 0) {
			if (objData[position] != null && objData[position] != 'null') {
				if (objData[position].trim().length() > 0) {
					o.Draw_Date__c = Date.valueOf(objData[position]);					
				}
			}
		}
		
		position = getFieldPosition(columns, 'Winner_Name__c');
		if (position >= 0) {
			if (objData[position] == null && objData[position] == 'null') { o.Winner_Name__c = null; } else { o.Winner_Name__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Suburb__c');
		if (position >= 0) {
			if (objData[position] == null && objData[position] == 'null') { o.Suburb__c = null; } else { o.Suburb__c = objData[position]; }
		}

		position = getFieldPosition(columns, 'Post_Code__c');
		if (position >= 0) {
			if (objData[position] == null && objData[position] == 'null') { o.Post_Code__c = null; } else { o.Post_Code__c = objData[position]; }
		}

		position = getFieldPosition(columns, 'Telephone__c');
		if (position >= 0) {
			if (objData[position] == null && objData[position] == 'null') { o.Telephone__c = null; } else { o.Telephone__c = objData[position]; }
		}

		position = getFieldPosition(columns, 'Comments__c');
		if (position >= 0) {
			if (objData[position] == null && objData[position] == 'null') { o.Comments__c = null; } else { o.Comments__c = objData[position]; }
		}

		position = getFieldPosition(columns, 'Target_Attendance__c');
		if (position >= 0) {
			if (objData[position] == null && objData[position] == 'null') { 
				o.Target_Attendance__c = null; 
			} else {
				if (objData[position].trim().length() > 0) {
					o.Target_Attendance__c = Integer.valueOf(objData[position]); 					
				} 
			}
		}

		position = getFieldPosition(columns, 'Target_Age_Group__c');
		if (position >= 0) {
			if (objData[position] == null && objData[position] == 'null') { o.Target_Age_Group__c = null; } else { o.Target_Age_Group__c = objData[position]; }
		}

		position = getFieldPosition(columns, 'Is_Active__c');
		if (position >= 0) {
			if (objData[position] == null && objData[position] == 'null') { o.Is_Active__c = false; } else { o.Is_Active__c = Boolean.valueOf(objData[position]); }
		}

		position = getFieldPosition(columns, 'Remind_Me_Date__c');
		if (position >= 0) {
			if (objData[position] != null && objData[position] != 'null') { 
				if (objData[position].trim().length() > 0) {
					o.Remind_Me_Date__c = Date.valueOf(objData[position]); 					
				}
			}
		}
		
		
		return o;
	}
	
	private static Group_Promotions__c updateDeal(string sessionID, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		updateAuditLog(auditLog, sessionID, 'in update deal function. rowtype:' + rowType + ', isCreateable: ' + R.isCreateable() + ', isUpdateable: ' + R.isUpdateable());
		if (objData == null) { updateAuditLog(auditLog, sessionID, 'objData is null'); return null; }
		
		Integer position = getFieldPosition(columns, 'Id');
		System.debug('[promotion] rowType: ' + rowType);
		System.debug('[promotion] columns: ' + columns);
		System.debug('[promotion] objData: ' + objData);
		Group_Promotions__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			updateAuditLog(auditLog, sessionID, 'Preparing data for new Deal');
			o = updateDealFields(null, sessionID, auditLog, columns, objData);
		} else {
			
			string oId = objData[position];
			List<Group_Promotions__c> l = [SELECT Id, Name, AccountName__c FROM Group_Promotions__c WHERE Id = :oId];				
		
			if (l != null && l.size() > 0) {
				o = l[0];
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems(o);
					updateAuditLog(auditLog, sessionID, 'Deleting Deal ' + o.Id + ' for Account ' + o.AccountName__c);
					delete o;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					updateAuditLog(auditLog, sessionID, 'Preparing data to update Deal ' + o.Id + ' for Account ' + o.AccountName__c);
					o = updateDealFields(o, sessionID, auditLog, columns, objData);					
				}					
			}
		}		
						
		return o;		
	}
	private static Group_Promotions__c updateDealFields(Group_Promotions__c o, string sessionId, List<wombat_Sync_Audit__c> auditLog, List<String> columns, List<String> objData) {
		if (o == null) { o = new Group_Promotions__c(); }
		
		Integer position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Client_ID: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Legacy_Code__c = ''; } else { o.Legacy_Code__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Account__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Account__c: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null') { o.Account__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'RecordTypeId');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'RecordTypeId: ' + objData[position]);
			if (objData[position] != null && objData[position] == 'null') { o.RecordTypeId = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Account_Wholesaler__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Account_Wholeasler__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Account_Wholesaler__c = null; } else { o.Account_Wholesaler__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Activity_Code__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Activity_Code__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Activity_Code__c = null; } else { o.Activity_Code__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Activity_Comment__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Activity_Comment__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Activity_Comment__c = null; } else { o.Activity_Comment__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Application__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Application__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Application__c = null; } else { o.Application__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Deal_Channel__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Deal_Channel__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Deal_Channel__c = null; } else { o.Deal_Channel__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Deal_Method__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Deal_Method__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Deal_Method__c = null; } else { o.Deal_Method__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Buy_Period_Start_Date__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Buy_Period_Start_Date__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Buy_Period_Start_Date__c = null; } else { o.Buy_Period_Start_Date__c = Date.valueOf(objData[position]); }
		}
		
		position = getFieldPosition(columns, 'Buy_Period_End_Date__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Buy_Period_End_Date__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Buy_Period_End_Date__c = null; } else { o.Buy_Period_End_Date__c = Date.valueOf(objData[position]); }
		}
		
		position = getFieldPosition(columns, 'Wholesaler__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Wholesaler__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Wholesaler__c = null; } else { o.Wholesaler__c = objData[position]; }
		}

		return o;		
	}
	
	private static Group_Promotion_Item__c updateDealItem(string sessionID, string ownerId, Integer rowType, List<wombat_Sync_Audit__c> auditLog, Schema.DescribeSObjectResult R, List<String> columns, List<string> objData) {
		if (objData == null) { return null; }
		
		Integer position = getFieldPosition(columns, 'Id');
		System.debug('[promotion] rowType: ' + rowType);
		System.debug('[promotion] columns: ' + columns);
		System.debug('[promotion] objData: ' + objData);
		Group_Promotion_Item__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			updateAuditLog(auditLog, sessionID, 'Preparing data for new Deal Item');
			o = updateDealItemFields(null, sessionID, auditLog, columns, objData);
		} else {
			
			string oId = objData[position];
			List<Group_Promotion_Item__c> l = [SELECT Id, Name, Group_Promotion__c FROM Group_Promotion_Item__c WHERE Id = :oId];				
		
			if (l != null && l.size() > 0) {
				o = l[0];
				if (rowType == 3 && R.isDeletable() == true) {
					//deletedItems(o);
					updateAuditLog(auditLog, sessionID, 'Deleting Deal Item' + o.Id + ' for Deal ' + o.Group_Promotion__c);
					delete o;					
					return null;		
				} else if (rowType == 2 && R.isUpdateable() == true) {
					updateAuditLog(auditLog, sessionID, 'Preparing data to update Deal Item ' + o.Id + ' for Deal ' + o.Group_Promotion__c);
					o = updateDealItemFields(o, sessionID, auditLog, columns, objData);					
				}					
			}
		}		
						
		return o;		
	}
	private static Group_Promotion_Item__c updateDealItemFields(Group_Promotion_Item__c o, string sessionId, List<wombat_Sync_Audit__c> auditLog, List<String> columns, List<String> objData) {
		if (o == null) { o = new Group_Promotion_Item__c(); }
		
		Integer position = getFieldPosition(columns, 'Client_ID');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Client_ID: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Legacy_Code__c = ''; } else { o.Legacy_Code__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Account__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Account__c: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null') { o.Account__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'RecordTypeId');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'RecordTypeId: ' + objData[position]);
			if (objData[position] != null && objData[position] == 'null') { o.RecordTypeId = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Group_Promotion__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Group_Promotion__c: ' + objData[position]);
			if (objData[position] != null && objData[position] != 'null') { o.Group_Promotion__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Discount_Amount__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Discount_Amount__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Discount_Amount__c = null; } else { o.Discount_Amount__c = Decimal.valueOf(objData[position]); }
		}
		
		position = getFieldPosition(columns, 'Reference_Material_Group__c');
		if (position >= 0) { 
			updateAuditLog(auditLog, sessionId, 'Reference_Material_Group__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Reference_Material_Group__c = null; } else { o.Reference_Material_Group__c = objData[position]; }
		}
		
		position = getFieldPosition(columns, 'Price_Vision__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Price_Visition__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Price_Vision__c = null; } else { o.Price_Vision__c = Decimal.valueOf(objData[position]); }
		}
		
		position = getFieldPosition(columns, 'Price_Vision_Type__c');
		if (position >= 0) {
			updateAuditLog(auditLog, sessionId, 'Price_Visition_Type__c: ' + objData[position]);
			if (objData[position] == null || objData[position] == 'null') { o.Price_Vision_Type__c = null; } else { o.Price_Vision_Type__c = objData[position]; }
		}

		return o;		
	}
	
		
}