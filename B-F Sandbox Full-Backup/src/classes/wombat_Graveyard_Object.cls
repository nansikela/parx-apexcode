global class wombat_Graveyard_Object {
	public Boolean Success { get; set; }
	public List<wombat_Graveyard_Item> Items { get; set; }
	public Integer TotalSize { get { return (Items == null ? 0 : Items.size()); } }
}