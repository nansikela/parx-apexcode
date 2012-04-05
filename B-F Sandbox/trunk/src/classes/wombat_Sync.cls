@RestResource(urlMapping='/Wombat/*')
global class wombat_Sync {
	public final static Integer twoBillion = 2000000000;

	@HttpPost
	global static void updateServer(String sessionID, String ownerId, List<List<String>> clientData) {
		wombat_Transaction_Items__c wti;
		boolean success = true;
		System.debug('sessionID: ' + sessionID + ', ownerId: ' + ownerId);
		System.debug('numberof client data rows: ' + clientData.size());
		
		Wombat_Mobile_Config__c accountWMC = getObjectConfig('Account');
		Wombat_Mobile_Config__c venueWMC = getObjectConfig('Venue__c');
		Wombat_Mobile_Config__c contactWMC = getObjectConfig('Contact');
		Wombat_Mobile_Config__c outletVisitWMC = getObjectConfig('Outlet_Visit__c');
		Wombat_Mobile_Config__c outletVisitItemWMC = getObjectConfig('Outlet_Visit_Item__c');
		Wombat_Mobile_Config__c orderWMC = getObjectConfig('Order__c');
		Wombat_Mobile_Config__c orderItemWMC = getObjectConfig('Order_Item__c');
		Wombat_Mobile_Config__c accountWholesalerWMC = getObjectConfig('Account_Wholesaler__c');
		
		//Savepoint sp = Database.setSavepoint();
		try {
			string objectName; Integer rowType; Integer idPosition;
			for(List<String> o: clientData) {
				
				objectName = o[0].toLowerCase();
				rowType = Integer.valueOf(o[1]);

				wti = new wombat_Transaction_Items__c();
				wti.wombat_Sync_Session__c = sessionID;
				wti.Object_API_Name__c = objectName;
				wti.Row_Type__c = rowType;
				wti.ClientRowID__c = o[idPosition];
				wti.ServerRowID__c = wti.ClientRowID__c;
				
				if (objectName == 'account') {
					updateAccount(sessionID, ownerId, accountWMC, o);
				} else if (objectName == 'venue__c') {
					idPosition = getFieldPosition(venueWMC, 'Id');
					if (idPosition < 0) { throw new wombat_Exception('Field Id not found on object Venue__c'); }
											
					Venue__c v = updateVenue(sessionID, ownerId, venueWMC, o);
					if (v != null && rowType == 1) {
						wti.ServerRowID__c = v.Id;
					
						Integer vPos = -1;
						for (List<string> s: clientData) {
							if (s[0].toLowerCase() == 'contact') {
								vPos = getFieldPosition(contactWMC, 'Venue__c');
								if (vPos >= 0) {
									if(s[vPos] == wti.ClientRowID__c) {
										s[vPos] = v.Id;
									}
								}	
							} else if (s[0].toLowerCase() == 'Outlet_Visit__c') {
								vPos = getFieldPosition(null, 'Venue__c');
								if (vPos >= 0) {
									if (s[vPos] == wti.ClientRowID__c) {
										s[vPos] = v.Id;
									}
								}
							}
						}
					}
					
				} else if (objectName == 'contact') {
					idPosition = getFieldPosition(contactWMC, 'Id');
					if (idPosition < 0) { throw new wombat_Exception('Field Id not found on object Contact'); }
					
					Contact c = updateContact(sessionID, ownerId, contactWMC, o);
					if (c != null && rowType == 1) {
						wti.ServerRowID__c = c.Id;
						
						// loop through clientData and update Contact Id on Promotion and Order
						Integer cPos = -1;
						for (List<string> s: clientData) {
							if (s[0].toLowerCase() == 'order__c') {
								cPos = getFieldPosition(orderWMC, 'Contact__c');
								if (cPos >= 0) {
									if (s[cPos] == wti.ClientRowID__c) {
										s[cPos] = c.Id;
										break; 										
									} 
								}
							}
						}
					}
					
				} else if (objectName == 'asset__c') {
					//updateAsset(sessionID, ownerId, o);
				} else if (objectName == 'asset_move__c') {
					
				} else if (objectName == 'account_wholesaler__c') {
					idPosition = getFieldPosition(orderWMC, 'Id');
					if (idPosition < 0) { throw new wombat_Exception('Field Id not found on object Account_Wholesaler__c'); }

					Account_Wholesaler__c aw = updateAccountWholesaler(sessionID, ownerId, accountWholesalerWMC, o);
					if (aw != null && rowType == 1) {
						wti.ServerRowID__c = aw.Id;
						
						// loop through clientData and update AccountWholesaler Id on Order
						Integer wPos = -1;
						for(List<string> s: clientData) {
							if (s[0].toLowerCase() == 'order__c') {
								wPos = getFieldPosition(orderWMC, 'Wholesalers__c');
								if (wPos >= 0) { 
									if (o[wPos] == wti.ClientRowID__c) {
										s[wPos] = aw.Id;
										break;
									}
								}
							}
						}
					}
					
				} else if (objectName == 'order__c') {
					idPosition = getFieldPosition(orderWMC, 'Id');
					if (idPosition < 0) { throw new wombat_Exception('Field Id not found on object Order__c'); }
					
					Order__c ord = updateOrder(sessionID, ownerId, orderWMC, o);
					if (ord != null && rowType == 1) {
						wti.ServerRowID__c = ord.Id;
						
						// loop through clientData and update OrderId on the line items
						string clientID; Integer vPos = -1;
						for (List<string> s: clientData) {
							if (s[0].toLowerCase() == 'order_item__c') {
								vPos = getFieldPosition(orderItemWMC, 'Order__c');
								if (vPos >= 0) {
									clientID = s[vPos];
									if (clientID == wti.ClientRowID__c) { 
										s[vPos] = wti.ServerRowID__c;
										break;
									}
								}
							}
						}
					}
					
				} else if (objectName == 'order_item__c') {
					idPosition = getFieldPosition(orderItemWMC, 'Id');
					if (idPosition < 0) { throw new wombat_Exception('Field Id not found on object Order_Item__c'); }
				
					
					Order_Item__c oi = updateOrderItems(sessionID, ownerId, orderItemWMC, o);
					if (oi != null && rowType == 1) {
						wti.ServerRowID__c = oi.Id;						
					} 
					
				} else if (objectName == 'outlet_visit__c') {
					idPosition = getFieldPosition(outletVisitWMC, 'Id');
					if (idPosition < 0) { throw new wombat_Exception('Field Id not found on object Outlet_Visit__c'); }
						
					Outlet_Visit__c ov = updateOutletVisit(sessionID, ownerId, outletVisitWMC, o);
					if (ov != null && rowType == 1) {
						wti.ServerRowID__c = ov.Id;
						
						// loop thought clientData and update outletVisit ID on line items
						integer vPos;
						for (List<string> s: clientData) {
							if (s[0].toLowerCase() == 'outlet_visit_item__c') {
								vPos = getFieldPosition(outletVisitItemWMC, 'Outlet_Visit__c');
								if (vPos >= 0) {
									if (s[vPos] == wti.ClientRowID__c) {
										s[vPos] = ov.Id;
										break;
									}
								}
							}
						}
					}			
					//updateOrder(sessionID, ownerId, o);
				} else if (objectName == 'outlet_visit_item__c') {
					idPosition = getFieldPosition(outletVisitItemWMC, 'Id');
					if (idPosition < 0) { throw new wombat_Exception('Field Id not found on object Outlet_Visit_Item__c'); }
						
					Outlet_Visit_Item__c ovi = updateOutletVisitItem(sessionID, ownerId, outletVisitItemWMC, o);
					if (ovi != null && rowType == 1) {
						wti.ServerRowID__c = ovi.Id;
					}
				
					//updateOrderItem(sessionID, ownerId, o);
				} else if (objectName == 'promotion__c') {
					//updatePromotion(sessionID, ownerId, o);
				}
				
				insert wti;
			}
		} catch(Exception ex) {
			//Database.rollback(sp);
			
			success = false;
			updateAuditLog(sessionID, 'Exception raised updating server with client data.\n' + ex.getMessage());
		} finally {
			List<wombat_Sync_Session__c> wss = [SELECT InProgress__c, SessionStart__c, SessionFinish__c FROM Wombat_Sync_Session__c WHERE Id = :sessionID];
			if (!wss.isEmpty()) {
				wss[0].InProgress__c = false;
				wss[0].SessionFinish__c = DateTime.now();
				wss[0].Status__c = success ? 'Success' : 'Fail';
				
				update wss;
			}
		}
				
	}

	private static void updateAuditLog(String sessionID, String message) {
		wombat_Sync_Audit__c wsa = new wombat_Sync_Audit__c();
		wsa.wombat_Sync_Session__c = sessionId;
		wsa.Message__c = message;
		
		insert wsa;
	}

	private static string getSOQLSelectForObject(string objectName) {
		string soql = '';
		if (objectName.length() > 0) { 
			List<Wombat_Mobile_Config__c> wmc = [SELECT Id, Select_SOQL_For_Sync_Update__c FROM Wombat_Mobile_Config__c WHERE Object_API_Name__c = :objectName];
			if (!wmc.isEmpty()) {
				soql = wmc[0].Select_SOQL_for_Sync_Update__c;
			}
		} 
		
		
		return soql;
	}

	private static Wombat_Mobile_Config__c getObjectConfig(string objectName) {
		if (objectName.length() == 0) { return null; }
		
		Wombat_Mobile_Config__c wmc = [SELECT Id, (SELECT Id, FieldName__c, Position__c FROM Wombat_Mobile_Config_Fields__r) FROM Wombat_Mobile_Config__c WHERE Object_API_Name__c = :objectName LIMIT 1];
		return wmc;		
	}
	private static integer getFieldPosition(Wombat_Mobile_Config__c wmc, string fieldName) {
		if (wmc == null) { return -1; }
		
		integer position = 0;
		for (Wombat_Mobile_Config_Fields__c f: wmc.Wombat_Mobile_Config_Fields__r) {
			if (f.FieldName__c == fieldName) {
				position = (Integer)f.Position__c;
				break;
			}
		}
		
		position += 2; // Add 2 index spots to fields position to allow for tablename and rowtype inserted by client
		System.debug('[getFieldPosition] fieldName: ' + fieldName + ', position: ' + position);
		return position;
	}

	private static void updateAccount(string sessionId, String ownerId, Wombat_Mobile_Config__c wmc, List<String> acc) {
		if (acc == null) { return; }

		Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
		Integer rowType = Integer.valueOf(acc[1]);
		Integer position = getFieldPosition(wmc, 'Id');
		System.debug('[updateAccount] rowType: ' + rowType);
		
		wombat_Transaction_Items__c wti = new wombat_Transaction_Items__c();
		wti.wombat_Sync_Session__c = sessionId;
		wti.Object_API_Name__c = 'Account';
		wti.Row_Type__c = rowType;
		wti.ClientRowID__c = acc[position];
		wti.ServerRowID__c = wti.ClientRowID__c;

		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			Account a = updateAccountFields(null, wmc, acc);
			insert a;
	
			wti.ServerRowID__c = a.Id;

		} else {
			Account a;
			String soql = getSOQLSelectForObject('Account');
			
			
			if (soql.length() == 0) {
				a = [SELECT Id, Name, AccountNumber FROM Account WHERE Id = :acc[position] LIMIT 1];				
			} else {
				soql = soql.replace('%Id%', acc[position]);
				System.debug('[updateAccount] id field position: ' + position);
				System.debug('[updateAccount] soql: ' + soql);
				
				a = Database.query(soql);
			}
		
			if (a != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					delete a;					
				} else if (rowType == 2 && R.isUpdateable() == true) {
					a = updateAccountFields(a, wmc, acc);	
					
					System.debug('[updateAccount] account fields updated. id: ' + a.Id);				
					update a;				
				}					
			}
		}

		insert wti;		
	}
	private static Account updateAccountFields(Account a, Wombat_Mobile_Config__c wmc, List<String> acc) {
		if (a == null) { a = new Account(); }
		
		System.debug('[updateAccountFields] length of clientdata: ' + acc.size());
		integer position = 0;
		position = getFieldPosition(wmc, 'Name');
		if (position >= 0) { 
			if (acc[position] != null && acc[position] != 'null') { a.Name = acc[position]; }
		}
		position = getFieldPosition(wmc, 'AccountNumber');
		if (position >= 0) {
			if (acc[position] == null || acc[position] == 'null') { a.AccountNumber = null; } else { a.AccountNumber = acc[position]; }
		}
		
		position = getFieldPosition(wmc, 'LMAA_Number__c');
		if (position >= 0) {
			if (acc[position] == null || acc[position] == 'null') { a.LMAA_Number__c = null; } else { a.LMAA_Number__c = acc[position]; }
		}
		
		position = getFieldPosition(wmc, 'Account_Licence_Number__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Account_Licence_Number__c = null; } else { a.Account_Licence_Number__c = acc[position]; }
		}
		
		position = getFieldPosition(wmc, 'Account_Licence_Type__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Account_Licence_Type__c = null; } else { a.Account_Licence_Type__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Account_Type__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Account_Type__c = null; } else { a.Account_Type__c = acc[position]; }
		}
		
		position = getFieldPosition(wmc, 'Channel__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Channel__c = null; } else { a.Channel__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'On_Segment__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.On_Segment__c = null; } else { a.On_Segment__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Off_Segment__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Off_Segment__c = null; } else { a.Off_Segment__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Banner_Group__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Banner_Group__c = null; } else { a.Banner_Group__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Banner_Sub_Group__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Banner_Sub_Group__c = null; } else { a.Banner_Sub_Group__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Status__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Status__c = null; } else { a.Status__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Legal_Entity__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Legal_Entity__c = null; } else { a.Legal_Entity__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Phone');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Phone = null; } else { a.Phone = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Fax');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Fax = null; } else { a.Fax = acc[position]; }
		}
		
		position = getFieldPosition(wmc, 'E_Mail_Address__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.E_Mail_Address__c = null; } else { a.E_Mail_Address__c = acc[position]; }
		}
		
		position = getFieldPosition(wmc, 'Website');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Website = null; } else { a.Website = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Last_Visit_Date__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Last_Visit_Date__c = null; } else { a.Last_Visit_Date__c = Date.valueOf(acc[position]); }
		} 

		position = getFieldPosition(wmc, 'Region__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Region__c = null; } else { a.Region__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Sales_Region__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Sales_Region__c = null; } else { a.Sales_Region__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'ShippingStreet');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.ShippingStreet = null; } else { a.ShippingStreet = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Shipping_Suburb__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Shipping_Suburb__c = null; } else { a.Shipping_Suburb__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'ShippingCity');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.ShippingCity = null; } else { a.ShippingCity = acc[position]; }
		}

		position = getFieldPosition(wmc, 'ShippingPostalCode');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.ShippingPostalCode = null; } else { a.ShippingPostalCode = acc[position]; }
		}

		position = getFieldPosition(wmc, 'ShippingState');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.ShippingState = null; } else { a.ShippingState = acc[position]; }
		}

		position = getFieldPosition(wmc, 'ShippingCountry');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.ShippingCountry = null; } else { a.ShippingCountry = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Order_Type__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Order_Type__c = null; } else { a.Order_Type__c = Boolean.valueOf(acc[position]); }
		}

		position = getFieldPosition(wmc, 'Outlet_Class__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Outlet_Class__c = null; } else { a.Outlet_Class__c = acc[position]; }
		}

		position = getFieldPosition(wmc, 'Market__c');
		if (position >= 0) { 
			if (acc[position] == null || acc[position] == 'null') { a.Market__c = null; } else { a.Market__c = acc[position]; }
		}

		return a;		
	}

	private static Venue__c updateVenue(string sessionId, string ownerId, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (objData == null) { return null; }

		Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
		Integer rowType = Integer.valueOf(objData[1]);
		Integer position = getFieldPosition(wmc, 'Id');
		
		wombat_Transaction_Items__c wti = new wombat_Transaction_Items__c();
		wti.wombat_Sync_Session__c = sessionId;
		wti.Object_API_Name__c = 'Venue__c';
		wti.Row_Type__c = rowType;
		wti.ClientRowID__c = objData[position];
		wti.ServerRowID__c = wti.ClientRowID__c;
		
		Venue__c v = null;
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			v = updateVenueFields(null, wmc, objData);
			insert v;
			
			wti.ServerRowID__c = v.Id;
		} else {
			String soql = getSOQLSelectForObject('Venue__c');
			if (soql.length() == 0) {
				v = [SELECT Id, Name FROM Venue__c WHERE Id = :objData[2] LIMIT 1];				
			} else {
				soql = soql.replace('%Id%', objData[2]);
				v = Database.query(soql);
			}
		
			if (v != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					delete v;					
				} else if (rowType == 2 && R.isUpdateable() == true) {
					v = updateVenueFields(v, wmc, objData);					
					update v;				
				}					
			}
		}
		
		return v;		
	}
	private static Venue__c updateVenueFields(Venue__c v, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (v == null) { v = new Venue__c(); }
		
		integer position = 0;
		position = getFieldPosition(wmc, 'Name');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Name = null; } else { v.Name = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Account__c');		
		if (position >= 0) { 
			if (objData[position] != null && objData[position] != 'null') { v.Venue_Name__c = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Channel__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Channel__c = null; } else { v.Channel__c = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Segment__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Segment__c = null; } else { v.Segment__c = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Area_Type__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Area_Type__c = null; } else { v.Area_Type__c = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Notes__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Notes__c = null; } else { v.Notes__c = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Is_Active__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { v.Is_Active__c = false; } else { v.Is_Active__c = Boolean.valueOf(objData[position]); } 
		}
		
		return v;
	}

	private static Contact updateContact(string sessionId, string ownerId, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (objData == null) { return null; }

		Schema.DescribeSObjectResult R = Contact.SObjectType.getDescribe();
		Integer rowType = Integer.valueOf(objData [1]);
		Integer position = getFieldPosition(wmc, 'Id');
		System.debug('[updateContact] rowType: ' + rowType);
		
		wombat_Transaction_Items__c wti = new wombat_Transaction_Items__c();
		wti.wombat_Sync_Session__c = sessionId;
		wti.Object_API_Name__c = 'Contact';
		wti.Row_Type__c = rowType;
		wti.ClientRowID__c = objData[position];
		wti.ServerRowID__c = wti.ClientRowID__c;
		
		Contact c = null;
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			c = updateContactFields(null, wmc, objData);
			insert c;
			
			wti.ServerRowID__c = c.Id;
		} else {
			String soql = getSOQLSelectForObject('Contact');
			if (soql.length() == 0) {
				c = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :objData[position] LIMIT 1];				
			} else {
				soql = soql.replace('%Id%', objData[2]);
				c = Database.query(soql);
			}
		
			if (c != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					delete c;					
				} else if (rowType == 2 && R.isUpdateable() == true) {
					c = updateContactFields(c, wmc, objData);					
					update c;				
				}					
			}
		}
		
		return c;		
	}
	
	private static Contact updateContactFields(Contact c, Wombat_Mobile_Config__c wmc, List<string> objData) { 
		if (c == null) { c = new Contact(); }
		
		integer position = 0;
		position = getFieldPosition(wmc, 'AccountId');
		if (position >= 0) { 
			if (objData[position] != null && objData[position] != 'null') { c.AccountId = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Venue__c');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.Venue__c = null; } else { c.Venue__c = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'FirstName');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.FirstName = null; } else { c.FirstName = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'LastName');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.LastName = null; } else { c.LastName = objData[position]; }
		}
		
		position = getFieldPosition(wmc, 'Salutation');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.Salutation = null; } else { c.Salutation = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Title');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.Title = null; } else { c.Title = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Title__c');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.Title__c = null; } else { c.Title__c = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Phone');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.Phone = null; } else { c.Phone = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Fax');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.Fax = null; } else { c.Fax = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'MobilePhone');
		if (position >= 0) { c.MobilePhone = objData[position]; }
		
		position = getFieldPosition(wmc, 'Email');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.Email = null; } else { c.Email = objData[position]; } 
		}
		
		position = getFieldPosition(wmc, 'Is_Fridge_Contact__c');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.Is_Fridge_Contact__c = null; } else { c.Is_Fridge_Contact__c = Boolean.valueOf(objData[position]); } 
		}
		
		position = getFieldPosition(wmc, 'Preferred_Contact_Method__c');
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { c.Preferred_Contact_Method__c = null; } else { c.Preferred_Contact_Method__c = objData[position]; } 
		}
		
		return c; 
	}

	private static Account_Wholesaler__c updateAccountWholesaler(string sessionId, string ownerId, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (objData == null) { return null; }

		Schema.DescribeSObjectResult R = Account_Wholesaler__c.SObjectType.getDescribe();
		Integer rowType = Integer.valueOf(objData[1]);
		Integer position = getFieldPosition(wmc, 'Id');
		System.debug('[updateContact] rowType: ' + rowType);
				
		Account_Wholesaler__c aw = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			aw = updateAccountWholesalerFields(null, wmc, objData);
			insert aw;
		} else {
			String soql = getSOQLSelectForObject('Account_Wholesaler__c');
			if (soql.length() == 0) {
				aw = [SELECT Id, Account__c, Wholesaler__c FROM Account_Wholesaler__c WHERE Id = :objData[2] LIMIT 1];				
			} else {
				soql = soql.replace('%Id%', objData[2]);
				aw = Database.query(soql);
			}
		
			if (aw != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					delete aw;					
				} else if (rowType == 2 && R.isUpdateable() == true) {
					aw = updateAccountWholesalerFields(aw, wmc, objData);					
					update aw;				
				}					
			}
		}				
		
		return aw;
	}
	private static Account_Wholesaler__c updateAccountWholesalerFields(Account_Wholesaler__c w, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (w == null) { w = new Account_Wholesaler__c(); }

		integer position = 0;
		position = getFieldPosition(wmc, 'Wholesaler__c');
		if (position >= 0) { w.Wholesaler__c = objData[position]; }
				
		position = getFieldPosition(wmc, 'Account__c');
		if (position >= 0) { w.Account__c = objData[position]; }
				
		position = getFieldPosition(wmc, 'Wholesaler_Account_Number__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Wholesaler_Account_Number__c = null; } else { w.Wholesaler_Account_Number__c = objData[position]; } 
		}
				
		position = getFieldPosition(wmc, 'Wholesaler_Account_Name__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Wholesaler_Account_Name__c = null; } else { w.Wholesaler_Account_Name__c = objData[position]; } 
		}
				
		position = getFieldPosition(wmc, 'Delivery_Day_1__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Delivery_Day_1__c = null; } else { w.Delivery_Day_1__c = objData[position]; } 
		}
				
		position = getFieldPosition(wmc, 'Delivery_Day_2__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Delivery_Day_2__c = null; } else { w.Delivery_Day_2__c = objData[position]; }
		}
				
		position = getFieldPosition(wmc, 'Allow_Order__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Allow_Order__c = null; } else { w.Allow_Order__c = Boolean.valueOf(objData[position]); } 
		}
				
		position = getFieldPosition(wmc, 'Is_Active__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Is_Active__c = null; } else { w.Is_Active__c = Boolean.valueOf(objData[position]); } 
		}

		position = getFieldPosition(wmc, 'Notes__c');		
		if (position >= 0) { 
			if (objData[position] == null || objData[position] == 'null') { w.Notes__c = null; } else { w.Notes__c = objData[position]; } 
		}
		
		return w;
	}

	public static Order__c updateOrder(string sessionID, string ownerId, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (objData == null) { return null; }

		Schema.DescribeSObjectResult R = Order__c.SObjectType.getDescribe();
		Integer rowType = Integer.valueOf(objData[1]);
		Integer position = getFieldPosition(wmc, 'Id');
		System.debug('[updateContact] rowType: ' + rowType);
				
		Order__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			o = updateOrderFields(null, wmc, objData);
			insert o;
		} else {
			String soql = getSOQLSelectForObject('Order__c');
			if (soql.length() == 0) {
				o = [SELECT Id, Account__c, Order_Date__c FROM Order__c WHERE Id = :objData[position] LIMIT 1];				
			} else {
				soql = soql.replace('%Id%', objData[position]);
				o = Database.query(soql);
			}
		
			if (o != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					delete o;					
				} else if (rowType == 2 && R.isUpdateable() == true) {
					o = updateOrderFields(o, wmc, objData);					
					update o;				
				}					
			}
		}				
		
		return o;		
	}
	private static Order__c updateOrderFields(Order__c o, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (objData == null) { return null; }

		integer position;
		position = getFieldPosition(wmc, 'Account__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Account__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					o.Account__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Contact__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Contact__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					o.Contact__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Wholesalers__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Wholesalers__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					o.Wholesalers__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Order_Date__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Order_Date__c = Date.today();
			} else {
				if (objData[position].trim().length() > 0) {
					o.Order_Date__c = Date.valueOf(position);
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Order_Type__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				o.Order_Type__c = 'In-Direct';
			} else {
				if (objData[position].trim().length() > 0) {
					o.Order_Type__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Notes__c');
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
	
	private static Order_Item__c updateOrderItems(string sessionId, string ownerId, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (objData == null) { return null; }
		
		Schema.DescribeSObjectResult R = Order_Item__c.SObjectType.getDescribe();
		Integer rowType = Integer.valueOf(objData[1]);
		Integer position = getFieldPosition(wmc, 'Id');
		System.debug('[updateContact] rowType: ' + rowType);
		
		Order_Item__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			o = updateOrderItemFields(null, wmc, objData);
			insert o;
		} else {
			String soql = getSOQLSelectForObject('Order_Item__c');
			if (soql.length() == 0) {
				o = [SELECT Id, Order__c, Product__c, Carton__c, Unit__c, Discount__c, Carton_Bonus__c, Unit_Bonus__c FROM Order_Item__c WHERE Id = :objData[position] LIMIT 1];				
			} else {
				soql = soql.replace('%Id%', objData[position]);
				o = Database.query(soql);
			}
		
			if (o != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					delete o;					
				} else if (rowType == 2 && R.isUpdateable() == true) {
					o = updateOrderItemFields(o, wmc, objData);					
					update o;				
				}					
			}
		}		
						
		return o;
	}
	private static Order_Item__c updateOrderItemFields(Order_Item__c oi, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (oi == null) { return oi; }

		integer position = 0;
		position = getFieldPosition(wmc, 'Order__c');
		if (position >= 0) {
			oi.Order__c = objData[position];
		}
		
		position = getFieldPosition(wmc, 'Product__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { oi.Product__c = null; } else { oi.Product__c = objData[position]; }
		}
		
		position = getFieldPosition(wmc, 'Carton__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { 
				oi.Carton__c = null; 
			} else { 
				if (objData[position].trim().length() > 0) {
					oi.Carton__c = Integer.valueOf(objData[position]); 					
				}
			}
			
		}
		
		position = getFieldPosition(wmc, 'Unit__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') { 
				oi.Unit__c = null; 
			} else { 
				if (objData[position].trim().length() > 0) {
					oi.Unit__c = Integer.valueOf(objData[position]); 					
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Carton_Bonus__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				oi.Carton_Bonus__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					oi.Carton_Bonus__c = Integer.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Unit_Bonus__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				oi.Unit_Bonus__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					oi.Unit_Bonus__c = Integer.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Discount__c');
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

	private static Outlet_Visit__c updateOutletVisit(string sessionID, string ownerId, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (objData == null) { return null; }
		
		Schema.DescribeSObjectResult R = Outlet_Visit__c.SObjectType.getDescribe();
		Integer rowType = Integer.valueOf(objData[1]);
		Integer position = getFieldPosition(wmc, 'Id');
		System.debug('[updateContact] rowType: ' + rowType);
		
		Outlet_Visit__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			o = updateOutletVisitFields(null, wmc, objData);
			insert o;
		} else {
			String soql = getSOQLSelectForObject('Outlet_Visit__c');
			if (soql.length() == 0) {
				o = [SELECT Id, Account__c, Visit_Date__c FROM Outlet_Visit__c WHERE Id = :objData[position] LIMIT 1];				
			} else {
				soql = soql.replace('%Id%', objData[position]);
				o = Database.query(soql);
			}
		
			if (o != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					delete o;					
				} else if (rowType == 2 && R.isUpdateable() == true) {
					o = updateOutletVisitFields(o, wmc, objData);					
					update o;				
				}					
			}
		}		
						
		return o;		
	}
	
	private static Outlet_Visit__c updateOutletVisitFields(Outlet_Visit__c ov, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (ov == null) { ov = new Outlet_Visit__c(); ov.Status__c = 'New'; }
		
		integer position = 0;
		position = getFieldPosition(wmc, 'Account__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ov.Account__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					ov.Account__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Venue__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ov.Venue__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					ov.Venue__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Met_With__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ov.Met_With__c = objData[position];
			} else {
				if (objData[position].trim().length() > 0) {
					ov.Met_With__c = objData[position];
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Visit_Date__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ov.Visit_Date__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					ov.Visit_Date__c = Date.valueOf(objData[position]);
				}
			}
		}
		
		position = getFieldPosition(wmc, 'Visit_Comments__c');
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
	
	private static Outlet_Visit_Item__c updateOutletVisitItem(string sessionID, string ownerId, Wombat_Mobile_Config__c wmc, List<String> objData) {
		if (objData == null) { return null; }
		
		
		Schema.DescribeSObjectResult R = Outlet_Visit_Item__c.SObjectType.getDescribe();
		Integer rowType = Integer.valueOf(objData[1]);
		Integer position = getFieldPosition(wmc, 'Id');
		System.debug('[updateContact] rowType: ' + rowType);
		
		Outlet_Visit_Item__c o = null;
		
		if (rowType == 1 && R.isCreateable() == true) {
			// Insert
			o = updateOutletVisitItemFields(null, wmc, objData);
			insert o;
		} else {
			String soql = getSOQLSelectForObject('Outlet_Visit_Item__c');
			if (soql.length() == 0) {
				o = [SELECT Id, Outlet_Visit__c, Channel__c, Product__c FROM Outlet_Visit_Item__c WHERE Id = :objData[position] LIMIT 1];				
			} else {
				soql = soql.replace('%Id%', objData[position]);
				o = Database.query(soql);
			}
		
			if (o != null) {
				if (rowType == 3 && R.isDeletable() == true) {
					delete o;					
				} else if (rowType == 2 && R.isUpdateable() == true) {
					o = updateOutletVisitItemFields(o, wmc, objData);					
					update o;				
				}					
			}
		}		
						
		return o;				
	}
	private static Outlet_Visit_Item__c updateOutletVisitItemFields(Outlet_Visit_Item__c ovi, Wombat_Mobile_Config__c wmc, List<string> objData) {
		if (ovi == null) { ovi = new Outlet_Visit_Item__c(); }
		
		integer position;
		position = getFieldPosition(wmc, 'Outlet_Visit__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.Outlet_Visit__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.Outlet_Visit__c = objData[position];
				}
			}			
		}
		
		position = getFieldPosition(wmc, 'Product__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.Product__c = null;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.Product__c = objData[position];
				}
			}			
		}
		
		position = getFieldPosition(wmc, 'Available__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.Available__c = false;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.Available__c = Boolean.valueOf(objData[position]);
				}
			}			
		}
		
		position = getFieldPosition(wmc, 'Position__c');
		if (position >= 0) {
			if (objData[position] == null || objData[position] == 'null') {
				ovi.Position__c = false;
			} else {
				if (objData[position].trim().length() > 0) {
					ovi.Position__c = Boolean.valueOf(objData[position]);
				}
			}			
		}
		
		/*
		if (ovi.Channel__c != null) {
			if (ovi.Channel__c = 'On') {
				position = getFieldPosition(wmc, 'BackBarVisit__c');
				if (position >= 0) {
					if (objData[position] == null || objData[position] == 'null') {
						ovi.BackBarVisit__c = false;
					} else {
						if (objData[position].trim().length() > 0) {
							ovi.BackBarVisit__c = Boolean.valueOf(objData[position]);
						}
					}
				}
				
				position = getFieldPosition(wmc, 'CocktailCount__c');
				if (position >= 0) {
					if (objData[position] == null || objData[position] == 'null') {
						ovi.CocktailCount__c = 0;
					} else {
						if (objData[position].trim().length() > 0) {
							ovi.CocktailCount__c = Integer.valueOf(objData[position]);
						}
					}
				}
			} else {
		
				position = getFieldPosition(wmc, 'Bottle_Price__c');
				if (position >= 0) {
					if (objData[position] == null || objData[position] == 'null') {
						ovi.Bottle_Price__c = 0;
					} else {
						if (objData[position].trim().length() > 0) {
							ovi.Bottle_Price__c = Decimal.valueOf(objData[position]);
						}
					}
				}	
				position = getFieldPosition(wmc, 'PriceTypeFlag__c');
				if (position >= 0) {
					if (objData[position] == null || objData[position] == 'null') {
						ovi.PriceTypeFlag__c = false;
					} else {
						if (objData[position].trim().length() > 0) {
							ovi.PriceTypeFlag__c = Boolean.valueOf(objData[position]);
						}
					}
				}			
			}
		}
		*/
		return ovi;
	}
	
}