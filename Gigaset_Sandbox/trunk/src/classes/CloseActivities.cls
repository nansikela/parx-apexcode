global class CloseActivities{
    
    /*Schliessen von Aktivitäten über einen Button mit der Bezeichnung „Close Activities“*/
    webservice static string init(list<String> ActivityIds) {
        list<Task> Activities= new list<Task>([select id, isClosed, Status from Task where Id IN: ActivityIds]);
        for(Task a:Activities) {
            if(!a.IsClosed)
                a.Status = 'Abgeschlossen';
        }
        try {
            update Activities;
        }
        catch(exception e) {
            return e.getMessage();
        }
        return 'true';
    }
    
    @isTest
    public static void testing() {
        Task a = new Task(Description = 'test');
            insert a;
            CloseActivities.init(new list<String>{a.Id});
    }
}