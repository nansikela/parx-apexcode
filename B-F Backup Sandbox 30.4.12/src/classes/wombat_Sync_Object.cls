global class wombat_Sync_Object {
	public boolean Success { get; set; }
	public List<String> Messages { get; set; }
	public Integer totalSize { 
		get { 
			if (this.Messages == null) {
				return 0;
			} else {
				return this.Messages.size();
			}
		} 
	}
}