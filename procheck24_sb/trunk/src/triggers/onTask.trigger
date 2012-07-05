trigger onTask on Task (before insert, after insert, 
						before update, after update, 
						before delete, after delete,
						after undelete) {

	new Triggers()
		.bind(Triggers.Evt.afterupdate, new TaskAfterUpdateHandlerShiftChainedTasks())
		// Done with adding all handlers, lets call the manage now for once only
		.manage();

}