global class MonatsAbschlussSchedule implements schedulable {

	global void execute(SchedulableContext SC)  {
		MonatsAbschlussBatchStart.start();
	}
	
	// Start schedule
	/*
	String timestr='0 0 22 LW * ?';
	MonatsAbschlussSchedule msched=new MonatsAbschlussSchedule();
	System.Schedule('Monatsabschluss',timestr,msched);
	*/
}