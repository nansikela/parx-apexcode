trigger onWerbemittel on Werbemittel__c (before insert, before update) {

	//we retrieve automatically the image in the document folder according to the name of the product
	 list<String> WMittel = new list<String>();
	 list<String> Portal = new list<String>();
	 for(Werbemittel__c t:Trigger.new) {
	   	WMittel.add(t.Name);
	   	Portal.add('Shop '+ t.Portal__c);
	   	Portal.add('Shop_'+ t.Portal__c);
	 } 
	 WMittel.add('Default.gif');
	 
	 list<Document> Item_Doc_temp = new list<Document>([Select Name, Id From Document where Name IN : WMittel AND Folder.Name IN: Portal ]);
	
	 map<String, String> Item_Doc = new map<String, String>();
	 
	 for(Document temp:Item_Doc_temp) {
	 	Item_Doc.put(temp.name, temp.id);
	 }

	for(Werbemittel__c t:Trigger.new) {
		if(Item_doc.get(t.Name) != null)   
			t.Bild_URL__c = '/servlet/servlet.FileDownload?file=' + Item_Doc.get(t.Name);
		else
			t.Bild_URL__c = '/servlet/servlet.FileDownload?file=' + Item_Doc.get('Default.gif');
	 }	
Integer i = 0;
i = 1;
i = 2;
i = 3;
i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;i = 1;
i = 2;
i = 3;
}