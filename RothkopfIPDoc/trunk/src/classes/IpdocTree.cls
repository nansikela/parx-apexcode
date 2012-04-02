public with sharing class IpdocTree {
	
	/* 
		for every file we create a new root node
		for every family we create a new node that should be a child node of its file node but it could be the case that the family node is root node
		for every portfolio we create a new node that should be a child node of ist family node but it could be the case that the portfolio node is root node
		
	*/
	
	map<id, Family__c> famMap = new map<Id, Family__c>();
	map<id, Portfolio__c> portfolioMap = new map<Id, Portfolio__c>();
	map<id, File__c> fileMap = new map<Id, File__c>();
	map<id, map<id, map<id, Portfolio__c>>> chain=new map<Id, map<Id, map<Id, Portfolio__c>>>();
	public map<Id, NodeData> nodes=new map<Id, NodeData>();
	
	public IpdocTree() {
		createNodes();
	}
	
	
	private void createNodes() {
		for (File__c f:[SELECT Id, Name FROM File__c limit 1000]) {
			fileMap.put(f.id,f);
			chain.put(f.id, new map<Id, map<Id, Portfolio__c>>());
			NodeData nd=new NodeData(f.id, f.Name, null, null, null, null);
			nodes.put(f.id, nd);
		}
		for (Family__c f: [SELECT Id, Name, File__c FROM Family__c limit 1000]) {
			famMap.put(f.id, f);
			NodeData nd=new NodeData(f.id, f.Name, null, null, null, null);
			if (chain.containsKey(f.File__c)) {
				chain.get(f.File__c).put(f.id, new map<Id, Portfolio__c>());
				nodes.get(f.File__c).children.add(nd);
			} else {
				nodes.put(f.id,nd);
			}
		}
		for (Portfolio__c p:[SELECT Id, Name, Family__c, Family__r.File__c FROM Portfolio__c limit 1000]) {
			portfolioMap.put(p.id, p);
			if (chain.containsKey(p.Family__r.File__c) && chain.get(p.Family__r.File__c).containsKey(p.Family__c)) 
					chain.get(p.Family__r.File__c).get(p.Family__c).put(p.id, p);
		}
		
	}
}