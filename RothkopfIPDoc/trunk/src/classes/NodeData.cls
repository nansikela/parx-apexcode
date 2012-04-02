public class NodeData {
	public String title;
	public String icon;
	public String state;
	public Id nodeid;
	
	public list<Attr> attributes=new list<Attr>();
	public list<NodeData> children=new list<NodeData>();
	
	public NodeData (Id sfid, String t, String i, String s, list<Attr> a, list<NodeData> c) {
		title=t;
		nodeid=sfid;
		icon='folder';
		state='closed';
		if (s!=null) state=s;
		if (i!=null) icon=i;
		if (a!=null && !a.isEmpty()) attributes=a;
		if (c!=null && !c.isEmpty()) children=c;
	}
	
	public String getNodeDataJSON() {
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeFieldName('data');
		gen.writeStartObject();
		gen.writeStringField('title', this.title);
		if (this.icon!=null) gen.writeStringField('icon', this.icon);
		if (this.state!=null) gen.writeStringField('state', this.state);
		if (this.attributes!=null && !this.attributes.isEmpty()) {
			gen.writeFieldName('attr');
			for (Attr a:this.attributes) {
				gen.writeStringField(a.aname, a.avalue);
			}
		}
		if (this.children!=null && !this.children.isEmpty()) {
			gen.writeFieldName('children');
			gen.writeStartArray();
			for (NodeData c:this.children) {
				gen.writeString(c.getNodeDataJSON());
			}
			gen.writeEndArray();
		}
		gen.writeEndObject();
		gen.writeEndObject();
		return gen.getAsString();
	}
		
	public class Attr {
		String aname;
		String avalue;
		
		public Attr(String n, String v) {
			aname=n; avalue=v;
		}
	}
	
}