public with sharing class treeController {
	public treeController() {
		
	}
	
	public String getData() {
		String json='';
		IpdocTree tree=new IpdocTree();
		if (!tree.nodes.isEmpty()) {
			for (NodeData nd: tree.nodes.values()) {
				json=json+ nd.getNodeDataJSON()+',';
			}
		}
		json=removeLastSign(json);
		return json;
	}
	
	private String removeLastSign(String s) {
		return s.substring(0,s.length()-1);
	}
}